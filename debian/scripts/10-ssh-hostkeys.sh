#!/usr/bin/env bash
#
# Remove the target systems ssh host keys. This ensures that the systems
# created from the build image do not all have the same ssh keys.
# Create a service to re-create/generate the ssh host keys on system
# startup prior to start up of the sshd server.

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Ensuring all systems created from target have unique ssh host keys"

# Remove all ssh host keys
rm -f /target/etc/ssh/ssh_host_*_key*

# Copy the unit file and associated script into place and ensure the
# service is set to start on boot
cp  ../files/generate-ssh-host-keys.service /target/etc/systemd/system/
cp ../files/generate-ssh-host-keys.sh /target/usr/local/sbin/
chmod +x /target/usr/local/sbin/generate-ssh-host-keys.sh
chroot /target systemctl enable generate-ssh-host-keys.service

exit 0
