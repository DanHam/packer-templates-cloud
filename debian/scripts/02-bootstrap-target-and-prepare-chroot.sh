#!/usr/bin/env bash
#
# Install required packages into the target filesystem using debootstrap
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Installing base packages into target filesystem..."

# The Debian codename should be set in the Packer template and passed to
# the script as an environment variable
if [ "x${DEBOOTSTRAP_CODENAME}" = "x" ]; then
    echo "Error: debootstrap requires the Debian codename to be set via" \
        "the Packer template. Please set a value for debootstrap_codename"
    exit 1
fi

# Ensure debootstrap is installed
if ! dpkg -s debootstrap &>/dev/null; then
    echo "Installing debootstrap to local system" >${redirect}
    DEBIAN_FRONTEND="noninteractive" apt-get install -y debootstrap \
        >${redirect} 2>&1
fi

# Sanity check
if ! mount | grep /target >/dev/null; then
    echo "ERROR: No filesystem mounted on /target. Exiting."
    exit 1
fi

# Set additional packages to install with debootstrap
packages="bash-completion,busybox,bzip2,ca-certificates,chrony,dbus,file," \
packages+="grub-pc,irqbalance,libpam-systemd,linux-image-amd64,less," \
packages+="locales,lsb-release,manpages,man-db,net-tools,openssh-server," \
packages+="openssl,psmisc,python-minimal,sudo,tree,uuid-runtime,xz-utils"

echo "Bootstrapping Debian ${DEBOOTSTRAP_CODENAME} into the build target" \
    "with debootstrap" >${redirect}
debootstrap --include=${packages} ${DEBOOTSTRAP_CODENAME} /target \
    http://httpredir.debian.org/debian >$redirect 2>&1

# Prepare the chroot environment
echo "Setting the target system hostname to 'localhost'" >${redirect}
echo "localhost" > /target/etc/hostname
echo "Enabling host name lookups from within the chroot target" >${redirect}
cp /etc/resolv.conf /target/etc/
echo "Creating required filesystem structures within the chroot" >${redirect}
mount --bind /dev /target/dev         # Populate the /dev tree
mount --bind /dev/pts /target/dev/pts # Support psuedo terminals
mount -t proc procfs /target/proc     # Create a proc filesystem
mount -t sysfs sysfs /target/sys      # Create a sysfs filesystem

exit 0
