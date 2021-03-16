REM Create priconfig.xml
cd %1
:makeconfig
cd PackageLayout
if exist priconfig.xml del priconfig.xml
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.15063.0\x64\makepri.exe" createconfig /cf priconfig.xml /dq en-US
cd ..

REM Create pri file(s) based on priconfig.xml created above
:makepri
cd PackageLayout
if exist resource*.pri del resource*.pri
"C:\Program Files (x86)\Windows Kits\10\bin\10.0.15063.0\x64\makepri.exe" new /pv 10.0.0 /pr . /cf .\priconfig.xml
del .\priconfig.xml
cd ..

:end
cd ..
