#!/usr/bin/env bash
#
# Ensure all files have the correct SELinux contexts
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Ensuring all files have the correct SELinux contexts..."

# The section of the fixfiles script that deals with /tmp makes use of
# commands that can only be used when the system (and SELinux) is up and
# running and therefore errors.
# However, we remove all files from /tmp and /var/tmp as part of the build.
# As such we don't need to relabel /tmp and can avoid the errors by
# commenting out this section in entirety
begin='echo \"Cleaning up labels on \/tmp\"'
end='\[ ! -e \/var\/lib\/debug \]'
sed -i "/^${begin}/,/^${end}/{s/^/#/g}" /target/sbin/fixfiles

# Relabel the filesystem
# We must specify a logfile (-l) here or the fixfile script errors. This
# is because there is no tty in the chroot.
chroot /target fixfiles -l /dev/null restore > ${redirect} 2>&1

# Restore the commented out section of the fixfiles script
sed -i "/^#${begin}/,/^#${end}/{s/^#//g}" /target/sbin/fixfiles

exit 0
