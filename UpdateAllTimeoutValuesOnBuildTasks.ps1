###################################################################################
#	Author: Christina Altman
#	Desciption: Update all Build Steps that require a custom timeoutInMinutes value
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
#       # This script goes into the build for an application and updates the Timeout Settings on all tasks that require the timeoutInMinutes value to be updated
#
#	History:
#		1.0		- Initial Release (Christina Altman)
###################################################################################


# Script parameters
param(
$project = 'ProjectName', #Example: 'ResearchCreditSolution'
$definitionName = 'ProjectName-ENV', #Example: 'ResearchCreditSolution-DEV'
$pat = 'YourPatWithColon' # MUST INCLUDE ":" Example: ':aksky2umz477uin971h297nduasn9d781n92ndjkans9d78hunl' PATs can be found in CyberArk or use Personal PAT if you have one
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

$fullUri= "https://pwc-us-tax-tech.visualstudio.com/$($project)/_apis/build/definitions?api-version=4.1-preview.3"

# GET the build objects based on the $definitionName. Returns all builds objects for the given $definitionName -- searchText lets you search for everything that starts with the string provided
$Build = (Invoke-RestMethod "$($uri)/_apis/build/definitions?name=$($definitionName)&api-version=4.1" -Method GET -Headers $header)

#Convert $build into a json
$json = ($Build | ConvertTo-json -depth 100)

#Tasks needing to be updated.Items with 60 minute timeout go in TaskArray60Minutes, items with 20 minute timeout go in TaskArray20Minutes
$TaskArray60Minutes = @('Build solution **\*.sln')
$TaskArray20Minutes = @('Publish Artifact: WebArtifact','Publish Artifact: DatabaseArtifact')

#Run the API Call for the ID returned above
$targetBuildDefinition = $build.value | ForEach-Object  {

$Build2 = (Invoke-RestMethod "$($uri)/_apis/build/definitions/$($_.id)?api-version=4.1" -Method GET -Headers $header)
Write-Output $Build2


#Location at which to make updates to the tasks from the arrays
$targettasktoupdate = $build2.process.phases.steps | ForEach-Object {


#Update items in TaskArray60Minutes to timeout of 60 minutes
$targettasktoupdate1 = $_ | Where-Object {$_.displayname -in $TaskArray60Minutes}

$targettasktoupdate1 | ForEach-Object {

$_.timeoutInMinutes = 60
}

#Update items in TaskArray20Minutes to timeout of 20 minutes
$targettasktoupdate2 = $_ | Where-Object {$_.displayname -in $TaskArray20Minutes}

$targettasktoupdate2 | ForEach-Object {

$_.timeoutInMinutes = 20

Write-Output $targettasktoupdate1
Write-Output $targettasktoupdate2
}
}

#Collect the URI with the ID
$uriWithID = "$($uri)/_apis/build/definitions/$($_.id)?api-version=4.1"

}

#Convert to json format for API call
$json = ($build2 | convertto-json -depth 100)

#Complete API call
Invoke-RestMethod -Method Put -ContentType application/json -Uri $uriWithID -Body $json -Headers $header


