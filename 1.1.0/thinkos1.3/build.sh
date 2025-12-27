#!/bin/bash

# THINK OS Build Script v2.0
# Builds both FAT12 and GUI versions

set -e  # Exit on error

echo "========================================"
echo "   THINK OS - Complete Build System"
echo "========================================"
echo ""

# Check for required tools
echo "[1/6] Checking dependencies..."
command -v nasm >/dev/null 2>&1 || { echo "ERROR: nasm not found. Install with: sudo apt-get install nasm"; exit 1; }
command -v qemu-system-i386 >/dev/null 2>&1 || { echo "WARNING: qemu not found. Install with: sudo apt-get install qemu-system-x86"; }

echo "✓ Dependencies OK"

# Check if stage1.asm exists
if [ ! -f stage1.asm ]; then
    echo ""
    echo "ERROR: stage1.asm not found!"
    echo "Please ensure stage1.asm is in the current directory"
    exit 1
fi

# Build stage 1 (bootloader)
echo ""
echo "[2/6] Assembling Stage 1 (bootloader)..."
nasm -f bin stage1.asm -o stage1.bin || { echo "ERROR: Stage 1 compilation failed!"; exit 1; }
SIZE=$(stat -f%z stage1.bin 2>/dev/null || stat -c%s stage1.bin 2>/dev/null)
echo "✓ Stage 1 assembled ($SIZE bytes)"

if [ $SIZE -ne 512 ]; then
    echo "WARNING: Boot sector should be exactly 512 bytes!"
fi

# Build FAT12 version
echo ""
echo "[3/6] Building FAT12 version..."
if [ -f stage2_fat12.asm ]; then
    nasm -f bin stage2_fat12.asm -o stage2_fat12.bin || { echo "ERROR: FAT12 compilation failed!"; exit 1; }
    
    # Create 1.44MB floppy image
    dd if=/dev/zero of=thinkos_fat12.img bs=512 count=2880 status=none
    
    # Write stage 1 (boot sector)
    dd if=stage1.bin of=thinkos_fat12.img conv=notrunc status=none
    
    # Write stage 2
    dd if=stage2_fat12.bin of=thinkos_fat12.img seek=1 conv=notrunc status=none
    
    echo "✓ FAT12 version built: thinkos_fat12.img"
elif [ -f stage2.asm ]; then
    echo "Found stage2.asm, building as FAT12..."
    nasm -f bin stage2.asm -o stage2.bin || { echo "ERROR: Stage 2 compilation failed!"; exit 1; }
    
    dd if=/dev/zero of=thinkos_fat12.img bs=512 count=2880 status=none
    dd if=stage1.bin of=thinkos_fat12.img conv=notrunc status=none
    dd if=stage2.bin of=thinkos_fat12.img seek=1 conv=notrunc status=none
    
    echo "✓ FAT12 version built: thinkos_fat12.img"
else
    echo "⚠ No stage2_fat12.asm or stage2.asm found, skipping FAT12 build"
fi

# Build GUI version
echo ""
echo "[4/6] Building GUI version..."
if [ -f stage2_gui.asm ]; then
    nasm -f bin stage2_gui.asm -o stage2_gui.bin || { echo "ERROR: GUI compilation failed!"; exit 1; }
    
    # Create image
    dd if=/dev/zero of=thinkos_gui.img bs=512 count=2880 status=none
    dd if=stage1.bin of=thinkos_gui.img conv=notrunc status=none
    dd if=stage2_gui.bin of=thinkos_gui.img seek=1 conv=notrunc status=none
    
    echo "✓ GUI version built: thinkos_gui.img"
else
    echo "⚠ stage2_gui.asm not found, skipping GUI build"
fi

# Show file sizes
echo ""
echo "[5/6] Build summary:"
echo "-----------------------------------"
ls -lh stage1.bin 2>/dev/null | awk '{print "Stage 1:      " $5 " (" $9 ")"}'
ls -lh stage2_fat12.bin stage2.bin 2>/dev/null | awk '{print "FAT12 stage2: " $5 " (" $9 ")"}'
ls -lh stage2_gui.bin 2>/dev/null | awk '{print "GUI stage2:   " $5 " (" $9 ")"}'
echo "-----------------------------------"
ls -lh thinkos_fat12.img 2>/dev/null | awk '{print "FAT12 image:  " $5 " (bootable)"}'
ls -lh thinkos_gui.img 2>/dev/null | awk '{print "GUI image:    " $5 " (bootable)"}'
echo "-----------------------------------"

# Test menu
echo ""
echo "[6/6] Build complete!"
echo ""
echo "What would you like to do?"
echo "1) Test FAT12 version in QEMU"
echo "2) Test GUI version in QEMU"
echo "3) Test FAT12 with file persistence"
echo "4) Create bootable USB (requires sudo)"
echo "5) Exit"
echo ""
read -p "Choice (1-5): " choice

