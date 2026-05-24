# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
QEMU_DIR="$ROOT_DIR/platform/qemu"
QEMU_BUILD_DIR="${QEMU_BUILD_DIR:-/tmp/taipan-qemu-build}"
QEMU_ARTIFACT_DIR="${QEMU_ARTIFACT_DIR:-$ROOT_DIR/artifacts/firmware/qemu}"
QEMU_TARGET_LIST="${QEMU_TARGET_LIST:-arm-softmmu,aarch64-softmmu}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"
SKIP_SUBPROJECTS="${SKIP_SUBPROJECTS:-1}"

if [ ! -d "$QEMU_DIR/.git" ]; then
    echo "qemu tree not found: $QEMU_DIR" >&2
    exit 1
fi

mkdir -p "$QEMU_BUILD_DIR" "$QEMU_ARTIFACT_DIR"

echo "============================================"
echo "Building QEMU aarch64-softmmu emulator"
echo "============================================"
echo "QEMU Dir:      $QEMU_DIR"
echo "Build Dir:     $QEMU_BUILD_DIR"
echo "Artifact Dir:  $QEMU_ARTIFACT_DIR"
echo "Target List:   $QEMU_TARGET_LIST"
echo "Jobs:          $JOBS"
echo "Skip Subproj:  $SKIP_SUBPROJECTS"
echo "============================================"

if [ "$SKIP_SUBPROJECTS" = "1" ]; then
    echo ""
    echo "[QEMU] Using simplified configuration (subprojects disabled)"
    echo "[QEMU] To enable all features, set: SKIP_SUBPROJECTS=0"
else
    echo ""
    echo "[QEMU] Downloading subprojects..."
    (
        cd "$QEMU_DIR"
        meson subprojects download 2>&1 | grep -E "Download|done" | tail -20 || true
        echo "[QEMU] Subproject download complete"
    )
fi

echo ""
echo "[QEMU] Configuring build system..."
(
    cd "$QEMU_BUILD_DIR"
    
    if [ "$SKIP_SUBPROJECTS" = "1" ]; then
        # Minimal configuration - disable all optional features
        "$QEMU_DIR/configure" \
            --target-list="$QEMU_TARGET_LIST" \
            --disable-docs \
            --disable-werror \
            --disable-slirp \
            --disable-virtfs \
            --disable-xkbcommon \
            --disable-ui \
            --disable-gtk \
            --disable-sdl \
            --disable-spice \
            --python=/usr/bin/python3 \
            --ninja="${NINJA:-ninja}" \
            2>&1 | tail -20
    else
        # Full configuration
        "$QEMU_DIR/configure" \
            --target-list="$QEMU_TARGET_LIST" \
            --disable-docs \
            --disable-werror \
            --without-default-features \
            --audio-drv-list=default \
            --python=/usr/bin/python3 \
            --ninja="${NINJA:-ninja}" \
            2>&1 | tail -20
    fi
)

echo ""
echo "[QEMU] Compiling (this may take several minutes)..."
echo "[QEMU] Log: $QEMU_BUILD_DIR/build.log"

"${NINJA:-ninja}" -C "$QEMU_BUILD_DIR" -j"$JOBS" 2>&1 | tee "$QEMU_BUILD_DIR/build.log"

echo ""
echo "[QEMU] Copying artifacts..."

if [ -f "$QEMU_BUILD_DIR/build.ninja" ] || [ -d "$QEMU_BUILD_DIR/subprojects" ]; then
    count=$(find "$QEMU_BUILD_DIR" -maxdepth 2 -type f \
        \( -name 'qemu-system-*' -o -name 'qemu-img' -o -name 'qemu-io' \) \
        -exec cp {} "$QEMU_ARTIFACT_DIR/" \; -print 2>/dev/null | wc -l)
    echo "[QEMU] Copied $count binaries"
fi

echo ""
echo "============================================"
printf 'QEMU build complete!\n'
printf '  artifacts: %s\n' "$QEMU_ARTIFACT_DIR"
if [ -d "$QEMU_ARTIFACT_DIR" ]; then
    ls -lh "$QEMU_ARTIFACT_DIR/" | tail -5
fi
echo "============================================"


