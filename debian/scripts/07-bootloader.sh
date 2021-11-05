#!/usr/bin/env bash
#
# Create required Grub configuration files and install the bootloader
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring Grub config files and installing the bootloader..."

# Configure Grub config options for AWS
sed -i -e 's/\(GRUB_TIMEOUT\)=.*/\1=0/g' \
       -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT\)=.*/\1=""/g' \
       -e 's/\(GRUB_CMDLINE_LINUX\)=.*/\1="elevator=noop console=tty console=ttyS0 net.ifnames=0"/' \
       /target/etc/default/grub

# The chroot target will share the same view of the device tree as the host
# system (same device names), so we can determine the disk we need to
# install the bootloader to from outside the chroot
target_device="/dev/$(lsblk --list --output PKNAME,TYPE,MOUNTPOINT | \
                      grep part | \
                      grep /target$ | \
                      tr -s '[:blank:]' ' ' | \
                      cut -d' ' -f1)"

echo "Installing the bootloader to ${target_device}" >${redirect}
chroot /target grub-install "${target_device}" >${redirect} 2>&1
echo "Creating the grub configuration file" >${redirect}
chroot /target grub-mkconfig -o /boot/grub/grub.cfg >${redirect} 2>&1

exit 0
