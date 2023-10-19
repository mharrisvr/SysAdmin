# 7-Zip uninstaller 
# Author: Mike Harris 
# Last updated 10-13-2023

#Get Version Installed (x64) Or (32-bit) and tries to uninstall whatever is installed. 

$uninstall32 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*7-Zip*"} | Select-Object -Property DisplayName, DisplayVersion, InstallLocation, UninstallString

if ($uninstall32.'InstallLocation' -ne $null) {
    Start-Process $uninstall32.'UninstallString' -ArgumentList "/S"
}
else {
    #Do nothing
}


$uninstallx64 = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.displayname -like "*7-Zip*"} | Select-Object -Property DisplayName, DisplayVersion, InstallLocation, UninstallString 

if ($uninstallx64.'InstallLocation' -ne $null) {
    Start-Process $uninstallx64.'UninstallString' -ArgumentList "/S" 
}
else {
    #Do nothing
}

# Install newest version 

Start-Process -FilePath 'msiexec.exe' -ArgumentList '/package 7z2301-x64.msi /qn /norestart' -Wait
