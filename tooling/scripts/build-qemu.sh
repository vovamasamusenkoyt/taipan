# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
QEMU_DIR="$ROOT_DIR/platform/qemu"
QEMU_BUILD_DIR="${QEMU_BUILD_DIR:-/tmp/taipan-qemu-build}"
QEMU_ARTIFACT_DIR="${QEMU_ARTIFACT_DIR:-$ROOT_DIR/artifacts/firmware/qemu}"
QEMU_TARGET_LIST="${QEMU_TARGET_LIST:-arm-softmmu,aarch64-softmmu}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"

if [ ! -d "$QEMU_DIR/.git" ]; then
    echo "qemu tree not found: $QEMU_DIR" >&2
    exit 1
fi

mkdir -p "$QEMU_BUILD_DIR" "$QEMU_ARTIFACT_DIR"

(
    cd "$QEMU_BUILD_DIR"
    "$QEMU_DIR/configure" \
        --target-list="$QEMU_TARGET_LIST" \
        --disable-docs \
        --disable-werror \
        --disable-download \
        --without-default-features \
        --audio-drv-list=default \
        --python=/usr/bin/python3 \
        --ninja="${NINJA:-ninja}"
)

"${NINJA:-ninja}" -C "$QEMU_BUILD_DIR" -j"$JOBS"

if [ -f "$QEMU_BUILD_DIR/build.ninja" ]; then
    find "$QEMU_BUILD_DIR" -maxdepth 1 -type f \
        \( -name 'qemu-system-*' -o -name 'qemu-img' -o -name 'qemu-io' \) \
        -exec cp {} "$QEMU_ARTIFACT_DIR/" \;
fi

printf 'QEMU build complete:\n'
printf '  artifacts: %s\n' "$QEMU_ARTIFACT_DIR"
