# MIDI Fix

Fixes MIDI track name encoding (Shift-JIS/EUC-JP to UTF-8).

## Installation (Windows)

1. Download `midifix-v1.1.0-x86_64-pc-windows-msvc.exe` from [Releases](https://github.com/ngtkana/midifix/releases)
2. Rename it to `midifix.exe`
3. Create a folder (e.g., `C:\Program Files\midifix`) and place `midifix.exe` there
4. Download `install.ps1` from this repository
5. Place `install.ps1` in the same folder
6. Right-click PowerShell and select "Run as administrator"
7. Navigate to the folder and run:
```powershell
.\install.ps1
```

This adds "Fix with MIDI Fix" to the right-click menu for .mid/.midi files.

## Usage

Right-click a MIDI file and select "Fix with MIDI Fix". Output is saved as `filename_fixed.mid`.

## Uninstall

```powershell
.\install.ps1 -Uninstall
```

## Build from Source

```bash
cargo build --release
```
