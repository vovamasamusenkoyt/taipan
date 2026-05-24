# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
ANDROID_DIR="$ROOT_DIR/guest/android"
ANDROID_BUILD_DIR="${ANDROID_BUILD_DIR:-/tmp/taipan-android-out}"
ANDROID_ARTIFACT_DIR="${ANDROID_ARTIFACT_DIR:-$ROOT_DIR/artifacts/images}"
ANDROID_PRODUCT="${ANDROID_PRODUCT:-taipan_arm64}"
ANDROID_TARGET="${ANDROID_TARGET:-userdebug}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"

if [ ! -d "$ANDROID_DIR" ]; then
    echo "Android tree not found: $ANDROID_DIR" >&2
    exit 1
fi

mkdir -p "$ANDROID_BUILD_DIR" "$ANDROID_ARTIFACT_DIR"

cd "$ANDROID_DIR"

echo "Building Android $ANDROID_PRODUCT for $ANDROID_TARGET..."

# Setup build environment
export OUT_DIR="$ANDROID_BUILD_DIR"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/default-java}"

# Build boot image and system image
# Note: full build requires m (mm, mmm) from lunch environment
# For now, we build just the boot image if possible
make \
    -j"$JOBS" \
    -C "$ANDROID_DIR" \
    OUT_DIR="$ANDROID_BUILD_DIR" \
    TARGET_PRODUCT="$ANDROID_PRODUCT" \
    TARGET_BUILD_VARIANT="$ANDROID_TARGET" \
    TARGET_BUILD_TYPE=release \
    bootimage \
    2>&1 | tee "$ANDROID_BUILD_DIR/build.log" || {
    echo "Android build failed. Log: $ANDROID_BUILD_DIR/build.log" >&2
    exit 1
}

# Copy artifacts
mkdir -p "$ANDROID_ARTIFACT_DIR"

if [ -f "$ANDROID_BUILD_DIR/boot.img" ]; then
    cp "$ANDROID_BUILD_DIR/boot.img" "$ANDROID_ARTIFACT_DIR/"
    printf 'Boot image built: %s/boot.img\n' "$ANDROID_ARTIFACT_DIR"
fi

if [ -f "$ANDROID_BUILD_DIR/system.img" ]; then
    cp "$ANDROID_BUILD_DIR/system.img" "$ANDROID_ARTIFACT_DIR/"
    printf 'System image built: %s/system.img\n' "$ANDROID_ARTIFACT_DIR"
fi

if [ -f "$ANDROID_BUILD_DIR/vendor.img" ]; then
    cp "$ANDROID_BUILD_DIR/vendor.img" "$ANDROID_ARTIFACT_DIR/"
    printf 'Vendor image built: %s/vendor.img\n' "$ANDROID_ARTIFACT_DIR"
fi

if [ -f "$ANDROID_BUILD_DIR/userdata.img" ]; then
    cp "$ANDROID_BUILD_DIR/userdata.img" "$ANDROID_ARTIFACT_DIR/"
    printf 'Userdata image built: %s/userdata.img\n' "$ANDROID_ARTIFACT_DIR"
fi

printf 'Android build complete.\n'
printf '  build directory: %s\n' "$ANDROID_BUILD_DIR"
printf '  artifact directory: %s\n' "$ANDROID_ARTIFACT_DIR"
