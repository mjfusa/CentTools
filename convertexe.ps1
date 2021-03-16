Write-Host $args[0]
$file1 = $args[0] + ".exe"
$appid =  "abc." + $args[0] 
$pdn=$args[0]
Write-Host $installpath
DesktopAppConverter.exe  -Installer $file1 `
						-Destination ".\Output" -AppId $appid `
						-PackageName $pdn -PackageDisplayName $pdn `
						-InstallerArguments '/S' `
						-AppDisplayName $args[0] -Publisher 'CN=76F03FF0-6FBC-4475-8F1A-617EA571XXXX' `
						-PackagePublisherDisplayName  "Contoso Consulting"  -Version "1.0.0.0" -MakeAppx  -verbose
