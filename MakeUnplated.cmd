cd %1\PackageLayout\Assets

for %%F in (44.png, 50.png, 150.png) do (
if not exist %%~nF.targetsize-%%~nF.png copy %%F %%~nF.targetsize-%%~nF.png
if not exist %%~nF.targetsize-%%~nF_altform-unplated.png copy %%F %%~nF.targetsize-%%~nF_altform-unplated.png
)

cd ..\..\..

:makeconfig
cd %1
cd PackageLayout
if exist priconfig.xml del priconfig.xml
makepri createconfig /cf priconfig.xml /dq en-US
cd ..\..

:makepri
cd %1
cd PackageLayout
if exist resources.pri del resources.pri
makepri new /pr . /cf .\priconfig.xml
cd ..

cd ..

