@echo off
REM ============================================================================
REM THINK OS - WINDOWS BUILD SCRIPT
REM ============================================================================
REM This script compiles and combines Stage 1 and Stage 2 into a bootable image
REM ============================================================================

echo ================================================
echo    THINK OS - BUILD SYSTEM v1.0.9
echo ================================================
echo.

REM Check if NASM is installed
where nasm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: NASM is not installed!
    echo Download from: https://www.nasm.us/
    pause
    exit /b 1
)

echo [1/5] Compiling Stage 1 bootloader...
nasm -f bin stage1.asm -o stage1.bin
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Stage 1 compilation failed!
    pause
    exit /b 1
)
echo       Stage 1 compiled successfully!

echo [2/5] Compiling Stage 2 kernel...
nasm -f bin stage2.asm -o stage2.bin
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Stage 2 compilation failed!
    pause
    exit /b 1
)
echo       Stage 2 compiled successfully!

echo [3/5] Creating disk image...
REM Create 1.44MB floppy image (2880 sectors of 512 bytes)
fsutil file createnew thinkos.img 1474560

echo [4/5] Writing bootloader to disk...
REM Write Stage 1 to first sector
copy /b stage1.bin + stage2.bin thinkos_temp.bin >nul
copy /b thinkos_temp.bin thinkos.img >nul
del thinkos_temp.bin

echo [5/5] Build complete!

echo.
echo ================================================
echo    BUILD COMPLETE!
echo ================================================
echo.
echo Output files:
echo   - stage1.bin    (Stage 1 bootloader)
echo   - stage2.bin    (Stage 2 kernel)
echo   - thinkos.img   (Complete bootable image)
echo.
echo To test in QEMU:
echo   qemu-system-i386.exe -fda thinkos.img
echo.
echo To test in VirtualBox:
echo   1. Create new VM (Other/Unknown, 32-bit)
echo   2. Add thinkos.img as floppy disk
echo   3. Boot the VM
echo.
echo To write to USB (requires admin):
echo   Use Rufus or Win32DiskImager
echo.

pause