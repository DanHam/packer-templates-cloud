#!/usr/bin/env bash
#
# Prepare the chroot target; Assumes a CentOS host
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Preparing the chroot environment for use..."

# Ensure repoquery is installed (part of yum-utils)
if ! rpm -q yum-utils >/dev/null; then
    echo "Installing yum-utils as it is required by this script" >${redirect}
    yum install -y yum-utils >${redirect} 2>&1
fi

# Sanity check
if ! mount | grep /target >/dev/null; then
    echo "ERROR: No filesystem mounted on /target. Exiting."
    exit 1
fi

# Install core CentOS files and package manager into the chroot target
echo "Installing core CentOS files into the chroot target" >${redirect}
yum --installroot /target --releasever=7 install -y centos-release >\
    ${redirect} 2>&1
echo "Installing the YUM package manager into the chroot target" >${redirect}
yum --installroot /target --releasever=7 install -y yum >${redirect} 2>&1

# Prepare the chroot environment
echo "Enabling host name lookups from within the chroot target" >${redirect}
cp /etc/resolv.conf /target/etc/
echo "Creating required filesystem structures within the chroot" >${redirect}
mount --bind /dev /target/dev      # Populate the /dev tree
mount -t proc procfs /target/proc  # Create a proc filesystem
mount -t sysfs sysfs /target/sys   # Create a sysfs filesystem

exit 0
