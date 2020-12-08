# Sysmon
Explorations autour de sysmon


## Téléchargement des Fichiers Nécessaires


| Fichiers | Site                                                         |
| ----------------------- | ------------------------------------------------------------ |
| WiX Toolset build tools | http://wixtoolset.org/releases/                              |
| Binaires  |  [Fichier ZIP avec les Binaires de WIX v3.11.1](https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip)  |
| Sysmon v9              | https://docs.microsoft.com/fr-fr/sysinternals/downloads/sysmon |
| Sysmon v9               | https://github.com/olafhartong/sysmon-modular                |


## Point d'attention

Pour chaque version de Sysmon une configuration précise est déclinée en fonction.


## 1 - Windows Installer XML (WiX) toolset


### 1.1  What is WiX?

WiX is a set of tools that allows you to create Windows Installer-based  deployment packages for your application. The WiX toolset is based on a  declarative XML authoring model. You can use WiX on the command line by using  the WiX tools or MSBuild. In addition, there is also a WiX Visual Studio plug-in  that supports VS2005, VS2008, and VS2010. The WiX toolset supports building the  following types of Windows Installer files:

- Installer (.msi)  
- Patches (.msp)  
- Merge Modules (.msm)  
- Transforms (.mst)



### 1.2.  Installation


Extraire les Binaires : "**wix311-binaries.zip**".

Ajouter le chemin vers les outils dans la variable PATH:

```bash
set PATH=%PATH%;[Chemin]\wix311-binaries\
```


## 2.  Nécessaire pour Sysmon


### 2.1.  Liste des fichiers nécessaires


Voici ce que vous devriez avoir au minimum pour travailler :

- wix-311-binaries
- Eula.txt
- Sysmon64.exe
- sysmonconfig-v9.xml

Sysmon utilise un fichier de configuration XML qu'il prend en compte lors de l'installation.



### 2.2. Récupération

- PowerShell

```powershell
####################    PowerShell Old School   ##################### 
# Version 64 bits
(new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon64.exe','.\Sysmon64.exe')
# Version 32 bits
(new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon.exe','.\Sysmon.exe')
# Fichier de Licence
(new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Eula.txt','.\Eula.txt')


####################    PowerShell 5 et plus    ##################### 
# Version 64 bits
wget "https://live.sysinternals.com/Sysmon64.exe" -Outfile ".\Sysmon64.exe"
# Version 32 bits
wget "https://live.sysinternals.com/Sysmon.exe" -Outfile ".\Sysmon.exe"
# Fichier de Licence
wget "https://live.sysinternals.com/Eula.txt" -Outfile ".\Eula.txt"
```



## 3.  Etapes de la conception



### 3.1.  Créer le fichier WXS ( WiX Source File ) 



