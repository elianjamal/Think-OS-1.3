#!/bin/bash
# ============================================================================
# THINK OS - LINUX BUILD SCRIPT
# ============================================================================
# This script compiles and combines Stage 1 and Stage 2 into a bootable image
# ============================================================================

echo "================================================"
echo "   THINK OS - BUILD SYSTEM v1.0.9"
echo "================================================"


# Check if NASM is installed
if ! command -v nasm &> /dev/null; then
    echo "ERROR: NASM is not installed!"
    echo "Install with: sudo apt-get install nasm (Debian/Ubuntu)"
    echo "            : sudo dnf install nasm (Fedora)"
    echo "            : sudo pacman -S nasm (Arch)"
    exit 1
fi

echo "[1/5] Compiling Stage 1 bootloader..."
nasm -f bin stage1.asm -o stage1.bin
if [ $? -ne 0 ]; then
    echo "ERROR: Stage 1 compilation failed!"
    exit 1
fi
echo "      Stage 1 compiled successfully!"

echo "[2/5] Compiling Stage 2 kernel..."
nasm -f bin stage2.asm -o stage2.bin
if [ $? -ne 0 ]; then
    echo "ERROR: Stage 2 compilation failed!"
    exit 1
fi
echo "      Stage 2 compiled successfully!"

echo "[3/5] Creating disk image..."
# Create 1.44MB floppy image (2880 sectors of 512 bytes)
dd if=/dev/zero of=thinkos.img bs=512 count=2880 status=none

echo "[4/5] Writing bootloader to disk..."
# Write Stage 1 and Stage 2 to the image
cat stage1.bin stage2.bin > thinkos_temp.bin
dd if=thinkos_temp.bin of=thinkos.img conv=notrunc status=none
rm thinkos_temp.bin

echo "[5/5] Build complete!"

echo ""
echo "================================================"
echo "   BUILD COMPLETE!"
echo "================================================"
echo ""
echo "Output files:"
echo "  - stage1.bin    (Stage 1 bootloader)"
echo "  - stage2.bin    (Stage 2 kernel)"
echo "  - thinkos.img   (Complete bootable image)"
echo ""
echo "To test in QEMU:"
echo "  qemu-system-i386 -fda thinkos.img"
echo ""
echo "To test in VirtualBox:"
echo "  1. Create new VM (Other/Unknown, 32-bit)"
echo "  2. Add thinkos.img as floppy disk"
echo "  3. Boot the VM"
echo ""
echo "To write to USB:"
echo "  sudo dd if=thinkos.img of=/dev/sdX bs=512"
echo "  (Replace /dev/sdX with your USB device)"
echo ""