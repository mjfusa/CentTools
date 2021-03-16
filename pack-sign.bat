cd %1
if not "%2"=="" goto %2

goto pack
:signFiles
cd PackageLayout
forfiles /s /m *.exe /c	"cmd /c Signtool.exe sign /a /v /fd SHA256 /f c:\users\mikefra\desktop\centtools\AppxTestRootAgency.pfx @file"
pause
forfiles /s /m *.dll /c	"cmd /c Signtool.exe sign /a /v /fd SHA256 /f c:\users\mikefra\desktop\centtools\AppxTestRootAgency.pfx @file"
pause
cd ..
:pack 
REM MakeAppx pack /l /d ./PackageLayout /p out.appx
MakeAppx pack /l /d ./PackageLayout /p out.appx
if errorlevel 0 goto signAppx
goto end
:signAppx
Signtool.exe sign /a /v /fd SHA256 /f ..\AppxTestRootAgency.pfx out.appx
:end
cd ..

