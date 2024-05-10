# Group policy repair
# Last updated 5/9/2024 
# Mike Harris
# For SCCM Deployment Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process 

Start-Transcript -Path "C:\Windows\CCM\Logs\gpfixer.log" -Verbose

Function Run-AllTheActions {
$codes = @('000000000121', '000000000003', '000000000010', '000000000001', '000000000021', '000000000002', '000000000031', '000000000114', '000000000113', '000000000032')
$names = @('Application Manager Policy Action', 'Data Discovery Record', 'File Collection', 'Hardware Inventory', 'Machine Policy Assignments Request', 'Software Inventory', 'Software Metering Generating Usage Report', 'Update Store Policy', 'Scan by Update Source', 'Source Update Message')
$i = 0
    foreach ($num in $codes)
    {
	    Write-Output " *** $($names[$i]) *** "
	    Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule "{00000000-0000-0000-0000-$num}"
	    $i++
    }
}

#Get all installed updates.. for log file. 
Write-Host "`nChecking installed updates... " 
Get-HotFix | Sort -Property InstalledOn -Descending

# Verify TierISupport Group for SCCM Remote Control 
Try {
    $Group = "ConfigMgr Remote Control Users"
    $Member = "TierISupport"
    $ConfigMgrUsers = Get-localgroupmember -Group $Group | Select name

    If ($ConfigMgrUsers -match "$Member") {
       # Group exists - do nothing 
       Write-Host "`n$Member is already in $Group"
    }
    Else {
        Add-LocalGroupMember -Group “$Group” -Member “$Member”
        Write-Host "$Member was not present but has been added to $Group" 
    }
}

Catch {
    Write-Host "Error with TierISupport Group" 
}

Try {
    #First thought... old reg.pol indicated bad registry.. BUT apparently not the case. 
    $Date = Get-Date
    $BadDate = $Date.AddDays(-30)
    Write-Output "`nTesting Machine Policy.. Please wait"
    #Test if registry.pol file exists in machinePolicyPath
    $MachinePath = "C:\Windows\System32\GroupPolicy\Machine\"
    $Filename = "registry.pol"
    $Exists0 = Test-Path -Path "$MachinePath\$filename"

    If ($Exists0 -eq 'True') {
        #Test if file is > X amount of days old 
        $lastModifiedDate = (Get-Item "$MachinePath\$Filename").LastWriteTime

        If ($lastModifiedDate -lt $BadDate){
            Write-Output "Uh oh, Group policy made an oopsie..Fixing that now"
            Remove-Item $MachinePath\$filename -Force
        } 
    
        Else {
        Write-Output "`Group Policy was last updated on '$lastmodifiedDate'.. but recreating anyways`n"
        Remove-Item $MachinePath\$filename -Force
        }
    }
}

Catch {
    Write-Host "Error with Registry.Pol file" 
}

# Delete Secedit.sdb file if out of date 
Try {
    $ExistsSecDB = Test-Path -Path "C:\WINDOWS\security\Database\secedit.sdb"

    If ($ExistsSecDB -eq 'True') {
        Remove-Item -Path $ExistsSecDB -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Secdb file deleted"
    }

    Else {
        Write-Host "File did not exist and was not deleted"
    }
}

Catch {
    Write-Host "Error with Secedit.sdb file"
}

Try {
    # Delete group policy history *if out of date
    $ExistsHistoryPath = Test-Path -Path "C:\ProgramData\Microsoft\Group Policy\History\"

    If ($ExistsHistoryPath -eq 'True') {
        Remove-Item -Path $ExistsHistoryPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "`nGroup Policy History Cleaned up`n" 
    }
    Else {
        Write-Output "Group Policy did not exist`n"
    }
}

Catch {
    Write-Host "Error with Group Policy History"
}

# Run each of the config mgr actions using each of the codes listed above.
# Required to re-create the registry.pol/secdb files 
Run-AllTheActions 

Write-Output "`nUpdating Group Policy now"
gpupdate /force

# Office updates pop up AFTER the group policy
# Run each of the config mgr actions using each of the codes listed above.
# Sleeps 5 minutes and kicks off actions again.. still might be a little short 
Sleep -Seconds 300
Run-AllTheActions

#Used for the detection method of script.. Until I figure out custom script detection method (WIll need to be updated). 
New-Item -Path $env:windir\Temp -Name "GroupPolicyRepair.txt" -ItemType "file" -Value "Group Policy repaired."
Stop-Transcript
