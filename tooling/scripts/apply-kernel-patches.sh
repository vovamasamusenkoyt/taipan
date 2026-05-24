# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
KERNEL_DIR="$ROOT_DIR/platform/kernel"
PATCH_ROOT="$ROOT_DIR/tooling/patches/kernel/series"

if [ ! -d "$KERNEL_DIR/.git" ]; then
    echo "kernel tree not found: $KERNEL_DIR" >&2
    exit 1
fi

if [ ! -d "$PATCH_ROOT" ]; then
    echo "patch directory not found: $PATCH_ROOT" >&2
    exit 1
fi

apply_dir() {
    patch_dir=$1

    if [ ! -d "$patch_dir" ]; then
        return 0
    fi

    found=0
    for patch in "$patch_dir"/*.patch; do
        if [ ! -f "$patch" ]; then
            continue
        fi

        found=1
        echo "Applying $(basename "$patch_dir")/$(basename "$patch")"
        git -C "$KERNEL_DIR" am "$patch"
    done

    if [ "$found" -eq 0 ]; then
        echo "No patches in $(basename "$patch_dir"), skipping"
    fi
}

apply_dir "$PATCH_ROOT/ksu"
apply_dir "$PATCH_ROOT/susfs"
apply_dir "$PATCH_ROOT/local"

echo "Kernel patch application complete."
