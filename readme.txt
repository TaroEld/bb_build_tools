This is my collection of scripts to improve the process of working on mods.
There's two main scripts:
init.ps1: Setup a new mod with folder and editor files. You can configure where the mods are placed, and what folders you want included in your editor project.
build.ps1: Pack files into a zip and transports it to your data folder. Also checks for syntax errors by compiling the files.

Needs Sublime Text or VSCode to make best use of the build scripts.

How to use:
Make sure you have 7zip installed, it's needed to create the zip file.
Edit config.json: 
	Edit the line after "ModFoldersPath" to point towards your mods folder.
	Edit the line after "DataPath" to point towards your BattleBrothers/ folder.
	Add any folders to "FolderPaths" that you want included in every project.
	Ignore the rest

To create a new mod:
Run "powershell ./init.ps1 mod_mymod" to create a new folder, where mod_mymod is the modname. If you want spaces in your modname, add "" around it.
The resulting folder will be opened. Edit the RENAME variables in scripts/mods_preload/.nut. You can doubleclick on the sublime-project file, or the 
code-workspace file in .vscode/ to open the project in the editor.

To build the zip and copy it into data, press ctrl+shift+b in sublime or VSCode while in the project. 
	"Update mod" will only replace the new zip in data with a fresh one. 
	"Update mod and run" will also terminate and relaunch BattleBrothers.exe.
You can switch projects in sublime with "ctrl+shift+o".
Alternatively, call build.ps1 while passing the path of the mod folder, and "true" as a second parameter to relaunch the game.