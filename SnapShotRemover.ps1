######################################
# REMOVE SNAPSHOTS OLDER THAN x DAYS 
######################################

$SMTPServer=""
$LogFilePath = "Snapshot.log"
$OlderThanDays=2
$vCenterServer="vcenter.fqdn.local"

cls

# Checks for PowerCLI CmdLets

$VMwareLoaded = $(Get-PSSnapin | ? {$_.Name -like “*VMware*”} ) -ne $null

If ($VMwareLoaded) { }

Else
{
	Write-host “Loading PowerCLI …” -ForeGroundColor Red
	Add-PSSnapin -Name “VMware.VimAutomation.Core” | Out-Null
}

# Connect vCenter Server
Write-host “Connecting vCenter …” -ForeGroundColor Yellow

Connect-VIserver -server $vCenterServer | Out-Null


$Snapshots= Get-VM | Get-Snapshot | ? {$_.created -lt (Get-Date).AddDays(-$OlderThanDays)} | Select vm,name,description, created, sizegb 

if ($Snapshots -eq $Null) 

{
	write-host "No Snapshots Found.." -ForeGroundColor Green
	$Snapshots = "No Snapshots..."	
 }

else 

{

$i=0
ForEach ($S in $Snapshots)
{
	Write-Host "Removing Snapshot " $s.Name  " created on "  $s.Created " for "  $s.vm
	Write-Progress -Activity "Removing Snapshots" -status "Removing $i/$Snapshots.Count" -percentComplete ($i / $Snapshots.Count*100)	
	Get-Snapshot -VM $S.vm | ? {$_.Name -eq $S.Name}| Remove-Snapshot -Confirm:$false
	$i++
	}
} 
$DateOfReport =  Get-Date

# Write Log
$FinalOutput = "Snapshot Reporting on $DateOfReport " 
Add-Content $LogFilePath "$FinalOutput `n"
Add-Content $LogFilePath $Snapshots

 
Disconnect-VIServer $vCenterServer -Confirm:$false | out-null

# Send email

#$subject = ""
#$emailbody = ""
#$emailbody = $Snapshots
#$mailer = New-Object Net.Mail.SMTPclient($SMTPServer)
#$msg = New-Object Net.Mail.MailMessage($from, $to, $subject, $emailbody)
#$msg.IsBodyHTML = $true
#$mailer.send($msg)
 
