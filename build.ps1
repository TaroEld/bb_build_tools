param(
	[string] $modPath,
	[Parameter(Mandatory=$false)][string] $bootAfterDone
)


function stopIfBadCode([int] $badCode) {
	if ($LASTEXITCODE -eq $badCode)
	{
		Write-Output "Exiting..."
		exit
	}
}

$command = "Building mod $modPath"
if ($bootAfterDone -eq "true")
{
	$command = $command + " and relaunching game"
}
Write-Output $command
if ($bootAfterDone -eq "true")
{
	$bb = Get-Process BattleBrothers -ErrorAction SilentlyContinue
	if ($bb) {
	  $bb | Stop-Process -Force
	}
}

$utilsPath = $PSScriptRoot
$masscompilePath = Join-Path $utilsPath \modtools\superior_masscompile.bat
$7zipPath = Join-Path $utilsPath \modtools\7zr.exe
$SQPath = Join-Path $utilsPath \modtools\sq.exe
$packBrushPath = Join-Path $utilsPath pack_brush.ps1
$configPath = Join-Path $utilsPath config.JSON
$configJSON = Get-Content -Path $configPath | ConvertFrom-Json
if ($configJSON.ModFoldersPath -eq "")
{
	Write-Output '
	ERROR: Mods Path not specified!
	Run bb_build/config.ps1 with -ModsPath "path/to/mods". Example:
		 config.ps1 -ModsPath "G:/Games/BB/Mods"
	Exiting...'
	exit
}
if ($configJSON.GamePath -eq "")
{
	Write-Output '
	ERROR: Game Path not specified!
	Run bb_build/config.ps1 with -GamePath "path/to/mods". Example:
		 config.ps1 -GamePath "G:/Games/BB/BattleBrothers"
	Exiting...'
	exit
}
$gamePath = $configJSON.GamePath
$path_to_data = Join-Path $gamePath data
$path_to_exe = Join-Path $gamePath win32\BattleBrothers.exe
$name = Split-Path -Path $modPath -Leaf

$excludedZipFolders = ".git",".github","unpacked",".vscode",".utils"
$excludedScriptFolders = ".git",".github","gfx","ui","preload","brushes","music","sounds","unpacked","tempfolder",".vscode","nexus", ".utils"
if(Test-Path -Path $modPath\$name.zip)
{
	del $modPath\$name.zip
}


& "$packBrushPath" $modPath
stopIfBadCode

mkdir $modPath\tempfolder | out-null

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
	& $SQPath -o "$path/$raw.cnut" -c "$path/$raw.nut" -e
	if ($LASTEXITCODE -eq -2)
	{
		Write-Output "Failed compiling file $raw!"
		$break = -2
	}
	$firstLine = Get-Content $file.FullName -First 1
	if ($firstLine -match "this\..+ <-")
	{
		$class = $firstLine.split(" ")[0].split(".")[1]
        if($raw -ne $class)
        {
        	$fullName =  $file.FullName
        	Write-Output "File $fullName is a BBClass but does not match filename! $raw != $class"
        	$break = -2
        }
	}
}
Remove-Item $modPath\tempfolder -Recurse

if ($break -eq -2)
{
	Write-Output "Exiting..."
	exit
}

Write-Output "Successfully compiled files"


foreach ($folder in Get-ChildItem -Path $modPath -Directory -Force)
{
	if (($excludedZipFolders -match $folder.Name).Length -eq 0)
	{
		$folderPath = Join-Path $modPath $folder
		if (Test-Path -Path $folderPath)
		{
			Compress-Archive -Update -DestinationPath archive.zip -Path $folder
			Write-Output "Adding folder: $folder"
		}
	}
}

Rename-Item -Path $modPath\archive.zip -NewName $name".zip" 
copy $modPath\$name.zip $path_to_data 
Write-Output "Copied mod $name.zip to $path_to_data"


if ($bootAfterDone -eq "true")
{
	Write-Output "Starting the game..."
	Start-Process $path_to_exe
}
Write-Output "Done!"	
