#!/usr/bin/env bash
#
# Create the network interfaces file
#
# Consistent network device names should have been disabled by a previous
# script so devices should be named using the familiar
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Creating the network interfaces file..."

# Add default contents and set up loopback
cat > /target/etc/network/interfaces <<EOF
# interfaces(5) file used by ifup(8) and ifdown(8)
#
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
# Set up the loopback interface
auto lo
iface lo inet loopback
EOF

# Configure the number of interfaces defined in the Packer template or else
# default to the number of interfaces defined below
: ${NUM_IFACES:="1"}
for i in $(seq 0 $((${NUM_IFACES}-1))) # Start at eth0...
do
	printf "%s" "\
        # Ethernet ${i}
        auto eth${i}
        iface eth${i} inet dhcp
        allow-hotplug eth${i}
    " | sed 's/^ *//g' >> /target/etc/network/interfaces
done

exit 0
