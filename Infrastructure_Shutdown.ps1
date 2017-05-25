<#
.SYNOPSIS
   ESX infrastructure shutdown
.DESCRIPTION
   This PowerCLI script connects to a given list of ESXi hosts and shutdowns VMs and physical hosts
   It takes the data from a TXT file.
   ESXi are put in maintenance mode before shutdown.   
#>

$esxlist = Get-Content C:\Path\To\ESXlist.txt

## Connect to ESXi

foreach($ESX in $esxlist) {

    Connect-VIServer $ESX  | Out-Null

    Write-Host "====================================================================" -ForegroundColor Green

    Write-Host "Apagando VMs en $ESX"  -ForegroundColor Green

    Get-VM | Where-Object {$_.powerstate -eq ‘PoweredOn’} | Shutdown-VMGuest -Confirm:$false

    sleep 20

    Write-Host "====================================================================" -ForegroundColor Green

    Write-Host "Apagado de VMs completado. Apagando ESXi $ESX"  -ForegroundColor Green

    Set-VMhost -VMhost $ESX -State Maintenance

    Sleep 20

    $ESX | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}

    Write-Host "====================================================================" -ForegroundColor Green

    Write-Host "Apagado de ESXi completado!"  -ForegroundColor Green

    Disconnect-VIServer $ESX -Confirm:$false

}
