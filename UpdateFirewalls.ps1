#Created by Meagan Longoria 2 Jan 2024
#This software is provided as is without warranty of any kind

# Input bindings are passed in via param block.
Param
(
    [Parameter (Mandatory= $false)]
    [String] $storageRG = "storageRG",

    [Parameter (Mandatory= $false)]
    [String] $sqlRG = "sqlRG",

    [Parameter (Mandatory= $false)]
    [String] $storageacctname = "stgacct",

    [Parameter (Mandatory= $false)]
    [String] $sqlservername = "sqldev",

    [Parameter (Mandatory= $false)]
    [String] $region = "EastUS",

    [Parameter (Mandatory= $false)]
    [String] $subscription = "mysub"
)

Import-Module Az.Storage
Import-Module Az.Sql
Import-Module Az.Resources

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# Set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
$sub = Select-azSubscription -SubscriptionName $subscription
Write-Output "Connected to Azure"


# Download the service tags for Azure services
$last_week = (Get-Date)
while ($last_week.DayOfWeek -ne 'Monday') {
    $last_week = $last_week.AddDays(-1)
}
$last_week = $last_week.ToString("yyyyMMdd")
$url = 'https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/ServiceTags_Public_' + $last_week + '.json'
$ip_ranges = Invoke-RestMethod $url -Method 'GET'

# Filter to only ADF in specified region
$STagName = "DataFactory.${region}"
$address_prefixes = $ip_ranges.values | Where-Object {$_.name -eq $STagName} | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty addressPrefixes
$address_prefixes = $address_prefixes | Where-Object { $_ -notmatch ":" } | ForEach-Object { @{ ipAddressOrRange = $_ } }
$address_prefixes
Write-Output "Latest IP ranges acquired"

#delete storage firewall rules
$SIPs = (Get-AzStorageAccountNetworkRuleSet  -ResourceGroupName $storageRG -Name $storageacctname).IpRules.IPAddressOrRange
foreach ($IPR in $SIPs) {
    Remove-AzStorageAccountNetworkRule -ResourceGroupName $storageRG -Name $storageacctname -IPAddressOrRange $IPR
}
Write-Output "Storage firewall rules removed"

#delete sql firewall rules
$FRules = Get-AzSqlServerFirewallRule -ResourceGroupName $sqlRG -ServerName $sqlservername
foreach ($FRule in $FRules) {
    Write-Output "Removing " + $Frule.FirewallRuleName 
    Remove-AzSqlServerFirewallRule -ServerName $sqlservername -ResourceGroupName $sqlRG -FirewallRuleName $Frule.FirewallRuleName 
    }
Write-Output "SQL firewall rules removed"


$addrct = 0

foreach ($address_prefix in $address_prefixes.values) {

   # Add rule to storage account firewall

    Add-AzStorageAccountNetworkRule -ResourceGroupName $storageRG -Name $storageacctname -IPAddressOrRange $address_prefix
    
    # Add rule to sql server firewall
    $addrct = $addrct + 1
    $RuleName = "ADF Rule " + $addrct.ToString()
    
    #Convert CIDR to IPV4 start and end
    $StrNetworkAddress = ($address_prefix.split("/"))[0]
    $NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
    [Array]::Reverse($NetworkIP)
    $NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
    #Note: Do not add 1. ADF uses this base address
	$StartIP = $NetworkIP 

    #Convert To Double
    If (($StartIP.Gettype()).Name -ine "double")
    {
        $StartIP = [Convert]::ToDouble($StartIP)
    }
    $StartIP = [System.Net.IPAddress]$StartIP


    [int]$NetworkLength = ($address_prefix.split("/"))[1]
    $IPLength = 32-$NetworkLength
    $NumberOfIPs = ([System.Math]::Pow(2, $IPLength)) -1
    $NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
    [Array]::Reverse($NetworkIP)
    $NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
    $EndIP = $NetworkIP + $NumberOfIPs
    If (($EndIP.Gettype()).Name -ine "double")
    {
        $EndIP = [Convert]::ToDouble($EndIP)
    }
    $EndIP = [System.Net.IPAddress]$EndIP

    New-AzSqlServerFirewallRule -ResourceGroupName $sqlRG -ServerName $sqlservername -FirewallRuleName  $RuleName -StartIpAddress $StartIP.ToString() -EndIpAddress $EndIP.ToString()  
}

#Static IPs - UPDATE THESE 
$CorpIP = "X.X.X.X"
$CorpIP2 = "X.X.X.X"

#re-add static IP to Storage
Add-AzStorageAccountNetworkRule -ResourceGroupName $storageRG -Name $storageacctname -IPAddressOrRange $CorpIP
Add-AzStorageAccountNetworkRule -ResourceGroupName $storageRG -Name $storageacctname -IPAddressOrRange $CorpIP2

#re-add static IP to SQL
New-AzSqlServerFirewallRule -ResourceGroupName $sqlRG -ServerName $sqlservername -FirewallRuleName  "CorpIP" -StartIpAddress $CorpIP -EndIpAddress $CorpIP
New-AzSqlServerFirewallRule -ResourceGroupName $sqlRG -ServerName $sqlservername -FirewallRuleName  "CorpIP2" -StartIpAddress $CorpIP2 -EndIpAddress $CorpIP2
