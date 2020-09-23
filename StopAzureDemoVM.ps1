#stop demo vm

$x = (get-AzResourceGroup -Tag @{'Use' = 'Demo' })
$rgnames = $x.ResourceGroupName
foreach ($rgname in $rgnames) {
    $vmnames = get-AzVM -ResourceGroupName $RGName 
    foreach ($vmname in $vmnames) {
        $vms = ((Get-AzVM -ResourceGroupName $rgName -VMName $vmname.name -Status).Statuses[1]).Code
 
        if ($vms -eq 'PowerState/running')
        { stop-AzVM -ResourceGroupName $RGName -Name $VMName.name }

        $vdisks = $vmname.StorageProfile.DataDisks

        foreach ($vdisk in $vdisks) {
            $d = Get-AzDisk -DiskName $vdisk.Name
            if ($d.sku.tier -eq "premium") {
                $storageType = 'Standard_LRS'   
                $d.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
                $d | Update-AzDisk
            }
        }
    }
}
