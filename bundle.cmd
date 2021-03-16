:copyfiles
cd %1\PackageLayout
md bundle
xcopy /q *.appx bundle
cd bundle
del out.appxbundle
makeappx bundle /d . /p out.appxbundle
copy *.appxbundle ..
cd ..

