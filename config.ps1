[CmdletBinding(PositionalBinding=$false)]
param(
	[string] $ModsPath,
	[string] $GamePath,
	[string[]] $FolderPaths
)

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
	Write-Output 'Arguments: 
	-ModsPath : 
		Set the path to your mods folder, for example:
		config.ps1 -ModsPath "G:\Games\BB\Mods"
	-GamePath : 
		Set the path to your game folder, for example:
		config.ps1 -GamePath "G:\Games\BB\BattleBrothers"
	-FolderPaths : 
		Set the path to additional folders that will be included in the project files of sublime or vscode.
		The paths need to be comma-separated if more than one. For example:
		config.ps1 -FolderPaths "F:\MODDING\basegame\scripts","G:\Games\BB\Mods\WIP\mod_msu"'
}
$json | ConvertTo-Json | Out-File $PSScriptRoot\config.json