#!/usr/bin/env bash
#
# Configure networking
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring networking..."

# Initscripts don't like this file to be missing.
cat > /target/etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
chroot /target rm -f /etc/udev/rules.d/70*
chroot /target ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# Create a simple eth0 config, again not hard-coded to the build hardware
cat > /target/etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

# Configure the hosts file
cat > /target/etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF

# Override default timings for dhcp
cat > /etc/dhcp/dhclient.conf << EOF
# Cloud dhcp overrides - wait longer and retry faster!
timeout 300;
retry 60;
EOF

exit 0
