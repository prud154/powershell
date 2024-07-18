Connect-AzureRmAccount -SubscriptionId "468e65e9-bb97-4585-9a9e-78569cffd485"
#To get Group Object Id
#Get-AzureRmADGroup -SearchString "FirstName LastName"

#To get User Object Id
#Get-AzureRmADUser -DisplayName "123445656.."

#To get User Object Id
#Get-AzureRmADServicePrincipal -ServicePrincipalName "xyz"


$ListMemberName = "prudhvi.pemmasani@pwc.com","jason.m.cunningham@pwc.com" #add users added on AAD
#$ListObjectId = "1234","5678"

$Role = "Application Insights Component Contributor" #enter the role name like reader, contributer here

$resource = "devInsights" #name of the resource

$resourcetype = "microsoft.insights/components" #type of that resource 
#you can find resource type by running this script in powershell 
#Get-AzureRmResource -ResourceGroupName $resourcegroup | ft
#this will list down resource types of all the resources in the resourcegroup

$resourcegroup = "devSample" #type in the resource group name

#1 using the SignInName, assign a user to a role in a resource 

for ($i = 0; $i -le ($ListMemberName.length - 1); $i += 1) {
New-AzureRmRoleAssignment -SignInName $ListMemberName[$i] -RoleDefinitionName $Role -ResourceName $resource -ResourceType $resourcetype -ResourceGroupName $resourcegroup -ErrorAction SilentlyContinue 
}

#2 using the ObjectId, assign a user/group/app to a role in a resource

#for ($i = 0; $i -le ($ListObjectId.length - 1); $i += 1) {
#New-AzureRmRoleAssignment -ObjectId $ListObjectId[$i] -RoleDefinitionName $Role -ResourceName $resource -ResourceType $resourcetype -ResourceGroupName $resourcegroup -ErrorAction SilentlyContinue 
#}





