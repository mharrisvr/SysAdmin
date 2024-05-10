#================================================================================================================================#
# GroupCleaner.ps1
# Author: Mike Harris 
# Last Modified: 2-5-2024
# Purpose: Temporary fix to empty out all of the AD Groups that are being managed here until I figure out cleaning up per user. 
#================================================================================================================================#

Import-Module ActiveDirectory

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        #[ValidateNotNullOrEmpty()]
        [string]$Message, 
        
        [Parameter()]
        #[ValidateNullOrNotEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )

    [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
        Severity = $Severity
    } | Export-CSV -Path "$env:Temp\GroupCleaner.csv" -Append -NoTypeInformation
}

#Groups for personal notes (In order of Collection ID), Notepad++, Wireshark, etc replace with your own.. but no utilized so finy to leave empty too 
$GUIDs = @('1','2','3','5','6') #Replace with your own AD-GUIDs

for ($i = 0; $i -lt $GUIDs.Count; $i++)
{
    $Group = Get-ADGroup -Filter "ObjectGUID -eq '$($GUIDs[$i])'"
    $GroupMembers = Get-ADGroupMember -Identity $Group -Recursive
    $Count = $GroupMembers.Count
    Remove-ADGroupMember -Identity $Group -Members $GroupMembers -Verbose -Confirm:$false
    Write-Log -Severity Information -Message "$Count members have been removed from $Group"
}
