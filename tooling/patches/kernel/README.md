# Kernel Patch Stack

`Taipan` keeps the Android common kernel in [`platform/kernel`](/hdd/taipan/platform/kernel)
as a mostly clean upstream checkout of `android15-6.6-lts`.

Local kernel customization should be carried as patch stacks here instead of
being edited ad hoc in the kernel tree.

## Layout

```text
tooling/patches/kernel/
  README.md
  series/
    ksu/
    susfs/
    local/
```

## Rules

1. Keep [`platform/kernel`](/hdd/taipan/platform/kernel) close to upstream.
2. Put third-party or feature patch sets into their own subdirectory.
3. Apply patch sets in a deterministic order.
4. Keep Taipan-specific changes in `series/local/`.
5. Rebase patch stacks when updating `android15-6.6-lts`.

## Expected flow

1. Sync or reset [`platform/kernel`](/hdd/taipan/platform/kernel) to the chosen upstream commit.
2. Drop patch files into one of:
   - `series/ksu/`
   - `series/susfs/`
   - `series/local/`
3. Run `tooling/scripts/apply-kernel-patches.sh`.
4. Build the kernel from the patched working tree.

## Notes

- `KernelSU` and `SUSFS` should stay as isolated patch stacks whenever possible.
- If either project requires large non-patch asset drops, keep those in a
  dedicated import branch and regenerate patch files from there.
