::-----------------------------------------------------------------------------
:: Script Name: Apply-Default-Profile
:: Original Author: jfullmer
:: Created Date: 2016-02-18 16:39:27
:: Last Updated Date: 2016-06-02 14:51:01
:: Update Author: jfullmer
:: Version: 2.8
::-----------------------------------------------------------------------------

@ECHO OFF
	REM @ECHO off to not output the commands being run to the console
	REM Requires args passed of department
	rem if department is Touchscreen autologon is enabled and fog will reboot after applying the profile

set dept=%1
set domain="domain for network login to share with network path (put localhost for local login) ?: "
set username="Username for network share?: "
set passwd="Password for network share?: "
call :OSversion

call :main
exit

:main
	REM main Function that just calls the other Functions

	call :funcHead "Welcome to the Windows 10 Default Profile Copy Script!"
	call :setVars
	call :CopyFromNetwork
	call :funcHead "Done creating custom default profile! & echo.Goodbye"	
	EXIT /B

:setVars
	REM Function to set script variables

	REM c stands for Custom, d stands for default. cUser should be the name of the user you Customized
	REM These variables just point to the user folders and the local and roaming appdata folders that 
	REM store all the settings for a user profile

	call :funcHead "Setting directory variables..."
	
	set cUser=adl
	set custom=C:\Users\%cUser%
	set default=C:\Users\Default
	set cLocal=C:\Users\%cUser%\AppData\Local
	set dLocal=C:\Users\Default\AppData\Local
	set cRoam=C:\Users\%cUser%\AppData\Roaming
	set dRoam=C:\Users\Default\AppData\Roaming
	set share=\\path\to\DefaultProfiles\%winVer%\%dept%
	net use %share% /USER:%domain%\%username% %password%	
		
	call :dots
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

:CopyFromNetwork
	REM This copies the newly created profile to the network share

	call :funcHead "Copying profile From network!"
	echo. Delete and recreate default profile folder so there aren't remnants of other profiles...
	rmdir %default% /S /Q
	mkdir %default% 
	ROBOCOPY %share%\Default %default% /S /MIR /R:1 /W:1 /MT:128 /ZB /LOG:C:\defaultProfileApplied-%dept%.log
	XCOPY %share%\Default\ntuser* %default%\ /H /Y > C:\defaultProfile-ntuser-%dept%.log

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