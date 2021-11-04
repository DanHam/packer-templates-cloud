#!/usr/bin/env bash
#
# Configure network time
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Exit if systemd-timesyncd is not installed on the target system
if ! chroot /target dpkg -s systemd-timesyncd &>/dev/null; then
    exit 0
fi

# Logging for packer
echo "Configuring network time (systemd-timesyncd)..."

# Configure systemd-timesyncd
conf="/etc/systemd/timesyncd.conf"

# Use the Amazon Time Sync Service
sed -i -e "s/^#\(NTP\)/\1/" \
       -e "s/^\(NTP=\).*/\1169.254.169.123/" /target/"${conf}"
# Use the Debian NTP pool if the Amazon Time Sync Service is unavailable
sed -i "s/^#\(FallbackNTP.*\)/\1/" /target/"${conf}"

# Ensure the systemd-timesyncd service is enabled
chroot /target systemctl enable systemd-timesyncd.service > ${redirect} 2>&1

exit 0
