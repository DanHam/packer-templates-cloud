#!/usr/bin/env bash
#
# ec2 instances do not allow login via the console so we do not need to
# auto-spawn any gettys
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Disabling auto-spawn of gettys as EC2 doesn't allow console login..."

chroot /target sed -i -e 's/^#\(NAutoVTs.*\)/\1/g' \
                      -e 's/\(NAutoVTs\).*/\1=0/g' \
                      /etc/systemd/logind.conf

exit 0
