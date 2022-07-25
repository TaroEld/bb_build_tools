$name = $args[0];
$configJSON = Get-Content -Path .\config.JSON |  Out-String | ConvertFrom-Json

$modFoldersPath = $configJSON.ModFoldersPath
$modPath = Join-Path $modFoldersPath $name
Write-Output  $modFoldersPath $modPath

copy -r .\template $modFoldersPath
Rename-Item -Path $modFoldersPath\template -NewName $name -PassThru | Invoke-Item

$SublimeProjectObject = @{
	folders = @();
	build_systems = @();
}
$VSCodeProjectObject = @{
	folders = @();
	settings = @();
}
foreach ($buildSystem in $configJSON.build_systems)
{ 
	$SublimeProjectObject.build_systems += $buildSystem
}

foreach ($folder in $configJSON.FolderPaths)
{ 
	$SublimeProjectObject.folders += [pscustomobject]@{ path = $folder }
	$VSCodeProjectObject.folders += [pscustomobject]@{ path = $folder }
}


$SublimeProjectObject.folders += [pscustomobject]@{ path = $modPath }
$VSCodeProjectObject.folders += [pscustomobject]@{ path = $modPath }


$finishedSublimeJson = $SublimeProjectObject | ConvertTo-Json -depth 100 | %{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

$finishedVSCodeJson = $VSCodeProjectObject | ConvertTo-Json -depth 100 | %{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

Rename-Item -Path $modFoldersPath\$name\scripts\!mods_preload\template.nut -NewName $name".nut"

$projectPath = Join-Path $modPath "/$name.sublime-project"
$projectPathVSC = Join-Path $modPath "/.vscode/$name.code-workspace"
$finishedSublimeJson | Out-File -Encoding UTF8 $projectPath
$finishedVSCodeJson | Out-File -Encoding UTF8 $projectPathVSC

$utilsPath = Join-Path $modPath "/.utils/build.ps1" 
$buildScript = "
`$modPath = Resolve-Path (Join-Path `$PSScriptRoot '..')
$PSScriptRoot\build.ps1 `$modPath `$args[0]
"
$buildScript | Out-File -Encoding UTF8 $utilsPath

