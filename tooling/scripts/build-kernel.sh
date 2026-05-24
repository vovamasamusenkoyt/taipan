# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
KERNEL_DIR="$ROOT_DIR/platform/kernel"
NDK_BIN_DIR="${NDK_BIN_DIR:-/hdd/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin}"
KERNEL_BUILD_DIR="${KERNEL_BUILD_DIR:-/tmp/taipan-kernel-out}"
KERNEL_ARTIFACT_DIR="${KERNEL_ARTIFACT_DIR:-$ROOT_DIR/artifacts/kernels/android15-6.6}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"
KERNEL_DEFCONFIG="${KERNEL_DEFCONFIG:-gki_defconfig}"
KERNEL_IMAGE_TARGET="${KERNEL_IMAGE_TARGET:-Image.gz}"
KERNEL_DTB_TARGET="${KERNEL_DTB_TARGET:-taipan/taipan-virt.dtb}"
APPLY_KERNEL_PATCHES="${APPLY_KERNEL_PATCHES:-0}"

if [ ! -d "$KERNEL_DIR/.git" ]; then
    echo "kernel tree not found: $KERNEL_DIR" >&2
    exit 1
fi

if [ ! -x "$NDK_BIN_DIR/clang" ]; then
    echo "missing clang in NDK bin dir: $NDK_BIN_DIR" >&2
    exit 1
fi

mkdir -p "$KERNEL_BUILD_DIR" "$KERNEL_ARTIFACT_DIR"

if [ "$APPLY_KERNEL_PATCHES" = "1" ]; then
    "$ROOT_DIR/tooling/scripts/apply-kernel-patches.sh"
fi

export PATH="$NDK_BIN_DIR:$PATH"

make \
    -C "$KERNEL_DIR" \
    O="$KERNEL_BUILD_DIR" \
    ARCH=arm64 \
    LLVM=1 \
    "$KERNEL_DEFCONFIG"

make \
    -C "$KERNEL_DIR" \
    -j"$JOBS" \
    O="$KERNEL_BUILD_DIR" \
    ARCH=arm64 \
    LLVM=1 \
    "$KERNEL_IMAGE_TARGET" \
    "$KERNEL_DTB_TARGET"

cp "$KERNEL_BUILD_DIR/arch/arm64/boot/$KERNEL_IMAGE_TARGET" "$KERNEL_ARTIFACT_DIR/"
mkdir -p "$KERNEL_ARTIFACT_DIR/dtb"
cp "$KERNEL_BUILD_DIR/arch/arm64/boot/dts/$KERNEL_DTB_TARGET" "$KERNEL_ARTIFACT_DIR/dtb/"

printf 'Kernel build complete:\n'
printf '  image: %s/%s\n' "$KERNEL_ARTIFACT_DIR" "$KERNEL_IMAGE_TARGET"
if [ -d "$KERNEL_ARTIFACT_DIR/dtb" ]; then
    printf '  dtb dir: %s/dtb\n' "$KERNEL_ARTIFACT_DIR"
fi
