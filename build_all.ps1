
Write-Host ""
Write-Host "    ____            _   _       _     ____                                            "
Write-Host "   | __ )   _   _  (_) | |   __| |   / ___|   _   _   ___   _ __ ___     ___    _ __  "
Write-Host "   |  _ \  | | | | | | | |  / _  |   \___ \  | | | | / __| |  _   _ \   / _ \  |  _ \ "
Write-Host "   | |_) | | |_| | | | | | | (_| |    ___) | | |_| | \__ \ | | | | | | | (_) | | | | |"
Write-Host "   |____/   \____| |_| |_|  \____|   |____/   \__  | |___/ |_| |_| |_|  \___/  |_| |_|"
Write-Host "                                              |___/                                   "
Write-Host "                                                                  By Croko-fr"


if ( ( Test-Path .\wix311-binaries.zip ) -eq $false  ) {
	Write-Host " [+] Gathering Wix ToolSet binaries"
	Invoke-WebRequest -Uri "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip" -OutFile "wix311-binaries.zip"
}

if ( ( Test-Path .\sysmon_modular.xml ) -eq $false  ) {
	Write-Host " [+] Gathering https://github.com/olafhartong/sysmon-modular/sysmonconfig.xml"
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml" -OutFile "sysmon_modular.xml"
}

if ( ( Test-Path .\sysmon_swift.xml ) -eq $false  ) {
	Write-Host " [+] Gathering https://github.com/SwiftOnSecurity/sysmon-config/sysmonconfig-export.xml"
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmon_swift.xml"
}

if ( ( Test-Path .\Sysmon64.exe ) -eq $false  ) {
	Write-Host " [+] Gathering https://live.sysinternals.com/Sysmon64.exe"
	Invoke-WebRequest -Uri "https://live.sysinternals.com/Sysmon64.exe" -OutFile "Sysmon64.exe"
}

if ( ( Test-Path .\Sysmon.exe ) -eq $false  ) {
	Write-Host " [+] Gathering https://live.sysinternals.com/Sysmon.exe"
	Invoke-WebRequest -Uri "https://live.sysinternals.com/Sysmon.exe" -OutFile "Sysmon.exe"
}

if ( ( Test-Path .\Eula.txt ) -eq $false  ) {
	Write-Host " [+] Gathering https://live.sysinternals.com/Eula.txt"
	Invoke-WebRequest -Uri "https://live.sysinternals.com/Eula.txt" -OutFile "Eula.txt"
}

if ( ( Test-Path .\wix311-binaries ) -eq $false  ) {
	Write-Host " [+] Expanding Wix ToolSet binaries"
	Expand-Archive .\wix311-binaries.zip
}

if ( ( Test-Path .\wix311-binaries.zip ) -eq $false  ) {
	Write-Host " [x] Missing wix311-binaries.zip - Aborting" -ForegroundColor "Red"
    Break
}

if ( Test-Path .\wix311-binaries ) {
	Write-Host " [+] Addind binaries to PATH"
    $env:Path = $pwd.Path + "\wix311-binaries;" + $env:Path
}


foreach ( $file in (Get-ChildItem -Path . -Filter *.wxs).Name ) {
    $FileName = $file.Replace(".wxs","")
    if ( ( Test-Path ".\$FileName.msi" ) -eq $false ) {
        Write-Host " [+] Compiling      : $FileName.wxs"
        candle "$file" | Out-Null
        Write-Host " [+] Linking        : $FileName.wixobj"
        light "$FileName.wixobj" | Out-Null
    } else {
        Write-Host " [+] $FileName.msi already exists !" -ForegroundColor "Green"
    }
}


if ( Test-Path .\Sysmon64_swift.msi ) {

    Write-Host " [+] Cleaning in progress ..."

    if ( Test-Path ".\wix311-binaries" ) {
        Write-Host " [+] Cleaning file  : .\wix311-binaries"
        Remove-Item -Path ".\wix311-binaries" -Force -Recurse
    }

    foreach ( $file in "wix311-binaries.zip Eula.txt Sysmon.exe Sysmon64.exe sysmon_modular.xml sysmon_swift.xml".Split(" ") ) {

        if ( Test-Path ".\$file" ) {
            Write-Host " [+] Cleaning file  : .\$file"
            Remove-Item -Path ".\$file" -Force
        }

    }

    foreach ( $file in (Get-ChildItem -Path . -Filter *.wix*).Name ) {
        Write-Host " [+] Cleaning file  : .\$file"
        Remove-Item -Path ".\$file" -Force
    }

}