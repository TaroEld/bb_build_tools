Use Sublime Text to make use of the build script.
Edit config.json: 
	Edit the line after "DataPath" in config.txt to point towards your data folder.
	Add any folders you want included in the project.

Run "powershell ./init.ps1 mod_mymod" to create a new folder, where mod_mymod is the modname. Sublime will be opened within a new project. Edit the RENAME variables.
To build the zip and copy it into data, either press ctrl+b in sublime while in the project, or call build.ps1 while passing the path of the mod folder.