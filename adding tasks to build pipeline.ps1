Param(
[Parameter(mandatory=$true)]
[string] $PATToken,
[Parameter(mandatory=$true)]
[string] $VSTSaccount,
[Parameter(mandatory=$true)]
[string] $ProjectName,
[Parameter(mandatory=$true)]
[string] $Buildid

)

$publishartifacts='{
            "environment": {},
            "enabled": true,
            "continueOnError": false,
            "alwaysRun": false,
            "displayName": "Publish Artifact: prudhvi",
            "timeoutInMinutes": 0,
            "condition": "succeeded()",
            "task": {
              "id": "2ff763a7-ce83-4e1f-bc89-0ae63477cebe",
              "versionSpec": "1.*",
              "definitionType": "task"
            },
            "inputs": {
              "PathtoPublish": "$(Build.ArtifactStagingDirectory)/test",
              "ArtifactName": "droptest",
              "ArtifactType": "Container",
              "TargetPath": "",
              "Parallel": "false",
              "ParallelCount": "8"
            }
          }'

$copyfiles = '{
            "environment": {},
            "enabled": true,
            "continueOnError": false,
            "alwaysRun": false,
            "displayName": "Copy Files to: test",
            "timeoutInMinutes": 0,
            "condition": "succeeded()",
            "task": {
              "id": "5bfb729a-a7c8-4a78-a7c3-8d717bb7c13c",
              "versionSpec": "2.*",
              "definitionType": "task"
            },
            "inputs": {
              "SourceFolder": "test",
              "Contents": "**",
              "TargetFolder": "test",
              "CleanTargetFolder": "false",
              "OverWrite": "false",
              "flattenFolders": "false"
            }
          }'
$task = Read-Host("enter task type of task to add to build def copyfiles/publishartifacts")

if($task -eq "publishartifacts")
{
    $taskjson = @{ }
    Write-Host("loading publishartifacts task")
    $taskjson = $publishartifacts |ConvertFrom-Json
    $taskjson.displayName = Read-Host("Enter displayname")
    $taskjson.inputs.ArtifactName = Read-Host("Enter ArtifactName")
    $taskjson.inputs.PathtoPublish = Read-Host("Enter PathtoPublish")
    $publishlocation= Read-Host("Enter Publish location number 1.Azure Pipelines/TFS 2.a file Share ")
    if($publishlocation -eq 1)
    {
        $taskjson.inputs.ArtifactType= "Container"
        Write-host("adding task")

    }
    elseif($publishartifacts -eq 2)
    {
        $taskjson.inputs.ArtifactType= "FilePath"
        $taskjson.inputs.TargetPath= Read-Host("Enter TargetPath")
    }
}
elseif($task -eq "copyfiles" )
{
    $taskjson = @{ }
    Write-Host("loading copy files task")
    $taskjson = $copyfiles |ConvertFrom-Json
    $taskjson.displayName=Read-Host("displayName")
    $taskjson.inputs.SourceFolder=Read-Host("SourceFolder")
    $taskjson.inputs.TargetFolder=Read-Host("TargetFolder")
    $taskjson.inputs.Contents=Read-Host("Contents")
    Write-host("adding task")
}
else
{
Write-Host("enter correct string copyfiles/publishartifacts")
}

$agentphase = Read-Host("enter agent phase in which task needed to added")
#Agent job 1
$uri = "https://$VSTSaccount.visualstudio.com/$ProjectName/_apis/build/Definitions/$Buildid"+"?api-version=5.1-preview.7"
$pipeline = Invoke-RestMethod -Uri $uri -Headers @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PATToken)")) } 
#$pipeline = Invoke-RestMethod -Uri $uri -Headers @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)")) } 
$array =@() 

$phases=$pipeline.process.phases
foreach($phase in $phases)
{
if($phase.name -eq "Agent job 1")
{ 
$phase.steps.Count
$array = $phase.steps
$array+= $taskjson
$phase.steps = $array
$phase.steps.Count
}
}

$data= $pipeline|ConvertTo-Json -depth 100 
$pipeline1 = Invoke-RestMethod -Uri $uri -Method Put -Headers @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PATToken)")) } -ContentType "application/json" -Body $data
