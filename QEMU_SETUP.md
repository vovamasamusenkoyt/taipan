# Taipan QEMU Setup and Running Guide

SPDX-License-Identifier: GPL-2.0-only

## Prerequisites

### For Arch Linux
```bash
sudo pacman -S qemu-system-aarch64 qemu-utils
```

### For Ubuntu/Debian
```bash
sudo apt-get install qemu-system-aarch64 qemu-utils
```

### For Fedora/RHEL
```bash
sudo dnf install qemu-system-aarch64 qemu-utils
```

## Building Taipan Components

### Build All Platform Components (kernel, u-boot, qemu)
```bash
/hdd/taipan/tooling/scripts/build.sh platform
```

### Or Build Individually
```bash
# Build kernel
/hdd/taipan/tooling/scripts/build.sh kernel

# Build U-Boot bootloader
/hdd/taipan/tooling/scripts/build.sh u-boot

# Build QEMU emulator (if not using system QEMU)
/hdd/taipan/tooling/scripts/build.sh qemu
```

## Running Taipan in QEMU

### Quick Start
```bash
/hdd/taipan/tooling/scripts/run-qemu.sh
```

### With Custom Options
```bash
# Customize CPU cores
CORES=8 /hdd/taipan/tooling/scripts/run-qemu.sh

# Customize memory
MEMORY=4096 /hdd/taipan/tooling/scripts/run-qemu.sh

# Both
CORES=8 MEMORY=4096 /hdd/taipan/tooling/scripts/run-qemu.sh
```

### Available Environment Variables
- `QEMU_BIN` - Path to qemu-system-aarch64 binary
- `UBOOT_BIN` - Path to U-Boot binary
- `KERNEL_IMAGE` - Path to kernel image (Image.gz)
- `KERNEL_DTB` - Path to device tree blob
- `MACHINE` - QEMU machine type (default: virt)
- `CPU` - CPU model (default: cortex-a72)
- `CORES` - Number of CPU cores (default: 4)
- `MEMORY` - RAM in MB (default: 2048)
- `APPEND` - Kernel command line (default: console=ttyAMA0,38400n8 ro root=/dev/vda)

### Example: Run with Custom Configuration
```bash
CORES=4 MEMORY=2048 VERBOSE=1 /hdd/taipan/tooling/scripts/run-qemu.sh
```

## Build Artifacts

All build artifacts are stored in `/hdd/taipan/artifacts/`:

```
artifacts/
├── firmware/
│   ├── qemu/                  # QEMU binaries
│   │   └── qemu-system-aarch64
│   └── u-boot/
│       ├── u-boot.bin         # Bootloader
│       └── u-boot
├── kernels/
│   └── android15-6.6/
│       ├── Image.gz           # Kernel image
│       └── dtb/
│           └── taipan-virt.dtb  # Device tree
└── images/                    # Android system images
    ├── boot.img
    ├── system.img
    ├── vendor.img
    └── userdata.img
```

## Boot Output Interpretation

### Expected Boot Sequence
```
[QEMU console output]
U-Boot> (bootloader)
Booting kernel...
Linux kernel output...
Android init system starting...
```

### Serial Console Access
The default QEMU run uses serial console on `ttyAMA0` (ARM UART), output goes to stdio.

To see boot messages:
```bash
/hdd/taipan/tooling/scripts/run-qemu.sh 2>&1 | tee boot.log
```

### Kernel Boot Parameters
The default kernel command line is:
```
console=ttyAMA0,38400n8 ro root=/dev/vda
```

To customize:
```bash
APPEND="console=ttyAMA0,115200 ro root=/dev/vda debug" /hdd/taipan/tooling/scripts/run-qemu.sh
```

## Troubleshooting

### QEMU Not Found
If you see `qemu-system-aarch64 not found`:
1. Install QEMU using package manager (see Prerequisites above)
2. Or set `QEMU_BIN` to custom build path

### Kernel Not Found
Check that kernel is built:
```bash
ls -lh /hdd/taipan/artifacts/kernels/android15-6.6/Image.gz
```

If missing, build kernel:
```bash
/hdd/taipan/tooling/scripts/build.sh kernel
```

### U-Boot Not Found
Check:
```bash
ls -lh /hdd/taipan/artifacts/firmware/u-boot/u-boot.bin
```

If missing, build u-boot:
```bash
/hdd/taipan/tooling/scripts/build.sh u-boot
```

### Device Tree (DTB) Not Found
Check:
```bash
ls -lh /hdd/taipan/artifacts/kernels/android15-6.6/dtb/taipan-virt.dtb
```

### QEMU Hangs/No Output
1. Verify serial console: `VERBOSE=1 /hdd/taipan/tooling/scripts/run-qemu.sh`
2. Check kernel command line in run-qemu.sh
3. Ensure ttyAMA0 is available in kernel config

## Development Workflow

### Quick Iteration
1. Make changes to source (kernel, u-boot, Android)
2. Rebuild changed component:
   ```bash
   /hdd/taipan/tooling/scripts/build.sh kernel  # or u-boot
   ```
3. Re-run QEMU:
   ```bash
   /hdd/taipan/tooling/scripts/run-qemu.sh
   ```

### Monitoring Build Progress
```bash
# Watch build log in real-time
tail -f /tmp/taipan-qemu-build/build.log

# Or check build directory size
du -sh /tmp/taipan-qemu-build/
```

### Clean Rebuild
```bash
# Full platform rebuild
rm -rf /tmp/taipan-* /hdd/taipan/artifacts/*
/hdd/taipan/tooling/scripts/build.sh platform
```

## Performance Tips

### For Faster Emulation
- Use more CPU cores: `CORES=8`
- Use more memory: `MEMORY=4096`
- On Linux with KVM support: kernel should detect automatically

### For Faster Builds
```bash
# Set jobs explicitly
JOBS=8 /hdd/taipan/tooling/scripts/build.sh platform

# Or set globally
export JOBS=8
```

## Documentation Links

- [Taipan Platform Architecture](../docs/architecture/taipan-platform-naming.md)
- [Android Boot Flow](guest/android/device/vendor/taipan/taipan_arm64/BOOT_FLOW.md)
- [QEMU ARM virt Machine](https://wiki.qemu.org/Documentation/Platforms/ARM)
- [U-Boot Documentation](https://source.denx.de/u-boot/u-boot/-/blob/master/doc/README.md)
