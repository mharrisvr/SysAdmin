# Wrote these two functions to enable and disable drain mode of an Azure Virtual desktop machine 
# Just copied from my local profile
# Plans are to update so they can take multiple machines in input

function Set-DrainModeEnabled {
	param(
            [Parameter(Mandatory=$true,
                HelpMessage = 'Enter the AVD Machine you want to drain'    
            )]
            $ComputerName,
	    [Parameter(Mandatory=$true,
                HelpMessage = 'Enter the Host pool'    
            )]	        
            [ValidateSet("HP1", "HP2", "HP3", "etc")] #Update with your own host pools 
            $HostPool
        )
	
	$params = @{
   	ResourceGroupName = 'VDI-RG'
    	HostPoolName = $HostPool
    	Name = $ComputerName
    	AllowNewSession = $False
	}

	$DrainStatus = Update-AzWvdSessionHost @params
	$DrainStatus | Select Name, Status, SystemDataLastModifiedBy, UpdateState
}

function Set-DrainModeDisabled {
	param(
            [Parameter(Mandatory=$true,
                HelpMessage = 'Enter the AVD Machine you want to drain'    
            )]
            $ComputerName,
	    [Parameter(Mandatory=$true,
                HelpMessage = 'Enter the Host pool'    
            )]	        
            [ValidateSet("HP1", "HP2", "HP3", "etc")] #Update with your own host pools 
            $HostPool
        )
	
	$params = @{
   	ResourceGroupName = 'VDI-RG'
    	HostPoolName = $HostPool
    	Name = $ComputerName
    	AllowNewSession = $True
	}

	Update-AzWvdSessionHost @params
}
