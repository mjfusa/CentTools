Param(
   [string]$vmname ="w10s",
   [string]$VMUserName ="DESKTOP-PBAMDH1\mjf",
   [string]$AppxFullName ="C:\users\mikefra\Desktop\CentTools\DesktopBridgeAPPX\packageStoreSigned.appx"

) 

function GetCredenitals
{
    $CredsFile = ".\RemoteVMcredentials.txt"
    $CredsExist = Test-Path $CredsFile
    if ($CredsExist -eq $false)
    {
        Write-Host ("Enter password for " + $VMUserName)
        read-host -assecurestring | convertfrom-securestring | out-file  $CredsFile
    } 
    $password = Get-Content $CredsFile | ConvertTo-SecureString
    $cred = new-object -typename System.Management.Automation.PSCredential `
             -argumentlist $VMUserName, $password
    return $cred
}


Get-VM $vmname | Get-VMSnapshot -Name 'Baseline' | Restore-VMSnapshot -Confirm:$false
Start-vm -name $vmname
Get-VM $vmname | Get-VMIntegrationService -Name "Guest Service Interface" | Enable-VMIntegrationService -Passthru
$AppXName = [System.IO.Path]::GetFileName($AppxFullName)

Start-Sleep -s 120
Copy-VMFile $vmname -SourcePath $AppxFullName  -DestinationPath C:\desktopbridgeappx -CreateFullPath -FileSource Host -Force


# Add remote VM to Trusted Host List
winrm s winrm/config/client '@{TrustedHosts="DESKTOP-PBAMDH1.mshome.net"}'
Exit

#Start remote session - retry loop
$Stoploop = $false
[int]$Retrycount = "0"
$creds = GetCredenitals
do {
	try {
#        $Error.Clear()    	
        Enter-PSSession -ComputerName DESKTOP-PBAMDH1.mshome.net -Credential $creds
#        if ($Error[0].Exception.HResult -eq 0)
#    	{
            $Stoploop = $true
#		}
    }
	catch {
		if ($Retrycount -gt 3){
			Write-Host "Could not send Information after 3 retrys."
			$Stoploop = $true
		}
		else {
			Write-Host "Could not send Information retrying in 30 seconds..."
			Start-Sleep -Seconds 30
			$Retrycount = $Retrycount + 1
		}
	}
}
While ($Stoploop -eq $false)

if ($RetryCount -eq 3)
{
    Write-Host "Could not connect to VM. Exiting."
    Exit
}


#Install APPX
Add-AppxPackage ("c:\desktopbridgeappx\" + $AppXName)
#Run App
$var=Get-AppxPackage -Name *Package* |  % {  $_.PackageFamilyName} #get Name from id in appxmanifest
$var= "shell:AppsFolder\" + $var + "!App" 
Start $var

#Wait 60 seconds
Start-Sleep -s 60

#Collect Event Logs
# https://docs.microsoft.com/en-us/windows-server/administration/server-manager/configure-remote-management-in-server-manager#BKMK_windows
$AppXFileNameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($AppxFullName)
Get-WinEvent -ProviderName 'Microsoft-Windows-CodeIntegrity'  -MaxEvents 10 > (c:\DesktopBridgeAppx\"+ $AppXFileNameNoExt + ".CodeIntegrityLog.txt")
Get-WinEvent -LogName 'Application' -MaxEvents 10 > (c:\DesktopBridgeAppx\"+ $AppXFileNameNoExt + ".ApplicationEventsLog.txt")
# Exit remote session
Exit-PSSession

Remove-PSDrive -Name Y
New-PSDrive -Name Y -PSProvider FileSystem -Root \\DESKTOP-PBAMDH1.mshome.net\desktopbridgeappx 
Copy-Item y:\*.txt C:\users\mikefra\Desktop\CentTools\DesktopBridgeAPPX

#Restore VM and shutdown
#Get-VM "w10 1703" | Get-VMSnapshot -Name 'Start' | Restore-VMSnapshot -Confirm:$false
#Shutdown VM
Stop-VM -name $vmname -force

