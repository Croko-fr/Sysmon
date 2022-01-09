@echo off

echo.
echo    ____            _   _       _     ____                                            
echo   ^| __ )   _   _  (_) ^| ^|   __^| ^|   / ___^|   _   _   ___   _ __ ___     ___    _ __  
echo   ^|  _ \  ^| ^| ^| ^| ^| ^| ^| ^|  / _` ^|   \___ \  ^| ^| ^| ^| / __^| ^| '_ ` _ \   / _ \  ^| '_ \ 
echo   ^| ^|_) ^| ^| ^|_^| ^| ^| ^| ^| ^| ^| (_^| ^|    ___) ^| ^| ^|_^| ^| \__ \ ^| ^| ^| ^| ^| ^| ^| (_) ^| ^| ^| ^| ^|
echo   ^|____/   \__,_^| ^|_^| ^|_^|  \__,_^|   ^|____/   \__, ^| ^|___/ ^|_^| ^|_^| ^|_^|  \___/  ^|_^| ^|_^|
echo                                              ^|___/                                   
echo.

if not exist wix311-binaries.zip (
	echo [+] Gathering Wix ToolSet binaries
	powershell "& { (new-object System.Net.WebClient).DownloadFile('https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip','.\wix311-binaries.zip') }"
)

if not exist sysmon_modular.xml (
	echo [+] Gathering https://github.com/olafhartong/sysmon-modular/sysmonconfig.xml
	powershell "& { (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml','.\sysmon_modular.xml') }"
)

if not exist sysmon_swift.xml (
	echo [+] Gathering https://github.com/SwiftOnSecurity/sysmon-config/sysmonconfig-export.xml
	powershell "& { (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml','.\sysmon_swift.xml') }"
)

if not exist Sysmon64.exe (
	echo [+] Gathering https://live.sysinternals.com/Sysmon64.exe
	powershell "& { (new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon64.exe','.\Sysmon64.exe') }"
)

if not exist Sysmon.exe (
	echo [+] Gathering https://live.sysinternals.com/Sysmon.exe
	powershell "& { (new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon.exe','.\Sysmon.exe') }"
)

if not exist Eula.txt (
	echo [+] Gathering https://live.sysinternals.com/Eula.txt
	powershell "& { (new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Eula.txt','.\Eula.txt') }"
)

if not exist wix311-binaries (
	echo [+] Expanding Wix ToolSet binaries
	powershell "& { Expand-Archive .\wix311-binaries.zip }"
)

if not exist wix311-binaries.zip (
	echo [x] Missing wix311-binaries.zip - Aborting
	break
)

echo [+] Addind binaries to PATH
set PATH=%PATH%;%~dp0wix311-binaries\

for /f "tokens=1 delims=." %%a in ('dir /b *.wxs') do (
	echo [+] Compiling      : %%a.wxs
	candle %%a.wxs >NUL
	echo [+] Linking        : %%a.wixobj
	light %%a.wixobj >NUL
)

if exist Sysmon64_swift.msi (
	echo [+] Cleaning files : wix311-binaries
	del /s /q wix311-binaries >NUL
	rmdir /s /q wix311-binaries
	
	set FilesToDelete=wix311-binaries.zip Eula.txt Sysmon.exe Sysmon64.exe sysmon_modular.xml sysmon_swift.xml
	for %%b in (%FilesToDelete%) do (
		echo [+] Cleaning file  : %%b 
		del /q %%b >NUL
	)
	for /f %%b in ('dir /b *.wix*') do (
		echo [+] Cleaning file  : %%b 
		del /q %%b >NUL
	)
)