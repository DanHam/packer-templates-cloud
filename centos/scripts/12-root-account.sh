#!/usr/bin/env bash
#
# Delete any configured root user password and lock the root account
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "${DEBUG}" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Deleting any configured root user password and locking the account"

chroot /target passwd -d root > ${redirect} 2>&1
chroot /target passwd -l root > ${redirect} 2>&1

exit 0