case $choice in
    1)
        if [ -f thinkos_fat12.img ]; then
            echo ""
            echo "======================================"
            echo "  Starting QEMU - FAT12 Version"
            echo "======================================"
            echo "Password: 123"
            echo ""
            echo "Features:"
            echo "- Press 1: Write files to disk"
            echo "- Press 2: View saved files"
            echo "- Files persist after reboot!"
            echo ""
            echo "Controls:"
            echo "- Ctrl+Alt+G: Release mouse"
            echo "- Ctrl+Alt+F: Fullscreen"
            echo "- Ctrl+C: Exit QEMU"
            echo ""
            read -p "Press Enter to start..."
            qemu-system-i386 -drive file=thinkos_fat12.img,format=raw,if=floppy -m 16
        else
            echo "ERROR: thinkos_fat12.img not found"
        fi
        ;;
    2)
        if [ -f thinkos_gui.img ]; then
            echo ""
            echo "======================================"
            echo "  Starting QEMU - GUI Version"
            echo "======================================"
            echo "Password: 123"
            echo ""
            echo "Features:"
            echo "- Mouse-driven interface"
            echo "- Click icons to open windows"
            echo "- 4 desktop icons: FILES, GAMES, TERM, CALC"
            echo ""
            echo "Controls:"
            echo "- Ctrl+Alt+G: Release mouse"
            echo "- ESC: Exit GUI"
            echo "- Ctrl+C: Exit QEMU"
            echo ""
            read -p "Press Enter to start..."
            qemu-system-i386 -drive file=thinkos_gui.img,format=raw -usb -device usb-tablet -m 16
        else
            echo "ERROR: thinkos_gui.img not found"
        fi
        ;;
    3)
        if [ -f thinkos_fat12.img ]; then
            echo ""
            echo "======================================"
            echo "  File Persistence Test"
            echo "======================================"
            echo ""
            echo "This will:"
            echo "1. Boot THINK OS"
            echo "2. Let you create files"
            echo "3. Reboot to verify persistence"
            echo ""
            echo "Test procedure:"
            echo "- Login (password: 123)"
            echo "- Press 1 to write a file"
            echo "- Enter filename: TEST.TXT"
            echo "- Type some text"
            echo "- Press ESC to save"
            echo "- Press 8 to logout"
            echo "- Choose 1 to reboot"
            echo "- Login again"
            echo "- Press 2 to view files"
            echo "- Your file should still be there!"
            echo ""
            read -p "Press Enter to start..."
            qemu-system-i386 -drive file=thinkos_fat12.img,format=raw,if=floppy -m 16
        else
            echo "ERROR: thinkos_fat12.img not found"
        fi
        ;;
    4)
        echo ""
        echo "======================================"
        echo "  CREATE BOOTABLE USB"
        echo "======================================"
        echo ""
        echo "⚠️  WARNING: This will ERASE all data on the selected drive!"
        echo ""
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -v loop
        echo ""
        read -p "Enter device (e.g., sdb): " device
        
        if [ -z "$device" ]; then
            echo "No device specified. Exiting."
            exit 0
        fi
        
        # Check if device exists
        if [ ! -b "/dev/$device" ]; then
            echo "ERROR: /dev/$device does not exist!"
            exit 1
        fi
        
        echo ""
        echo "Choose version:"
        echo "1) FAT12 (with file persistence)"
        echo "2) GUI (graphical mode)"
        read -p "Version (1-2): " version
        
        case $version in
            1) image="thinkos_fat12.img" ;;
            2) image="thinkos_gui.img" ;;
            *) echo "Invalid choice"; exit 1 ;;
        esac
        
        if [ ! -f "$image" ]; then
            echo "ERROR: $image not found"
            exit 1
        fi
        
        echo ""
        echo "╔════════════════════════════════════╗"
        echo "║        FINAL CONFIRMATION          ║"
        echo "╚════════════════════════════════════╝"
        echo ""
        echo "Image:  $image"
        echo "Device: /dev/$device"
        echo ""
        echo "This will PERMANENTLY ERASE /dev/$device"
        echo ""
        read -p "Type 'YES' to proceed: " confirm
        
        if [ "$confirm" = "YES" ]; then
            echo ""
            echo "Writing to USB..."
            sudo dd if=$image of=/dev/$device bs=4M status=progress
            sudo sync
            echo ""
            echo "✓ USB drive created successfully!"
            echo ""
            echo "Boot instructions:"
            echo "1. Insert USB into target computer"
            echo "2. Reboot and press boot menu key:"
            echo "   - Dell: F12"
            echo "   - HP: F9 or ESC"
            echo "   - Lenovo: F12"
            echo "   - ASUS: ESC or F8"
            echo "3. Select USB drive from boot menu"
            echo "4. THINK OS will boot!"
            echo ""
            echo "Note: You may need to:"
            echo "- Disable Secure Boot in BIOS"
            echo "- Enable Legacy/CSM boot mode"
        else
            echo "Cancelled."
        fi
        ;;
    5)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        ;;
esac

echo ""
echo "Build script finished!"
echo ""
echo "Quick commands:"
echo "- Test FAT12: qemu-system-i386 -drive file=thinkos_fat12.img,format=raw,if=floppy"
echo "- Test GUI:   qemu-system-i386 -drive file=thinkos_gui.img,format=raw -usb -device usb-tablet"
echo "- Rebuild:    ./build_thinkos.sh"
echo ""