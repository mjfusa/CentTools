rem Run WACK 
set P=%PATH%
set PATH=%PATH%;"C:\Program Files (x86)\Windows Kits\10\App Certification Kit"
if exist %1 forfiles /m %1 /c ^"cmd /c ^
echo Starting WACK test for @file ^&^
appcert.exe reset ^&^
appcert.exe test -appxpackagepath @path -reportoutputpath """%CD%\WackResults.xml"""^"
set PATH=P
set P=
