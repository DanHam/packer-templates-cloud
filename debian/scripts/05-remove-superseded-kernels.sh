#!/usr/bin/env bash
#
# Remove old or superseded kernel packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Removing old kernels post upgrade..."

# Get a list of all kernels installed in the chroot target
list=$(LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
    dpkg -l | \
    awk '/linux-image-[0-9]+\./ { print $2,$3; }' | \
    sort --unique --reverse --version-sort | \
    cut -d' ' -f 1)
echo -e "Currently installed kernel packages:\n${list}" >${redirect}

latest="$(echo "${list}" | head -n1)"
echo -e "Latest kernel:\n${latest}" >${redirect}

superseded="$(echo "${list}" | tail --lines=+2 | tr -s '\n' ' ')"

if [ "x${superseded}" = "x" ]; then
    echo "No superseded kernels to remove" >${redirect}
else
    echo -e "Removing superseded kernels:\n${superseded}" >${redirect}
    LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
        apt-get --purge remove -y ${superseded} >${redirect} 2>&1
fi

exit 0
