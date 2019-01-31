#!/usr/bin/env bash
#
# Install security updates
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Installing security updates..."

LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
        apt-get update >${redirect} 2>&1

LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
        apt-get --no-install-recommends -y upgrade >${redirect} 2>&1

exit 0
