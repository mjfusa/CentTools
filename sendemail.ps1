#Below is the PowerShell 4 / Office 365 CMDlet that works. 
$appName="Graphics Power"
$subject="Windows App Certificaiton Kit test results: " + $appName
$attachmentFilename= "C:\Users\mikefra\Desktop\CentTools\DesktopBridgeAPPX\DiscoveryToolAppPackaging_1.0.0.148_x64.WackResults.xml"

$secpasswd = ConvertTo-SecureString “11Thanks+time” -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential (“mikefra@microsoft.com”, $secpasswd)

Send-MailMessage -To "mikefra@microsoft.com" -Cc "mikefra@microsoft.com" -Attachments $attachmentFilename -SmtpServer "smtp.office365.com" -Credential $mycreds -UseSsl $subject -Port "587" `
-Body '<p>I tested the converted app&nbsp; with the Windows App Certification Kit and it passed all tests, except for an issue an updater EXE that requires elevated permissions and Blocked Executables. (Results attached.) There is a list of EXEs that are not supported on Windows 10S. Because of this if an app attempts to call one of the blocked EXEs it will halt the execution of the app. See here for a list of <b>Inbox components</b> that are blocked on Windows 10S: <a href="https://docs.microsoft.com/en-us/windows-hardware/drivers/install/Windows10SDriverRequirements">https://docs.microsoft.com/en-us/windows-hardware/drivers/install/Windows10SDriverRequirements</a>. The action here is to review the source of the errors and verify:<ol><li>No apps outside of the app package are being launched.<li>None of the blocked executables are being launched.</li></ol>' `
-From "mikefra@microsoft.com" -BodyAsHtml


