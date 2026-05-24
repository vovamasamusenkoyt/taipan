# SPDX-License-Identifier: GPL-2.0-only
#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

build_kernel=0
build_uboot=0
build_qemu=0

if [ "$#" -eq 0 ]; then
    build_kernel=1
    build_uboot=1
    build_qemu=1
fi

for arg in "$@"; do
    case "$arg" in
        all)
            build_kernel=1
            build_uboot=1
            build_qemu=1
            ;;
        kernel)
            build_kernel=1
            ;;
        u-boot|uboot)
            build_uboot=1
            ;;
        qemu)
            build_qemu=1
            ;;
        *)
            echo "unknown build target: $arg" >&2
            echo "usage: $0 [all|kernel|u-boot|qemu ...]" >&2
            exit 1
            ;;
    esac
done

if [ "$build_qemu" -eq 1 ]; then
    "$ROOT_DIR/tooling/scripts/build-qemu.sh"
fi

if [ "$build_uboot" -eq 1 ]; then
    "$ROOT_DIR/tooling/scripts/build-u-boot.sh"
fi

if [ "$build_kernel" -eq 1 ]; then
    "$ROOT_DIR/tooling/scripts/build-kernel.sh"
fi

printf 'Taipan build finished.\n'
