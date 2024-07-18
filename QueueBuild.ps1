###################################################################################
#	Author: Christina Altman
#	Desciption: Queue All Builds for a project
#	Created On: 08/29/2018
#
#   Update Variables:
#   Update $project with project name
#   Update $definitionName with Build Definition Name
#   Update $pat with personal PAT or PAT from CyberARK
#		
#	Usage:
#       # Input $project, $definitionName, and $pat values to queue a build remotely. 
#       # Can be run from any location with internet access to VSTS (example: your machine)
#
#	History:
#		1.0		- Initial Release (Christina Altman)
###################################################################################


# Script parameters
param(
$project = 'YourProject', #Example: 'ResearchCreditSolution'
$definitionName = 'BuildDefinitionName', #Example: 'ResearchCreditSolution-DEV'
$pat = 'YourPATWithColon' # MUST INCLUDE ":" Example: ':aksky2umz477uin971h297nduasn9d781n92ndjkans9d78hunl' PATs can be found in CyberArk or use Personal PAT if you have one
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

$uri = "https://pwc-us-tax-tech.visualstudio.com/$($project)"

$fullUri= "https://pwc-us-tax-tech.visualstudio.com/$($project)/_apis/build/builds?api-version=4.1-preview.3"

# GET the build objects based on the $definitionName. Returns all builds objects for the given $definitionName -- searchText lets you search for everything that starts with the string provided
$Build = (Invoke-RestMethod "$($uri)/_apis/build/definitions?name=$($definitionName)&api-version=4.1" -Method GET -Headers $header)

#Convert $build into a json
$json2 = ($Build | ConvertTo-json)

#Run the API Call for the ID returned above
$targetBuildDefinition = $build.value | ForEach-Object  {

#Creates a body with ID of 0000 as a placeholder

$body = '
{ 
        "definition": {
            "id": 0000
        } 
}
'
#Converts the body to a json
$bodyJson=$body | ConvertFrom-Json
Write-Output $bodyJson

#Set the ID to the value that was retrieved above
$bodyJson.definition.id=$_.id

#Converts the bodyJson into a string for the API call
$bodyString=$bodyJson | ConvertTo-Json -Depth 100
Write-Output $bodyString

#Performs the API call using the $bodyString
$buildresponse = Invoke-RestMethod -Method Post -ContentType application/json -Uri $fullUri -Body $bodyString -Headers $header
write-host $buildresponse

}