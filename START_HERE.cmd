@echo off
REM T509 Mainline Linux BuildKit - Windows Launcher
REM Run this on Windows to extract and view instructions

echo ==========================================
echo  T509 Mainline Linux BuildKit
echo  Samsung Galaxy Tab A7 Lite (SM-T509)
echo  Unisoc UMS512 (T618)
echo ==========================================
echo.

echo This BuildKit contains everything needed to build a mainline Linux kernel
echo for the T509 and flash it via TWRP - NO dual boot, NO UEFI, NO fastboot.
echo.

echo Contents:
dir /b
echo.

echo ------------------------------------------
echo QUICK START (requires Linux/WSL/VM):
echo ------------------------------------------
echo 1. Copy this entire folder to a Linux machine (Ubuntu/Debian/WSL/VM)
echo 2. cd T509_Mainline_BuildKit
echo 3. chmod +x build_all.sh scripts/*.sh
echo 4. ./build_all.sh all
echo 5. Flash output/t509-mainline-boot.img via TWRP
echo.

echo ------------------------------------------
echo NO LINUX MACHINE? Use GitHub Actions:
echo ------------------------------------------
echo 1. Create a GitHub repo and push this folder
echo 2. Go to Actions tab -> "Build T509 Mainline Kernel" -> Run workflow
echo 3. Download 't509-mainline-bootimg' artifact when done
echo 4. Flash via TWRP
echo.

echo ------------------------------------------
echo FILES INCLUDED:
echo ------------------------------------------
echo kernel/linux-7.1/          - Mainline Linux 7.1 source + T509 DTB
echo rg-rotate-linux/           - Reference build (WiFi, U-Boot, tools)
echo firmware/                  - WiFi/BT/Audio/GNSS blobs (for rootfs)
echo scripts/                   - Build scripts (toolchain, busybox, kernel, bootimg)
echo build_all.sh               - Master build script
echo README.md                  - Full documentation
echo .github/workflows/build.yml - GitHub Actions cloud build
echo.

echo ------------------------------------------
echo OUTPUT (after build):
echo ------------------------------------------
echo output/t509-mainline-boot.img   <-- FLASH THIS VIA TWRP
echo output/Image                     Kernel
echo output/ums512-t509.dtb           Device Tree
echo output/initramfs.cpio.gz         Busybox initramfs
echo.

echo ------------------------------------------
echo TWRP FLASH COMMANDS:
echo ------------------------------------------
echo adb reboot recovery
echo adb push output/t509-mainline-boot.img /tmp/
echo adb shell twrp flash boot /tmp/t509-mainline-boot.img
echo.

echo ------------------------------------------
echo REQUIREMENTS:
echo ------------------------------------------
echo - TWRP installed on T509 (gta4lve TWRP)
echo - Linux build env: Ubuntu 22.04+, Debian 12+, WSL2, or VM
echo - OR GitHub account for cloud build
echo - 8GB+ free disk space
echo.

pause