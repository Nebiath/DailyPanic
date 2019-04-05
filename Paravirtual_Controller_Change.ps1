<# VM_ParavirtualSCSI_Config.ps1
.Synopsis
   Changes SCSI driver of a given VM to ParaVirtual.
.DESCRIPTION
   PowerShell script to modify the SCSI ParaVirtual Controller. It will shutdown the VM twice for the change to be conducted.
   Take into account this KB https://kb.vmware.com/s/article/2015181
.EXAMPLE

.INPUTS

.NOTES

.FUNCTIONALITY

#>

#$vmName = Get-Content "C:\Webs\VMs.txt"

$vmName = "VM_Paravirtual_Test"

Write-Host (get-date -uformat %I:%M:%S) "Processing virtual machine:" $vmName -ForegroundColor Green

# VM Shutdown
Write-Host `t(get-date -uformat %I:%M:%S) "Shutting down virtual machine" -ForegroundColor Green
shutdown-vmguest -vm $vmName -Confirm:$false | Out-Null
do {start-sleep -s 3;$powerstate = get-vm $vmName | % {$_.PowerState}} while ($powerstate -ne "PoweredOff")

# Add the new disk on Paravirtual Adapter Type
Write-Host `t(get-date -uformat %I:%M:%S) "Adding temporary hard drive on paravirtual SCSI controller" -ForegroundColor Green
Get-VM $vmName | New-HardDisk -CapacityKB 1024 -StorageFormat Thin | New-ScsiController -Type paravirtual | Out-Null

# Waiting a bit to start the VM because reasons...
Start-Sleep -s 10

# VM start and wait a bit for the drivers to be installed
Write-Host `t(get-date -uformat %I:%M:%S) "Starting virtual machine" -ForegroundColor Green
start-vm -vm $vmName -Confirm:$false | Out-Null
do {start-sleep -s 3;$vmwaretools = get-vm $vmName | % {get-view $_.ID} | % {$_.Guest.ToolsRunningStatus}} while ($vmwaretools -eq "guestToolsNotRunning")

Start-Sleep -s 40

# Online disks with PVSCSI resolving the online policy
Write-Host `t(get-date -uformat %I:%M:%S) "Bringing the disks online" -ForegroundColor Green
Invoke-VMScript -ScriptText "$offlinedisks = get-disk | where OperationalStatus -EQ offline foreach ($disk in $offlinedisks) {Set-Disk -Number $disk.Number -IsOffline $false Set-Disk -Number $disk.Number -IsReadOnly $false}" -VM $vmName -GuestUser user - GuestPassword pass -Verbose:$false | Write-Verbose

# Second VM Shutdown
Write-Host `t(get-date -uformat %I:%M:%S) "Shutting down virtual machine" -ForegroundColor Green
shutdown-vmguest -vm $vmName -Confirm:$false | Out-Null
do {start-sleep -s 3;$powerstate = get-vm $vmName | % {$_.PowerState}} while ($powerstate -ne "PoweredOff")

# VM disk reconfiguration
Write-Host `t(get-date -uformat %I:%M:%S) "Removing temporary hard drive from virtual machine" -ForegroundColor Green
Get-HardDisk -vm $vmName | Where {$_.CapacityKB -eq 1024} | Remove-HardDisk -DeletePermanently -Confirm:$False | Out-Null
Write-Host `t(get-date -uformat %I:%M:%S) "Changing Primary SCSI controller to paravirtual" -ForegroundColor Green
Get-HardDisk -VM $vmName | Select -First 1 | Get-ScsiController | Set-ScsiController -Type paravirtual | Out-Null

# Waiting a bit to start the VM because reasons, again...
Start-Sleep -s 10
Write-Host `t(get-date -uformat %I:%M:%S) "Starting virtual machine" -ForegroundColor Green
start-vm -vm $vmName -Confirm:$false | Out-Null

Write-Host (get-date -uformat %I:%M:%S) "Processing completed! Please review change log above." -ForegroundColor Green
