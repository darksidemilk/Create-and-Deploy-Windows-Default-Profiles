::-----------------------------------------------------------------------------
:: Script Name: Create-Deployable-Default-Profile
:: Original Author: jfullmer
:: Created Date: 2016-02-18 16:39:23
:: Last Updated Date: 2016-06-02 14:50:07
:: Update Author: jfullmer
:: Version: 3.8
::-----------------------------------------------------------------------------

@ECHO OFF
	REM @ECHO off to not output the commands being run to the console
	REM This script copies a Customized windows 10 profile to the default profile so that
	REM all new profiles are created with the same settings

SET pwd=%~dp0
set /p domain="domain for network login to share with network path (put localhost for local login) ?: "
set /p username="Username for network share?: "
set /p passwd="Password for network share?: "
set /p networkPathToScript="Enter full path to this file on the network: "
call :main
del C:\Create-Deployable-Default-Profile.bat & exit

:main
	REM main Function that just calls the other Functions

	call :copySelf
	call :funcHead "Welcome to the Windows Default Profile Creator Script!"
	call :setVars
	call :funcHead "Copying Customized Profile From %custom% to %default% ..."
	call :AppData
	call :CustomSettings
	call :CopyToNetwork
	call :funcHead "Done creating custom default profile! & echo.Goodbye"	
	EXIT /B

:copySelf
	IF NOT %pwd%==C:\ (
		echo. Copying self to C drive
		net use \\script\share /USER:%domain%\%username% %password%	
		XCOPY %networkPathToScript% C:\ /H /Y
	 	net session >nul 2>&1
	    if %errorLevel% == 0 (
			echo opening copied version.
			start C:\Create-Deployable-Default-Profile.bat
			exit
	    ) else (
	        echo This needs to be run as admin, try again please.
	    	@pause
	    	exit
		)
    )
	EXIT /B

:setVars
	REM Function to set script variables

	REM c stands for Custom, d stands for default. cUser should be the name of the user you Customized
	REM These variables just point to the user folders and the local and roaming appdata folders that 
	REM store all the settings for a user profile

	call :funcHead "Setting directory variables..."
	
	rem set cUser=adl
	echo. Don't run this script from the user you're copying!
	set /p cUser="What is the username of the profile you customized? -> "
	set custom=C:\Users\%cUser%
	set default=C:\Users\Default
	set cPF=C:\Users\%cUser%\AppData\ProgramFiles
	set dPF=C:\Users\Default\AppData\ProgramFiles
	set cLocal=C:\Users\%cUser%\AppData\Local
	set dLocal=C:\Users\Default\AppData\Local
	set cRoam=C:\Users\%cUser%\AppData\Roaming
	set dRoam=C:\Users\Default\AppData\Roaming
	set profiles=\\path\toshare\DefaultProfiles
	net use %profiles% /USER:%domain%\%username% %password%
	call :OSversion
	call :setDept
		
	call :dots
	EXIT /B

:setDept
	rem Function to set department via prompt. 
	echo. What department/group is this profile for? (no spaces)
	echo. The Current Choices are... (A different entry will create a new folder)
	rem list profiles
	dir /b %profiles%\%winVer%
	set /P dept="Enter The Dept Here -> "
	set share=%profiles%\%winVer%\%dept%
	if NOT EXIST %share% mkdir %share%
	if NOT EXIST %share%\logs mkdir %share%\logs
	set logs=%share%\logs
	EXIT /B

:OSversion
	:: Function to get current OS version
	echo. Getting OS...
	FOR /F "tokens=4-5 delims=. " %%i in ('ver') do set os=%%i.%%j
	if "%os%" == "5.1" set winVer=WinXP
	if "%os%" == "5.2" set winVer=WinXP
	if "%os%" == "6.1" set winVer=Win7
	if "%os%" == "6.2" set winVer=Win8
	if "%os%" == "6.3" set winVer=Win8.1
	if "%os%" == "10.0" set winVer=Win10

	EXIT /B

