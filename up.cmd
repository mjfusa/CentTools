if NOT "%1"=="" goto unpack
unpack DesktopBridgeAPPX -wack -sendresults -sideload
goto end

:unpack
REM unpack %1 -wack -sendresults -sideload
unpack %1 -sideload
:end
