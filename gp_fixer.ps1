# Automagically rebuild group policy 
# 4/30/2024 
# Mike Harris
# Needs some fiddling still

$Date = Get-Date
$BadDate = $Date.AddDays(-30)

$MachinePath = "C:\Windows\System32\GroupPolicy\Machine"
$UserPath = "C:\Windows\System32\GroupPolicy\User"
$filename = "registry.pol"

#Test if registry.pol file exists in machinePolicyPath
$Exists0 = Test-Path -Path $MachinePath\$filename

If ($Exists0 -eq 'True') {
    #Test if file is > X amount of days old 
    $lastModifiedDate = (Get-Item "$MachinePath\$filename").LastWriteTime

    If ($lastModifiedDate -lt $BadDate){
        Write-Output "Uh oh, Group policy made an oopsie..Fixing that now"
        Remove-Item $MachinePath\$filename -Force
        Gpupdate /force 
    } 
    
    Else {
    Write-Output "Group Policy is all set and was last updated on '$lastmodifiedDate'"
    }
}

#Verifies User registry.pol 
$Exists1 = Test-Path -Path $UserPath\$filename

If ($Exists1 -eq 'True') {
    #Test if file is > X amount of days old 
    $lastModifiedDate = (Get-Item "$UserPath\$filename").LastWriteTime

    If ($lastModifiedDate -lt $BadDate){
        Write-Output "Uh oh, Group policy made an oopsie..Fixing that now"
        Remove-Item $UserPath\$filename -Force
        Gpupdate /force 
    } 
    
    Else {
    Write-Output "Group Policy is all set and was last updated on '$lastmodifiedDate'"
    }
}
