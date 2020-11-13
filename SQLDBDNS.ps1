
#Add DNS Alias to AzureDNS
Try {

$DNSAlias = $ServerName+".database.windows.net"
$Records = @()
$Records += New-AzDnsRecordConfig -Cname $DNSAlias
$RecordSet=New-AzDnsRecordSet -Name $ClientName  -RecordType CNAME  -ResourceGroupName "SharedResources"  -TTL 3600 -ZoneName "contoso.com" -DnsRecords $Records

$ClientName=$ClientName.ToLower()

}

Catch{$ErrorMessage = $_.Exception.Message 
       Write-Error "Creating DNS Alias for SQL. Error was $ErrorMessage"}

Try{
$serverDnsAlias=New-AzSQLServerDNSAlias -DNSAliasName $clientName -ServerName $ServerName -ResourceGroupName $RGName
$serverDnsAlias=Get-AzSQLServerDNSAlias -DNSAliasName $clientName -ServerName $ServerName -ResourceGroupName $RGName
}
Catch {$ErrorMessage = $_.Exception.Message 
       Write-Error "Associating DNS Alias with SQL DB. Error was $ErrorMessage"}
