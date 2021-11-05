#!/usr/bin/env bash
#
# Disable consistent network device naming
#
# Consistent network device naming is not particularly useful for VMs and
# can be disabled by adding net.ifnames=0 to the kernel boot arguments
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

grub_update() {
    echo "Updating grub post changes" >${redirect}
    chroot /target update-grub >${redirect} 2>&1
}

# Logging for packer
echo "Ensuring consistent network device naming is disabled"

# Check for the required kernel arg in the GRUB_CMDLINE_LINUX and
# GRUB_CMDLINE_LINUX_DEFAULT stanza's ignoring commented lines
grub="/etc/default/grub"
karg="$(sed -n 's/^GRUB_CMDLINE_LINUX.*=".*\(net.ifnames=.*\).*"/\1/p' \
    /target/${grub})"

if [ -z "${karg}" ]; then
    # The kernel arg to disable consistent net device naming is missing
    # from the grub config file and needs to be added. Add the arg to the
    # GRUB_CMDLINE_LINUX stanza in preference to GRUB_CMDLINE_LINUX_DEFAULT
    echo "Adding the required kernel arg to the grub config" >${redirect}
    # If the GRUB_CMDLINE_LINUX stanza itself is missing (or commented out) we
    # can just add the stanza and kernel arg to the end of the file. Otherwise
    # we need to add the required kernel arg to the existing stanza/arguments
    if ! grep ^GRUB_CMDLINE_LINUX= /target/${grub} >/dev/null; then
        printf "%s" '
            # Configure kernel command line options
            GRUB_CMDLINE_LINUX="net.ifnames=0"
        ' | sed 's/^ *//g' >> /target/${grub}
    else
        sed -i 's/\(GRUB_CMDLINE_LINUX="\)\(.*\)\("\)/\1\2 net.ifnames=0\3/g' \
            /target/${grub}
    fi
    grub_update # Update grub post changes
else
    # The kernel arg is present in the grub config file. We need to ensure it
    # is set to *disable* consistent net device naming e.g. net.ifnames=0
    if [ "${karg#*=}" != "0" ]; then
        echo "Consistent net dev naming is currently enabled. Disabling." \
            >${redirect}
        sed -i 's/\(GRUB_CMDLINE_LINUX.*=".*net.ifnames\)=[0-9]\(.*"\)/\1=0\2/g' \
            /target/${grub}
        grub_update # Update grub post changes
    fi
fi

exit 0
