$esxlist = Get-Content C:\Path\To\ESXlist.txt

foreach($ESX in $esxlist) {

Connect-VIServer $ESX  | Out-Null

Get-VM | Get-NetworkAdapter | Where-Object {$_.MacAddress -eq "00:0c:29:b1:e1:ed"} | Format-List -Property *

Disconnect-VIServer $ESX -confirm:$false

}
