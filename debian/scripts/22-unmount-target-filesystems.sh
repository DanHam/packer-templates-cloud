#!/usr/bin/env bash
#
# Unmount all filesystems under /target
set -o errexit

# Logging for packer
echo "Unmounting filesystems under /target..."

umount /target/dev/pts
umount /target/dev
umount /target/proc
umount /target/sys
umount /target/boot
umount /target

exit 0
