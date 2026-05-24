# Taipan Platform Naming

`Taipan` keeps the upstream execution model but introduces its own guest-facing
identity across the kernel, bootloader, and Android device configuration.

## QEMU

- Machine: `virt`
- System target: `aarch64-softmmu`

## Kernel

- DTS subtree: `arch/arm64/boot/dts/taipan/`
- DTS: `taipan-virt.dts`
- DTB: `taipan-virt.dtb`
- Compatible: `taipan,taipan-virt`, `qemu,virt`

## U-Boot

- DTS: `arch/arm/dts/taipan-virt.dts`
- Default device tree: `taipan-virt`
- Defconfig: `taipan_virt_arm64_defconfig`

## Android

- Vendor path: `guest/android/device/vendor/taipan/taipan_arm64`
- Product: `taipan_arm64`
- Board/platform: `taipan-virt`
