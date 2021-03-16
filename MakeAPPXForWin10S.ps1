<#

.SYNOPSIS
MakeAPPXForWin10S

.DESCRIPTION
Takes an APPX or BUNDLE file, repackages and signs it using the Store test certificate.
There is only one parameter which is the full path to a .APPX or .APPXBUNDLE file

.EXAMPLE
Use a full path to an .APPX file:
MakeAPPXForWin10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"

.EXAMPLE
Use a local path to an .APPX file:
MakeAPPXForWin10S.cmd "MyLocalfolderAPPXFile.appx"

.EXAMPLE
Use a full path to an .APPXBUNDLE file:
MakeAPPXForWin10S.cmd "MyLocalfolderAPPXBUNDLEFile.appxbundle"

.NOTES
The signed Appx/Bundle file name will be 'InitialFileNameStoreSigned.appx' or 'InitialFileNameStoreSigned.appxbundle' in the same folder as the original file

.LINK
https://github.com/sbovo/DesktopBridgeTools/tree/develop/RepackageForWindows10S

#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true, HelpMessage="Full path to the .APPX or .APPXBUNDLE file")]
    [AllowEmptyString()]
    [string]$AppxOrBundleFile,

    [parameter(Mandatory=$false)]
    [alias("wack")]
    [switch]$RunWack,

    [parameter(Mandatory=$false)]
    [alias("sideload")]
    [switch]$SideloadApp,

    [parameter(Mandatory=$false)]
    [alias("sendresults")]
    [switch]$EmailResults,

    [parameter(Mandatory=$false)]
    [alias("vmtest")]
    [switch]$teston10S
)

$ModifiedAppxBundleFile = ""
$AppxPathOnly = ""
#$doWork=$true
$AppxOrBundleFilenameWithoutExtension = ""
$AppIdentityName=""
$FileExtension = ""
$WackResultsFilename = ""
$username = $env:USERNAME  + "@microsoft.com"

# Functions
function ModifyManifestFile ($ManifestFile) {
    Add-Type -A 'System.Xml.Linq'
    try {
        $doc = [System.Xml.Linq.XDocument]::Load($ManifestFile)
    }
    catch {
        Write-Host "[Error] Not able to open '$ManifestFile'" -ForegroundColor Red
        $telemetryException = New-Object "Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry"  
        $telemetryException.Exception = $_.Exception  
        $client.TrackException($telemetryException)  
        exit
    }

# Get Identity Name
    foreach($element in $doc.Descendants())
    {
        if($element.Name.LocalName -eq 'Identity')
        {
            foreach($attribute in $element.Attributes())
            {
                if($attribute.Name.LocalName -eq "Name")
                {
                    $Global:AppIdentityName = $attribute.value
                }
            }
        }
    }

    $AppxManifestModified = $false
    foreach($element in $doc.Descendants())
    {
        if($element.Name.LocalName -eq 'Identity')
        {
            foreach($attribute in $element.Attributes())
            {
                if($attribute.Name.LocalName -eq "Publisher")
                {
                    $attribute.value='CN=Appx Test Root Agency Ex'
                    $AppxManifestModified = $true
                    Write-Host "Done" -ForegroundColor Yellow
                    break
                }
            }
        }
    }
   
    if ($AppxManifestModified)
    {
        try {
             $doc.Save($AppxManifestFile);
        }
        catch {
            Write-Host "[Error] Not able to save back '$AppxManifestFile'" -ForegroundColor Red
            exit
        }
    }
    else
    {
        Write-Host "[Error] Not able to find the Publisher attribute for the identity element in '$AppxManifestFile'" -ForegroundColor Red
        exit
    }
}


