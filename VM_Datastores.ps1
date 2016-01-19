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
