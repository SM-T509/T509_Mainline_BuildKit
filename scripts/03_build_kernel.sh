#!/bin/bash
# Build mainline Linux kernel for T509
# Run after toolchain and busybox

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
KERNEL_DIR="$ROOT_DIR/kernel/linux-7.1"
BUILD_DIR="$ROOT_DIR/output/kernel_build"
OUTPUT_DIR="$ROOT_DIR/output"

mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

export PATH="$ROOT_DIR/toolchain/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH"
CROSS_COMPILE=aarch64-linux-gnu-
ARCH=arm64
JOBS=$(nproc)

echo "=== Building Linux 7.1 kernel for T509 ==="
echo "Kernel dir: $KERNEL_DIR"
echo "Build dir: $BUILD_DIR"
echo "Jobs: $JOBS"

cd "$KERNEL_DIR"

# Clean previous build (optional)
# make O="$BUILD_DIR" ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE mrproper

# Configure
echo "Configuring kernel..."
make O="$BUILD_DIR" ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE t509_defconfig

# Build kernel Image + DTBs
echo "Building kernel and DTBs..."
make -j$JOBS O="$BUILD_DIR" ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE Image dtbs

# Verify outputs
if [ ! -f "$BUILD_DIR/arch/arm64/boot/Image" ]; then
    echo "ERROR: Kernel Image not found!"
    exit 1
fi

if [ ! -f "$BUILD_DIR/arch/arm64/boot/dts/sprd/ums512-t509.dtb" ]; then
    echo "ERROR: T509 DTB not found!"
    exit 1
fi

# Copy to output
cp "$BUILD_DIR/arch/arm64/boot/Image" "$OUTPUT_DIR/Image"
cp "$BUILD_DIR/arch/arm64/boot/dts/sprd/ums512-t509.dtb" "$OUTPUT_DIR/ums512-t509.dtb"
cp "$BUILD_DIR/arch/arm64/boot/dts/sprd/ums512-1h10.dtb" "$OUTPUT_DIR/ums512-1h10.dtb" 2>/dev/null || true

echo "=== Kernel build complete ==="
echo "Image: $OUTPUT_DIR/Image ($(du -h $OUTPUT_DIR/Image | cut -f1))"
echo "DTB:   $OUTPUT_DIR/ums512-t509.dtb ($(du -h $OUTPUT_DIR/ums512-t509.dtb | cut -f1))"

# Also build modules if needed
# make -j$JOBS O="$BUILD_DIR" ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules
# make O="$BUILD_DIR" ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH="$ROOT_DIR/output/modules" modules_install