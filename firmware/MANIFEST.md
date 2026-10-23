# T509 Firmware Blobs for Mainline Linux
# Source: Extracted from device via BROM (wcnmodem, l_agdsp, l_ldsp, l_gdsp)

| File | Size | Description | Kernel Driver |
|------|------|-------------|---------------|
| fw-wifi.bin | 10MB | sc2355/marlin3 WiFi/BT/FM/GNSS combo | sprdwl_ng / btusb |
| fw-audio-agdsp.bin | 6MB | Audio DSP (SharkL5 AUDCP) | snd_soc_sprd_agdsp |
| fw-audio-ldsp.bin | 20MB | Low-power DSP (main audio) | snd_soc_sprd_ldsp |
| fw-gnss.bin | 10MB | GNSS DSP (.PSD88CS_S00) | sprd_gnss |

Total: ~46MB

Install location (in rootfs):
/lib/firmware/sprd/
  ├── fw-wifi.bin
  ├── fw-audio-agdsp.bin
  ├── fw-audio-ldsp.bin
  └── fw-gnss.bin
