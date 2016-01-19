<#
.SYNOPSIS
   Shutdown and delete VMs
.DESCRIPTION
   This PowerCLI script checks if a list of given VMs are running, power them down if they are
   and proceed to delete them from disk.
   
#>

$VMs = (Get-Content "C:\temp\VM.txt")
$vmObj = Get-vm $vms
 
foreach($active in $vmObj){
if($active.PowerState -eq "PoweredOn"){
Stop-VM -VM $active -Confirm:$false -RunAsync | Out-Null} 
}
Start-Sleep -Seconds 7
 
foreach($delete in $vmObj){
Remove-VM -VM $delete -DeleteFromDisk -Confirm:$false -RunAsync | Out-Null}
