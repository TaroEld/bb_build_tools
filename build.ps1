param(
	[string] $modPath,
	[Parameter(Mandatory=$false)][string] $bootAfterDone
)


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
$SQPath = Join-Path $utilsPath \modtools\sq.exe
$packBrushPath = Join-Path $utilsPath pack_brush.ps1

# Check if config has been defined
$configJSON = Get-Content -Path (Join-Path $utilsPath config.JSON) | ConvertFrom-Json
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
$pathToData = Join-Path $gamePath data
$pathToExe = Join-Path $gamePath win32\BattleBrothers.exe
$name = Split-Path -Path $modPath -Leaf

$excludedZipFolders = ".git",".github","unpacked",".vscode",".utils"
$excludedScriptFolders = ".git",".github","gfx","ui","preload","brushes","music","sounds","unpacked","tempfolder",".vscode","nexus", ".utils"

# Remove old .zip
if (Test-Path -Path $modPath\$name.zip)
{
	Remove-Item $modPath\$name.zip
}

# Call the pack brush .ps1; exit if it returns an error
& "$packBrushPath" $modPath
if ($LASTEXITCODE -eq -2)
{
	Write-Output "Exiting..."
	exit
}


# Get all .nut files in designated folders
function getAllScriptFilesOfType{
	param(
		[string]$filePath,
		[string]$type
	)
	$files = Get-ChildItem -Path $filePath -Directory -Force | Where-Object {
	($excludedScriptFolders -contains $_.Name) -eq $False
	} | Get-ChildItem -Recurse -Force -File | Where-Object { $_.Extension -eq $type}
	return $files;
}

$break = 0
foreach ($file in (getAllScriptFilesOfType -filePath $modPath -type ".nut"))
{	
	$raw = $file.Basename
	$path = $file.DirectoryName
	& $SQPath -o "$path/$raw.cnut" -c "$path/$raw.nut" -e
	if ($LASTEXITCODE -eq -2)
	{
		Write-Output "Failed compiling file $raw!"
		$break = -2
	}
	else 
	{
		Remove-Item "$path/$raw.cnut"
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
Copy-Item $modPath\$name.zip $pathToData 
Write-Output "Copied mod $name.zip to $pathToData"


if ($bootAfterDone -eq "true")
{
	Write-Output "Starting the game..."
	Start-Process $pathToExe
}
Write-Output "Done!"	
