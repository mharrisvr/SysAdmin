#
# Re-add TierISupport
# Last Modified: 5/7/2024
# REQUIRES being on VPN or in office. 
# Group required to be able to remote connect over SCCM. 
#

$Group = "ConfigMgr Remote Control Users"
$Member = "<Insert Your Required Group Name Here>"

$ConfigMgrUsers = Get-localgroupmember -Group $Group | Select name

If ($ConfigMgrUsers -match "$Member") {
   # Group exists - do nothing 
  # Write-Host "`n$Member is already in $Group"
}

Else {
    Add-LocalGroupMember -Group “$Group” -Member “$Member”
  #  Write-Host "$Member was not present but has been added to $Group" 
}
