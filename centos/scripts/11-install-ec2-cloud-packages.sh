#!/usr/bin/env bash
#
# Install cloud packages appropriate to AWS EC2
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Only install and configure cloud-init if configured to do so in the
# Packer template
[ "$ENABLE_CLOUD_INIT" = true ] || exit 0

# Logging for packer
echo "Installing cloud packages for EC2..."

# Install cloud-init and associated utils
packages="cloud-init cloud-utils-growpart"
chroot /target yum install -y ${packages} >${redirect} 2>&1

exit 0
