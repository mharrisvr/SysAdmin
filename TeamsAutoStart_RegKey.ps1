# Registry key checker 
# Gets value of registry key related to Teams AutoStart 

$keyPath = "HKLM:\SOFTWARE\Microsoft\Teams"
$valueName = "IsWVDEnvironment"
$keyValue = Get-ItemPropertyValue -Path $keyPath -Name $valueName
Write-Host "Value of '$valueName': $keyValue"
