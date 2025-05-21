# Description: Downloads, Extracts, and installs FSLogix on the session hosts 
# Written by Mike Harris
# Modified based of: https://johanvanneuville.com/automation/install-or-update-fslogix-the-easy-way/
# Last updated: 5/21/2025


$FsLogixUrl= "https://aka.ms/fslogix_download"
$TempPath = "C:\Windows\Temp\FSLogix\install"

Start-Transcript -Path "$TempPath\FSlogixDownloader.txt" -Append 

# Get date for log file 
$Date = Get-Date 
Write-Host "`nFSLogix downloaded and updated started on $Date"

# Make directory to host install files 
mkdir $TempPath -Force -Verbose

Read-Host -Prompt "Open Edge and authenticate at google.com before continuing.. Press any key to continue..."

# Downloading the newest FSLogix download. 
Invoke-WebRequest -Uri $FsLogixUrl -OutFile "$TempPath\FSLogixAppsSetup.zip" -UseBasicParsing -Verbose

# Extracting the zipped download file. 
Expand-Archive -LiteralPath "$TempPath\FSLogixAppsSetup.zip" -DestinationPath $TempPath -Force -Verbose
[Net.ServicePointManager]::SecurityProtocol = 
[Net.SecurityProtocolType]::Tls12

cd $TempPath

# Install FSLogix.  
Write-Host "INFO: Installing FSLogix. . ."
Start-Process "C:\Windows\Temp\fslogix\install\x64\Release\FSLogixAppsSetup.exe" `
    -ArgumentList "/install /quiet /norestart" `
    -Wait `
    -Passthru `

Write-Host "FSLogix install finished and updated. Please reboot ASAP"

# End Logging
Stop-Transcript
