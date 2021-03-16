rem @echo off
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0
cd %1 
if "%1"=="" goto veryend

:extractmanifest
cd PackageLayout
cmd /c "scriptcs ..\..\GetAppExeName.csx"
cd ..	
goto end

:end
cd ..
:veryend


