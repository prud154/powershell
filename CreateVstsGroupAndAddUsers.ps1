<#
.SYNOPSIS
Creates a group in VSTS / Azure DevOps and adds the specified users to it.

.DESCRIPTION
Manages a group and user membership for that group. If the group already exists, users will only be added. If the group does not exist, it will be created.

ACLs are not managed; groups are created without any specific security settings in place.

Users can only be looked up by email address. 


.PARAMETER PAT
A personal authentication token for the VSTS account
.PARAMETER VstsAccountName 
The name of the VSTS account, without any URL components (e.g. 'pwc-us-tax-tech', not 'https://pwc-us-tax-tech.visualstudio.com')
.PARAMETER TeamProject 
The name of the team project
.PARAMETER NewGroupName 
The name of the group to create
.PARAMETER NewGroupDescription
A description for the group
.PARAMETER Users
An array of user email addresses
#>


param(
    [Parameter(Mandatory=$true)][string]$PAT,
    [Parameter(Mandatory=$true)][string]$VstsAccountName,
    [Parameter(Mandatory=$true)][string]$TeamProject,
    [Parameter(Mandatory=$true)][string]$NewGroupName,
    [Parameter(Mandatory=$true)][string]$NewGroupDescription,
    [Parameter(Mandatory=$true)][Array]$Users
)

$base64 = [System.Convert]::ToBase64String([System.Text.ASCIIEncoding]::ASCII.GetBytes(":$($pat)"))
$header = @{Authorization = "Basic $base64" }

$vstsRestUri = "https://$VstsAccountName.visualstudio.com"
$vstsIdentityRestUri = "https://$VstsAccountName.vssps.visualstudio.com"

# Get the team project's information
$teamProjectInfo = (invoke-restmethod "$vstsRestUri/_apis/projects/$($teamProject)?api-version=4.1" `
    -Headers $header)

# Translate the team project's GUID into a graph descriptor
$teamProjectDescriptor = (invoke-restmethod "$vstsIdentityRestUri/_apis/graph/descriptors/$($teamProjectInfo.Id)?api-version=4.1-preview.1" `
    -Headers $header).value

$newGroupBody = @{displayName = $NewGroupName; description = $NewGroupDescription }

# Create the group
$groupDescriptor = (invoke-restmethod "$vstsIdentityRestUri/_apis/graph/groups/?scopeDescriptor=$($teamProjectDescriptor)&api-version=4.1-preview.1" `
    -Headers $header -Method Post -ContentType 'application/json' -Body ($newGroupBody | convertto-json -depth 10 -Compress)).descriptor

# Look up each user by email address and add them to the group
foreach ($userEmail in $Users) {
    $userDescriptor = (invoke-restmethod "$vstsIdentityRestUri/_apis/Identities?searchFilter=MailAddress&filterValue=$($userEmail)&options=None&queryMembership=None&api-version=4.1-preview.1" -Headers $header).value.subjectDescriptor

    (invoke-restmethod "$vstsIdentityRestUri/_apis/graph/memberships/$($userDescriptor)/$($groupDescriptor)?api-version=4.1-preview.1" `
        -Headers $header -Method Put)
}