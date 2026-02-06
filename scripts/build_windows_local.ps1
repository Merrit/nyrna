param(
    [switch]$SkipFlutterConfig
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "== Nyrna Windows build (local) ==" -ForegroundColor Cyan

# Use a fixed Flutter SDK based on the provided flutter_tester.exe path.
# Base path given by you:
#   X:\apps\flutter_sdk\flutter\bin\cache\artifacts\engine\windows-x64\flutter_tester.exe
$flutterTesterPath = 'X:\apps\flutter_sdk\flutter\bin\cache\artifacts\engine\windows-x64\flutter_tester.exe'

if (-not (Test-Path $flutterTesterPath)) {
    Write-Error "Expected flutter_tester.exe not found at '$flutterTesterPath'. Please check the path."
    exit 1
}

# Derive Flutter root and flutter.bat from the tester path
$flutterRoot = 'X:\apps\flutter_sdk\flutter'
$flutterExe  = Join-Path $flutterRoot 'bin\flutter.bat'

if (-not (Test-Path $flutterExe)) {
    Write-Error "Flutter CLI not found at '$flutterExe'. Please verify your Flutter SDK installation."
    exit 1
}

Write-Host "Using Flutter SDK at: $flutterRoot" -ForegroundColor DarkCyan

# Ensure flutter is callable in this session
$env:FLUTTER_ROOT = $flutterRoot
$env:PATH = (Join-Path $flutterRoot 'bin') + [System.IO.Path]::PathSeparator + $env:PATH

# Ensure vswhere.exe is on PATH so flutter_app_builder can locate VC++ redist
$vswhereCandidates = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe',
    'C:\Users\y9_win11\.cursor\extensions\ms-vscode.cmake-tools-1.21.36-universal\res\vswhere.exe'
)

foreach ($candidate in $vswhereCandidates) {
    if (Test-Path $candidate) {
        $vswhereDir = Split-Path -Parent $candidate
        if (-not ($env:PATH -split [System.IO.Path]::PathSeparator | Where-Object { $_ -eq $vswhereDir })) {
            $env:PATH = $vswhereDir + [System.IO.Path]::PathSeparator + $env:PATH
        }
    }
}

function Invoke-Flutter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Arguments
    )

    & $flutterExe @($Arguments.Split(' '))  # simple splitter is enough for our uses here

    if ($LASTEXITCODE -ne 0) {
        throw "Flutter command failed (exit code $LASTEXITCODE): flutter $Arguments"
    }
}

function Prepare-OutputDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootPath
    )

    $outputDir = Join-Path $RepoRootPath 'output'
    if (-not (Test-Path $outputDir)) {
        return
    }

    try {
        Remove-Item -LiteralPath $outputDir -Recurse -Force -ErrorAction Stop
        return
    }
    catch {
        Write-Warning "Failed to remove '$outputDir'. Attempting to archive it and continue."
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $archivedOutputDir = Join-Path $RepoRootPath "output_locked_$timestamp"

    try {
        Rename-Item -LiteralPath $outputDir -NewName (Split-Path $archivedOutputDir -Leaf) -ErrorAction Stop
        Write-Host "Archived locked output directory to: $archivedOutputDir" -ForegroundColor DarkYellow
    }
    catch {
        throw "Unable to clear or archive '$outputDir'. Close processes using files in output/ and retry."
    }
}

# Change working directory to repo root (this script is expected to live in scripts/)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot  = Resolve-Path (Join-Path $scriptDir '..')
Set-Location $repoRoot

Write-Host "Working directory: $repoRoot" -ForegroundColor DarkCyan

try {
    Prepare-OutputDirectory -RepoRootPath $repoRoot

    if (-not $SkipFlutterConfig) {
        Write-Host "Configuring Flutter for Windows desktop..." -ForegroundColor Yellow
        Invoke-Flutter "config --enable-windows-desktop"
    } else {
        Write-Host "Skipping 'flutter config --enable-windows-desktop' (per parameter)..." -ForegroundColor Yellow
    }

    Write-Host "Fetching pub dependencies (flutter pub get)..." -ForegroundColor Yellow
    Invoke-Flutter "pub get"

    Write-Host "Running flutter_app_builder for Windows..." -ForegroundColor Yellow
    Invoke-Flutter "pub run flutter_app_builder -v --platforms=windows"

    Write-Host ""
    Write-Host "Build finished. Check the 'output' directory under the repo root for artifacts." -ForegroundColor Green
}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}
