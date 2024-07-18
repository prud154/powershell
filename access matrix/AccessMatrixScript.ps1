
#update PortalPermissionsTemplate.json settings object below to portalpermissionsappname
$settingsObject = Get-Content -path ./PortalPermissionsTemplate.json | ConvertFrom-Json

$nonProd = @{
    environments = @("DEV", "QA", "UAT")
    baseName = "PZI-GTUS-N-RGP-$($settingsObject.appname)-"
}
$prod = @{
    environments = @("STG", "PROD")
    baseName = "PZI-GTUS-P-RGP-$($settingsObject.appname)-"
}
Foreach ($env in $settingsObject.environments) {
    Set-AzureRmContext -Subscription $env.subscription
    If ($nonProd.environments -contains $env.name) {
        #concat RG name based off of naming schema pattern 
        $resourceGroup = $nonprod.baseName+$env.name
        $resourceGroup
    }
    ElseIf ($prod.environments -contains $env.name) { 
        $resourceGroup = $prod.baseName+$env.name
        $resourceGroup
    }
    Foreach ($tier in $env.tiers) {
        #per resource loop
        Foreach ($resource in $tier.resources) {
            #per member loop
            Foreach ($memberForAssignment in $tier.members) {             
                #per RG access level loop
                Foreach ($accessLevel in $resource.resourceAccessLevel) {
                    write-Host "Assigning $memberForAssignment $accessLevel access to resource group $resourceGroup."
                    New-AzureRmRoleAssignment -ResourceGroupName $resourceGroup `
                        -SignInName $memberForAssignment `
                        -RoleDefinitionName $accessLevel `
                        -ErrorAction SilentlyContinue
                }
            }
        }
    }
}



