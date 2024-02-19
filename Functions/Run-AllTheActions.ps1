# Runs all of the configuration manager actions instead of having to click them all and run manually 

function Run-AllTheActions {
<#
.SYNOPSIS
Runs all the configuration Manager actions 

.OUTPUTS
Runs the config mgr actions, and outputs it running 

.EXAMPLE
 *** Application Manager Policy Action ***


__GENUS          : 1
__CLASS          : __PARAMETERS
__SUPERCLASS     :
__DYNASTY        : __PARAMETERS
__RELPATH        : __PARAMETERS
__PROPERTY_COUNT : 1
__DERIVATION     : {}
__SERVER         : Computername
__NAMESPACE      : ROOT\ccm
__PATH           : \\ComputerName\ROOT\ccm:__PARAMETERS
ReturnValue      :
PSComputerName   : Computername
#>

$codes = @('000000000121', '000000000003', '000000000010', '000000000001', '000000000021', '000000000002', '000000000031', '000000000114', '000000000113', '000000000032')
$names = @('Application Manager Policy Action', 'Data Discovery Record', 'File Collection', 'Hardware Inventory', 'Machine Policy Assignments Request', 'Software Inventory', 'Software Metering Generating Usage Report', 'Update Store Policy', 'Scan by Update Source', 'Source Update Message')
$i = 0

# Run each of the config mgr actions using each of the codes listed above.
foreach ($num in $codes)
{
	Write-Output " *** $($names[$i]) *** "
	Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule "{00000000-0000-0000-0000-$num}"
	$i++
}

}
