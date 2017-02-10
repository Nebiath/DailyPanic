
<#
.SYNOPSIS
   Change VM Memory in batch
.DESCRIPTION
   This PowerCLI script changes the memory of a list of given VMs.
   It takes the data from a TXT file.
   VMs are powered down before and booted up after the change.
   
#>

## Connect to vCenter
$vcenter = 'IP_Vcenter'
Write-Host "Connecting to $vcenter" -ForegroundColor Green
Connect-VIServer $vcenter | Out-Null

# Get requested VMs
$vms = Get-VM (Get-Content "C:\temp\VM.txt") 


	foreach ($vm in $vms) {

# Shutdown and wait some time
Shutdown-VMGuest -VM $vm -Confirm:$false
}

sleep 120

# For each VM, perform proper actions
foreach ($vm in $vms) {

# Change VM config
Set-VM -VM $vm -memoryMB ($vm.memoryMB + 8192) -Confirm:$false
}

sleep 120

foreach ($vm in $vms) {

# Start VM
Start-VM -VM $vm -Confirm:$false
}
