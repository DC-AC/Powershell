
#StopDemoVM

$RGName = "BitsDemos"
$VM = "SQL1"

$v=get-AzVM -ResourceGroupName $RGName -VMName $VM 

$vms=((Get-AzVM -ResourceGroupName $rgName -VMName $vm -Status).Statuses[1]).Code
 
 if ($vms -eq 'PowerState/running')
{stop-AzVM -ResourceGroupName $RGName -Name $VM}

$vdisks=$v.StorageProfile.DataDisks

foreach ($vdisk in $vdisks)
{
    $d=Get-AzDisk -DiskName $vdisk.Name
   
    if ($d.sku.tier -eq "premium")
    {
        $storageType = 'Standard_LRS'   
        $d.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
        $d | Update-AzDisk
    }
}
