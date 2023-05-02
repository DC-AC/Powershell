
try
{  
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# set and store context
$Context = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
$aadToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.windows.net").AccessToken
Connect-AzureAD -AadAccessToken $aadToken -AccountId $context.Account.Id -TenantId $context.tenant.id
$AzureContext
 
write-output "Connected to Azure"

}

 Catch
 {$ErrorMessage = $_.Exception.Message
    Write-Error "Login Failure. The error message was $ErrorMessage"
 }
 
 
 # Validate Connection
 try
 {
 $dbtest=get--AzSqlDatabase -ResourceGroupName "ResourceGroup" -ServerName "DevSQLServer" -DatabaseName "uatdb"
 write-output $dbtest
 }
 
  Catch
 {$ErrorMessage = $_.Exception.Message
    Write-Error "Error getting database information. The error message was $ErrorMessage"
 }
  
  # Delete existing
 try
 { 
 remove-AzSqlDatabase -ResourceGroupName "ResourceGroup" -ServerName "DevSQLServer" -DatabaseName "uatdb"
 }
 
   Catch
 {$ErrorMessage = $_.Exception.Message
    Write-Error "Error deleting database. The error message was $ErrorMessage"
 }
 
 
 try
 {
 $databaseCopy = New-AzSqlDatabaseCopy -CopyDatabaseName "proddb" -CopyResourceGroupName "ResourceGroup" -CopyServerName "DevSQLServer" -DatabaseName "proddb" -ResourceGroupName "ResourceGroup" -ServerName "ProdSQLServer" -ElasticPoolName "elasticpool"
 }
 
catch
{
$ErrorMessage = $_.Exception.Message
    Write-Error "Error creating copy of database. The error message was $ErrorMessage"
}

 
