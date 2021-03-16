Write-Host $args[0]
$file1 = $args[0] + ".cmd"
$appid =  "abc." + $args[0] 
$pdn=$args[0]
Write-Host $installpath
DesktopAppConverter.exe -PackageArch x64 -Installer $file1 `
						-Destination ".\Output" -AppId $appid `
						-PackageName $pdn -PackageDisplayName $pdn `
						-AppDisplayName $args[0] -Publisher 'CN=76F03FF0-6FBC-4475-8F1A-617EA571XXXX' `
						-PackagePublisherDisplayName  "Contoso Consulting"  -Version "1.0.0.0" -Sign -MakeAppx  -verbose
