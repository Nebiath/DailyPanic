<# VM_ParavirtualSCSI_Config.ps1
.Synopsis
   Changes SCSI driver of a given VM or VM list to ParaVirtual.
.DESCRIPTION
   PowerShell script to modify the SCSI ParaVirtual Controller. It will shutdown the VM twice for the change to be conducted.
   Take into account this KB https://kb.vmware.com/s/article/2015181
   Also checks if the advanced setting disk.enableUUID is set to true in the VM and sets if needed.
.EXAMPLE
   .\Paravirtual_Controller_Change.ps1
.INPUTS
   A file with the VMs name must be included inn a given location.
.NOTES
   VMtools need to be installed ands running in the VMs to be modifies for the script to work as intended.
   Also, the user needs to be connected to the vcenter where the VMs are located with an account with enough privileges.
   Version: 1.3
   Author: Carlos Urgel
   Creation date: 26/04/2019
.FUNCTIONALITY

#>

$WarningPreference = 'SilentlyContinue'
# Asking for OS Credentials
$localCreds = Get-Credential -Message "Please enter credentials to access the VM Operating System"

# Defined variables
# VM list to be modified. One name per line. It's a good idea to separate the VMs by vcenter.
$vmName = Get-Content "C:\Webs\VMs.txt"

Start-Transcript -Path "C:\Webs\Transcript.txt" -Append

foreach($VM in $vmName) {

  Write-Host (get-date -uformat %I:%M:%S) "Processing virtual machine:" $VM -ForegroundColor Green

  # VM Shutdown
  Write-Host `t(get-date -uformat %I:%M:%S) "Shutting down virtual machine" -ForegroundColor Green
  shutdown-vmguest -vm $VM -Confirm:$false | Out-Null
  do {start-sleep -s 3;$powerstate = get-vm $VM | % {$_.PowerState}} while ($powerstate -ne "PoweredOff")

  # Add the new disk on Paravirtual Adapter Type
  Write-Host `t(get-date -uformat %I:%M:%S) "Adding temporary hard drive on paravirtual SCSI controller" -ForegroundColor Green
  Get-VM $VM | New-HardDisk -CapacityKB 1048 -StorageFormat Thin | New-ScsiController -Type paravirtual | Out-Null

  # Waiting a bit to start the VM because reasons...
  Start-Sleep -s 10

  # VM start and wait a bit for the drivers to be installed
  Write-Host `t(get-date -uformat %I:%M:%S) "Starting virtual machine..." -ForegroundColor Green
  start-vm -vm $VM -Confirm:$false | Out-Null
  do {start-sleep -s 3;$vmwaretools = get-vm $VM | % {get-view $_.ID} | % {$_.Guest.ToolsRunningStatus}} while ($vmwaretools -eq "guestToolsNotRunning")

  Start-Sleep -s 10

  # Second VM Shutdown
  Write-Host `t(get-date -uformat %I:%M:%S) "Shutting down virtual machine..." -ForegroundColor Green
  shutdown-vmguest -vm $VM -Confirm:$false | Out-Null
  do {start-sleep -s 3;$powerstate = get-vm $VM | % {$_.PowerState}} while ($powerstate -ne "PoweredOff")

  # VM disk reconfiguration
  Write-Host `t(get-date -uformat %I:%M:%S) "Removing temporary hard drive from virtual machine" -ForegroundColor Green
  Get-HardDisk -vm $VM | Where {$_.CapacityKB -eq 1048} | Remove-HardDisk -DeletePermanently -Confirm:$False | Out-Null
  Write-Host `t(get-date -uformat %I:%M:%S) "Changing Primary SCSI controller to paravirtual" -ForegroundColor Green
  Get-HardDisk -vm $VM | Select -First 1 | Get-ScsiController | Set-ScsiController -Type paravirtual | Out-Null

  # Waiting a bit to start the VM because reasons, again...
  Start-Sleep -s 10
  Write-Host `t(get-date -uformat %I:%M:%S) "Starting virtual machine" -ForegroundColor Green
  start-vm -vm $VM -Confirm:$false | Out-Null

  # Changing the advanced setting disk.enableUUID
  Write-Host `t(get-date -uformat %I:%M:%S) "Checking if disk.enableUUID is set to TRUE" -ForegroundColor Green
  if((get-vm $VM | Get-AdvancedSetting -Name disk.enableUUID).Value -ne "true"){
	   Get-VM $VM | New-AdvancedSetting -Name "disk.enableUUID" -Value "true" -Confirm:$false | Out-Null
	    Write-Host `t(get-date -uformat %I:%M:%S) "Changing disk.enableUUID to TRUE" -ForegroundColor Green
    }
    else {
	     Write-Host `t(get-date -uformat %I:%M:%S) "Disk.enableUUID already set to TRUE - Nothing to do" -ForegroundColor Green
     }

     Start-Sleep -s 10

     # Online disks with PVSCSI resolving the online policy
     Write-Host `t(get-date -uformat %I:%M:%S) "Bringing the disks online" -ForegroundColor Green
     Invoke-VMScript -vm $VM -GuestCredential $localCreds -ScriptText 'get-disk | where OperationalStatus -eq "Offline" | %{$_.Number ; Set-Disk -Number $_.Number -IsOffline $false; Set-Disk -Number $_.Number -IsReadOnly $false}' -Verbose:$false | Write-Verbose

     Write-Host (get-date -uformat %I:%M:%S) "Processing completed! Please review change log above." -ForegroundColor Green
}
