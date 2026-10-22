# T509 Mainline Linux BuildKit
**Samsung Galaxy Tab A7 Lite (SM-T509) - Unisoc UMS512 (T618)**

Boots mainline Linux 7.1 via TWRP - **no dual boot, no UEFI, no fastboot needed**.

## 🎯 What This Does
- Builds **mainline Linux 7.1** kernel with T509 DTB
- Creates **flashable boot.img** for TWRP
- Runs **pure mainline Linux** (Debian/Alpine/Arch rootfs later)
- **No Android dual boot** - replaces boot partition entirely
- Works with **TWRP** (flash `boot` partition)

## 📋 Hardware Support (from stock DTB)
| Component | Driver | Status |
|-----------|--------|--------|
| CPU | 2×A75 + 6×A55 | ✅ PSCI/SMP |
| GICv3 | arm,gic-v3 | ✅ 0x12000000 |
| UART | sprd,ums512-uart | ✅ 0x70100000 (ttyS1) |
| eMMC | sprd,sdhci-r11 | ✅ 0x71400000 |
| USB | sprd,sharkl5-musb | ✅ 0x5FFF0000 (OTG) |
| WiFi/BT | sprd,sc2355-wifi | ✅ SDIO (marlin3) |
| Touch | novatek,NVT-ts-spi | ✅ SPI |
| Audio | sc2730 + ak4376 | ✅ I2S |
| PMIC | sprd,sc2730 | ✅ SPI (regulators, RTC, charger) |
| GPU | sprd,mali-gondul | ✅ Mali G52 |
| Charger | ti,bq25890 | ✅ I2C |
| Sensors | sprd,sharkl5pro-sensorhub | ✅ |

## 🚀 Quick Start (Linux/WSL/VM)

```bash
# 1. Extract BuildKit (from Windows zip) or clone
cd T509_Mainline_BuildKit

# 2. Run full build (needs Ubuntu/Debian/WSL with sudo)
chmod +x build_all.sh scripts/*.sh
./build_all.sh all

# 3. Flash via TWRP
adb reboot recovery
# In TWRP: Install -> Flash Image -> Select boot -> output/t509-mainline-boot.img
# Or via adb:
adb reboot recovery
# Wait for TWRP, then:
adb push output/t509-mainline-boot.img /tmp/
adb shell twrp flash boot /tmp/t509-mainline-boot.img
```

## 📦 Output Files
```
output/
├── Image                    # Kernel (gzip compressed)
├── ums512-t509.dtb          # Device tree
├── initramfs.cpio.gz        # Busybox initramfs
└── t509-mainline-boot.img   # Flashable boot.img (header v2)
```

## 🔧 Build Steps (Manual)
```bash
# 1. Toolchain (once)
./scripts/01_download_toolchain.sh

# 2. Busybox initramfs
./scripts/02_build_busybox.sh

# 3. Kernel + DTB
./scripts/03_build_kernel.sh

# 4. Boot image
./scripts/04_create_bootimg.sh

# Or all at once:
./build_all.sh all
```

## 📱 Flashing via TWRP
1. **Boot to TWRP**: Power off → Vol Up + Power
2. **Flash boot.img**: 
   - TWRP UI: Install → Flash Image → boot → select `t509-mainline-boot.img`
   - Or CLI: `twrp flash boot /path/to/t509-mainline-boot.img`
3. **Reboot**: System will boot mainline Linux

## 🐧 Next: Rootfs
After booting to initramfs shell, mount a rootfs:
```bash
# Option A: Debian (debootstrap)
mkdir /mnt/root
mount /dev/mmcblk0p2 /mnt/root  # your rootfs partition
exec switch_root /mnt/root /sbin/init

# Option B: Alpine (apk)
# Option C: Arch (pacstrap)
```

## 🔄 GitHub Actions (Cloud Build - No Local Linux Needed!)
Push this repo to GitHub → Actions builds automatically → Download `boot.img` artifact.

```yaml
# .github/workflows/build.yml
name: Build T509 Mainline Kernel
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: |
          chmod +x build_all.sh scripts/*.sh
          ./build_all.sh all
      - name: Upload boot.img
        uses: actions/upload-artifact@v4
        with:
          name: t509-bootimg
          path: output/t509-mainline-boot.img
```

## 📁 BuildKit Structure
```
T509_Mainline_BuildKit/
├── build_all.sh              # Master script
├── scripts/
│   ├── 01_download_toolchain.sh
│   ├── 02_build_busybox.sh
│   ├── 03_build_kernel.sh
│   └── 04_create_bootimg.sh
├── kernel/linux-7.1/         # Mainline kernel source + T509 DTB
├── rg-rotate-linux/          # Reference (WiFi, U-Boot, flash tools)
├── firmware/                 # WiFi/BT/Audio/GNSS blobs
├── initramfs/                # Busybox source + rootfs
└── output/                   # Build artifacts
```

## ⚠️ Notes
- **Boot partition ONLY** - doesn't touch system/data/vendor
- **Stock Android still works** - reflash stock boot.img to restore
- **No warranty** - test at your own risk
- **TWRP required** - tested with gta4lve TWRP

## 🙏 Credits
- **beebono/rg-rotate-linux** - Mainline UMS512 reference
- **torvalds/linux** - UMS512 mainline support
- **Unisoc** - UMS512 DTB upstreaming
- **Samsung** - Stock DTB/firmware

## 📞 Support
- Check `rg-rotate-linux/DEVICE-BRINGUP.md` for debugging
- Serial console: `ttyS1` 115200 (UART1 @ 0x70100000)
- Earlycon: `earlycon=sprd,ums512-uart,0x70100000`