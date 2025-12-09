#!/bin/bash
set -e

echo "Building for Windows..."
cargo build --release --target x86_64-pc-windows-gnu

echo "Copying to Windows Downloads..."
cp target/x86_64-pc-windows-gnu/release/midifix.exe /mnt/c/Users/ngtka/Downloads/
cp midifix-wrapper.bat /mnt/c/Users/ngtka/Downloads/
cp dev-install.ps1 /mnt/c/Users/ngtka/Downloads/

echo ""
echo "Done! Files copied to C:\\Users\\ngtka\\Downloads\\"
echo "Run dev-install.ps1 on Windows to install."
