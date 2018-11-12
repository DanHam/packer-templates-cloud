#!/usr/bin/env bash
#
# Avoid possible misunderstanding of message at boot caused by CentOS
# attempting to load the ic2_piix4 kernel module. The corresponding
# hardware for this module doesn't exist on an EC2 instance. However,
# attempting to load the module results in the following (rather
# misleading) message being displayed during boot:
#
#   kernel: piix4_smbus 0000:00:01.3: SMBus base address uninitalized -
#           upgrade BIOS or use force_addr=0xaddr
#
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Blacklisting i2c_piix4 kernel module to avoid erroneous boot messages..."

cat > /target/etc/modprobe.d/piix4_smbus-blacklist.conf <<EOF
# Blacklist piix4_smbus to prevent erroneous warning on EC2 instance boot

blacklist i2c_piix4
EOF

exit 0
