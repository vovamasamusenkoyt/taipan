# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
UBOOT_DIR="$ROOT_DIR/platform/u-boot"
UBOOT_BUILD_DIR="${UBOOT_BUILD_DIR:-/tmp/taipan-u-boot-out}"
UBOOT_ARTIFACT_DIR="${UBOOT_ARTIFACT_DIR:-$ROOT_DIR/artifacts/firmware/u-boot}"
UBOOT_DEFCONFIG="${UBOOT_DEFCONFIG:-taipan_virt_arm64_defconfig}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"

if [ ! -d "$UBOOT_DIR/.git" ]; then
    echo "u-boot tree not found: $UBOOT_DIR" >&2
    exit 1
fi

mkdir -p "$UBOOT_BUILD_DIR" "$UBOOT_ARTIFACT_DIR"

make \
    -C "$UBOOT_DIR" \
    O="$UBOOT_BUILD_DIR" \
    CROSS_COMPILE="${CROSS_COMPILE:-aarch64-linux-gnu-}" \
    "$UBOOT_DEFCONFIG"

make \
    -C "$UBOOT_DIR" \
    -j"$JOBS" \
    O="$UBOOT_BUILD_DIR" \
    CROSS_COMPILE="${CROSS_COMPILE:-aarch64-linux-gnu-}"

for artifact in u-boot.bin u-boot u-boot.dtb; do
    if [ -f "$UBOOT_BUILD_DIR/$artifact" ]; then
        cp "$UBOOT_BUILD_DIR/$artifact" "$UBOOT_ARTIFACT_DIR/"
    fi
done

printf 'U-Boot build complete:\n'
printf '  artifacts: %s\n' "$UBOOT_ARTIFACT_DIR"
