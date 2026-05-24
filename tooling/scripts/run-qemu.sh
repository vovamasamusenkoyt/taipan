# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

# Try to find QEMU binary - prefer system, then custom, then built
QEMU_BIN="${QEMU_BIN:-}"
if [ -z "$QEMU_BIN" ]; then
    # Try system QEMU first
    if command -v qemu-system-aarch64 >/dev/null 2>&1; then
        QEMU_BIN="qemu-system-aarch64"
    # Try built QEMU
    elif [ -f "$ROOT_DIR/artifacts/firmware/qemu/qemu-system-aarch64" ]; then
        QEMU_BIN="$ROOT_DIR/artifacts/firmware/qemu/qemu-system-aarch64"
    else
        echo "Error: qemu-system-aarch64 not found" >&2
        echo "Install with: sudo pacman -S qemu-system-aarch64" >&2
        exit 1
    fi
fi

UBOOT_BIN="${UBOOT_BIN:-$ROOT_DIR/artifacts/firmware/u-boot/u-boot.bin}"
KERNEL_IMAGE="${KERNEL_IMAGE:-$ROOT_DIR/artifacts/kernels/android15-6.6/Image.gz}"
KERNEL_DTB="${KERNEL_DTB:-$ROOT_DIR/artifacts/kernels/android15-6.6/dtb/taipan-virt.dtb}"
SYSTEM_IMG="${SYSTEM_IMG:-$ROOT_DIR/artifacts/images/system.img}"
VENDOR_IMG="${VENDOR_IMG:-$ROOT_DIR/artifacts/images/vendor.img}"
USERDATA_IMG="${USERDATA_IMG:-$ROOT_DIR/artifacts/images/userdata.img}"

# QEMU configuration
MACHINE="${MACHINE:-virt}"
CPU="${CPU:-cortex-a72}"
CORES="${CORES:-4}"
MEMORY="${MEMORY:-2048}"
APPEND="${APPEND:-console=ttyAMA0,38400n8 ro root=/dev/vda}"

# Verify required files
for file in "$UBOOT_BIN" "$KERNEL_IMAGE" "$KERNEL_DTB"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file not found: $file" >&2
        exit 1
    fi
done

echo "Starting Taipan virtual device..."
echo "  QEMU:    $QEMU_BIN"
echo "  U-Boot:  $UBOOT_BIN"
echo "  Kernel:  $KERNEL_IMAGE"
echo "  DTB:     $KERNEL_DTB"
echo "  Machine: $MACHINE"
echo "  CPUs:    $CORES"
echo "  Memory:  ${MEMORY}M"
echo ""

# Build QEMU command
qemu_cmd="$QEMU_BIN"
qemu_cmd="$qemu_cmd -machine $MACHINE"
qemu_cmd="$qemu_cmd -cpu $CPU"
qemu_cmd="$qemu_cmd -smp cores=$CORES,threads=1"
qemu_cmd="$qemu_cmd -m $MEMORY"

# Firmware and kernel
qemu_cmd="$qemu_cmd -bios $UBOOT_BIN"
qemu_cmd="$qemu_cmd -kernel $KERNEL_IMAGE"
qemu_cmd="$qemu_cmd -dtb $KERNEL_DTB"

# Serial console
qemu_cmd="$qemu_cmd -serial pty"
qemu_cmd="$qemu_cmd -monitor stdio"

# Network
qemu_cmd="$qemu_cmd -netdev user,id=net0,hostfwd=tcp::5556-:5555"
qemu_cmd="$qemu_cmd -device virtio-net-device,netdev=net0,mac=52:54:00:12:34:56"

# Block devices (optional - only if rootfs exists)
if [ -f "$ROOT_DIR/artifacts/images/rootfs.img" ]; then
    qemu_cmd="$qemu_cmd -drive file=$ROOT_DIR/artifacts/images/rootfs.img,id=vda,format=raw,if=none"
    qemu_cmd="$qemu_cmd -device virtio-blk-device,drive=vda"
fi

# Display
qemu_cmd="$qemu_cmd -nographic"

# Enable debugging if verbose
if [ "${VERBOSE:-0}" = "1" ]; then
    qemu_cmd="$qemu_cmd -d guest_errors,cpu_reset"
fi

# Run QEMU
exec $qemu_cmd
