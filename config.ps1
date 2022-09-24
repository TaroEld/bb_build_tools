[CmdletBinding(PositionalBinding=$false)]
param(
	[string] $ModsPath,
	[string] $GamePath,
	[string[]] $FolderPaths
)

$json = Get-Content $PSScriptRoot\config.json | ConvertFrom-Json 
$buildPath = Join-Path $PSScriptRoot "\build.ps1";
$buildPath = $buildPath.replace("\", "\\")
$sqPath = Join-Path $PSScriptRoot "\modtools\sq.exe";
$sqPath = $sqPath.replace("\", "\\")

$verbatimSublimeBuildTools = "
{
	`"working_dir`":  `"`$project_path`",
	`"selector`": `"source.squirrel`",
	`"variants`": [
		{
		    `"name`" : `"Update Mod and Launch`",
		    `"working_dir`" : `"`$project_path`",
		    `"shell_cmd`" : `"powershell \`"$buildPath\`" \`"`$project_path\`" true`",
		},
	    {
	        `"name`" : `"Update Mod`",
	        `"working_dir`" : `"$project_path`",
	        `"shell_cmd`" : `"powershell \`"$buildPath\`" \`"`$project_path\`" `",
	    },
	    {
	        `"name`" : `"Run Locally`",
	        `"shell_cmd`":  `"powershell \`"$sqPath\`" `$file`"
	    },

	],
}"
$verbatimVScodeBuildTools = "
{
    `"version`": `"2.0.0`",
    `"tasks`": [
        {
            `"label`": `"Update mod`",
            `"type`": `"shell`",
            `"command`": `"powershell \`"$buildPath\`" \`"`${fileWorkspaceFolder}\`" `",
            `"problemMatcher`": [],
            `"group`": {
                `"kind`": `"build`",
                `"isDefault`": true
            }
        },
        {
            `"label`": `"Update mod and launch`",
            `"type`": `"shell`",
            `"command`": `"powershell \`"$buildPath\`" \`"`${fileWorkspaceFolder}\`" true`",
            `"problemMatcher`": [],
            `"group`": {
                `"kind`": `"build`",
                `"isDefault`": true
            }
        },
        {
            `"label`": `"Run locally`",
            `"type`": `"shell`",
            `"command`": `"powershell \`"$sqPath\`" \`"`${file}\`" `",
            `"problemMatcher`": [],
            `"group`": {
                `"kind`": `"build`",
                `"isDefault`": false
            }
        },
    ]
}
"

$finishedSublimeJson = $verbatimSublimeBuildTools | %{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

$finishedVSCodeJson = $verbatimVScodeBuildTools | %{
    [Regex]::Replace($_, 
        "(?<!\\)\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} 

$finishedSublimeJson | Out-File -Encoding UTF8 $PSScriptRoot/bb_build.sublime-build
$finishedVSCodeJson | Out-File -Encoding UTF8 $PSScriptRoot/tasks.json

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