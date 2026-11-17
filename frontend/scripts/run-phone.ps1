[CmdletBinding()]
param(
    [string]$DeviceId,
    [ValidateRange(1, 65535)]
    [int]$Port = 5000,
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

$apiBaseUrl = "http://127.0.0.1:$Port/api"
try {
    $health = Invoke-RestMethod -Uri "$apiBaseUrl/health" -TimeoutSec 10
    if ($health.success -ne $true) { throw 'The API health check did not succeed.' }
} catch {
    throw "MindSphere backend is not healthy at $apiBaseUrl. Start it with npm.cmd start in the backend directory, then try again. $($_.Exception.Message)"
}

# Forward the phone's loopback port to this computer, avoiding LAN/firewall issues.
& $adb -s $DeviceId reverse "tcp:$Port" "tcp:$Port"
if ($LASTEXITCODE -ne 0) { throw 'Could not forward the backend port to the phone.' }

Write-Host "Running MindSphere on $DeviceId with API $apiBaseUrl"
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
    & $flutter build apk --debug "--target-platform=$platform" "--dart-define=API_BASE_URL=$apiBaseUrl"
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
