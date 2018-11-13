#!/usr/bin/env bash
#
# Create the fstab file
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Creating the fstab file..."

# Get the UUID's of the target root and boot filesystems
target_root_uuid="$(lsblk --list --output NAME,TYPE,UUID,MOUNTPOINT | \
                    grep part | \
                    grep /target$ | \
                    tr -s '[[:blank:]]' ' ' | \
                    cut -d' ' -f3)"

if [ "x${target_root_uuid}" == "x" ]; then
    echo "ERROR: Failed to determine UUID for root device"
    exit 1
fi
echo "Root UUID: ${target_root_uuid}" >${redirect}

target_boot_uuid="$(lsblk --list --output NAME,TYPE,UUID,MOUNTPOINT | \
                    grep part | \
                    grep /target/boot$ | \
                    tr -s '[[:blank:]]' ' ' | \
                    cut -d' ' -f3)"

if [ "x${target_boot_uuid}" == "x" ]; then
    echo "ERROR: Failed to determine UUID for boot device"
    exit 1
fi
echo "Boot UUID: ${target_boot_uuid}" >${redirect}

cat > /target/etc/fstab <<EOF
# /etc/fstab
#
# Device                                   Mountpoint  FS type  FS opts   Dump/Check
UUID=${target_boot_uuid}  /boot       xfs      defaults  0 0
UUID=${target_root_uuid}  /           xfs      defaults  0 0
EOF

exit 0
