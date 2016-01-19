<#
.SYNOPSIS
   Move VMs to folder
.DESCRIPTION
   This PowerCLI script moves a list of given VMs into its correspondent folder.
   It takes the data from a CSV file, formatted as following:
   
   VM,ROLE
   DENLB0001VC001T,App server
   DENLB9010AS055T,DB
   DENLB9010AS044R_clone,Test
   
#>

## Connect to vCenter
$vcenter = 'IP_Vcenter'
Write-Host "Connecting to $vcenter" -ForegroundColor Green
Connect-VIServer $vcenter | Out-Null

$List = Import-Csv "C:\Temp\FMOFinal.csv"

ForEach ($vm in $List) {

Get-Datacenter 'NLB' | Get-VM -Name $vm.VM | Move-VM -Destination ( Get-Folder -Name $vm.ROLE)

}
