<#
.SYNOPSIS
   Display Datastore Cluster of VMs
.DESCRIPTION
   This PowerCLI script creates a list with the Datastore Cluster name in which
   are placed of a given list of VMs. 
   
   The list should be formatted as following:
   
   VM1
   VM2
   VM3
   VM4
   ... 
#>

## Connect to vCenter
$vcenter = 'vcenter.ip.adress'

$txt = Get-Content C:\Path\To\File\Serverlist.txt

$report = @()
Foreach ($entry in $txt) {
    $vm = Get-VM $entry 
    $dsc = $vm | Get-DatastoreCluster

    $line = '' | select vmname,dscluster
    $line.vmname = $vm.name
    $line.dscluster = $dsc.name
    $report += $line
}
$report