function Work($AppxOrBundleFile, $InsideAppx) {
    $FileExtension = ([System.IO.Path]::GetExtension($AppxOrBundleFile)).ToUpper()
    # 1. Creates a new unique folder for extracting the Appx/Bundle files
    $global:Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Extracting Appx/Bundle files" -PercentComplete ($Index / $Steps * 100)
    $AppxPathOnly = Split-Path -Path $AppxOrBundleFile
    if ($AppxPathOnly -eq "") # AppxOrBundleFile is located in the current directory
    {
        # AppxPathOnly = current path
        $AppxPathOnly=Split-Path $PSScriptPath
    }
    # Does not use an unique folder name. Reusing the same folder in order to allow manual modifications
    #$CurrentDateTime = Get-Date -UFormat "%Y-%m-%d-%Hh-%Mm-%Ss"
    $global:AppxOrBundleFilenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($AppxOrBundleFile)
    $UnzippedFolder =  $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension #+ "_" + $CurrentDateTime
    Write-Host "[INFO] Unzipped folder = '$UnzippedFolder'"
    Write-Host "[WORK] Extracting files from '$AppxOrBundleFile' to '$UnzippedFolder'..."

    if($FileExtension -eq '.APPX') {
        # APPX
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' unpack /p $AppxOrBundleFile /d $UnzippedFolder /o
    }
    else {
        #BUNDLE
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' unbundle /p $AppxOrBundleFile /d $UnzippedFolder /o
    }
    Write-Host "Done" -ForegroundColor Yellow
    # =============================================================================


    # 2. Modifies the 'CN' in the extracted AppxManifest.xml
    $global:Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Modifying AppxManifest.xml file" -PercentComplete ($Index / $Steps * 100)

    # So we are looking for Publisher="CN=Blabla.�&  blablabla!?; etc..."
    # or Publisher='CN=Blabla.�&  blablabla!?; etc...'
    if($FileExtension -eq '.APPX') {
        # APPX
        $AppxManifestFile = $UnzippedFolder + "\AppxManifest.xml"
        Write-Host "[WORK] Modifying the '$AppxManifestFile' to use Publisher=""CN=Appx Test Root Agency Ex""..."
        ModifyManifestFile($AppxManifestFile)    
    }
    else {
        # BUNDLE
        $AppxManifestFile = $UnzippedFolder + "\AppxMetadata\AppxBundleManifest.xml"
        Write-Host "[WORK] Modifying the '$AppxManifestFile' to use Publisher=""CN=Appx Test Root Agency Ex""..."
        ModifyManifestFile($AppxManifestFile)
        
        # All Manifest of all packages have to be modified
        Get-ChildItem $UnzippedFolder -Filter *.appx | 
        Foreach-Object {
            Work -AppxOrBundleFile $_.FullName -InsideAppx $true     
        }
    }

    # =============================================================================


    # 3. Recreates the Appx/Bundle file with the modified AppxManifest.xml
    $global:Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Repackaging the Appx/Bundle file" -PercentComplete ($Index / $Steps * 100)
    $global:ModifiedAppxBundleFile = ""
    if($FileExtension -eq '.APPX') {
        # APPX
        if ($InsideAppx) {
            $global:ModifiedAppxBundleFile = $AppxOrBundleFile
        }
        else {
            $global:ModifiedAppxBundleFile = $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension + "StoreSigned.appx"
        }
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' pack -p $ModifiedAppxBundleFile -d $UnzippedFolder -l -o
    }
    else {
        # BUNDLE
        $global:ModifiedAppxBundleFile = $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension + "StoreSigned.appxbundle"
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' bundle -p $ModifiedAppxBundleFile -d $UnzippedFolder -o
    }
    if ($InsideAppx) {
        # Deletes the temp Appx fodler
        Remove-Item $UnzippedFolder -force -Recurse
    }
    Write-Host "Done" -ForegroundColor Yellow
    # =============================================================================


    # 4. Sign the Appx/Bundle file with the AppxTestRootAgency providedby the Store team
    $global:Index += 1
    $certFile =  "$PSScriptRoot" + "\AppxTestRootAgency.pfx"    
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Signing the Appx file" -PercentComplete ($Index / $Steps * 100)
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe' sign /a /v /fd SHA256 /f $certFile $ModifiedAppxBundleFile
    Write-Host "Done" -ForegroundColor Yellow
    # =============================================================================


    Write-Host "`nNewly and signed Appx/Bundle file available at " -nonewline
    Write-Host "$ModifiedAppxBundleFile" -ForegroundColor Green

    # App packager (MakeAppx.exe) - https://msdn.microsoft.com/en-us/library/windows/desktop/hh446767(v=vs.85).aspx
    # Porting and testing your classic desktop applications on Windows 10 S with the Desktop Bridge - https://blogs.msdn.microsoft.com/appconsult/2017/06/15/porting-and-testing-your-classic-desktop-applications-on-windows-10-s-with-the-desktop-bridge/

    # Ends AppInsights telemetry
    $client.Flush()

    # ApplicationInsights documentation - https://docs.microsoft.com/en-us/azure/application-insights/application-insights-custom-operations-tracking
}
# =============================================================================


