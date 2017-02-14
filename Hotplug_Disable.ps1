<#
.SYNOPSIS
   Massive Hotplugadd disable for VMs in a cluster
.DESCRIPTION
   Script to disable the HotAdd/HotPlug capability in ESXi 5.x and ESXi/ESX 4.x virtual machines
   to comply with this KB http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1012225
   Can be reused to change any other value in a given VM.
#>
# General variable definition
$key = "devices.hotplug"
$value = "false"

$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
$vmConfigSpec.extraconfig[0].Key=$key
$vmConfigSpec.extraconfig[0].Value=$value

$Allvms = Get-Cluster DMZ-HAM-TEST | Get-VM

# VMs power down

Foreach ($VM in $Allvms) {

	$VM | Shutdown-VMGuest -Confirm:$false | Out-Null

}

#Hotplug add disable

Foreach ($VM in $Allvms) { 

	$VM | Get-View | %{$_.ReconfigVM($vmConfigSpec)}

}

Start-Sleep -Seconds 10

# VMs power back on

Foreach ($VM in $Allvms) {

	$VM | Start-VM -Confirm:$false -RunAsync| Out-Null

}
