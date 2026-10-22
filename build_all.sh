#!/bin/bash
# Master build script - runs all steps sequentially
# Usage: ./build_all.sh [step]
#   step: toolchain, busybox, kernel, bootimg, all (default)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

STEP="${1:-all}"

echo "=========================================="
echo "  T509 Mainline Linux Build System"
echo "  Samsung Galaxy Tab A7 Lite (SM-T509)"
echo "  Unisoc UMS512 (T618)"
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
        run_step "Toolchain" "$SCRIPT_DIR/01_download_toolchain.sh"
        ;;
    busybox)
        run_step "Busybox" "$SCRIPT_DIR/02_build_busybox.sh"
        ;;
    kernel)
        run_step "Kernel" "$SCRIPT_DIR/03_build_kernel.sh"
        ;;
    bootimg)
        run_step "Boot Image" "$SCRIPT_DIR/04_create_bootimg.sh"
        ;;
    all)
        run_step "Toolchain" "$SCRIPT_DIR/01_download_toolchain.sh"
        run_step "Busybox" "$SCRIPT_DIR/02_build_busybox.sh"
        run_step "Kernel" "$SCRIPT_DIR/03_build_kernel.sh"
        run_step "Boot Image" "$SCRIPT_DIR/04_create_bootimg.sh"
        echo "=========================================="
        echo "  BUILD COMPLETE!"
        echo "=========================================="
        echo "Output files in $ROOT_DIR/output/:"
        ls -lh "$ROOT_DIR/output/"
        echo ""
        echo "Flash via TWRP:"
        echo "  adb reboot recovery"
        echo "  twrp flash boot $ROOT_DIR/output/t509-mainline-boot.img"
        echo ""
        echo "Or fastboot (if available):"
        echo "  fastboot flash boot $ROOT_DIR/output/t509-mainline-boot.img"
        ;;
    *)
        echo "Usage: $0 [toolchain|busybox|kernel|bootimg|all]"
        exit 1
        ;;
esac