#Gets all the log files related to the setup/rollback logs and zips them to a folder. 

# Define log paths
$LogPaths = @(
    "$env:SystemDrive\$WINDOWS.~BT\Sources\Panther",
    "$env:SystemDrive\$WINDOWS.~BT\Sources\Rollback",
    "$env:WinDir\Panther",
    "$env:WinDir\Panther\UnattendGC",
    "$env:SystemDrive\$WINDOWS.~BT\Sources\Diagnostics",
    "$env:LocalAppData\Temp\SetupDiagResults.log"
)

# Create output folder
$OutputFolder = "$env:USERPROFILE\Desktop\UpgradeLogs"
New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null

# Copy logs
foreach ($path in $LogPaths) {
    if (Test-Path $path) {
        Copy-Item $path -Destination $OutputFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Zip logs
$ZipPath = "$env:USERPROFILE\Desktop\UpgradeLogs.zip"
Compress-Archive -Path $OutputFolder\* -DestinationPath $ZipPath -Force

Write-Output "Logs collected and zipped to: $ZipPath"
