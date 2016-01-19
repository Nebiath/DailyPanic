<#
.SYNOPSIS
   Get datastores da
.DESCRIPTION
   This PowerCLI script takes input from a list of datastores in the cluster and outputs some data
   of the VMs inside it. Specifically: VM Name, Powerstate, Provisioned and used size (In GB) 
  
  This output is saved to a CSV file.
#>

## Connect to vCenter
$vcenter = 'IP_Vcenter'
Write-Host "Connecting to $vcenter" -ForegroundColor Green
Connect-VIServer $vcenter | Out-Null

$ds_str = Get-Content C:\temp\Datastores.txt

$dss = Get-Datastore -name $ds_str
$report  = @()
foreach ($ds in $dss) {
    $vms = $ds | get-vm
    foreach ($vm in $vms) {
        $line = '' | select datastore,name,powerstate,provisionedspacegb,usedspacegb
        $line.datastore = $ds.name
        $line.name = $vm.name
        $line.powerstate = $vm.powerstate
        $line.provisionedspacegb = $vm.provisionedspacegb
        $line.usedspacegb = $vm.usedspacegb

        $report += $line
    }
}

$report | Export-Csv C:\Users\carlos.urgel.adm\Desktop\Datastores.csv
