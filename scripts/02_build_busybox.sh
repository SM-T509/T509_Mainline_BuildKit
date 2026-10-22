#!/bin/bash
# Build busybox for initramfs
# Run after toolchain setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUSYBOX_DIR="$ROOT_DIR/initramfs/busybox"
INITRAMFS_DIR="$ROOT_DIR/initramfs/rootfs"
OUTPUT_DIR="$ROOT_DIR/output"

mkdir -p "$BUSYBOX_DIR" "$INITRAMFS_DIR" "$OUTPUT_DIR"

export PATH="$ROOT_DIR/toolchain/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH"
CROSS_COMPILE=aarch64-linux-gnu-
ARCH=arm64

echo "=== Building busybox ==="

# Download busybox if not present
if [ ! -d "$BUSYBOX_DIR/busybox-1.36.1" ]; then
    cd "$BUSYBOX_DIR"
    wget -c https://busybox.net/downloads/busybox-1.36.1.tar.bz2
    tar -xf busybox-1.36.1.tar.bz2
fi

cd "$BUSYBOX_DIR/busybox-1.36.1"

# Configure busybox (static build for initramfs)
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config  # Disable tc (traffic control) to avoid issues

# Build
make -j$(nproc) CROSS_COMPILE=$CROSS_COMPILE ARCH=$ARCH

# Install to initramfs rootfs
make CONFIG_PREFIX="$INITRAMFS_DIR" CROSS_COMPILE=$CROSS_COMPILE ARCH=$ARCH install

echo "=== Busybox installed to $INITRAMFS_DIR ==="

# Create initramfs directory structure
cd "$INITRAMFS_DIR"
mkdir -p proc sys dev dev/pts etc mnt/root tmp var/run var/log

# Create init script
cat > init << 'EOF'
#!/bin/busybox sh
# Minimal init for T509 mainline Linux

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# Mount essential filesystems
/bin/busybox mount -t proc none /proc
/bin/busybox mount -t sysfs none /sys
/bin/busybox mount -t devtmpfs none /dev
/bin/busybox mkdir -p /dev/pts
/bin/busybox mount -t devpts none /dev/pts

# Set hostname
/bin/busybox hostname t509-mainline

# Start logging
/bin/busybox syslogd -C 64
/bin/busybox klogd

# Network (if needed)
# /bin/busybox ifconfig lo up

echo ""
echo "=========================================="
echo "  T509 Mainline Linux - Initramfs Shell"
echo "  Samsung Galaxy Tab A7 Lite (SM-T509)"
echo "  Unisoc UMS512 (T618)"
echo "=========================================="
echo ""
echo "Available commands: ls, cat, mount, fdisk, dd, etc."
echo "Rootfs will be mounted at /mnt/root"
echo ""

# Drop to shell (replace with actual init later)
exec /bin/busybox sh
EOF

chmod +x init

echo "=== Initramfs rootfs ready at $INITRAMFS_DIR ==="