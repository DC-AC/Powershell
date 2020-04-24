



#essentially the same format as the disk space report.  This will check for services down, specifically the database engine and agent.  
$servers = @("server1","server2", "server3", "server4")
$services = @("SQL Server (MSSQLSERVER)", "SQL Server Agent (MSSQLSERVER)")

$report = ForEach ($Server in ($Servers)){
             get-service -computername $Server -name $services -ErrorAction SilentlyContinue | Where-Object {($_.Status -ne 'Running')} |  Select-Object @{Label = "Server Name";Expression = {$_.MachineName}}, `
                                    @{Label = "Display Name";Expression = {$_.DisplayName}},`
                                    @{Label = "Service Name";Expression = {$_.Name}},`
                                    @{Label = "Status";Expression = {$_.Status}} 
            } 

$body = $report | convertto-html | out-string

$messageParameters = @{                         
                Subject = "Service Down"                         
                Body = $body
                From = "donotreply@somedomain.com"                         
                To = "john@doe.com" 
                SmtpServer = "smtpserver.domain.com"                         
            }    

IF ($Report.count -gt 0){
   Send-MailMessage @messageParameters -BodyAsHtml
}