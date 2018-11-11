#!/usr/bin/env bash
#
# Ensure all files have the correct SELinux contexts

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Ensure all files have the correct SELinux contexts..."

# The SELinux script used to correct the SELinux contexts assumes a tty.
# Since this run under a chroot there isn't one so we need a temp fix.
sed -i '/^logit () {$/a LOGFILE="/dev/null"' /target/sbin/fixfiles

# Relabel the filesystem
chroot /target fixfiles restore > ${redirect} 2>&1

# Undo the temp fix
sed -i '/^logit () {$/{n;d}' /target/sbin/fixfiles

exit 0
