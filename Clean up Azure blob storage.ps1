##########################################################################################
#- Author: John Morehouse
# Date: July 2019
# B: https://sqlrus.com
# W: https://dcac.com
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY 
# AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
# IN OTHER WORDS: USE AT YOUR OWN RISK.
#
# AUTHOR ASSUMES ZERO LIABILITY OR RESPONSIBILITY.
#
##########################################################################################
#Import-Module -Name AzureRM

$SAS = ""
$storageaccountname = ""

#forcing TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

#set cleanup time to 31 days (in hours). The will ensure files are deleted well after 30 days
$CleanupTime = [DateTime]::UtcNow.AddHours(-744)

#get a list of blobs that need to be trashed
$context = New-AzureStorageContext -StorageAccountName $storageaccountname -SasToken $SAS
$x = Get-AzureStorageBlob -Container "sqlbackups-container" -Context $context | Where-Object { $_.LastModified.UtcDateTime -lt $CleanupTime} # | Remove-AzureStorageBlob

# do the dirty work
$x | Remove-AzureStorageBlob