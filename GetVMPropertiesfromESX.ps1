

#check for VMWare module
if (!(get-module -ListAvailable -name VMWare.PowerCLI)){
    write-host "VMWare cmdlets Not found.  Installing...."
    install-module -name VMWare.PowerCLI -AllowClobber
}

#check for VMWare module
if (!(get-module -ListAvailable -name ImportExcel)){
    write-host "ImportExcel cmdlets Not found.  Installing...."
    install-module -name ImportExcel -AllowClobber
}

#get credentials safely
$pass = get-credential
$srvName = "VCenter Server Name Goes Here"

# If you get a invalid certificate error you can bypass it via the cmd below
#Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

#connet to the vcenter server
connect-viserver -server $srvName -credential $pass

$hostname = @("vmhostname1","vmhostname2")

#get sysinfo on the hosts
foreach ($vmwarehost in $hostname){
    get-vmhost -Name $vmwarehost | Export-excel -worksheetname "VMWare Hosts" -path c:\temp\VMWareConfig.xlsx -Append 
}

#get all of the vm's thatwe are interested in. In this case those that reside on a particular host(s).
$vms = get-vm | ? {$_.VMHost.tostring() -in $hostname}

#start to the stuff we want
#Note:  the ImportExcel module is needed:  install-module -name ImportExcel
foreach ($vm in $vms){
    #get VM properties
    $vm | select * | Export-excel -worksheetname "Virtual Machines" -path c:\temp\VMWareConfig.xlsx -Append 
    
    #get SCSI Controller Informtaion
    $vm | Get-scsicontroller | export-excel -worksheetname "SCSI Controllers" -path c:\temp\VMWareConfig.xlsx -Append

    #get harddisk info
    get-harddisk -VM $vm | export-excel -worksheetname "Hard Disk" -path C:\temp\VMWareConfig.xlsx -Append
}

