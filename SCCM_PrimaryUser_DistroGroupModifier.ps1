#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
# Last updated: 2-5-2024
# Updated by: Mike Harris 
# Working as of 2-5-24 but likely not final form. 
#

#Needs to be replaced with your own info
# Site configuration
$SiteCode = "XXX" # Site code 
$ProviderMachineName = "my.domain.com" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#Sync SCCM Collections to AD Security Groups

#Modules
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
    } | Export-CSV -Path "$env:Temp\GroupPopulatorLogFile.csv" -Append -NoTypeInformation
}

#Groups for personal notes (In order of Collection ID), Notepad++, Wireshark, etc

$Collections = @('1','2','3','4','5')
$GUIDs = @('1','2','3','4','5')

#CleanUp functionality.. will re-write into only removing users that no longer are in SCCM collection eventually.. but this is pretty quick to run. 
<#
# Still needed**Clean up functionality

for ($i = 0; $i -lt $GUIDs.Count; $i++)
{
    $Group = Get-ADGroup -Filter "ObjectGUID -eq '$($GUIDs[$i])'"
    $GroupMembers = Get-ADGroupMember -Identity $Group -Recursive
    $Count = $GroupMembers.Count
    Remove-ADGroupMember -Identity $Group -Members $GroupMembers -ErrorAction SilentlyContinue -Verbose -Confirm:$false
    Write-Log -Severity Information -Message "$Count members have been removed from $Group"  
}

$j = 0

Foreach ($Col in $Collections) {

    #Working Variables

    $CollectionMembers = Get-CMDevice -CollectionId $Col | Select -Property Name, username, primaryuser

    #Finds the AD Group
    $Group = Get-ADGroup -Filter "ObjectGUID -eq '$($GUIDs[$j])'"
    $groupname = $Group.Name

    #Get list of users in group
    $groupmembers = Get-ADGroupMember $Group | Select-Object name, samaccountname

    Write-Output "`nAttempting to add new members to $Groupname" -Verbose 
    Write-Log -Message "`nAttempting to add new members to '$Groupname'`n" -Severity Information
    

    foreach ($CollectionMember in $CollectionMembers) {
    
        #modifies the primary user (Splits the DCS\username.. and only uses the username[1])
        $primaryUser = ($CollectionMember.primaryuser -split '\\')[1] 

        #Determine if user is in AD #-and (Description -notlike 'Admin Account') 
        $User = $(try {Get-ADUser -Filter "(Samaccountname -like '$primaryUser') -and (Description -notlike '*Admin*')"} catch {$null})
        If ($User -ne $null) {
        
            #Determine if already in group
            If ($groupmembers.samaccountname -contains $primaryUser) {    
                Write-Log "$user is already in group, and was not added" -Severity Information
            }
             #If not in Group.. add to group
             Else {
                Add-ADGroupMember -Identity $Group -Members $User
                Write-Log -Message "$primaryUser has been added to the $Group" -Severity Information
                }
            }

         Else {
            Write-Log -Message "Please Review: $CollectionMember.Name was not added to group" -Severity Warning
            }   
    }
    $i++
}
