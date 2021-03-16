cd %1
if not "%2"=="" goto %2
:pack 
MakeAppx pack /l /d ./PackageLayout /p out.appx
if errorlevel 0 goto sign
goto end
:sign
cd PackageLayout
forfiles /s /m *.exe /c	"cmd /c Signtool.exe sign /a /v /fd SHA256 /f c:\users\mikefra\desktop\centtools\AppxTestRootAgency.pfx @file"
pause
forfiles /s /m *.dll /c	"cmd /c Signtool.exe sign /a /v /fd SHA256 /f c:\users\mikefra\desktop\centtools\AppxTestRootAgency.pfx @file"
pause
cd ..
Signtool.exe sign /a /v /fd SHA256 /f ..\AppxTestRootAgency.pfx out.appx
:end
cd ..

