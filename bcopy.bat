rem @echo off
for /f "tokens=*" %%a in (copy.txt) do (
copyFSU %%a
)
pause