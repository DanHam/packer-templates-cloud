#!/usr/bin/env bash
#
# Partition the build disk, create filesystems, and mount them.
#
# The script assumes the file systems supporting the running system are all
# located on the same disk as the rootfs. It also assumes the build disk is
# the only other disk attached to the system.
# If the build disk has existing partitions the script takes no action and
# exits
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Partitioning, creating filesystems, and mounting the build disk..."

# Install required tools on the host system
if [ "x$(rpm -qa | grep xfsprogs)" == "x" ]; then
    echo "Installing required filesystem tools on the host system" > \
        ${redirect}
    yum install -y xfsprogs >${redirect} 2>&1
fi

# Get the name of the disk containing the rootfs of the running system
rootdisk="$(lsblk --list --output PKNAME,TYPE,MOUNTPOINT | \
            grep part | \
            grep /$ | \
            tr -s '[[:blank:]]' ' ' | \
            cut -d' ' -f 1)"

echo "Root filesystem for running system is on: ${rootdisk}" > ${redirect}

# Determine and set the name for the build disk
blddisk="$(lsblk --list --output TYPE,NAME | \
             grep -v ${rootdisk} | \
             grep disk | \
             tr -s '[[:blank:]]' ' ' | \
             cut -d' ' -f2)"

echo "Found device for chroot build: ${blddisk}" > ${redirect}

# Ensure the build disk has no existing partitions
if [ "x$(lsblk -l -o NAME,TYPE | grep ${blddisk} | grep part)" != "x" ]; then
    echo "ERROR: Build disk ${blddisk} has existing partitions. Exiting"
    exit 2
fi

# Configure the build disk and create required partitions
echo "Partitioning the build disk..." > $redirect
printf "%s" "\
    o # Create a new empty DOS partition table
    n # Create a new partition for the boot filesystem
        p     # Primary partition
        1     # Partition number 1
              # Accept default first sector
        +150M # Set the partition size
    a # Set the bootable flag on the boot partition
    n # Create a new partition for the root filesystem
        p     # Primary partition
        2     # Partition number 2
              # Accept default first sector
              # Accept default last sector - end of disk
    w # Write the partition table and quit
    " | sed -e 's/^ *//g' -e 's/[ ]*#.*//g' | \
        fdisk /dev/${blddisk} &>/dev/null
fdisk -l /dev/${blddisk} > ${redirect}

# Create the build disk filesystems and partition labels
echo "Creating filesystems within the build disk partitions..." > ${redirect}
bootpart="/dev/${blddisk}1"
rootpart="/dev/${blddisk}2"
mkfs.xfs -f -L "BOOT" ${bootpart} > ${redirect} 2>&1
mkfs.xfs -f -L "ROOT" ${rootpart} > ${redirect} 2>&1

# Mount the build disk
echo "Mounting build disk partitions under /target..." > ${redirect}
[ ! -e /target ] && mkdir /target
mount ${rootpart} /target
mkdir /target/boot
mount ${bootpart} /target/boot
mount | grep ${blddisk} > ${redirect}

exit 0
