#!/usr/bin/env bash
#
# Install packages of benefit when running as a cloud instance
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Only install cloud-init if configured to do so in the Packer template
[ "${ENABLE_CLOUD_INIT}" = true ] || exit 0

# Packer logging
echo "Installing cloud packages for EC2..."

# Install cloud-init and associated utils
packages=(
    policykit-1
    cloud-init
    cloud-guest-utils
)

chroot /target apt-get update >${redirect} 2>&1
DEBIAN_FRONTEND="noninteractive" chroot /target \
    apt-get --no-install-recommends -y install "${packages[@]}" \
    >${redirect} 2>&1

exit 0
