


<# borrowed code from here:
    https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Script-Sample-f7164554
#>

$Servers = @("server1","server2")

$DiskReport = ForEach ($Server in ($Servers))  
    {Get-WmiObject win32_logicaldisk `
        -ComputerName $Server -Filter "Drivetype=3" `
        -ErrorAction SilentlyContinue
}   

$DiskReport |  Select-Object @{Label = "Server Name";Expression = {$_.SystemName}}, 
        @{Label = "Drive Letter";Expression = {$_.DeviceID}}, 
        @{Label = "Drive Name";Expression = {$_.VolumeName}},
        @{Label = "Total Capacity (GB)";Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
        @{Label = "Free Space (GB)";Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) }}, 
        @{Label = 'Free Space (%)'; Expression = {"{0:P0}" -f ($_.freespace/$_.size)}} | sort-object -property "Free Space (%)" | format-table