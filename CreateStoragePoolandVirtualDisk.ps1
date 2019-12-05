$PhysicalDisks = (Get-PhysicalDisk -CanPool $True)

New-StoragePool -FriendlyName pool01 -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks -ResiliencySettingNameDefault Simple -ProvisioningTypeDefault Fixed -Verbose

$disks = Get-StoragePool –FriendlyName pool01 -IsPrimordial $false | Get-PhysicalDisk

#this sets column name equal to the number of disks. Adjust accordingly. 

New-VirtualDisk -StoragePoolFriendlyName pool01 -FriendlyName "vdisk01" -NumberOfColumns $disks.Count -Interleave 65536 -UseMaximumSize

#Note--the formatting part of this had been failing for me, and I've been executing volume creation manually

Get-VirtualDisk –FriendlyName vdisk01 | Get-Disk | Initialize-Disk –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume –AllocationUnitSize 65536
