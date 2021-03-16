@echo off
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0
cd %1 
if "%1"=="" goto veryend
if NOT "%2"=="" goto %2


:unpack
if exist .\files\ goto GetExeName
forfiles /m *.appx /c "cmd /c makeappx unpack /v /l /p @file /d .\files"

:GetExeName
cmd /c scriptcs ..\GetAppExeName.csx

REM Create cmdline.txt and modify AppxManifest.xml
:createCommandLine
goto extractmanifest
if exist .\files\cmdline.txt goto copyfiles
scriptcs ..\search.csx
if NOT errorlevel 0 goto end

:copyfiles
if exist .\files\cwd.exe goto register
if not exist .\files\cwd.exe copy ..\inject_dll\x86\cwd.exe files
if not exist *.bak copy files\AppxManifest.xml .\*.bak
copy files\AppxManifest1.xml files\AppxManifest.xml 
del files\AppxManifest1.xml

:extractmanifest
if exist "%AppExeName%.manifest" goto register
cd files
mt.exe -inputresource:"%AppExeName%" -out:"%AppExeName%.manifest"
if not %errorlevel%==0 copy ..\..\generic.manifest "%AppExeName%.manifest"
cd ..	
goto end

:register
powershell ..\regapp.ps1

:end
cd ..
:veryend


