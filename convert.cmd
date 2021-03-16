rem @echo off
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0
SET OSGSHARE=\\redmond\osg\Teams\CORE\DEP\Centennial\Installers
cd %1 
if "%1"=="" goto veryend
if NOT "%2"=="" goto %2

:convert
cd setup
if exist .\output rd /q /s .\output
md output
if exist *.msi for %%g in (.msi) do forfiles /m *%%g /c "cmd /c powershell ..\..\convertmsi.ps1 @FNAME & copy .\output\@FNAME\*.appx .."
if exist *.exe for %%g in (.exe) do forfiles /m *%%g /c "cmd /c powershell ..\..\convertexe.ps1 @FNAME & copy .\output\@FNAME\*.appx .."
goto end

:batch
cd setup
if exist .\output rd /q /s .\output
md output
if exist *.cmd for %%g in (.cmd) do forfiles /m *%%g /c "cmd /c powershell ..\..\convertcmd.ps1 @FNAME & copy .\output\@FNAME\*.appx .."
goto end


:noinstaller
rem cd setup
if exist .\output rd /q /s .\output
md output
powershell ..\convertNoInstaller.ps1 .\setup\%1.exe & copy .\output\*.appx .."
goto end


:end
cd ..\..
:veryend


