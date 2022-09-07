$name = $args[0];
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
$modPath = Join-Path $modFoldersPath $name

copy -r .\template $modFoldersPath
Rename-Item -Path $modFoldersPath\template -NewName $name

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

$preloadPath = Join-Path $modPath "/scripts/!mods_preload/$name.nut" 
$preloadFile = "::RENAME <- {
	ID = `"$name`",
	Name = `"RENAME`",
	Version = `"1.0.0`"
}
::mods_registerMod(::RENAME.ID, ::RENAME.Version)

::mods_queue(::RENAME.ID, null, function()
{
	// ::mods_registerJS(::RENAME.ID + '.js'); // Delete if not needed 
	// ::mods_registerCSS(::RENAME.ID + '.css'); // Delete if not needed 
	// ::RENAME.Mod <- ::MSU.Class.Mod(::RENAME.ID, ::RENAME.Version, ::RENAME.Name); // Delete if not needed 

})
"
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($preloadPath, $preloadFile, $Utf8NoBomEncoding)

mkdir $modFoldersPath\$name\unpacked

Invoke-Item $modFoldersPath\$name