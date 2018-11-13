#!/usr/bin/env bash
#
# Install all required CentOS packages into the chroot target
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Installing all required CentOS packages in the chroot target..."

packages="audit authconfig basesystem bash bash-completion biosdevname \
coreutils cronie curl deltarpm dhclient filesystem glibc grub2 hostname \
hwdata initscripts iproute iprutils iptables iputils irqbalance kbd \
kernel less lshw lsof man-db ncurses openssh-clients openssh-server \
openssl parted passwd policycoreutils policycoreutils-restorecond \
procps-ng rootfiles rpm rsyslog selinux-policy-targeted setup shadow-utils \
sudo systemd tar tree tuned util-linux vim-minimal xfsprogs yum"

chroot /target yum install -y ${packages} >${redirect} 2>&1

# The linux firmware package is always pulled in as a dependancy for the
# kernel. This is not required for a virtual instance and can be deleted
chroot /target yum remove -y linux-firmware >${redirect} 2>&1

exit 0
