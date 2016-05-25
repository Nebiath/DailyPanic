<#
.SYNOPSIS
   List VM locations
.DESCRIPTION
   This PowerCLI script takes input from a list of VMs in the vcenter and outputs specific data:
   VM Name, ESXi Host running and Datastore that have the physical files. 
  
  This output is saved to a CSV file.
#>

## Connect to vCenter
$vcenter = '14.111.17.16'
Write-Host "Connecting to $vcenter" -ForegroundColor Green
Connect-VIServer $vcenter | Out-Null


$vmlist = Get-Content C:\temp\VMlist.txt

foreach($vm in $vmlist) {
    Get-VM $vm | Select Name,VMHost,@{N="Datastore"; E={$_ | Get-Datastore}} | Export-Csv -Path  C:\temp\VMsAndHostsInfo.csv -NoTypeInformation -UseCulture
}
