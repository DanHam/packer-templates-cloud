#!/usr/bin/env bash
#
# Prepare the source instance
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Preparing the source instance..."

echo "Updating the source instance apt cache..." > ${redirect}
apt-get update >${redirect} 2>&1

exit 0
