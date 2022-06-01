$name = $args[0];
$configJSON = Get-Content -Path .\config.JSON |  Out-String | ConvertFrom-Json

$modFoldersPath = $configJSON.ModFoldersPath
copy -r .\template $modFoldersPath
Rename-Item -Path $modFoldersPath\template -NewName $name -PassThru | Invoke-Item

$projectObject = @{
	folders = @();
	build_systems = @();
}
foreach ($buildSystem in $configJSON.build_systems)
{ 
	$projectObject.build_systems += $buildSystem
}

foreach ($folder in $configJSON.FolderPaths)
{ 
	$projectObject.folders += [pscustomobject]@{ path = $folder }
}

$projectObject.folders += [pscustomobject]@{ path = Join-Path $modFoldersPath $name }

$finishedJson = $projectObject | ConvertTo-Json -depth 100 | %{
    [Regex]::Replace($_, 
        "\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

Rename-Item -Path $modFoldersPath\$name\scripts\!mods_preload\template.nut -NewName $name".nut" -PassThru | Invoke-Item
$projectPath = Join-Path $modFoldersPath "/$name/$name.sublime-project"
$finishedJson | Out-File -Encoding UTF8 $projectPath
$projectPath | Invoke-Item
