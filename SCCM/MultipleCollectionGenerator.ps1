# Purpose is to generate a list of machines and primary users that are in two SCCM Collections. 
# Needed to generate a list of machines that might have an issue related to an app/yubikey/Inplace upgrade. 
# Last updated: 4/9/2024
# Updated by: Mike Harris 

# Site configuration - Replace with your own SCCM Configuration 
$SiteCode = "XXX" # Site code 
$ProviderMachineName = "XXXX" # SMS Provider machine name

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

# Collection names to compare
$CollectionName1 = "Group1"
$CollectionName2 = "Group2"

# Get Collection IDs
Write-Host "Checking for existence of first collection $Collection1"
$Collection1 = Get-CMDeviceCollection | Where-Object { $_.Name -eq $CollectionName1 }
Write-Host "Checking for Existence of second collection $Collection2"
$Collection2 = Get-CMDeviceCollection | Where-Object { $_.Name -eq $CollectionName2 }

if (-not $Collection1 -or -not $Collection2) {
    Write-Error "One or both collections were not found."
    return
}

# Get devices in each collection
$Devices1 = Get-CMDevice -CollectionId $Collection1.CollectionID
$Devices2 = Get-CMDevice -CollectionId $Collection2.CollectionID

# Compare and find common device names
$CommonNames = Compare-Object `
    -ReferenceObject $Devices1.Name `
    -DifferenceObject $Devices2.Name `
    -IncludeEqual `
    -ExcludeDifferent |
    Where-Object { $_.SideIndicator -eq "==" } |
    Select-Object -ExpandProperty InputObject

# Get matching device objects and primary users
$CommonDeviceInfo = foreach ($name in $CommonNames) {
    $device = Get-CMDevice -Name $name
    $primaryUser = Get-CMUserDeviceAffinity -ResourceId $device.ResourceID | Select-Object -First 1
    [PSCustomObject]@{
        ComputerName = $device.Name
        PrimaryUser  = if ($primaryUser) { $primaryUser.UniqueUserName } else { "N/A" }
    }
}

# Output the list
Write-Output "`nDevices in both collections with primary users:"
$CommonDeviceInfo | Sort-Object ComputerName | Format-Table -AutoSize
