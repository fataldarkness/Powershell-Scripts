# Build function to check firewall status

Function Get-FirewallState {
	[CmdletBinding()]	
	$ErrorActionPreference = "Stop"
    Try {
        $FirewallBlock = {
		    $content = netsh advfirewall show allprofiles

		    # Checking Domain Profile
		    if ($domprofile = $content | Select-String 'Domain Profile' -Context 2 | Out-String) { 
		    	$domainpro = ($domprofile.Substring($domprofile.Length - 9)).Trim()
		    }
		    else { 
		    	$domainpro = $null 
		    }

		    # Checking Private Profile
		    if ($priprofile = $content | Select-String 'Private Profile' -Context 2 | Out-String) { 
		    	$privatepro = ($priprofile.Substring($priprofile.Length - 9)).Trim()
		    }
		    else { 
		    	$privatepro = $null 
		    }

		    # Checking Public Profile
		    if ($pubprofile = $content | Select-String 'Public Profile' -Context 2 | Out-String) { 
		    	$publicpro = ($pubprofile.Substring($pubprofile.Length - 9)).Trim()
		    }
		    else { 
		    	$publicpro = $null 
		    }
		
			# Build an object with the results
		    $FirewallObject = New-Object PSObject
		    Add-Member -inputObject $FirewallObject -memberType NoteProperty -name "FirewallDomain" -value $domainpro
		    Add-Member -inputObject $FirewallObject -memberType NoteProperty -name "FirewallPrivate" -value $privatepro
		    Add-Member -inputObject $FirewallObject -memberType NoteProperty -name "FirewallPublic" -value $publicpro
    		$FirewallObject
    	}
     
    Invoke-Command -computerName localhost -command $FirewallBlock | Select-Object FirewallDomain, FirewallPrivate, FirewallPublic
 
    }
    Catch {
       Write-Host  ($_.Exception.Message -split ' For')[0] -ForegroundColor Red
    }
}

# Build funtion to turn on firewall profiles that are currently off
function Set-FirewallOn {
	Try {
	    $fwstatus = get-firewallstate

	    #Turn on Domain firewall profile
	    if ($fwstatus.FirewallDomain -eq "OFF") {
	      netsh advfirewall set Domain state on
	    }

	    #Turn on Public firewall profile
	    if ($fwstatus.FirewallPublic -eq "OFF") {
	        netsh advfirewall set Public state on
	    }

	    #Turn on Private firewall profile
	    if ($fwstatus.FirewallPrivate -eq "OFF") {
	        netsh advfirewall set Private state on
	    }
	}
	Catch {
	    Write-Host  ($_.Exception.Message -split ' For')[0] -ForegroundColor Red
	}

}

#Call the main function

Set-FirewallOn 