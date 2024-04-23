# ActivClient install causes issues with yubikey and cisco anyconnect VPN requiring machine cert.
# Purpose is to determien if certificate exists on yubikey or not and take action pending that. 
# Last modified 4/23/2024
# All write-hosts commented out, only used for troubleshooting 
# ActivClient install switches: https://docs.hidglobal.com/activid-activclient-v7.4.1/activid-activclient/customize-deploy-ac/activclient-setup-cust-option.htm

#Certutil check if logon cert exists 

#Finds certificates by Serial Number (Not good enough alone.. since each cert will have a different S/N BUT non-cert yubikeys will NOT have S/N)
$SCSerials = certutil -scinfo -silent | Where{$_ -match 'Serial Number: (\S+)'} | ForEach {$Matches[1]}

If ($SCSerials -eq $null) { 
    #Write-Host "Hello World, your certifcate is empty"
	  #Write-Host "Disabling PIV Device" 
    $instanceID = get-pnpdevice -InstanceID "USB\VID_1050&PID_0407&MI_02\*" -Status OK | Disable-PnpDevice -Confirm:$false	
}

Else {
    Write-Host "Certificate detected moving on to install ActivClient"
}

#Install activClient 8.2 

#For SCCM Deployment
#Write-Host "Installing ActivClient 8.2" 
msiexec.exe  /i "C:\ActivClient 8.2 install\ActivClient-8.2.0.msi" /q REBOOT=ReallySupress


