#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '8/14/2024 1:01:39 PM'.

# Site configuration
$SiteCode = "P05" # Site code 
$ProviderMachineName = "sscm.location.com" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

Start-Transcript -Path "C:\windows\ccm\logs\collectionupdater.log"

# Variables 
$LimitingCollection = "Workstations with Windows 10"

$CollectionMachines = Get-CMCollectionDependent -Name "Workstations with Windows 10" | Select DependentCollectionName -Unique | Sort -Descending

Write-Host "All these collections below point to Workstations with Windows 10". 
Write-Host "#######################################################################"
$Collections

Write-Host "We currently have $Collections.Count Collections with this Limiting Collection"

Foreach ($Col in $CollectionMachines) {
    $Collection = Get-CMCollection -Name $Col
    Set-CMCollection -inputObject $Collection -LimitToCollectionName "Workstations with Windows 10 or 11"
}

Stop-Transcript
