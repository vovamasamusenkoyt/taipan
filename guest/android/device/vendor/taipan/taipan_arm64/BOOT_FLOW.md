# Taipan Virtual Device - Boot Flow Documentation

SPDX-License-Identifier: GPL-2.0-only

## Overview

This directory contains the Android device configuration for **Taipan virtual device**, an ARM64 emulated device running on QEMU with the `virt` machine type.

## Boot Flow Architecture

### 1. **Early Init Phase** (`init.taipan-virt.rc` - `on early-init`)

Runs before the kernel device drivers are fully initialized.

**Key Actions:**
- Set hardware identification properties (`ro.hardware=taipan`)
- Configure platform/board properties (`ro.board.platform=taipan-virt`)
- Setup bootloader info and serial number
- Configure ARM64 CPU capabilities
- Setup console output to `ttyAMA0` (ARM UART)
- Enable QEMU-specific kernel flags (`ro.kernel.qemu=1`)
- Configure Dalvik/ART heap and stack traces

**Property Examples:**
```
ro.hardware=taipan
ro.boot.console=ttyAMA0
ro.boot.serialno=TAIPAN0000001
ro.kernel.qemu=1
```

### 2. **Init Phase** (`init.taipan-virt.rc` - `on init`)

Runs after early-init, sets up core system services.

**Key Actions:**
- Set Zygote configuration (32+64-bit)
- Enable userspace reboot support
- Configure verified boot state
- Setup Vulkan hardware capabilities

### 3. **Hardware/HW Phase** (`init.taipan-virt.hw.rc`)

Platform-specific hardware initialization.

**Key Actions:**
- Configure virtio block device permissions (`/dev/vda`, `/dev/vdb`, etc.)
- Setup virtual network device (`/dev/vnet0`)
- Enable watchdog support
- Configure CPU governors for virtual CPUs
- Initialize memory cgroup subsystem
- Setup timezone and locale

**Virtio Devices:**
- `vda`, `vdb`, `vdc`, `vdd` - virtual block devices
- `vnet0` - virtual network interface
- `vrng` - virtual random number generator

### 4. **File System Phase** (`init.taipan-virt.fs.rc`)

Handles partition mounting with dynamic partition support.

**Key Actions:**
- Wait for super partition block device
- Mount boot and init_boot partitions
- Setup overlay mount points
- Configure scratch partitions

**Dynamic Partitions:**
- `system`, `system_ext`, `product`, `vendor` - logical partitions from super
- `userdata` - user data partition
- `metadata` - device metadata

### 5. **Debug Phase** (`init.taipan-virt.debug.rc`)

Enhanced logging for boot debugging.

**Key Actions:**
- Log boot phases and timestamps
- Enable kernel debug output
- Create tombstone and ANR directories
- Log device tree information
- Track boot completion

### 6. **Mount Table** (`fstab.taipan-virt`)

Defines partition mounting points and options.

**Flags:**
- `wait` - wait for device before mounting
- `logical` - logical partition from super
- `first_stage_mount` - mount during first stage init
- `slotselect` - A/B OTA partition support
- `formattable` - partition can be formatted
- `errors=panic` - panic on mount errors (emulator safety)

## QEMU-Specific Adaptations

### Virtual Block Devices

Taipan uses QEMU virtio block devices:
```
/dev/vda - system images
/dev/vdb - vendor partition
/dev/vdc - product partition  
/dev/vdd - user data
```

### ARM64 UART Console

Serial console configured via:
- Kernel: `console=ttyAMA0,38400n8`
- Property: `ro.boot.console=ttyAMA0`
- Device: `/dev/ttyAMA0` (ARM PL011 UART)

### Virtual CPU Support

CPU governors set to `performance` for 4 virtual CPUs.

### Memory Management

- Heap size: 512MB
- cgroup memory limits configurable
- Memory pressure notifications enabled

## Properties Reference

| Property | Value | Purpose |
|----------|-------|---------|
| `ro.hardware` | `taipan` | Hardware ID |
| `ro.board.platform` | `taipan-virt` | Board platform |
| `ro.boot.console` | `ttyAMA0` | Serial console |
| `ro.boot.serialno` | `TAIPAN0000001` | Device serial |
| `ro.kernel.qemu` | `1` | QEMU detection |
| `ro.zygote` | `zygote64_32` | 32+64-bit support |
| `ro.product.cpu.abilist` | `arm64-v8a` | CPU ABI list |

## Boot Sequence Timeline

1. **Bootloader** (U-Boot) → loads kernel + initrd
2. **Early Init** → hardware properties, console setup
3. **First Stage Mount** → mount critical partitions
4. **Init** → system property setup
5. **HW Init** → virtio device setup
6. **FS Mount** → full partition mounting
7. **Zygote** → Java runtime starts
8. **System Services** → Android framework
9. **Boot Complete** → system ready

## Debugging

### Enable Verbose Logging

```sh
adb shell setprop ro.init.verbose 1
adb shell setprop ro.debuggable 1
```

### Check Boot Messages

```sh
adb shell dmesg | grep -i taipan
adb logcat | grep TaipanBoot
```

### Monitor Early Boot

```sh
# Watch kernel console directly
qemu-system-aarch64 -serial stdio ...
```

## Troubleshooting

### Boot Hangs on First Stage Mount

- Check `fstab.taipan-virt` partition names match device layout
- Verify super partition is properly formatted
- Ensure virtio block devices are available in QEMU

### Console Not Visible

- Verify `ttyAMA0` device available in QEMU
- Check kernel command line has `console=ttyAMA0,38400n8`
- Confirm `ro.boot.console=ttyAMA0` property set

### Partition Mount Failures

- Check `errors=panic` flag properly set
- Verify filesystem integrity with `fsck`
- Ensure partition table matches fstab definitions

## File Structure

```
taipan_arm64/
├── AndroidProducts.mk              # Product definitions
├── BoardConfig.mk                  # Board configuration
├── device.mk                       # Device copy files
├── taipan_arm64.mk                 # Product makefile
├── manifest.xml                    # Hardware VINTF manifest
├── init.taipan-virt.rc             # Main init config
├── init.taipan-virt.hw.rc          # Hardware-specific init
├── init.taipan-virt.fs.rc          # Filesystem mount config
├── init.taipan-virt.debug.rc       # Debug configuration
└── fstab.taipan-virt               # Mount table
```

## References

- [Android Init Language](https://android.googlesource.com/platform/system/core/+/master/init/README.md)
- [First Stage Mount](https://source.android.com/docs/core/bootloader/partitions/ab-updates)
- [QEMU ARM virt Machine](https://wiki.qemu.org/Documentation/Platforms/ARM)
