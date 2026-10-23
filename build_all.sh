#!/bin/bash
# Master build script - runs all steps sequentially

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Download kernel if not present
download_kernel() {
    if [ ! -d "$ROOT_DIR/kernel/linux-7.1" ]; then
        echo "Downloading Linux 7.1 kernel source..."
        mkdir -p "$ROOT_DIR/kernel"
        cd "$ROOT_DIR/kernel"
        wget -q https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.1.tar.xz
        tar -xf linux-7.1.tar.xz
        mv linux-7.1 linux-7.1
        # Copy our T509 DTB
        cp "$ROOT_DIR/sprd-dts/ums512-t509.dts" linux-7.1/arch/arm64/boot/dts/sprd/
        # Update Makefile
        sed -i 's/ums512-1h10.dtb/ums512-1h10.dtb \\n\\tums512-t509.dtb/' linux-7.1/arch/arm64/boot/dts/sprd/Makefile
        echo "Kernel source ready"
    fi
}

STEP="${1:-all}"

echo "=========================================="
echo "  T509 Mainline Linux Build System"
echo "=========================================="
echo "Step: $STEP"
echo ""

run_step() {
    local name="$1"
    local script="$2"
    echo ">>> Running $name..."
    if bash "$script"; then
        echo "✓ $name completed"
    else
        echo "✗ $name FAILED"
        exit 1
    fi
    echo ""
}

case "$STEP" in
    toolchain)
        download_kernel
        run_step "Toolchain" "$SCRIPT_DIR/01_download_toolchain.sh"
        ;;
    busybox)
        download_kernel
        run_step "Busybox" "$SCRIPT_DIR/02_build_busybox.sh"
        ;;
    kernel)
        download_kernel
        run_step "Kernel" "$SCRIPT_DIR/03_build_kernel.sh"
        ;;
    bootimg)
        download_kernel
        run_step "Boot Image" "$SCRIPT_DIR/04_create_bootimg.sh"
        ;;
    all)
        download_kernel
        run_step "Toolchain" "$SCRIPT_DIR/01_download_toolchain.sh"
        run_step "Busybox" "$SCRIPT_DIR/02_build_busybox.sh"
        run_step "Kernel" "$SCRIPT_DIR/03_build_kernel.sh"
        run_step "Boot Image" "$SCRIPT_DIR/04_create_bootimg.sh"
        echo "=========================================="
        echo "  BUILD COMPLETE!"
        echo "=========================================="
        ls -lh "$ROOT_DIR/output/"
        ;;
    *)
        echo "Usage: $0 [toolchain|busybox|kernel|bootimg|all]"
        exit 1
        ;;
esac