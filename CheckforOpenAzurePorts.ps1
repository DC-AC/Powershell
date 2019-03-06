$path = "c:\temp\openports.txt"

#log into Azure Account if needed
IF (-NOT (get-azcontext)){
    Login-AzAccount
}

#get all of the subs
$subs = get-azsubscription
foreach($sub in $subs){
    set-azcontext -SubscriptionID $sub.ID
    $nsgs = Get-AzNetworkSecurityGroup 
        foreach($nsg in $nsgs){
            $nsg | get-aznetworksecurityruleconfig | where-object -FilterScript {$_.sourceaddressprefix -eq "*" -and $_.Access -eq "Allow"} | out-file -FilePath $path -Append
    }
}

#open the file
invoke-item $path
