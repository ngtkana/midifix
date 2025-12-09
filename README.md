# MIDI Fix

Fixes MIDI track name encoding (Shift-JIS/EUC-JP to UTF-8).

## Installation (Windows)

1. Download `installer.ps1` from [Releases](https://github.com/ngtkana/midifix/releases)
2. Right-click `installer.ps1` and select "Run with PowerShell"
3. If prompted, allow administrator privileges

The installer will automatically download and install MIDI Fix to `%LOCALAPPDATA%\midifix`.

## Usage

Right-click a MIDI file and select "Fix with MIDI Fix". Output is saved as `filename_fixed.mid`.

## Uninstall

Right-click `installer.ps1` and select "Run with PowerShell", then run:
```powershell
.\installer.ps1 -Uninstall
```

## Build from Source

```bash
cargo build --release
```
