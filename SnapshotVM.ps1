<#
.SYNOPSIS
 Create Snapshot of VMs
.DESCRIPTION
 This PowerCLI script creates a snapshot of a given list of VMs. 
 It also adds a customizable descripction and name with the date.
 The list should be formatted as following:
 
 VM1
 VM2
 VM3
 VM4
 ... 
#>
## Connect to vCenter
$vcenter = 'VCENTER_IP'
Write-Host "Connecting to $vcenter" -ForegroundColor Green
Connect-VIServer $vcenter | Out-Null
$vmlist = Get-Content C:\Path\To\Serverlist.txt
$date = Get-Date -format g
foreach($VM in $VMlist) {
 New-Snapshot -VM $vm -Name "Snapshot requested $date" -description "Add information here" -RunAsync
}
