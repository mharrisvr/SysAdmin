# Windows 11 Tweaks 
# Lasted edited by: Mike Harris 
# Last Edited: 7/24/2024
#   -Additional configurations for cleaning up user interface
#   -Removes default Appx apps and Windows Capability apps
#   - Finalized Win 11 Tweaking script to set all our preferences 
#                                                             
###############################################################

Start-Transcript -Path "C:\Windows\CCM\Logs\Win11Tweaker.log" -Verbose -Append
Write-Host "Comment - Running Win11Tweaks script" 

#Delete all shortcuts from C:\Users\Public\Desktop. Otherwise, non-admins unable to delete them and generates Help Desk tickets. -> Testing working
Remove-Item -Path $env:SystemDrive'\Users\Public\Desktop\*.lnk' -Force

# Registry Key Tweaks 

############################################################
### Custom registry tweaks made to the default profile    ##
### These changes will be applied to new user profiles    ##
############################################################

#Load Default user hive
Write-Host "Loading Default user hive"
reg load HKLM\DEFAULT c:\users\default\ntuser.dat

# Moves task bar to the left 
Write-Host "Comment - Moving task bar to the left" 
reg add "HKLM\DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" /v TaskbarAl /t REG_DWORD /d 0 /f

<#
# Set Taskbar search icon in reg to Icon only as default (User can change) 0 = Hide 1 = Icon Only 2 = Icon and Label 3 = Full Search bar - Created Reg Key fine, but will need to kick off fresh build to test
Write-Host "Setting Taskbar mode"
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 00000001 /f
#>

#Show known file extensions
Write-Host "Comment - Applying Reg key for Show known file extensions"
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f

# Disable AutoPlay 
Write-Host "Comment - Disable AutoPlay"
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v DisableAutoplay /t REG_DWORD /d 1 /f

#Disable automatic hide scroll bars - https://beebom.com/how-always-show-scrollbars-windows-11/
# Had to swap 0 to 1, as 0 automatically hides task bar in Win 11 
Write-Host "Comment - Disable automatic hide scroll bars"
reg add "HKLM\DEFAULT\Control Panel\Accessibility" /v DynamicScrollbars /t REG_DWORD /d 1 /f

# Quick Access Modifications: 
# Remove Music folder
Write-Host "Hiding Music Folder by default"
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum\" /v "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /t REG_DWORD /d 00000001 /f
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /v HiddenByDefault /t REG_DWORD /d 00000001 /f

# Removing Videos Folder 
Write-Host "Hiding Videos folder by default"
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum\" /v "{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /t REG_DWORD /d 00000001 /f
reg add "HKLM\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /v HiddenByDefault /t REG_DWORD /d 00000001 /f

#Unload Default user hive
Write-Host "Comment - Unloading Default User Hive and Sleeping"
reg unload HKLM\DEFAULT 

#Sleep to allow hive to unload
Start-Sleep -Seconds 10

reg load HKU\DEFAULT c:\users\default\ntuser.dat

#Hide Search Box from the Taskbar
Write-Host "Comment - Hide Search box from the task bar"
reg add "HKU\DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f
reg add "HKU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f

reg unload HKU\DEFAULT

#Sleep to allow hive to unload
Start-Sleep -Seconds 10

# Delete keys outside of default, then they won't be created for new users that log in. 
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f

#######################################################
###         Remove Default Windows 11 Apps          ###
###         List generated from Get-Appxpackage     ###
#######################################################

#List of application that will be removed 
$applist = @(
    "Clipchamp.Clipchamp"
    "Microsoft.BingNews"
    "Microsoft.BingWeather" 
    "Microsoft.GetHelp" 
    "Microsoft.Getstarted"
    "Microsoft.Messaging" 
    "Microsoft.MicrosoftOfficeHub" 
    "Microsoft.MicrosoftSolitaireCollection" 
    "Microsoft.People" 
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.StorePurchaseApp"
    "microsoft.windowscommunicationsapps" 
    "Microsoft.WindowsFeedbackHub" 
    "Microsoft.WindowsMaps" 
    "Microsoft.Xbox.TCUI" 
    "Microsoft.XboxApp"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxGameOverlay" 
    "Microsoft.XboxGamingOverlay" 
    "Microsoft.XboxIdentityProvider" 
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone" 
    "Microsoft.ZuneMusic" 
    "Microsoft.ZuneVideo" 
    "MicrosoftCorporationII.QuickAssist"
    "Microsoft.GamingApp"
)

Write-Host "Comment - Try to remove the following Win10 apps: $appList"
ForEach ($app in $appList){

    #Removes provisioned packages so new users don't get the app installs
    $provisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object {$_.displayName -eq $app}

    if ($provisionedPackage -ne $null){
          Write-Host "Comment - Removing Appx Provisioned Package: $app"
          Remove-AppxProvisionedPackage -Online -packagename $provisionedPackage.PackageName
    }
    else{
          Write-Host "Comment - Unable to find provisioned package: $app"
    }
}
