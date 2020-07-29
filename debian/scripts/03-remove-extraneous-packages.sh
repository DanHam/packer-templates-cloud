#!/usr/bin/env bash
#
# Remove extraneous packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Removing extraneous packages installed by debootstrap..."

# Set packages to remove
packages="cgmanager libcgmanager0 libnih-dbus1 libnih1 systemd-shim"

LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
    apt-get --purge autoremove -y ${packages} >${redirect} 2>&1

exit 0
