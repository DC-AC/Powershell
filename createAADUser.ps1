Param
(
    [Parameter (Mandatory = $true)]
    [String] $Username,
    [Parameter (Mandatory = $true)]
    [String] $ClientName,
    [Parameter (Mandatory = $true)]
    [INT] $Database = 0
)

$cred=Get-AutomationPSCredential -Name 'AutomationAccount'
Connect-AzureRMAccount -Credential $cred -InformationVariable InfoVar -ErrorVariable ErrorVar
select-azurermsubscription 
Connect-AzureAD -Credential $cred

if ((get-azureadgroup -Filter "DisplayName eq '$clientName'").count -lt 1)
{
new-azureadgroup -DisplayName $ClientName -MailEnabled $false -SecurityEnabled $true `
 -Description $ClientName `
 -MailNickname $clientName
}


$Password = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join ''

$password
$user=$username+"@daas.contoso.com"

$SecureStringPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $Password

New-AzureADUser -DisplayName $Username -PasswordProfile $PasswordProfile -UserPrincipalName $User `
-AccountEnabled $true `
-MailNickname $UserName$ClientName

$GroupID=(get-azureadgroup -Filter "DisplayName eq '$clientName'").ObjectID
$UserId=(Get-AzureADUser -ObjectID $user).ObjectID

Add-AzureADGroupMember -ObjectID $GroupID -RefObjectID $UserId


$GroupID=(get-azureadgroup -SearchString "DaaSRO").ObjectID
Add-AzureADGroupMember -ObjectID $GroupID -RefObjectID $UserId
#New-AzureRmADUser -DisplayName $UserName -UserPrincipalName $username -Password $SecureStringPassword -MailNickname $ClientName



if ($Database -eq 1)

{
$adminlogin = "DBAdmin"

$pwd = (get-AzureKeyVaultSecret -vaultName "DaaSKeys" -name "daaslogin").SecretValueText
$pwd = ConvertTo-SecureString $pwd  -AsPlainText -Force

$sqlcred = New-Object System.Management.Automation.PSCredential($adminlogin,$pwd)

#TODO: SQL to be fixed with specific role. And should grant be to group or user?

$server = Connect-DbaInstance -SqlInstance 'db1.database.windows.net' -Database 'daasevalDB' -Credential $sqlcred -DisableException
Invoke-DbaQuery -SqlInstance $server -Query  "create login $UserName from external provider"
Invoke-DbaQuery -SqlInstance $server -Query "grant db_ddladmin to $UserName"

}
