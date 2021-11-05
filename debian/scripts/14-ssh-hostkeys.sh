#!/usr/bin/env bash
#
# Remove the target systems ssh host keys. This ensures that the systems
# created from the build image do not all have the same ssh keys.
#
# Regeneration of the keys will occur automatically for systems with
# cloud-init installed.
#
# For systems without cloud-init we need to create a service to
# re-create/generate the ssh host keys on system startup prior to start up
# of the sshd server. Packer should have uploaded the required unit file
# and script to the location given by the TARGET_FILES_DIR env var. The env
# var should be set in the Packer template and exported in the provisioner
# calling this script
set -o errexit
set -o nounset

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Ensuring all systems created from target have unique ssh host keys"

# Remove all ssh host keys
rm -f /target/etc/ssh/ssh_host_*_key*

# Exit if cloud-init is going to be installed. Otherwise copy the unit file
# and associated script into place and ensure the service is set to start
# on boot
if [ "$ENABLE_CLOUD_INIT" = true ]; then
    echo "Exiting: cloud-init is set to be installed and generate ssh keys" \
        > ${redirect}
    exit 0
else
    echo "Creating systemd service to generate ssh host keys on next boot" \
        > ${redirect}
fi

cp "${TARGET_FILES_DIR}"/generate-ssh-host-keys.service \
    /target/etc/systemd/system/
cp "${TARGET_FILES_DIR}"/generate-ssh-host-keys.sh /target/usr/local/sbin/
chmod +x /target/usr/local/sbin/generate-ssh-host-keys.sh
chroot /target systemctl enable generate-ssh-host-keys.service

exit 0
