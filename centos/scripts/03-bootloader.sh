#!/usr/bin/env bash
#
# Create required Grub configuration files and install the bootloader
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Creating required Grub config files and installing the bootloader..."

# Set grub options
cat > /target/etc/default/grub << EOF
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="\$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL="serial console"
GRUB_SERIAL_COMMAND="serial --speed=115200"
GRUB_CMDLINE_LINUX="console=tty0 crashkernel=auto console=ttyS0,115200"
GRUB_DISABLE_RECOVERY="true"
EOF

# The chroot target will share the same view of the device tree as the host
# system (same device names), so we can determine the disk we need to
# install the bootloader to from outside the chroot
target_device="/dev/$(lsblk --list --output PKNAME,TYPE,MOUNTPOINT | \
                      grep part | \
                      grep /target$ | \
                      tr -s '[[:blank:]]' ' ' | \
                      cut -d' ' -f1)"
# Install the bootloader
chroot /target grub2-install ${target_device} >${redirect} 2>&1
# Write out the Grub configuration file
chroot /target grub2-mkconfig -o /boot/grub2/grub.cfg >${redirect} 2>&1

exit 0
