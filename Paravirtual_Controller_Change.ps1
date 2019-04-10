<# VM_ParavirtualSCSI_Config.ps1
.Synopsis
   Changes SCSI driver of a given VM or VM list to ParaVirtual.
.DESCRIPTION
   PowerShell script to modify the SCSI ParaVirtual Controller. It will shutdown the VM twice for the change to be conducted.
   Take into account this KB https://kb.vmware.com/s/article/2015181
   Also checks if the advanced setting disk.enableUUID is set to true in the VM and sets if needed.
.EXAMPLE
   .\Paravirtual_Controller_Change.ps1 User Password
.INPUTS
   A username and password for the gust VM's OS must be provided. Also, a file with the VMs name must be included.
.NOTES
   VMtools need to be installed ands running in the VMs to be modifies for the script to work as intended.
.FUNCTIONALITY

#>

[CmdletBinding()]

param (
  [Parameter(Position = 0, Mandatory, HelpMessage = "Please provide a username for connecting to the VMs OS.")]
  [ValidateNotNullorEmpty()]
	[string]$User,

	[Parameter(Position = 1, Mandatory, HelpMessage = "Please provide a password for connecting to the VMs OS.")]
  [ValidateNotNullorEmpty()]
  [string]$Password

)

$WarningPreference = 'SilentlyContinue'

# Defined variables
$vmName = Get-Content "C:\Path_To_File\VMs.txt"

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
Write-Host `t(get-date -uformat %I:%M:%S) "Starting virtual machine..." -ForegroundColor Green
start-vm -vm $vmName -Confirm:$false | Out-Null
do {start-sleep -s 3;$vmwaretools = get-vm $vmName | % {get-view $_.ID} | % {$_.Guest.ToolsRunningStatus}} while ($vmwaretools -eq "guestToolsNotRunning")

Start-Sleep -s 20

# Second VM Shutdown
Write-Host `t(get-date -uformat %I:%M:%S) "Shutting down virtual machine..." -ForegroundColor Green
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

# Changing the advanced setting disk.enableUUID
Write-Host `t(get-date -uformat %I:%M:%S) "Checking if disk.enableUUID is set to TRUE" -ForegroundColor Green
if((get-vm $vmName | Get-AdvancedSetting -Name disk.enableUUID).Value -ne "true"){
	Get-VM $vmName | New-AdvancedSetting -Name "disk.enableUUID" -Value "true" -Confirm:$false | Out-Null
	Write-Host `t(get-date -uformat %I:%M:%S) "Changing disk.enableUUID to TRUE" -ForegroundColor Green
}
else {
	Write-Host `t(get-date -uformat %I:%M:%S) "Disk.enableUUID already set to TRUE - Nothing to do" -ForegroundColor Green
}

Start-Sleep -s 40

# Online disks with PVSCSI resolving the online policy
Write-Host `t(get-date -uformat %I:%M:%S) "Bringing the disks online" -ForegroundColor Green
Invoke-VMScript -VM $vmName -GuestUser $User -GuestPassword $Password -ScriptText 'get-disk | where OperationalStatus -eq "Offline" | %{$_.Number ; Set-Disk -Number $_.Number -IsOffline $false; Set-Disk -Number $_.Number -IsReadOnly $false}' -Verbose:$false | Write-Verbose

Write-Host (get-date -uformat %I:%M:%S) "Processing completed! Please review change log above." -ForegroundColor Green
