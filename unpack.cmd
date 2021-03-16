rem @echo off
SETLOCAL ENABLEEXTENSIONS
SET CURRENT_DIR=%~dp0
SET CURRENT_DIR=%CURRENT_DIR:~0,-1%
SET OSGSHARE=\\redmond\osg\Teams\CORE\DEP\Centennial\Packages
SET WACKPATH="C:\Program Files (x86)\Windows Kits\10\App Certification Kit"
SET PATH=%WACKPATH%;%PATH%
rem cd %1 
if "%1"=="" goto veryend
rem if NOT "%2"=="" goto %2


:unpack
if exist .\PackageLayout\ goto register
rem forfiles /m *.appx /c 		"cmd /c makeappx unpack /v /l /p @file /d .\PackageLayout"
forfiles /m *.msix /c 		"cmd /c makeappx unpack /v /l /p @file /d .\PackageLayout"
rem forfiles /m *.appxbundle /c 	"cmd /c makeappx unbundle /p @file /d .\Bundle & cd Bundle & ..\..\unpack.cmd . unpack"
rem if exist %1\*.appx forfiles /p %1 /m *.appx /c 		"cmd /c %CURRENT_DIR%\MakeAPPXForWin10S.cmd @PATH %2 %3 %4"
rem if exist %1\*.msix forfiles /p %1 /m *.msix /c 		"cmd /c %CURRENT_DIR%\MakeAPPXForWin10S.cmd @PATH %2 %3 %4"
rem if exist %1\*.appxbundle forfiles /p %1 /m *.appxbundle /c 	"cmd /c %CURRENT_DIR%\MakeAPPXForWin10S.cmd @PATH %2 %3 %4"
goto end

:register
if exist ..\..\regapp.ps1 powershell ..\..\regapp.ps1
if exist ..\regapp.ps1 powershell ..\regapp.ps1
if NOT "%2"=="" goto end

:test
rem Run WACK 
if exist *.appx forfiles /m *.appxbundle /c ^"cmd /c ^
echo Starting WACK test for @file ^&^
appcert.exe reset ^&^
appcert.exe test -appxpackagepath @path -reportoutputpath %CD%\WackResults.xml^"

if exist *.appxbundle forfiles /m *.appxbundle /c ^"cmd /c ^
echo Starting WACK test for @file ^&^
appcert.exe reset ^&^
appcert.exe test -appxpackagepath @path -reportoutputpath %CD%\WackResults.xml^"

if NOT "%2"=="" goto end

:copyresults
for %%a in (.appx .appxbundle) do forfiles /m *%%a /c "cmd /c if not exist %osgshare%\@FNAME\ md %osgshare%\@FNAME"
forfiles /m *.appxbundle /c "cmd /c  copy @FILE %osgshare%\@FNAME"
forfiles /m *.appx /c "cmd /c  copy @FILE %osgshare%\@FNAME"
forfiles /m *.appx /c "cmd /c  copy *.X?L %osgshare%\@FNAME"
forfiles /m *.appx /c "cmd /c  copy *.png %osgshare%\@FNAME"

forfiles /m *.appxbundle /c "cmd /c  copy @FILE %osgshare%\@FNAME"
forfiles /m *.appxbundle /c "cmd /c  copy *.X?L %osgshare%\@FNAME"
forfiles /m *.appxbundle /c "cmd /c  copy *.png %osgshare%\@FNAME"

:end
cd ..
:veryend


