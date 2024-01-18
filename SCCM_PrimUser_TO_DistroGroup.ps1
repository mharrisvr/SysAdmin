#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
# Last updated: 1/5/2024
# Updated by: Mike Harris 
#

# Site configuration -> Fill in with your own
$SiteCode = "XXX" # Site code 
$ProviderMachineName = "XXX" # SMS Provider machine name 

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
    } | Export-CSV -Path "$env:Temp\LogFile.csv" -Append -NoTypeInformation
}

#======================#
#   Wireshark Users    #
#======================#

$CollectionID = XXX
$GUID = XXX

$CollectionMembers = Get-CMDevice -CollectionId $CollectionID | Select -Property Name, username, primaryuser

#Finds the AD Group
$Group = Get-ADGroup -Filter "ObjectGUID -eq $GUID"

#Get list of users in group
$groupmembers = Get-ADGroupMember $Group | Select-Object name, samaccountname

Write-Output "`nAttempting to add new members to Wireshark Users`n" -Verbose
Write-Log -Message "`n" -Severity Information
Write-Log -Message "Attempting to add new members to Wireshark Users" -Severity Information
Write-Log -Message "`n" -Severity Information 

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
        Write-Log -Message "Please Review: $CollectionMember.Name was not added to group" -Severity Information
        } 
}

#***Still working out the logic for this piece here***
#IF no longer in SCCM Collection, remove from AD Group
    If ($CollectionMembers -contains $primaryUser) {
        Write-Output "Cleaning up existing AD Group since $primaryUser is no longer in SCCM Collection" 
        Write-Log -Message "$primaryUser is no longer in SCCM collection and has been removed from $Group"
        Remove-ADGroupMember -Identity $Group -Members $primaryuser -Verbose -Confirm:$false
    }
