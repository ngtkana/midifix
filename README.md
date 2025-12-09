# MIDI Fix

Fixes MIDI track name encoding (Shift-JIS/EUC-JP to UTF-8).

## Installation (Windows)

1. Download `installer.ps1` from [Releases](https://github.com/ngtkana/midifix/releases)
2. Right-click `installer.ps1` and select "Run with PowerShell"
3. If prompted, allow administrator privileges

The installer will automatically download and install MIDI Fix to `%LOCALAPPDATA%\midifix`.

### Troubleshooting

If you get an execution policy error, unblock the file first:
```powershell
Unblock-File .\installer.ps1
```

Then run the installer:
```powershell
.\installer.ps1
```

Alternatively, run with bypass (no unblock needed):
```powershell
PowerShell -ExecutionPolicy Bypass -File .\installer.ps1
```

## Usage

Right-click a MIDI file and select "Fix with MIDI Fix". The tool processes the file silently and saves output as `filename_fixed.mid` in the same directory.

## Uninstall

```powershell
.\installer.ps1 -Uninstall
```

## Build from Source

```bash
cargo build --release
```