# =============================================================================
# Run Windows App Certication Tests on appx / appxbundle
function RunWackTest($AppxPathOnly, $ModifiedAppxFile)
{
    # 5. Run WACK Tests
    $global:Index += 1
    $OutputPath=$AppxPathOnly
    Write-Host "Running WACK tests on $ModifiedAppxFile" 
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Running WACK tests on $ModifiedAppxFile" -PercentComplete ($Index / $Steps * 100)
    $global:WackResultsFilename = $($OutputPath + "\" + $AppxOrBundleFilenameWithoutExtension + ".WackResults.xml")
    
    if (Test-Path $($OutputPath + "\" + $AppxOrBundleFilenameWithoutExtension + ".WackResults.xml"))
    {
        Remove-item $($OutputPath + "\" + $AppxOrBundleFilenameWithoutExtension + ".WackResults.xml")
    }
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe' reset
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe' test -appxpackagepath "$ModifiedAppxFile" -reportoutputpath $WackResultsFilename
    Write-Host WACK Completed with the following exit code: $LASTEXITCODE -ForegroundColor Green
    Write-Host WACK results here: $($OutputPath + "\" + $AppxOrBundleFilenameWithoutExtension + ".WackResults.xml") -ForegroundColor Green
}
# =============================================================================

function SendEmailResults
{
    $global:Index += 1
    Write-Host "Sending WACK tests on $ModifiedAppxBundleFile" 
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Sending WACK test results on $ModifiedAppxFile" -PercentComplete ($Index / $Steps * 100)
    $creds = GetCredenitals
    $subject="Windows App Certification Kit test results: " + [System.IO.Path]::GetFileName($WackResultsFilename) 
    $attachmentFilename=$WackResultsFilename
    Send-MailMessage -To "$username" -Cc "$username"  -Attachments $attachmentFilename -SmtpServer "smtp.office365.com" -Credential $creds -UseSsl $subject -Port "587" `
    -Body '<p>I tested the converted app&nbsp; with the Windows App Certification Kit and it passed all tests, except for an issue an updater EXE that requires elevated permissions and Blocked Executables. (Results attached.) There is a list of EXEs that are not supported on Windows 10S. Because of this if an app attempts to call one of the blocked EXEs it will halt the execution of the app. See here for a list of <b>Inbox components</b> that are blocked on Windows 10S: <a href="https://docs.microsoft.com/en-us/windows-hardware/drivers/install/Windows10SDriverRequirements">https://docs.microsoft.com/en-us/windows-hardware/drivers/install/Windows10SDriverRequirements</a>. The action here is to review the source of the errors and verify:<ol><li>No apps outside of the app package are being launched.<li>None of the blocked executables are being launched.</li></ol>' `
    -From "$username" -BodyAsHtml
    
}

function GetCredenitals
{
    $CredsFile = ".\credentials.txt"
    $CredsExist = Test-Path $CredsFile
    if ($CredsExist -eq $false)
    {
        Write-Host "Enter password for " + "$env:USERNAME"
        read-host -assecurestring | convertfrom-securestring | out-file  $CredsFile
    } 
    $password = Get-Content $CredsFile | ConvertTo-SecureString
    $cred = new-object -typename System.Management.Automation.PSCredential `
             -argumentlist $username, $password
    return $cred
}


function DetectFeatures
{

}

function SetupFilenameVars( $AppxOrBundleFile)
{
    $global:FileExtension = ([System.IO.Path]::GetExtension($AppxOrBundleFile)).ToUpper()
    if ($AppxOrBundleFile.Contains("StoreSigned"))
    {
        return $false
    }
    $global:AppxOrBundleFilenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($AppxOrBundleFile)
    $global:FileExtension = [System.IO.Path]::GetExtension($AppxOrBundleFile)
    
    $destFile = $AppxOrBundleFilenameWithoutExtension + "StoreSigned" + $FileExtension
    $AppxExists = Test-Path $destFile
    if ($AppxExists)
    {
        return $false
    }
    
    return $true
}

# Starting point
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

# AppInsights telemetry initialization
$str = "$PSScriptRoot" + "\DllsLocalCopies\Microsoft.ApplicationInsights.dll"  
Add-Type -Path $str
$client = New-Object Microsoft.ApplicationInsights.TelemetryClient  
$client.InstrumentationKey="22708eb2-9a6b-4b7f-a0a2-e67b7b5c0b03"
$client.TrackPageView("MakeAPPXForWin10S") 

if ($AppxOrBundleFile -eq '') {
    Write-Host "[Error] A .APPX or .APPXBUNDLE file was not specified." -ForegroundColor Red
    Write-Host "Please use 'get-help .\MakeAPPXForWin10S.ps1' for more details" 
    exit 
}

$FileExtension = ([System.IO.Path]::GetExtension($AppxOrBundleFile)).ToUpper()
if ($FileExtension -ne '.APPX' -and $FileExtension -ne '.APPXBUNDLE') {
    Write-Host "[Error] '$AppxOrBundleFile' is not either a .APPX or a .APPXBUNDLE file." -ForegroundColor Red
    Write-Host "Please use 'get-help .\MakeAPPXForWin10S.ps1' for more details" 
    exit 
}

$AppxExists = Test-Path $AppxOrBundleFile
if ($AppxExists -eq $false)
{
    Write-Host "[Error] '$AppxOrBundleFile' file was not found" -ForegroundColor Red
    exit
}

$global:AppxPathOnly = Split-Path -Path $AppxOrBundleFile

$Index = 0
$Steps = 4

if ($RunWack)
{
    $Steps += 1
    if ($EmailResults)
    {
        $Steps += 1
    }    

} 

if ($SideloadApp)
{
    $Steps += 1
} 

$continue = SetupFilenameVars -AppxOrBundleFile $AppxOrBundleFile

if ($continue -eq $false)
{
    exit
}

Work -AppxOrBundleFile $AppxOrBundleFile -InsideAppx $false 

if ($SideloadApp)
{
    $global:Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Installing App" -PercentComplete ($Index / $Steps * 100)
    Remove-AppxPackage $AppIdentityName
    Add-AppxPackage -Path $ModifiedAppxBundleFile
}

if ($RunWack)
{
    RunWackTest $AppxPathOnly $ModifiedAppxBundleFile
    if ($EmailResults)
    {
        
        SendEmailResults
    }
} 

if ($teston10S)
{
#Start VM
Start-vm -name "w10 1703"
Get-vm "w10 1703" | Checkpoint-VM -SnapshotName "Start"
Get-VM "w10 1703" | Get-VMIntegrationService -Name "Guest Service Interface" | Enable-VMIntegrationService -Passthru
# Copy to VM
Copy-VMFile "W10 1703" -SourcePath c:\users\mikefra\desktop\centtools\desktopbridgeappx\ReasoningMindAppStoreSigned.appx  -DestinationPath C:\desktopbridgeappx -FileSource Host

} 