Contenu du fichier à sauvegarder sous le nom **Sysmon64.wxs** dans le dossier de travail.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Name="Sysmon64" 
           Id="*" 
           UpgradeCode="049183f7-e1ad-4b1c-95a7-fefa6142ab7d"
           Language="1034"
           Codepage="1252"
           Version="9.1.0.0"
           Manufacturer="Croko">
    <Package Id="*"
             Keywords="Installer"
             Description="Sysinternals - System Activity Monitor"
             Languages="1034"
             Compressed="yes"
             SummaryCodepage="1252"/>
    <Media Id="1" Cabinet="sysmon.cab" EmbedCab="yes" DiskPrompt="Not Used"/>
    <Property Id="DiskPrompt" Value="Not Used"/>
    
    <MajorUpgrade AllowDowngrades="yes"/>
      
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="TempFolder" Name="Temp">
        <Component Id="sysmonEula" Guid="58389911-f2b8-455c-84cb-dbced4580c2a">
          <File Id="eula" Name="Eula.txt" Source="Eula.txt" KeyPath="yes"/>
        </Component>
        <Component Id="Configuration" Guid="dd9b3f75-e072-4dea-8236-4aea02716318">
          <File Id="config" Name="sysmonconfig-v9.xml" Source="sysmonconfig-v9.xml" KeyPath="yes"/>
        </Component>
        <Component Id="SysmonBinary" Guid="fc5b8d42-61a2-4983-b091-552393854272">
          <File Id="SysmonBinaryFile" Name="Sysmon64.exe" Source="Sysmon64.exe" KeyPath="yes"/>
        </Component>
      </Directory>
    </Directory>

    <Property Id="SYSMON_EXISTS">
      <DirectorySearch Id="CheckFileDir" Path="[WindowsFolder]" Depth="0">
        <FileSearch Id="CheckFile" Name="Sysmon64.exe" />
      </DirectorySearch>
    </Property>
	
    <CustomAction Id="SetPath" Property="SYSMON" Value="[WindowsFolder]\Sysmon64.exe"/>
    <CustomAction Id="RemoveSysmon" Directory="TARGETDIR" ExeCommand='cmd /C "del [SYSMON]"' Impersonate="no" Execute="commit" Return="check"/>
    <CustomAction Id="StopSysmon" Property="SYSMON" ExeCommand="-u" Impersonate="no" Execute="commit" Return="ignore"/> 
    
    <CustomAction Id="UninstallSysmon" Property="SYSMON" ExeCommand="-u" Return="ignore"/> 
    <CustomAction Id="InstallSysmon" Directory="TARGETDIR" ExeCommand="[TempFolder]\Sysmon64.exe -accepteula -i [TempFolder]\sysmonconfig-v9.xml" Execute="commit" Impersonate="no" Return="check"/>

    <InstallExecuteSequence>
      <Custom Action="SetPath" Before="StopSysmon"></Custom>
      <Custom Action="StopSysmon" After="InstallInitialize">SYSMON_EXISTS</Custom>
      <Custom Action="RemoveSysmon" After="StopSysmon">SYSMON_EXISTS</Custom>
      <Custom Action="InstallSysmon" Before="InstallFinalize">NOT REMOVE</Custom>
    </InstallExecuteSequence>
	
    <Feature Id='Complete' Level='1'>
      <Feature Id='MainProgram' Level='1'>
        <ComponentRef Id='sysmonEula' />
        <ComponentRef Id='Configuration' />  
        <ComponentRef Id='SysmonBinary' />
      </Feature>
    </Feature>
    
  </Product>
</Wix>
```

### 3.2. Generation de GUID

```powershell
# Chaque GUID dans le WXS doit être unique
Guid="58389911-f2b8-455c-84cb-dbced4580c2a"

# Generation d'un GUID
PS> [guid]::NewGuid()

Guid
----
b22a2c19-d602-4531-96c3-1a9a5869eb83
```


### 3.3.  Compiler le fichier Sysmon64.wxs



`CMD : candle.exe Sysmon64.wixobj`

```bash
d:\> candle Sysmon64.wxs
Windows Installer XML Toolset Compiler version 3.11.1.2318
Copyright (c) .NET Foundation and contributors. All rights reserved.

Sysmon64.wxs

d:\>
```

Un fichier **Sysmon64.wixobj** est créé par le compilateur pour chaque fichier source compilé. Ce fichier contient une ou plusieures sections, qui contiennent les symboles et les références pour créer le MSI.


### 3.4.  Linker le fichier Sysmon64.wixobj


`CMD : light.exe Sysmon64.wixobj`

```bash
d:\> light.exe Sysmon64.wixobj
Windows Installer XML Toolset Linker version 3.11.1.2318
Copyright (c) .NET Foundation and contributors. All rights reserved.

d:\Creation_MSI\Sysmon64.wxs(20) : warning LGHT1076 : ICE61: This product should remove only older versions of itself. No Maximum version was detected for the current product. (WIX_UPGRADE_DETECTED)

d:\>
```

Le warning précise que la désinstallation ne se fait pas en fonction de la version installée.
Nous en sommes conscient et notre but n'est pas de contrôler forcément les versions ici.

Un fichier **Sysmon64.wixpdb** est créé par le linker pour chaque résultat final. Il contient les information de debug.

## 5. Résultat

**Le MSI est généré !!**
