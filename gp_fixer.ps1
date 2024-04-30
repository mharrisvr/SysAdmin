# Automagically rebuild group policy 
# 4/30/2024 
# Mike Harris
# Made some changes before uploading.. needs a little more fixing. Not functional*

$Date = Get-Date
$BadDate = $Date.AddDays(-30)

$MachinePath = "C:\Windows\System32\GroupPolicy\Machine"
$UserPath = "C:\Windows\System32\GroupPolicy\User"
$filename = "registry.pol"

#Test if registry.pol file exists

$Exists0 = Test-Path -Path $MachinePath\$filename

$Exists1 = Test-Path

If ($Exists -eq 'True') {
    #Test if file is > X amount of days old 
    $lastModifiedDate = (Get-Item "$Path\$filename").LastWriteTime

    If ($lastModifiedDate -lt $BadDate){
        Write-Output "Uh oh, Group policy made an oopsie..Fixing that now"
        Remove-Item $Path\$filename -Force
        Gpupdate /force 
    } 
    
    Else {
    Write-Output "Group Policy is all set and was last updated on '$lastmodifiedDate'"
    }
}


#Update Group Policy to pull new registry.pol
#gpupdate /force 
