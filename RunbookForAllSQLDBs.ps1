# $DebugPreference="Continue"
$connectionName = 'AzureRunAsConnection'
# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

   "Logging in to Azure..."
$RunbookSub=Connect-AzAccount `
       -ServicePrincipal `
       -TenantId $servicePrincipalConnection.TenantId `
       -ApplicationId $servicePrincipalConnection.ApplicationId `
       -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
       -SubscriptionID $SubscriptionID



$subscriptions = Get-AzSubscription -WarningAction SilentlyContinue  -tenantid $tenantID  

foreach ($subscription in $subscriptions) {
  $su=$subscription.name
 $Context=$Context=Set-AzContext -Subscription $subscription.ID
 $SQLServers = Get-AzResourceGroup | Get-AzSqlServer

foreach ($sqlserver in $sqlservers) 
    {
    $databases = Get-AzSqlDatabase -ResourceGroupName $sqlserver.ResourceGroupName   -ServerName $sqlserver.ServerName  -WarningAction SilentlyContinue | Where-Object { $_.DatabaseName -NE "master" -and $_.DatabaseName -notlike "*copy*"}
    
    foreach ($database  in $databases) 
         {#$Out = $out + "db:{0} " -f $database.DatabaseName 
          #Write-Host $out
            #Insert SQL Code or CMD
            try
            {   
                $d=$database.DatabaseName
                $s=$sqlserver.fullyqualifieddomainname
                $params = @{"Svrs"=$s;"Database"=$d;"Sub"=$su}
                #TDE Check to Wake up Serverless Databases
                Get-AzSqlDatabaseTransparentDataEncryption -ServerName $sqlserver.ServerName -ResourceGroupName $sqlserver.ResourceGroupName -DatabaseName $d
                Start-AzAutomationRunbook -AutomationAccountName "SQLAdmin" -Name "ChildIndexRunbook" –ResourceGroupName  "SQLPlayground" -Parameters $params -DefaultProfile $RunbookSub
                $params
            }
            catch
            { Write-Host "An error occurred:" Write-Host $_.Exception.Message -ErrorAction Continue}
         }
          
    }
 #Remove-AzContext -Name $Context.Name -Confirm:$false -Force
}
