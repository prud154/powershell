###################################################################################
#	Author: Prudhvi Pemmasani
#	Desciption: Create Webhooks for Aggregator
#	Created On: 02/05/2019
#		
#	Usage:
#       # Input $projectName, $pat, and update "url" in $postbody. 
#       # Can be run from any location with internet access to VSTS (example: your machine)
#
#	History:
#		1.0		- Initial Release (Prudhvi Pemmasani)
###################################################################################


# Script parameters

#Enter Project name 
$projectName = "ProjectName" #Example: "Operations"

#Enter PAT Token
$pat = "YourPAT" # Example: 'aksky2umz477uin971h297nduasn9d781n92ndjkans9d78hunl' PATs can be found in CyberArk or use Personal PAT if you have one

# Update URL with URL of the tool you want to integrate with Example (Aggregator): https://pwc.aha.io/api/v1/webhooks/a53e3cd44a5521bd8325bd0d26470770e60c475b94446eed16cc5cefbac22fbc
$postbody='"
  },
  "consumerInputs": {
    "url": "EXAMPLE URL"
  }
}';

###################################################################################
# IMPORTANT:  The below line must be included to enusre proper error handling
###################################################################################
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
###################################################################################


###################################################################################
# BEGIN 
###################################################################################

#Enter Azure devops account name 
$vstsAccount = "pwc-us-tax-tech"


#Authenitication 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "",$pat)))
$uri = "https://$($vstsAccount).visualstudio.com/_apis/projects?api-version=5.0-preview.1"
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

#Return Project ID
$projectId = $result.value | Where-Object { $_.name -eq $projectName } | Select-Object -ExpandProperty id

#Body to Post back to API
$prebodywic='{
  "publisherId": "tfs",
  "eventType": "workitem.created",
  "resourceVersion": "1.0-preview.1",
  "consumerId": "webHooks",
  "consumerActionId": "httpRequest",
  "publisherInputs": {
     "projectId": "';
$prebodywid='{
  "publisherId": "tfs",
  "eventType": "workitem.deleted",
  "resourceVersion": "1.0-preview.1",
  "consumerId": "webHooks",
  "consumerActionId": "httpRequest",
  "publisherInputs": {
     "projectId": "';


#Put Everything Together
$wicbodyJson = $prebodywic + $projectId +$postbody
$widbodyJson = $prebodywid + $projectId +$postbody

$uri = "https://$($vstsAccount).visualstudio.com/_apis/hooks/subscriptions?api-version=5.0-preview.1"

#Invoke Rest Method
Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $wicbodyJson
Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Body $widbodyJson