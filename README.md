# MIDI Fix

Fixes MIDI track name encoding (Shift-JIS/EUC-JP to UTF-8).

## Build

```bash
cargo build --release
```

## Install (Windows)

Run PowerShell as administrator:

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