:copyDir
	REM Function inputs - 1 = display of what is copying 2 = source folder 3 = destination folder 
	
	REM This Function simply displays what you're copying and copies it. Did a Function to have less
	REM copy paste of command line options and have cleaner code.
	REM Note that when calling the Function all passed parameters should be encased in double quotes
	REM otherwise ROBOCOPY won't read the directories as seperate
	
	REM ROBOCOPY or robust copy, is a tool for copying directories or files in windows command line
	REM The syntax is ROBOCOPY sourceFolder DestFolder options
	REM the options used make it so a mirrored version of the source and its subdirectories are copied
	REM to the destination with 64 threads (64 files at once) overwriting existin files retrying any failed files 
	REM only once after 1 second of waiting and all without any verbose output
	
	REM /S - subdirectories /MIR - mirror /MT:64 - multithreaded copy with 64 threads, i.e. 64 files at a time instead of 1. 
	REM /LOG - output to logfile instead of console, ROBOCOPY /? says this provides better performance in multithreaded mode
	REM /IS - include same files i.e. overwrite existing /R:1 retry on error once (default is 1 million) 
	REM W:1 - wait one second between retry on error (default is 30 seconds) 
	REM the /N* are all to decrease output for automation. Since they go to a log file you can take them out if you want ( I did take them out)
	REM /NP - no progress /NS - don't log file sizes /NC - don't log file classes /NFL - don't log file names /NDL - don't log directory names
	REM /NJH - no job header /NJS - no job summary

	echo. Copying %~1...
	ROBOCOPY "%~2" "%~3" /S /MIR /MT:128 /LOG:"%logs%\%~1.log" /IS /R:1 /W:1 /ZB
	echo. Done Copying %~1
	EXIT /B

:AppData
	REM Function to copy all Customizations settings that are stored in files in the AppData folder
	
	call :funcHead "Copying Customizations From AppData..."
	
	REM directories used in all versions of windows
	call :copyDir "Desktop" "%custom%\Desktop" "%default%\Desktop"	
	call :copyDir "Firefox Customizations" "%cRoam%\Mozilla" "%dRoam%\Mozilla"
	call :copyDir "Google Chrome Customizations" "%cLocal%\Google" "%dLocal%\Google"
	call :copyDir "Task Bar Pin Shortcuts" "%cRoam%\Microsoft\Internet Explorer" "%dRoam%\Microsoft\Internet Explorer"
	call :copyDir "VLC settings" "%cRoam%\vlc" "%dRoam%\vlc"
	
	REM The remaining dirs are specific to Windows 10 
	REM Note: A starup script will be required on first login to copy the favorites for Microsoft edge to the Packages directory in the newly created User
	REM That logon script would only need to be one line like so...
	REM ROBOCOPY "%localAppData%\MicrosoftEdge\User" "%localAppData%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User" /S /MIR /MT:64 /LOG:C:\logs\edgeBookmarks.txt /IS /R:1 /W:1 
	
	rem call :copyDir "Microsoft Edge Customizations" "%cLocal%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User" "%dLocal%\MicrosoftEdge\User"
	call :copyDir "Start Menu Tiles Part 1 of 3" "%cLocal%\TileDataLayer" "%dLocal%\TileDataLayer"
	call :copyDir "Start Menu Tiles Part 2 of 3" "%cRoam%\Microsoft\Windows\Start Menu" "%dRoam%\Microsoft\Windows\Start Menu"
	call :copyDir "Start Menu Tiles Part 3 of 3" "%cLocal%\Microsoft\Windows\Shell" "%dLocal%\Microsoft\Windows\Shell"
	
	echo. Done Copying AppData Folders...
	call :dots
	EXIT /B

:CustomSettings
	REM This Function copies the ntuser.dat and related system files that store things like task bar pin order, 
	REM mapped network drives, taskbar toolbars, explorer settings, desktop background settings, etc.
	REM It uses xcopy to copy all files that start with ntuser via * wildcard and uses the options...
	REM \H - copy hidden system files /Y - overwrite existsing files without prompt 

	call :funcHead "Copying custom settings (i.e. task bar pins and toolbars, desktop background, etc.) from ntuser .dat system files..."
	
	XCOPY %custom%\ntuser* %default%\ /H /Y > %logs%\ntuserFiles.log

	echo. Done Copying Custom Settings
	call :dots
	EXIT /B

:CopyToNetwork
	REM This copies the newly created profile to the network share

	call :funcHead "Copying profile to network!"

	ROBOCOPY %default% %share%\Default /S /MIR /R:1 /W:1 /MT:128 /ZB /XJ
	XCOPY %default%\ntuser* %share%\Default\ /H /Y > %logs%\ntuserFilesRemote.log

	net use %share% /delete 

	EXIT /B

:dots
	REM just echoing dots in a Function instead of copy pasting them so that it's consistent
	echo ......................................................................
	EXIT /B

:funcHead
	REM A simple function for displaying a consistent header at the start of functions
	call :dots
	echo. %~1
	call :dots
	EXIT /B