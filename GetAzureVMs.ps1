write-output "Gathering Data from Azure API"
$regions=(Get-AzLocation|where-object {$_.RegionType -eq 'physical'}).location 

foreach ($region in $regions)
{

#Demo this--to show Azure geolcations and region    
$VMs = Get-AzComputeResourceSku -Location $region | Where-Object { $_.ResourceType -eq 'virtualmachines’ }
 
$Results = foreach ($VM in $VMs) {
 
    [pscustomobject]@{
        Name     = $vm.name
        CPU      = ($Vm.Capabilities  | Where-Object { $_.Name -eq 'vCPUS' }).value
        MemoryGB = ($vm.Capabilities | Where-Object { $_.Name -eq 'MemoryGB' }).value
        IOPS     = ($vm.Capabilities | Where-Object { $_.Name -eq 'UncachedDiskIOPs' }).value
        MaxNICS  = ($vm.Capabilities | Where-Object { $_.Name -eq 'MaxNetworkInterfaces' }).value
        MaxDisks = ($vm.Capabilities | Where-Object { $_.Name -eq 'MaxDataDiskCount' }).value
        AcceleratedNetworking = ($vm.Capabilities | Where-Object { $_.Name -eq 'AcceleratedNetworkingEnabled' }).value
        EphemeralOSDiskSupported = ($vm.Capabilities | Where-Object { $_.Name -eq 'EphemeralOSDiskSupported' }).value
        Region = $Region
    }
 
}
$results=$results|convertto-json

$Context=new-AzStorageContext -storageaccountname $storageaccountname -useConnectedAccount
$container=Get-AzStorageContainer -Name $ContainerName -Context $context

 
$content = [system.Text.Encoding]::UTF8.GetBytes($Results)
$container.CloudBlobContainer.GetBlockBlobReference("my$region.json").UploadFromByteArray($content,0,$content.Length)

write-output "$Region processing is completed"

}
