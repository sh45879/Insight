
$pass = 
$user = 
$ftp = 



#run dts export for file based inventory
$dtsargs = "/file", "\\dcms1ms\dccm\reports\Insight\SH_FileBased-SCCM-Inventory.dtsx"
$dts = start-process dtexec -argumentlist $dtsargs -wait -nonewwindow -passthru




#rename files to add datestamp

$filePath = "\\dcms1ms\dccm\reports\insight"

get-childitem $filepath -filter *.csv | foreach-object {
  
  write-host $_.fullname
  
  $newfilename = 
  rename-item $_.fullname -newname $($_.basename + '_' + $(get-date -format 'yyyy_MM_dd') + $_.extension)
}




#Set the credentials
$Password = ConvertTo-SecureString '$pass' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ('$user', $Password)

#Set local file path, SFTP path, and the backup location path which I assume is an SMB path
$SftpPath = '/'

#Set the IP of the SFTP server
$SftpIp = '$ftp'

#Establish the SFTP connection
New-SFTPSession -ComputerName $SftpIp -Credential $Credential



#Upload the file to the SFTP path
get-childitem $filepath -filter *.csv | foreach-object {

	Set-SFTPFile -SessionId 0 -LocalFile $_.fullname -RemotePath $SftpPath

}

#Disconnect SFTP session
(Get-SFTPSession -SessionId 0).Disconnect()


#Move files to transferred location
get-childitem $filepath -filter *.csv | foreach-object { move-item -path $_.fullname -destination $($filepath + "\Transferred\" + $_.basename + $_.extension) }
