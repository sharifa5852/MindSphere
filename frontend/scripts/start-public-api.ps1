[CmdletBinding()]
param(
    [ValidateRange(1, 65535)]
    [int]$Port = 5000
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeDir = Join-Path $projectRoot '.local'
$statePath = Join-Path $runtimeDir "public-api-$Port.json"
$cloudflared = Join-Path $runtimeDir 'cloudflared.exe'
$origin = "http://127.0.0.1:$Port"

$health = Invoke-RestMethod -Uri "$origin/api/health" -TimeoutSec 8
if ($health.success -ne $true) { throw 'Start the MindSphere backend before opening a public connection.' }
New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null

if (Test-Path -LiteralPath $statePath) {
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    $existing = Get-Process -Id $state.processId -ErrorAction SilentlyContinue
    if ($existing -and $existing.Path -eq $cloudflared) {
        try {
            $remoteHealth = Invoke-RestMethod -Uri "$($state.apiBaseUrl)/health" -TimeoutSec 10
            if ($remoteHealth.success -eq $true) {
                Write-Host 'Reusing the existing temporary HTTPS connection.'
                return $state.apiBaseUrl
            }
        } catch {
            throw 'The existing tunnel is running but unhealthy. Check the backend, internet connection, and .local tunnel logs before restarting it.'
        }
    }
}

if (-not (Test-Path -LiteralPath $cloudflared)) {
    Write-Host 'Downloading the official Cloudflare tunnel helper...'
    Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile $cloudflared -UseBasicParsing
}

$logId = [guid]::NewGuid().ToString('N')
$stdoutPath = Join-Path $runtimeDir "tunnel-$Port-$logId.stdout.log"
$stderrPath = Join-Path $runtimeDir "tunnel-$Port-$logId.stderr.log"
$tunnel = Start-Process -FilePath $cloudflared -ArgumentList @(
    'tunnel', '--url', $origin, '--no-autoupdate', '--protocol', 'http2'
) -WorkingDirectory $runtimeDir -WindowStyle Hidden -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath

$deadline = (Get-Date).AddSeconds(40)
$publicUrl = $null
while ((Get-Date) -lt $deadline) {
    $tunnel.Refresh()
    if ($tunnel.HasExited) { throw "The tunnel stopped. See $stderrPath for details." }
    if (Test-Path -LiteralPath $stderrPath) {
        $stream = [System.IO.File]::Open($stderrPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $reader = New-Object System.IO.StreamReader($stream)
        try { $logText = $reader.ReadToEnd() } finally { $reader.Dispose() }
        $match = [regex]::Match($logText, 'https://[a-z0-9-]+\.trycloudflare\.com')
        if ($match.Success) { $publicUrl = $match.Value; break }
    }
    Start-Sleep -Milliseconds 500
}
if (-not $publicUrl) { throw "The tunnel did not provide a URL. See $stderrPath." }

$apiBaseUrl = "$publicUrl/api"
# Record the process before checking DNS so a slow DNS update cannot orphan it.
@{
    processId = $tunnel.Id
    apiBaseUrl = $apiBaseUrl
    origin = $origin
    createdAt = [DateTime]::UtcNow.ToString('o')
    logPath = $stderrPath
} | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8

$connected = $false
$healthDeadline = (Get-Date).AddSeconds(60)
while ((Get-Date) -lt $healthDeadline) {
    try {
        $remoteHealth = Invoke-RestMethod -Uri "$apiBaseUrl/health" -TimeoutSec 8
        if ($remoteHealth.success -eq $true) { $connected = $true; break }
    } catch { Start-Sleep -Seconds 2 }
}
if (-not $connected) { throw "The HTTPS connection is not responding. See $stderrPath." }

Write-Host 'Temporary HTTPS connection is ready. Keep this computer, the backend, and the tunnel running.'
return $apiBaseUrl
