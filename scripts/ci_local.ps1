# Mimic Merrit's CI (tests.yml + build-windows) for local verification.
# Run before pushing to avoid embarrassing CI failures.
# Usage: .\scripts\ci_local.ps1  [-TestsOnly] [-BuildOnly]
#
# Ensure FLUTTER_ROOT is set (e.g. X:\apps\flutter_sdk\flutter) or flutter in PATH.

param(
    [switch]$TestsOnly,
    [switch]$BuildOnly
)

$ErrorActionPreference = "Stop"
$flutter = if ($env:FLUTTER_ROOT) { "$env:FLUTTER_ROOT\bin\flutter.bat" } else { "flutter" }
$dart = if ($env:FLUTTER_ROOT) { "$env:FLUTTER_ROOT\bin\dart.bat" } else { "dart" }
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root

function Step { param($name) Write-Host "`n===> $name" -ForegroundColor Cyan }
function Fail { param($msg) Write-Host "FAIL: $msg" -ForegroundColor Red; Pop-Location; exit 1 }
function Ok { Write-Host "OK" -ForegroundColor Green }

try {
    if (-not $BuildOnly) {
        # ----------- tests.yml (Windows steps) -----------
        Step "Setup: flutter pub get"
        & $flutter pub get
        if ($LASTEXITCODE -ne 0) { Fail "flutter pub get failed" }; Ok

        Step "Fix localizations formatting"
        & $dart format lib/localization/ -l 90
        if ($LASTEXITCODE -ne 0) { Fail "dart format lib/localization failed" }; Ok

        Step "Format all (so Verify will pass)"
        & $dart format -l 90 . | Out-Null
        Ok

        Step "Verify formatting"
        & $dart format -o none --set-exit-if-changed --line-length=90 .
        if ($LASTEXITCODE -ne 0) { Fail "Verify formatting failed - run 'dart format -l 90 .'" }; Ok

        Step "Run code generation"
        & $flutter pub run build_runner build --delete-conflicting-outputs
        if ($LASTEXITCODE -ne 0) { Fail "build_runner failed" }; Ok

        Step "Run i18n generation"
        & $flutter gen-l10n
        if ($LASTEXITCODE -ne 0) { Fail "gen-l10n failed" }; Ok

        Step "Run tests"
        & $flutter test
        if ($LASTEXITCODE -ne 0) { Fail "Tests failed" }; Ok
    }

    if (-not $TestsOnly) {
        # ----------- build-windows.yml -----------
        Step "Flutter config: enable-windows-desktop"
        & $flutter config --enable-windows-desktop
        if ($LASTEXITCODE -ne 0) { Fail "flutter config failed" }; Ok

        Step "Prepare: flutter pub get"
        & $flutter pub get
        if ($LASTEXITCODE -ne 0) { Fail "flutter pub get failed" }; Ok

        Step "Run build script (flutter_app_builder --platforms=windows)"
        $env:prerelease = "true"
        & $flutter pub run flutter_app_builder -v --platforms=windows
        if ($LASTEXITCODE -ne 0) { Fail "flutter_app_builder failed" }; Ok
    }

    Write-Host "`n=== All CI steps passed ===" -ForegroundColor Green
}
finally {
    Pop-Location
}
