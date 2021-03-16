$appid =  "App"
$appexe = $args[0]
$res=$appexe.split("\\")
Write-Host $res[2]
$pdn=$args[0]
DesktopAppConverter.exe  -Installer  "setup\"  `
						-Destination "Output" -AppId "$appid" `
						-PackageName "Package" -PackageDisplayName "$pdn" `
						-AppExecutable $res[2] `
						-AppDisplayName "$res[0]" -Publisher 'CN=76F03FF0-6FBC-4475-8F1A-617EA571XXXX' `
						-MakeAppx  -verbose -PackagePublisherDisplayName  "Contoso Consulting"  -Version "1.0.0.0" 
