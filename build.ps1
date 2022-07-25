$modPath = $args[0];
$bootAfterDone = $args[1];
if ($bootAfterDone -eq "true")
{
	$bb = Get-Process BattleBrothers -ErrorAction SilentlyContinue
	if ($bb) {
	  $bb | Stop-Process -Force
	}
}

$utilsPath = $PSScriptRoot
$masscompilePath = Join-Path $utilsPath \modtools\superior_masscompile.bat
$SQPath = Join-Path $utilsPath \modtools\sq.exe
$packBrushPath = Join-Path $utilsPath pack_brush.ps1
$configPath = Join-Path $utilsPath config.JSON
$configJSON = Get-Content -Path $configPath | ConvertFrom-Json
$gamePath = $configJSON.DataPath
$path_to_data = Join-Path $gamePath data
$path_to_exe = Join-Path $gamePath win32\BattleBrothers.exe
$name = Split-Path -Path $modPath -Leaf

$excludedZipFolders = ".git",".github","unpacked",".vscode",".utils"
$excludedScriptFolders = ".git",".github","gfx","ui","preload","brushes","music","sounds","unpacked","tempfolder",".vscode","nexus", ".utils"
del $modPath\$name.zip

& "$packBrushPath" $modPath
Set-Location $modPath

mkdir $modPath\tempfolder

foreach ($folder in Get-ChildItem -Path $modPath -Directory -Force)
{
	if (($excludedScriptFolders -match $folder.Name).Length -eq 0)
	{             
		copy -r $folder $modPath\tempfolder\ 
	}
}

$break = 0
foreach ($file in Get-ChildItem -Path $modPath\tempfolder -Recurse -Force -File)
{	
	$raw = $file.Basename
	$path = $file.DirectoryName
	& sq -o "$path/$raw.cnut" -c "$path/$raw.nut" -e
	if ($LASTEXITCODE -eq -2)
	{
		$break = -2
	}
}
Remove-Item $modPath\tempfolder -Recurse

if ($break -eq -2)
{
	exit
}


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

Rename-Item -Path $modPath\archive.zip -NewName $name".zip"
copy $modPath\$name.zip $path_to_data


Set-Location $utilsPath

if ($bootAfterDone -eq "true")
{
	Start-Process $path_to_exe
}
