[CmdletBinding()]
param(
    [string]$DeviceId,
    [ValidateRange(1, 65535)]
    [int]$Port = 5000,
    [string]$ApiBaseUrl,
    [switch]$Public,
    [switch]$NoResident
)

$ErrorActionPreference = 'Stop'
$frontendDirectory = Split-Path -Parent $PSScriptRoot
$flutter = (Get-Command flutter -ErrorAction Stop).Source
$adbCommand = Get-Command adb -ErrorAction SilentlyContinue

if ($adbCommand) {
    $adb = $adbCommand.Source
} else {
    $localProperties = Join-Path $frontendDirectory 'android/local.properties'
    $sdkLine = Get-Content -LiteralPath $localProperties |
        Where-Object { $_ -match '^sdk\.dir=' } | Select-Object -First 1
    if (-not $sdkLine) {
        throw 'Android SDK not found. Run flutter doctor and configure the Android SDK.'
    }
    $sdkDirectory = $sdkLine.Substring('sdk.dir='.Length).Replace('\\', '\').Replace('\:', ':')
    $adb = Join-Path $sdkDirectory 'platform-tools/adb.exe'
    if (-not (Test-Path -LiteralPath $adb)) {
        throw "Android Debug Bridge was not found at $adb. Run flutter doctor."
    }
}

if (-not $DeviceId) {
    $deviceOutput = & $adb devices
    if ($LASTEXITCODE -ne 0) { throw 'Could not list connected Android devices.' }
    $phones = @($deviceOutput | ForEach-Object {
        if ($_ -match '^(\S+)\s+device\s*$' -and $Matches[1] -notmatch '^emulator-') {
            $Matches[1]
        }
    })
    if ($phones.Count -ne 1) {
        throw 'Connect and unlock one Android phone, enable USB debugging and accept its authorization prompt. With multiple phones, pass -DeviceId <id> from adb devices.'
    }
    $DeviceId = $phones[0]
}

if ($Public -and $ApiBaseUrl) { throw 'Use either -Public or -ApiBaseUrl, not both.' }
if ($Public) {
    $ApiBaseUrl = & (Join-Path $PSScriptRoot 'start-public-api.ps1') -Port $Port
}
$useLocalBackend = [string]::IsNullOrWhiteSpace($ApiBaseUrl)
if ($useLocalBackend) {
    $ApiBaseUrl = "http://127.0.0.1:$Port/api"
} else {
    $parsedUrl = $null
    if (-not [Uri]::TryCreate($ApiBaseUrl.Trim(), [UriKind]::Absolute, [ref]$parsedUrl) -or
        $parsedUrl.Scheme -ne 'https' -or $parsedUrl.UserInfo -or $parsedUrl.Query -or $parsedUrl.Fragment) {
        throw 'The public API address must be an absolute HTTPS URL without credentials, a query, or a fragment.'
    }
    $ApiBaseUrl = $parsedUrl.AbsoluteUri.TrimEnd('/')
    if (-not $ApiBaseUrl.EndsWith('/api')) { $ApiBaseUrl += '/api' }
}
try {
    $health = Invoke-RestMethod -Uri "$ApiBaseUrl/health" -TimeoutSec 15
    if ($health.success -ne $true) { throw 'The API health check did not succeed.' }
} catch {
    throw "MindSphere backend is not healthy at $ApiBaseUrl. Check that the backend and internet connection are available. $($_.Exception.Message)"
}

# Forward the phone's loopback port to this computer, avoiding LAN/firewall issues.
if ($useLocalBackend) {
    & $adb -s $DeviceId reverse "tcp:$Port" "tcp:$Port"
    if ($LASTEXITCODE -ne 0) { throw 'Could not forward the backend port to the phone.' }
}

Write-Host "Running MindSphere on $DeviceId with API $ApiBaseUrl"
Push-Location -LiteralPath $frontendDirectory
try {
    $abi = (& $adb -s $DeviceId shell getprop ro.product.cpu.abi | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the phone architecture.' }
    $platform = switch ($abi) {
        'arm64-v8a' { 'android-arm64' }
        'armeabi-v7a' { 'android-arm' }
        'x86_64' { 'android-x64' }
        default { throw "Unsupported phone architecture: $abi" }
    }
    & $flutter build apk --debug "--target-platform=$platform" "--dart-define=API_BASE_URL=$ApiBaseUrl"
    if ($LASTEXITCODE -ne 0) { throw 'The Android build failed.' }

    # Install updates explicitly: a rejected install must never trigger an
    # automatic uninstall, which would erase the saved login and local data.
    & $adb -s $DeviceId install -r -t 'build/app/outputs/flutter-apk/app-debug.apk'
    if ($LASTEXITCODE -ne 0) {
        throw 'The phone refused the app update. Unlock it, approve installation, and rerun this script. The existing app has not been uninstalled.'
    }
    & $adb -s $DeviceId shell am start -W -n 'com.cuet.mindsphere/.MainActivity'
    if ($LASTEXITCODE -ne 0) { throw 'Could not launch MindSphere on the phone.' }

    $runExitCode = 0
    if (-not $NoResident) {
        & $flutter attach -d $DeviceId
        $runExitCode = $LASTEXITCODE
    }
} finally {
    Pop-Location
}
exit $runExitCode
