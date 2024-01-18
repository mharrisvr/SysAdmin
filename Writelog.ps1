#Just saving this for later user.. it works awesome

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
