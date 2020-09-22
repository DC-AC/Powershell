
#StartDemoVM

$RGName = "BitsDemos"
$VM = "SQL1"

$v=get-AzVM -ResourceGroupName $RGName -VMName $VM 

$vms=((Get-AzVM -ResourceGroupName $rgName -VMName $vm -Status).Statuses[1]).Code
 

$vdisks=$v.StorageProfile.DataDisks

foreach ($vdisk in $vdisks)
{
    $d=Get-AzDisk -DiskName $vdisk.Name
   
    if ($d.sku.tier -eq "standard")
    {
        $storageType = 'Premium_LRS'   
        $d.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
        $d | Update-AzDisk
    }
}


if ($vms -ne 'PowerState/running')
{start-AzVM -ResourceGroupName $RGName -Name $VM}
