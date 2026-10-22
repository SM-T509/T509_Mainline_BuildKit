#!/bin/bash
# Download and setup aarch64-linux-gnu cross-compiler toolchain
# Run this ONCE in a Linux environment (Ubuntu/Debian/WSL)

set -e

TOOLCHAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../toolchain" && pwd)"
mkdir -p "$TOOLCHAIN_DIR"

echo "=== Setting up aarch64-linux-gnu toolchain ==="

# Option 1: Ubuntu/Debian package (easiest)
if command -v apt &>/dev/null; then
    echo "Installing via apt..."
    sudo apt update
    sudo apt install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        make bc bison flex libssl-dev libc6-dev-arm64-cross \
        cpio gzip device-tree-compiler u-boot-tools
    echo "Toolchain installed via apt"
    exit 0
fi

# Option 2: Download prebuilt Linaro toolchain
echo "Downloading Linaro toolchain..."
cd "$TOOLCHAIN_DIR"
TOOLCHAIN_URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"
TOOLCHAIN_ARCHIVE="gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"

if [ ! -f "$TOOLCHAIN_ARCHIVE" ]; then
    wget -c "$TOOLCHAIN_URL" -O "$TOOLCHAIN_ARCHIVE"
fi

if [ ! -d "gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu" ]; then
    tar -xf "$TOOLCHAIN_ARCHIVE"
fi

export PATH="$TOOLCHAIN_DIR/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:$PATH"
echo "export PATH=\"$TOOLCHAIN_DIR/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin:\$PATH\"" >> ~/.bashrc

echo "=== Toolchain ready ==="
aarch64-linux-gnu-gcc --version