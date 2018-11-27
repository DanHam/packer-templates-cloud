#!/usr/bin/env bash
#
# Configure kernel modules
#
# * Blacklist ic2_piix4
#
# Avoid possible misunderstanding of message at boot caused by Debian
# attempting to load the ic2_piix4 kernel module. The corresponding
# hardware for this module doesn't exist on an EC2 instance. However,
# attempting to load the module results in the following (rather
# misleading) message being displayed during boot:
#
#   kernel: piix4_smbus 0000:00:01.3: SMBus base address uninitalized -
#           upgrade BIOS or use force_addr=0xaddr
#
# * Blacklist pcspkr and snd_pcsp
#
# We do not require beeps etc from the pc speaker and so can blacklist the
# associated modules
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring kernel modules..."

echo "Blacklisting i2c_piix4 to avoid erroneous boot messages" >${redirect}
cat > /target/etc/modprobe.d/i2c_piix4.conf <<EOF
blacklist i2c_piix4
EOF

echo "Blacklisting redundant pcspkr module" >${redirect}
cat > /target/etc/modprobe.d/pcspkr.conf <<EOF
blacklist pcspkr
EOF

echo "Blacklisting redundant snd_pcsp module" >${redirect}
cat > /target/etc/modprobe.d/snd_pcsp.conf <<EOF
blacklist snd_pcsp
EOF


exit 0
