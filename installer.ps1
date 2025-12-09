# MIDI Fix Installer
# Downloads and installs MIDI Fix with Windows context menu integration

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$VERSION = "v1.1.0"
$INSTALL_DIR = "$env:LOCALAPPDATA\midifix"
$EXE_PATH = "$INSTALL_DIR\midifix.exe"
$DOWNLOAD_URL = "https://github.com/ngtkana/midifix/releases/download/$VERSION/midifix-$VERSION-x86_64-pc-windows-msvc.exe"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Error: This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Right-click this script and select 'Run with PowerShell as administrator'." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not $Uninstall) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  MIDI Fix Installer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if (Test-Path $EXE_PATH) {
        Write-Host "MIDI Fix is already installed at: $INSTALL_DIR" -ForegroundColor Yellow
        $response = Read-Host "Do you want to reinstall? (y/n)"
        if ($response -ne "y") {
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
            exit 0
        }
    }

    Write-Host "Creating installation directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null

    Write-Host "Downloading MIDI Fix $VERSION..." -ForegroundColor Green
    try {
        Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $EXE_PATH -UseBasicParsing
    } catch {
        Write-Host "Error: Failed to download MIDI Fix." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }

    Write-Host "Registering context menu..." -ForegroundColor Green
    
    $regPath = "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix"
    $regCommandPath = "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix\command"
    
    reg add $regPath /ve /d "Fix with MIDI Fix" /f | Out-Null
    reg add $regPath /v "Icon" /d "`"$EXE_PATH`"" /f | Out-Null
    reg add $regCommandPath /ve /d "`"$EXE_PATH`" `"%1`"" /f | Out-Null

    $regPathMidi = "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix"
    $regCommandPathMidi = "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix\command"
    
    reg add $regPathMidi /ve /d "Fix with MIDI Fix" /f | Out-Null
    reg add $regPathMidi /v "Icon" /d "`"$EXE_PATH`"" /f | Out-Null
    reg add $regCommandPathMidi /ve /d "`"$EXE_PATH`" `"%1`"" /f | Out-Null

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
    Write-Host "To uninstall, run:" -ForegroundColor Cyan
    Write-Host "  .\installer.ps1 -Uninstall" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"

} else {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  MIDI Fix Uninstaller" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Removing registry entries..." -ForegroundColor Yellow
    reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.mid\shell\MidiFix" /f 2>$null
    reg delete "HKEY_CLASSES_ROOT\SystemFileAssociations\.midi\shell\MidiFix" /f 2>$null

    if (Test-Path $INSTALL_DIR) {
        Write-Host "Removing installation directory..." -ForegroundColor Yellow
        Remove-Item -Path $INSTALL_DIR -Recurse -Force
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Uninstallation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to exit"
}
