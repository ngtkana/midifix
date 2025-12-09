# MIDI Fix installer script
# Run as administrator

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Error: This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as administrator'." -ForegroundColor Yellow
    exit 1
}

$exePath = Join-Path $PSScriptRoot "target\release\midifix.exe"

if (-not $Uninstall) {
    Write-Host "Installing MIDI Fix..." -ForegroundColor Cyan

    if (-not (Test-Path $exePath)) {
        Write-Host "Error: $exePath not found." -ForegroundColor Red
        Write-Host "Run 'cargo build --release' first." -ForegroundColor Yellow
        exit 1
    }

    $regPath = "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix"
    $regCommandPath = "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix\command"

    Write-Host "Registering context menu..." -ForegroundColor Green
    
    reg add $regPath /ve /d "Fix with MIDI Fix" /f | Out-Null
    reg add $regPath /v "Icon" /d "`"$exePath`"" /f | Out-Null
    reg add $regCommandPath /ve /d "`"$exePath`" `"%1`"" /f | Out-Null

    $regPathMidi = "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix"
    $regCommandPathMidi = "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix\command"
    
    reg add $regPathMidi /ve /d "Fix with MIDI Fix" /f | Out-Null
    reg add $regPathMidi /v "Icon" /d "`"$exePath`"" /f | Out-Null
    reg add $regCommandPathMidi /ve /d "`"$exePath`" `"%1`"" /f | Out-Null

    Write-Host ""
    Write-Host "Installation complete." -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "  Right-click a .mid or .midi file and select 'Fix with MIDI Fix'" -ForegroundColor White
    Write-Host ""
    Write-Host "To uninstall:" -ForegroundColor Cyan
    Write-Host "  .\install.ps1 -Uninstall" -ForegroundColor White
    Write-Host ""

} else {
    Write-Host "Uninstalling MIDI Fix..." -ForegroundColor Cyan

    Write-Host "Removing registry entries..." -ForegroundColor Yellow
    
    reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix" /f 2>$null
    reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix" /f 2>$null

    Write-Host ""
    Write-Host "Uninstallation complete." -ForegroundColor Green
    Write-Host ""
}
