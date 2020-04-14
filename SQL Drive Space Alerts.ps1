
<# borrowed code from here:
    https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Script-Sample-f7164554
    https://sqlrus.com/2015/07/validating-cluster-instance-owner-with-powershell/
#>

$File = @("server1","server2", "server3", "server4")

$DiskReport = ForEach ($Servernames in ($File))  
    {Get-WmiObject win32_logicaldisk `
        -ComputerName $servernames -Filter "Drivetype=3" `
        -ErrorAction SilentlyContinue |  
        Where-Object {   ($_.freespace/$_.size) -le '0.10'} #10% free space. Adjust accordingly
}   
 
$body = $DiskReport |  
 
Select-Object @{Label = "Server Name";Expression = {$_.SystemName}}, 
@{Label = "Drive Letter";Expression = {$_.DeviceID}}, 
@{Label = "Total Capacity (GB)";Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
@{Label = "Free Space (GB)";Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) }}, 
@{Label = 'Free Space (%)'; Expression = {"{0:P0}" -f ($_.freespace/$_.size)}} | convertto-html -head $style | out-string

$messageParameters = @{                         
                Subject = "Low Disk Space Alert"                         
                Body = $body
                From = "donotreply@somedomain.org"                         
                To = "john@doe.com" 
                SmtpServer = "smtp_address_goes_here"                         
            }    

IF ($DiskReport.count -gt 0){
   Send-MailMessage @messageParameters -BodyAsHtml
}

