function stopIfBadCode {
	if ($LASTEXITCODE -eq -2)
	{
		Write-Output "Exiting..."
		exit
	}
}
$modPath = $args[0];
$bootAfterDone = $args[1];

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
$SQPath = Join-Path $utilsPath \modtools\sq.exe
$packBrushPath = Join-Path $utilsPath pack_brush.ps1
$configPath = Join-Path $utilsPath config.JSON
$configJSON = Get-Content -Path $configPath | ConvertFrom-Json
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
	& sq -o "$path/$raw.cnut" -c "$path/$raw.nut" -e
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

stopIfBadCode

Write-Output "Successfully compiled files"


foreach ($folder in Get-ChildItem -Path $modPath -Directory -Force)
{
	if (($excludedZipFolders -match $folder.Name).Length -eq 0)
	{
		$folderPath = Join-Path $modPath $folder
		if (Test-Path -Path $folderPath)
		{
			7z a archive.zip $folder | out-null
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
