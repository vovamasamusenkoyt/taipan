# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
KERNEL_DIR="$ROOT_DIR/platform/kernel"
OUT_DIR="$ROOT_DIR/artifacts/kernels/android15-6.6"

if [ ! -d "$KERNEL_DIR/.git" ]; then
    echo "kernel tree not found: $KERNEL_DIR" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

cat <<EOF
Kernel build entrypoint is not wired yet.

Expected kernel tree:
  $KERNEL_DIR

Planned output directory:
  $OUT_DIR

Next step:
  decide the exact Android ARM64 build target and toolchain flow,
  then replace this placeholder with the real build command.
EOF
