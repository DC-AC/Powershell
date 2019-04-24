
#get credentials safely
$pass = get-credential

#connet to the vcenter server
connect-viserver -server vcenter.domain.com -credential $pass

#get all of the vm's thatwe are interested in. In this case those that reside on a particular host(s).
$vms = get-vm | ? {$_.VMHost.tostring() -eq "host1.domain.com" -or $_.VMHost.tostring() -eq "host2.domain.com"}

#start to the stuff we want
#Note:  the ImportExcel module is needed:  install-module -name ImportExcel
foreach ($vm in $vms){
    #get VM properties
    $vm | select * | Export-excel -worksheetname "Virtual Machines" -path c:\temp\hosts.xlsx -Append 
    
    #get SCSI Controller Informtaion
    $vm | Get-scsicontroller | export-excel -worksheetname "SCSI Controllers" -path c:\temp\hosts.xlsx -Append
}

