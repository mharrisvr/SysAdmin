 <#
 InPlaceGrouper.ps1 
 This was used to populate SCCM Collections based on lists in CSV files Windows 11 In-place upgrade groups. 
 CSV Files just included: Name
                          Computer Name 1
 #>

 #Connect to your SCCM Console -> However you want to. 
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

# Folder containing CSV files
$CsvFolder = "Insert your Path here"

# Get all CSV files in the folder
$CsvFiles = Get-ChildItem -Path $CsvFolder -Filter *.csv

# Import contents of each CSV File - Files required to be named after SCCM Collection you want populated. 
foreach ($CsvFile in $CsvFiles) {
    # Use the file name (without extension) as the collection name
    $CollectionName = [System.IO.Path]::GetFileNameWithoutExtension($CsvFile.Name)
    Write-Host "`nProcessing file: $($CsvFile.Name) -> Collection: $CollectionName" -ForegroundColor Cyan

    # Try to get the existing collection or create a new one
    $Collection = Get-CMDeviceCollection -Name $CollectionName -ErrorAction SilentlyContinue
    if (-not $Collection) {
        #Commented out, but can be used IF you want to leverage this.. I didn't need it because the groups already existed in my case. 
        #Write-Host "Creating collection: $CollectionName"
        #$Collection = New-CMDeviceCollection -Name $CollectionName -LimitingCollectionName "All Systems"
    }

    # Import CSV data
    $Computers = Import-Csv -Path $CsvFile.FullName

    foreach ($Computer in $Computers) {
        $Device = Get-CMDevice -Name $Computer.Name
        Write-Host "Computer name is $Device"
        if ($Device) {
            # Check if the membership rule already exists (optional, to avoid duplicates)
            $existing = Get-CMDeviceCollectionDirectMembershipRule -CollectionId $Collection.CollectionID | Where-Object { $_.ResourceID -eq $Device.ResourceID }
            if (-not $existing) {
                Add-CMDeviceCollectionDirectMembershipRule -CollectionId $Collection.CollectionID -ResourceId $Device.ResourceID
                Write-Host "  Added $($Computer.Name) to $CollectionName"
            } else {
                Write-Host "  $($Computer.Name) already in $CollectionName"
            }
        } else {
            Write-Warning "  Device $($Computer.Name) not found in SCCM"
        }
    }
}
