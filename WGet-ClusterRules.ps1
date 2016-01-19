###############################################################################
# @date 25/03/2015
# @version 0.1.0
# @brief Shows affinity rules for specific cluster and discloses VM list and 
# 		host list (if existing)
###############################################################################

# Prompt for information
$strCluster = Read-Host -prompt "Enter the desired cluster (type * for all clusters)"
$strShowDisabled = Read-Host -prompt "Show disabled rules? (y/n)"
while (($strShowDisabled -ne "y") -and ($strShowDisabled -ne "n")) {
	$strShowDisabled = Read-Host -prompt "Show disabled rules? (y/n)"
}

# Get all Rules from Cluster
$rules =  Get-Cluster $strCluster | Get-DrsRule -Type vmhostaffinity,vmantiaffinity,vmaffinity

foreach ($rule in $rules) {
	
	if (($strShowDisabled -eq "y") -or ($rule.Enabled -eq "true")) {
		Write-Host "Rule name: " -nonewline; $rule.Name
		Write-Host "Rule type: " -nonewline; $rule.Type
		
		if ($rule.Enabled -eq "True") { Write-Host "Enabled: " -nonewline; Write-Host "$($rule.Enabled)" -foregroundcolor green -backgroundcolor blue }
		else { Write-Host "Enabled: " -nonewline; Write-Host "$($rule.Enabled)" -foregroundcolor yellow -backgroundcolor red } 

		# First we list VMAffinity and VMAntiAffinity
		if ($rule.Type -notmatch "host") {
			Write-Host "List of VMs: "
			foreach($vm in $rule.VMIDs) {Write-Host "`t" -nonewline; (Get-VM -Id $vm).Name}
		} elseif ($rule.Type -match "anti") { # Now HostAntiAffinity
			Write-Host "List of VMs: "
			foreach($vm in $rule.VMIDs) {Write-Host "`t" -nonewline; (Get-VM -Id $vm).Name}
			Write-Host "List of Hosts: "
			foreach($h in $rule.AntiAffineHostIds) {Write-Host "`t" -nonewline; (Get-VMHost -Id $h).Name}
		} else { # Finally HostAffinity
			Write-Host "List of VMs: "
			foreach($vm in $rule.VMIDs) {Write-Host "`t" -nonewline; (Get-VM -Id $vm).Name}
			Write-Host "List of Hosts: "
			foreach($h in $rule.AffineHostIds) {Write-Host "`t" -nonewline; (Get-VMHost -Id $h).Name}
		}
		Write-Host "`n"
	}
}
