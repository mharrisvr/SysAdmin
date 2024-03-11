function Get-MembersOfMultipleGroups
<#
.SYNOPSIS
Gets AD-users that are members of two specified AD groups

.DESCRIPTION
Read above.. I just wanted to be able to do this without opening AD 

.PARAMETER Group1
First AD Group to search for

.PARAMETER Group2
First AD Group to search for

.OUTPUTS
Returns list of all ADusers who are in both groups. 

.EXAMPLE
#>
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $FirstGroup,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$SecondGroup 
    )

    $Group1 = Get-ADGroup -Filter 'Name -like $FirstGroup' | Select-Object -ExpandProperty DistinguishedName
    $Group2 = Get-ADGroup -Filter 'Name -like $SecondGroup' | Select-Object -ExpandProperty DistinguishedName
    Try {Get-ADUser -Filter "(MemberOf -eq '$Group1') -and (MemberOf -eq '$Group2')" | Select name } Catch {$null}

}
