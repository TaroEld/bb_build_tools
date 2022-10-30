This is my collection of scripts to improve the process of working on mods.
There's three main scripts:
config.ps1: Setup your 'environment'.
init.ps1: Setup a new mod with folder and editor files. You can configure where the mods are placed, and what folders you want included in your editor project.
build.ps1: Pack files into a zip and transports it to your data folder. Also checks for syntax errors by compiling the files.

Needs Sublime Text or VSCode to make best use of the build scripts.
This is bundled with the BB modkit by Adam Milazzo:
http://www.adammil.net/blog/v133_Battle_Brothers_mod_kit.html
As well as 7zip:
https://www.7-zip.org/

How to use:
Download the .zip file and extract it in some location.
Open powershell in the newly extracted location. The easiest way is to just write "powershell" in the address bar and pressing enter.
Configure the paths to the game and your 'mods' folder by running ./config.ps1:
	-ModsPath : 
		Set the path to your mods folder. This is where newly created mod folders will be put. If you don't have one, make it first. For example:
		config.ps1 -ModsPath "G:\Games\BB\Mods"
	-GamePath : 
		Set the path to your game folder, for example:
		config.ps1 -GamePath "G:\Games\BB\BattleBrothers"
	-FolderPaths : 
		Set the path to additional folders that will be included in the project files of sublime or vscode.
		The paths need to be comma-separated if more than one. For example:
		config.ps1 -FolderPaths "F:\MODDING\basegame\scripts","G:\Games\BB\Mods\WIP\mod_msu"'

To create a new mod:
Run ./init.ps1 mod_mymod" from powershell to create a new folder, where mod_mymod is the modname. If you want spaces in your modname, add "" around it (don't do spaces in paths please).
The resulting folder will be opened. Edit the RENAME variables in scripts/mods_preload/.nut. You can doubleclick on the sublime-project file, or the 
code-workspace file in .vscode/ to open the project in the editor.

To initialise the editor build scripts:
	Sublime: Copy ./bb_build/bb_build.sublime-build into the sublime builds folder. This is found under %APPDATA%\Roaming\Sublime Text\Packages\User
		Then, in sublime, open settings (top left) -> tools -> build system -> bb_build
	VSCode: copy ./tasks.json to the vscode user tasks folder. This is found under %APPDATA%\Roaming\Code\User . If you already defined custom tasks, you can just add them there.
		You can also edit the user tasks by going ctrl+shift+P -> Tasks: Open User Tasks

To build the zip and copy it into data, press ctrl+shift+b in sublime or VSCode while in the project. 
	"Update mod" will only replace the new zip in data with a fresh one. 
	"Update mod and run" will also terminate and relaunch BattleBrothers.exe.
You can switch projects in sublime with "ctrl+shift+o".
Alternatively, call .utils/build.ps1 while passing the path of the mod folder, and "true" as a second parameter to relaunch the game.

If you want to pack brushes, any folder in unpacked will be packed, the name of that folder will be the name of the brush.
Within each folder, you need a metadata file with the name of the eventual .png, and the files you want to pack.
See unpacked_example folder for an example, other tutorials (if we have them) for more info on brushes.