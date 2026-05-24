# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
GSI_DIR="${GSI_DIR:-$ROOT_DIR/artifacts/gsi}"
GSI_TYPE="${GSI_TYPE:-gms}"  # gms or plain

mkdir -p "$GSI_DIR"

echo "=========================================="
echo "Android 16 GSI Setup"
echo "=========================================="
echo ""
echo "Build: BP2A.250605.031.A3 (June 3, 2025)"
echo "GSI Type: $GSI_TYPE"
echo "Download Dir: $GSI_DIR"
echo ""

if [ "$GSI_TYPE" = "gms" ]; then
    echo "Downloading ARM64 GSI with GMS..."
    echo "Download link:"
    echo "  https://flash.android.com/preview/baklava-gsi-gms"
    echo ""
    echo "Or use gsutil:"
    echo "  gsutil -m cp -r gs://baklava-gsi-arm64/baklava_gsi_arm64_* $GSI_DIR"
else
    echo "Downloading ARM64 GSI (vanilla, no GMS)..."
    echo "Download link:"
    echo "  https://flash.android.com/preview/baklava-gsi"
fi

echo ""
echo "After downloading and extracting:"
echo "  1. Extract: unzip baklava_gsi_arm64_*.zip"
echo "  2. Decompress: xz -d system.img.xz"
echo "  3. Mount as rootfs in QEMU"
echo ""
echo "SHA-256 checksums:"
echo "  ARM64+GMS: 38e52cb0a3331a5ee0c653a4da2401ce74598a955acbd00aa85b6326036154c5"
echo "  ARM64:     8227714351abe504eb27920d0e95c1b672722d2b7c9c9610dad2aee768624add"
echo ""
echo "=========================================="

