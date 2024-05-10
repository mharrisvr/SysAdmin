# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
# Last updated: 2/2/2024
#

#Needs to be replaced with your own info
# Site configuration
$SiteCode = "XXX" # Site code 
$ProviderMachineName = "my.domain.com" # SMS Provider machine name

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

$CollectionID = 'P00000' #Update with your own
$CollectionMembers = Get-CMDevice -CollectionId $CollectionID | Select -Property Name, username, primaryuser

$Group = Get-ADGroup -Filter "Name -eq 'Test Computers'" #Update with your own group name

foreach ($CollectionMember in $CollectionMembers) {
    $Name = $CollectionMember.Name
    $Computer = $(try {Get-ADComputer -Filter "(Name -like '$Name')"} catch {$null})
    Add-ADGroupMember -Identity $Group -Members $Computer
}
