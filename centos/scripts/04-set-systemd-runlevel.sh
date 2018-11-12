#!/usr/bin/env bash
#
# Set the required systemd runlevel/target
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring the required systemd runlevel/target..."

chroot /target rm -f /etc/systemd/system/default.target
chroot /target ln -s /lib/systemd/system/multi-user.target \
    /etc/systemd/system/default.target > ${redirect} 2>&1

exit 0
