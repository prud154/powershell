###################################################################################
#	Author: Clayton Hagan
#	Desciption: Disable tasks in a given release remotely
#	Created On: 08/27/2018
#		
#	Usage:
#       # Input $project, $definitionName, $NameOfPowershellTask, and $pat values to disable given release task. 
#       # Can be run from any location with internet access to VSTS (example: your machine)
#
#	History:
#		1.0		- Initial Release (Clayton Hagan)
###################################################################################


# Script parameters
param(
$project = 'NewProjectName', #Example: 'ResearchCreditSolution'
$definitionName = 'ReleaseDefinitionName', #Example: 'ResearchCreditSolution-DEV'
$NameOfPowershellTask = 'TaskToDisableName', #Example: 'Execute Webhook PwCTestWebHook'
$pat = ':YourPATHereWithColon' # MUST INCLUDE ":" Example: ':aksky2umz477uin971h297nduasn9d781n92ndjkans9d78hunl' PATs can be found in CyberArk or use Personal PAT if you have one
)

###################################################################################
# IMPORTANT:  The below line must be included to enusre proper error handling
###################################################################################
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
###################################################################################


###################################################################################
# BEGIN 
###################################################################################

# Authentication stuff
$encodedPat = [System.Text.ASCIIEncoding]::ASCII.GetBytes($pat)

#Create Header for authentication
$header = @{Authorization = "Basic $([Convert]::ToBase64String($encodedPat))"}

$uri = "https://pwc-us-tax-tech.vsrm.visualstudio.com/$($project)"
"$($uri)/_apis/release/definitions?api-version=4.1-preview.3"

# GET the release definition ID -- searchText lets you search for everything that starts with the string provided
$releaseId = (Invoke-RestMethod "$($uri)/_apis/release/definitions?searchText=$($definitionName)&api-version=4.1-preview.3" -Method GET -Headers $header).value.id

# GET the release definition with the specified ID
$releaseDefinition = (Invoke-RestMethod "$($uri)/_apis/release/definitions/$($releaseId)?api-version=4.1-preview.3" -Method GET -Headers $header)

$releaseDefinition # contains an object with all the stuff. Change it as desired

#Step through each environment and disable the step
$myTargetEnvironmentToModify = $releaseDefinition.environments | ForEach-Object {
    
$myTargetTaskToModify = $_.deployPhases.workflowTasks | Where-Object { $_.name -eq "$NameOfPowershellTask"}


$myTargetTaskToModify.enabled = 'false' 

}

# PUT the modified release definition to update it on the server
$json = ($releaseDefinition | ConvertTo-Json -Depth 100)
Invoke-RestMethod "$($uri)/_apis/release/definitions?api-version=4.1-preview.3" -Method Put -Headers $header -ContentType 'application/json' -Body $json -Verbose