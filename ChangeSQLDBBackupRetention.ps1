#You will need to have an app registration in your Azure Active Directory to get a clientID and clientSecret 
#If you haven't done that before, go here https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

# Variables
$TenantId = "" # Enter Tenant Id.
$ClientId = "" # Enter Client Id.
$ClientSecret = "" # Enter Client Secret.
$Resource = "https://management.core.windows.net/"
$SubscriptionId = ""
$RGName = "" #The Name of the resource group for you Azure SQL DB
$SQLSvr = "" #The name of your Azure SQL server
$DB = "" #The Name of your target db
$retentiondays = 1 #Number of Days to retain your database backups (minimum is 1, maxium is 35)


$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"

$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

Write-Host "Print Token" -ForegroundColor Green
Write-Output $Token


# Get Azure Resource Groups

$Headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")

$ResourceGroupApiUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups?api-version=2017-05-10"
$ResourceGroups = Invoke-RestMethod -Method Get -Uri $ResourceGroupApiUri -Headers $Headers

Write-Host "Print Resource groups" -ForegroundColor Green
Write-Output $ResourceGroups

# construct request body object
 
$requestBody = [pscustomobject]@{
    properties = [pscustomobject]@{
    retentiondays = $retentiondays
      }
    }

   $requestbody = convertto-json $requestBody

invoke-restmethod -URI https://management.azure.com/subscriptions/$subscriptionid/resourceGroups/$rgname/providers/Microsoft.Sql/servers/$SQLsvr/databases/$db/backupShortTermRetentionPolicies/default?api-version=2017-10-01-preview -method PUT -Headers $headers -Body $requestBody -ContentType application/json

