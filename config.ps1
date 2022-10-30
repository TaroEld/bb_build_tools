[CmdletBinding(PositionalBinding=$false)]
param(
	[string] $ModsPath,
	[string] $GamePath,
	[string[]] $FolderPaths
)

$buildPath = (Join-Path $PSScriptRoot "\build.ps1").replace("\", "\\");
$sqPath = (Join-Path $PSScriptRoot "\modtools\sq.exe").replace("\", "\\");

(Get-Content (Join-Path $PSScriptRoot "./assets/sublime_template")) -replace("BUILDPATH", $buildPath) -replace("SQPATH", $sqPath) | ForEach-Object{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} | Out-File -Encoding UTF8 $PSScriptRoot/bb_build.sublime-build

(Get-Content (Join-Path $PSScriptRoot "./assets/vscode_template")) -replace("BUILDPATH", $buildPath) -replace("SQPATH", $sqPath) | ForEach-Object{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} | Out-File -Encoding UTF8 $PSScriptRoot/tasks.json


$json = Get-Content $PSScriptRoot\config.json | ConvertFrom-Json 
if ($PSBoundParameters.ContainsKey('ModsPath'))
{
	$json.ModFoldersPath = $ModsPath
	Write-Output "Set Mod Folder Path to $ModsPath"
}
if ($PSBoundParameters.ContainsKey('GamePath'))
{
	$json.GamePath = $GamePath
	Write-Output "Set Game Path to $GamePath"
}
if ($PSBoundParameters.ContainsKey('FolderPaths'))
{
	$json.FolderPaths = $FolderPaths
	Write-Output "Set Folder Paths to $FolderPaths"
}
if ($ModsPath -eq "" -and $GamePath -eq "" -and $FolderPaths.count -eq 0) 
{
	Write-Output '
	Arguments: 
	-ModsPath : 
		Set the path to your mods folder. Example:
		config.ps1 -ModsPath "G:\Games\BB\Mods"
	-GamePath : 
		Set the path to your game folder. Example:
		config.ps1 -GamePath "G:\Games\BB\BattleBrothers"
	-FolderPaths : 
		Set the path to additional folders that will be included in the project files of sublime or vscode.
		The paths need to be comma-separated if more than one. Example:
		config.ps1 -FolderPaths "F:\MODDING\basegame\scripts","G:\Games\BB\Mods\WIP\mod_msu"
	When invoking config.ps1, build scripts (for sublime and vscode) are automatically updated.'
}
$json | ConvertTo-Json | Out-File $PSScriptRoot\config.json