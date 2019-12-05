#install-module az
<#

#Set connection and subscription before running

connect-azaccount

$subscriptionID=(Get-AzSubscription).SubscriptionId 

select-azsubscription $subscriptionid

#>

#If you VM already has disks allocated, set $n equal to the next disk in line

$n = 1

while ($n -lt 8 )

{
$rgName = $RGName
$vmName = $VMName
$location =  $location
$storageType = 'Premium_LRS'
$dataDiskName = $vmName + '_DataDisk_'+$n

#Configure DiskSizeGB to match the size of the disk you would like to select

$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB 8192
$dataDisk1 = New-AzDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName 
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun $n

Update-AzVM -VM $vm -ResourceGroupName $rgName

$n++

}
