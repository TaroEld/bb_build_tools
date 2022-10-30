param(
	[Parameter(Mandatory=$true)][string] $modName
)
$configJSON = Get-Content -Path .\config.JSON |  Out-String | ConvertFrom-Json
if ($configJSON.ModFoldersPath -eq "")
{
	Write-Output '
	ERROR: Mods Path not specified!
	Run bb_build/config.ps1 with -ModsPath "path/to/mods". Example:
		 config.ps1 -ModsPath "G:/Games/BB/Mods"
	Exiting...'
	exit
}
$modFoldersPath = $configJSON.ModFoldersPath
$modPath = Join-Path $modFoldersPath $modName

Copy-Item -r .\template $modFoldersPath
Rename-Item -Path $modFoldersPath\template -NewName $modName

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


$finishedSublimeJson = $SublimeProjectObject | ConvertTo-Json -depth 100 | ForEach-Object{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

$finishedVSCodeJson = $VSCodeProjectObject | ConvertTo-Json -depth 100 | ForEach-Object{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

$finishedSublimeJson | Out-File -Encoding UTF8 (Join-Path $modPath "/$modName.sublime-project")
$finishedVSCodeJson | Out-File -Encoding UTF8 (Join-Path $modPath "/.vscode/$modName.code-workspace")

$utilsPath = Join-Path $modPath "/.utils/build.ps1" 
$buildScript = "
`$modPath = Resolve-Path (Join-Path `$PSScriptRoot '..')
`$buildPath = Resolve-Path (Join-Path '$PSScriptRoot' '\build.ps1')
& `$buildPath `$modPath `$args[0]
"
$buildScript | Out-File -Encoding UTF8 $utilsPath

$preloadPath = Join-Path $modPath "/scripts/!mods_preload/$modName.nut" 
$preloadFile = Get-Content "./assets/template_preload.nut" 
$preloadFile[1] = "        ID = ""$modName"","
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($preloadPath, $preloadFile, $Utf8NoBomEncoding)

mkdir $modFoldersPath\$modName\unpacked

Invoke-Item $modFoldersPath\$modName