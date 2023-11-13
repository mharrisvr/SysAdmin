# Notepad Updater 
# Mike Harris
# Last updated 11-10-2023

#Find out install location and verify version installed 32bit or 64bit 

$uninstallx64 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*Notepad++*"} | Select-Object -Property DisplayName, DisplayVersion, InstallLocation, UninstallString, QuietUninstallString 

if ($uninstallx64.'InstallLocation' -ne $null) {
    
    $PluginsPath = 'C:\Program Files\Notepad++\plugins'

    #"Test to see if folder [$Folder]  exists"
    if (Test-Path -Path $PluginsPath) {
            #Create new folder 
            $TempPluginHolder = 'C:\Notepad++Temp'
            New-Item -Path $TempPluginHolder -ItemType Directory

            #Copy contents of plugins folder 
            Copy-Item -Path $PluginsPath -Destination $TempPluginHolder -Recurse 
    } 
    Start-Process $uninstallx64.'UninstallString' -ArgumentList "/S"
}
#Start-Process $uninstallx64.'UninstallString' -ArgumentList "/S"

$uninstallx86 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*Notepad++*"} | Select-Object -Property DisplayName, DisplayVersion, InstallLocation, UninstallString, QuietUninstallString 

if ($uninstallx86.'InstallLocation' -ne $null) {
    
    $PluginsPath = 'C:\Program Files (x86)\Notepad++\plugins'

    #"Test to see if folder [$Folder]  exists"
    if (Test-Path -Path $PluginsPath) {
            #Create new folder 
            $TempPluginHolder = 'C:\Notepad++Temp'
            New-Item -Path $TempPluginHolder -ItemType Directory

            #Copy contents of plugins folder 
            Copy-Item -Path $PluginsPath -Destination $TempPluginHolder -Recurse 
    } 
    #Uninstall existing version
    Start-Process $uninstallx86.'UninstallString' -ArgumentList "/S"
}
#Uninstall existing version
#Start-Process $uninstallx86.'UninstallString' -ArgumentList "/S"

#Install update to Notepad 
start-process -FilePath './npp.8.5.8.Installer.x64.exe' -ArgumentList '/S' -Verb runas -Wait

#Copy of copied folder moved back (Only if needed) 

Get-ChildItem $TempPluginHolder -Recurse | ForEach {
    $ModifiedDestination = $($_.FullName).Replace("$TempPluginHolder","$PluginsPath")
    If ((Test-Path $ModifiedDestination) -eq $False) {
        Copy-Item $_.FullName $ModifiedDestination -Recurse
        }
    }
	
#Delete created folder folder 
Remove-Item $TempPluginHolder -Recurse
