cd %1 
if "%1"=="" goto veryend
:signtest
forfiles /m *.appx /c "cmd /c ..\MakeAPPXForWin10S.cmd @FILE -wack -results"
:end
cd ..
:veryend