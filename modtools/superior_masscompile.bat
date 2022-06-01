@echo off
rem note: passed path must be scripts folder, so eg pass masscompile stuff/mypath/scripts
rem optional second argument: pass true to delete nuts

rem record currentdir to call sq and bbsq and later cd back
set currentdir=%~dp0
rem cd to passed path
cd  /d "%1"
SET DIRECTORY=%cd%
cd ..
for /R "%DIRECTORY%" %%x in (*.nut) do (
    rem get relative path
    call set "file=%%x"
	call set "result=%%file:%DIRECTORY%=%%"
	
	rem replace backslashes with forward ones, add scripts
	call set "full_nut=%2%%result:\=/%%

	rem replace nut with cnut
	call set "full_cnut=%%full_nut:.nut=.cnut%%"

	
	rem compile and encrypt, passing relative paths
	call "%%currentdir%%\sq" -o %%full_cnut%% -c %%full_nut%% || (
		call set /p id="failed compiling %%full_cnut%%"
	)
	call "%%currentdir%%\bbsq" -e %%full_cnut%%
	
) 

IF "%2" == "true" (
	for /R "%DIRECTORY%" %%x in (*.nut) do (
		call del "%%x"
	)
)
cd /d "%currentdir%"
