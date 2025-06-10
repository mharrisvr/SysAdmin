# Name: ComputerRandomizer.ps1
# Purpose: Generate 50 machines from entire SCCM collection for the In-place upgrade test. 
# Last updated: 6/10/2025

# Variables
# Site configuration
$SiteCode = "XXX" # Site code 
$ProviderMachineName = "Server Name" # SMS Provider machine name
$CollectionName = "Workstations with Windows 10 v22H2"  # The collection name to pick from
$NumberToSelect = 50             # Number of random computer names to pick

# Import SCCM module and connect to site
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Set-Location "$SiteCode`:"

# Get the collection object
$collection = Get-CMDeviceCollection -Name $CollectionName
if (-not $collection) {
    Write-Error "Collection '$CollectionName' not found."
    exit
}

# Get all members of the collection
$allComputers = Get-CMDevice -CollectionName $CollectionName | Select-Object -ExpandProperty Name

# Check if there are enough computers
if ($allComputers.Count -lt $NumberToSelect) {
    Write-Warning "Collection only contains $($allComputers.Count) computers, less than $NumberToSelect."
    $NumberToSelect = $allComputers.Count
}

# Pick random computers
$randomComputers = Get-Random -InputObject $allComputers -Count $NumberToSelect

# Output the results
$randomComputers | ForEach-Object { Write-Output $_ }

# Optional: Save to a file
# $randomComputers | Out-File -FilePath "C:\temp\RandomComputers.txt"
