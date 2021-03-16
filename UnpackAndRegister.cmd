cd %1 
if "%1"=="" goto veryend
if NOT "%2"=="" goto %2

:unpack
if exist .\PackageLayout\ goto register
forfiles /m *.appx /c 		"cmd /c makeappx unpack /v /l /p @file /d .\PackageLayout"

:register
if exist ..\..\regapp.ps1 powershell ..\..\regapp.ps1
if exist ..\regapp.ps1 powershell ..\regapp.ps1
if NOT "%2"=="" goto end


:end
cd ..
:veryend


