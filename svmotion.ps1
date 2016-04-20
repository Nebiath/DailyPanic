<#
.SYNOPSIS
   Migrate VMs to new datastores
.DESCRIPTION
   This PowerCLI script does a storage vMotion of a given list of VMs.
   It takes the VMs name from a TXT file.
   Destination can be to a specific datastore or datastore cluster.
   
#>

## Connect to vCenter

Connect-VIServer IP_Vcenter

Get-Content C:\Path\To\Desktop\Serverlist.txt | Foreach {
    Get-VM $_ | Move-VM -Datastore "Datastore name or cluster datastore name" -RunAsync
}
