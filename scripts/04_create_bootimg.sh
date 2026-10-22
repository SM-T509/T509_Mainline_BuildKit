#!/bin/bash
# Create flashable boot.img for TWRP (Android boot header v2)
# Run after kernel and busybox builds

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
KERNEL_DIR="$ROOT_DIR/kernel/linux-7.1"
BUILD_DIR="$ROOT_DIR/output/kernel_build"
OUTPUT_DIR="$ROOT_DIR/output"
INITRAMFS_DIR="$ROOT_DIR/initramfs/rootfs"
TOOLS_DIR="$ROOT_DIR/rg-rotate-linux/tools/mkbstub"

export PATH="$ROOT_DIR/toolchain/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH"
CROSS_COMPILE=aarch64-linux-gnu-
ARCH=arm64

echo "=== Creating flashable boot.img for TWRP ==="

# 1. Pack initramfs
echo "Packing initramfs..."
cd "$INITRAMFS_DIR"
find . -print0 | cpio --null -ov --format=newc | gzip -9 > "$OUTPUT_DIR/initramfs.cpio.gz"
echo "Initramfs: $(du -h $OUTPUT_DIR/initramfs.cpio.gz | cut -f1)"

# 2. Create boot.img using mkbootimg (from rg-rotate-linux or kernel source)
# Android boot header v2 (for Android 11+)
MKBOOTIMG="$TOOLS_DIR/mkbootimg.py"
if [ ! -f "$MKBOOTIMG" ]; then
    MKBOOTIMG="$KERNEL_DIR/scripts/mkbootimg/mkbootimg.py"
fi

if [ ! -f "$MKBOOTIMG" ]; then
    echo "ERROR: mkbootimg.py not found!"
    exit 1
fi

# T509 boot parameters (from stock boot.img analysis)
# header v2, page_size=2048, base=0x0, kernel_offset=0x8000, ramdisk_offset=0x5400000
# kernel_addr=0x80000, ramdisk_addr=0x5500000, tags_addr=0x1000
# dtb appended to kernel

KERNEL_IMG="$OUTPUT_DIR/Image"
DTB_FILE="$OUTPUT_DIR/ums512-t509.dtb"
RAMDISK="$OUTPUT_DIR/initramfs.cpio.gz"
OUTPUT_BOOTIMG="$OUTPUT_DIR/t509-mainline-boot.img"

# Combine kernel + DTB (mkbootimg with header v2 supports --dtb)
# For header v2, DTB is appended to kernel Image
cat "$KERNEL_IMG" "$DTB_FILE" > "$OUTPUT_DIR/Image-dtb"

# Create boot.img
python3 "$MKBOOTIMG" \
    --kernel "$OUTPUT_DIR/Image-dtb" \
    --ramdisk "$RAMDISK" \
    --header_version 2 \
    --pagesize 2048 \
    --base 0x0 \
    --kernel_offset 0x8000 \
    --ramdisk_offset 0x5400000 \
    --tags_offset 0x1000 \
    --dtb_offset 0x1f00000 \
    --cmdline "console=ttyS1,115200 root=/dev/mmcblk1p2 rw rootwait earlycon=sprd,ums512-uart,0x70100000" \
    -o "$OUTPUT_BOOTIMG"

echo "=== Boot image created ==="
echo "Output: $OUTPUT_BOOTIMG ($(du -h $OUTPUT_BOOTIMG | cut -f1))"

# Verify
python3 "$MKBOOTIMG" --info "$OUTPUT_BOOTIMG"

# Also create vendor_boot.img if needed (for GKI)
# python3 "$MKBOOTIMG" --vendor_boot ...