<#
.SYNOPSIS
   Change ESXi NTP server in batch
.DESCRIPTION
   This PowerCLI script changes the value of the NTP server in a group of ESXi
   It takes the data from a TXT file. 
#>

## Connect to vCenter
$vcenter = 'IP_Vcenter'
Write-Host "Connecting to $vcenter" -ForegroundColor Green
Connect-VIServer $vcenter | Out-Null

$ESXi = Get-Content C:\temp\ESXI.txt

Foreach ($esxname in $ESXi) {

    ## Se elimina el servidor NTP actual

    Remove-VmHostNtpServer -NtpServer 14.10.65.10, 217.10.94.16 -VMHost $esxname –confirm 

    ## Se instroduce la IP del nuevo servidor NTP

    Add-VmHostNtpServer -NtpServer 160.118.44.133, 160.118.44.134 -VMHost $esxname

    ## Se produce el reinicio de servicio NTP

    Get-VMHostService $esxname | where { $_.Key -eq “ntpd” } | Restart-VMHostService

}
