$modPath = $args[0];
$bootAfterDone = $args[1];
$utilsPath = $PSScriptRoot
$masscompilePath = Join-Path $utilsPath \modtools\superior_masscompile.bat
$packBrushPath = Join-Path $utilsPath pack_brush.ps1
$configPath = Join-Path $utilsPath config.JSON
$configJSON = Get-Content -Path $configPath | ConvertFrom-Json
$gamePath = $configJSON.DataPath
$path_to_data = Join-Path $gamePath data
$path_to_exe = Join-Path $gamePath win32\BattleBrothers.exe
$name = Split-Path -Path $modPath -Leaf

$excludedZipFolders = ".git",".github","unpacked"
$excludedScriptFolders = ".git",".github","gfx","ui","preload","brushes","music","sounds","unpacked","tempfolder"

& "$packBrushPath" $modPath
Set-Location $modPath

mkdir .\tempfolder

foreach ($folder in Get-ChildItem -Path $modPath -Directory -Force)
{
	if (($excludedScriptFolders -match $folder.Name).Length -eq 0)
	{
		copy -r $folder .\tempfolder\
		& $masscompilePath .\tempfolder\$folder $folder
	}
}

Remove-Item .\tempfolder -Recurse
foreach ($folder in Get-ChildItem -Path $modPath -Directory -Force)
{
	if (($excludedZipFolders -match $folder.Name).Length -eq 0)
	{
		$folderPath = Join-Path $modPath $folder
		if (Test-Path -Path $folderPath)
		{
			7z a archive.zip $folder
		}
	}
}
Rename-Item -Path .\archive.zip -NewName $name".zip"
copy .\$name.zip $path_to_data
del .\$name.zip

Set-Location $utilsPath

if ($bootAfterDone -eq "true")
{
	Start-Process $path_to_exe
}

