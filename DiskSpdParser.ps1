
$path='$InsertYourPathHere'

$Files = Get-ChildItem -Path $path

foreach ($file in $files)
{  
   $content = get-content $file

   $command= ($content)|select -first 1 -skip 1
   $results= ($content)|grep total -m1|sed 's/"|"/","/g'|sed 's/"total:"//g'
 
   $results= $results.split(",")

   $Output = New-Object -TypeName PSObject -Property @{
      FileName = $File.Name
      Command = $Command
      TotalBytes = $Results[0].Trim()
      TotalIOs = $results[1].Trim()
      MiBperSec = $results[2].Trim()
      IOPs = $results[3].Trim()
      AvgLatency = $results[4].Trim()
      LatStdDev = $results[5].Trim()}| Select-Object FileName,Command,TotalBytes, TotalIOs, MiBperSec, IOPs,AvgLatency,LatStdDev

      $Output|Export-CSV results.csv -Append
}
