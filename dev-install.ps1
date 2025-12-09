# Development installer for MIDI Fix
# Uses local midifix.exe file

$ErrorActionPreference = "Stop"

$EXE_PATH = "$PSScriptRoot\midifix.exe"
$WRAPPER_PATH = "$PSScriptRoot\midifix-wrapper.bat"
$INSTALL_DIR = "$env:LOCALAPPDATA\midifix"
$INSTALLED_EXE = "$INSTALL_DIR\midifix.exe"
$INSTALLED_WRAPPER = "$INSTALL_DIR\midifix-wrapper.bat"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Error: This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as administrator'." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path $EXE_PATH)) {
    Write-Host "Error: midifix.exe not found in current directory." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MIDI Fix Dev Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Cleaning existing installation..." -ForegroundColor Yellow
if (Test-Path $INSTALL_DIR) {
    Remove-Item -Path $INSTALL_DIR -Recurse -Force
}

Write-Host "Creating installation directory..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null

Write-Host "Copying files..." -ForegroundColor Green
Copy-Item $EXE_PATH -Destination $INSTALLED_EXE
if (Test-Path $WRAPPER_PATH) {
    Copy-Item $WRAPPER_PATH -Destination $INSTALLED_WRAPPER
}

Write-Host "Registering context menu..." -ForegroundColor Green

$regPath = "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix"
$regCommandPath = "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix\command"

reg add $regPath /ve /d "Fix with MIDI Fix" /f | Out-Null
reg add $regPath /v "Icon" /d "`"$INSTALLED_EXE`"" /f | Out-Null

if (Test-Path $INSTALLED_WRAPPER) {
    reg add $regCommandPath /ve /d "\`"$INSTALLED_WRAPPER\`" \`"%1\`"" /f | Out-Null
} else {
    reg add $regCommandPath /ve /d "\`"$INSTALLED_EXE\`" \`"%1\`"" /f | Out-Null
}

$regPathMidi = "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix"
$regCommandPathMidi = "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix\command"

reg add $regPathMidi /ve /d "Fix with MIDI Fix" /f | Out-Null
reg add $regPathMidi /v "Icon" /d "`"$INSTALLED_EXE`"" /f | Out-Null

if (Test-Path $INSTALLED_WRAPPER) {
    reg add $regCommandPathMidi /ve /d "\`"$INSTALLED_WRAPPER\`" \`"%1\`"" /f | Out-Null
} else {
    reg add $regCommandPathMidi /ve /d "\`"$INSTALLED_EXE\`" \`"%1\`"" /f | Out-Null
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installed to: $INSTALL_DIR" -ForegroundColor White
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  Right-click any .mid or .midi file" -ForegroundColor White
Write-Host "  Select 'Fix with MIDI Fix'" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
