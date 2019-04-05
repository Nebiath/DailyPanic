<#
.SYNOPSIS
   Migrate VM from vcenter to vcenter
.DESCRIPTION
   This PowerCLI script helps with the batch migration of the VMs from one vcenter to another one, deleting the
   NIC from the VM and storage vmotioning them to a shared datastore, unregistering them
   It takes the data from a TXT file.
#>

$VMList = Get-Content D:\Webs\VMs.txt

Foreach ($VM in $VMList) {

# Network card deletion

Get-NetworkAdapter $VM | where { $_.NetworkName -eq "VLAN_NUM" } | Remove-NetworkAdapter -Confirm:$false

Get-NetworkAdapter $VM | where { $_.NetworkName -eq "VLAN_NUM" } | Remove-NetworkAdapter -Confirm:$false

Get-NetworkAdapter $VM | where { $_.NetworkName -eq "VLAN_NUM" } | Remove-NetworkAdapter -Confirm:$false

# Storage vmotioning

Move-VM -VM $VM -Destination ESXi_FQDN -Datastore Datastore_Name -RunAsync

# vcenter unregister

Remove-VM -VM $VM -DeleteFromDisk:$false -Confirm:$false -RunAsync

}


# Second part of the script creates the NICs in the VMs and moves them to the given datastore cluster

$VMList = Get-Content C:\Users\curgel\Desktop\Lista_VM.txt
$myDatastoreCluster1 = Get-DatastoreCluster -Name 'Datastore_Name'

Foreach ($VM in $VMList) {

New-NetworkAdapter -VM $VM -Type Vmxnet3 -NetworkName VLAN_NUM -StartConnected:$true -Confirm:$false

New-NetworkAdapter -VM $VM -Type Vmxnet3 -NetworkName VLAN_NUM -StartConnected:$true -Confirm:$false

New-NetworkAdapter -VM $VM -Type Vmxnet3 -NetworkName VLAN_NUM -StartConnected:$true -Confirm:$false

Move-VM -VM $VM -Datastore $myDatastoreCluster1 -RunAsync

}
