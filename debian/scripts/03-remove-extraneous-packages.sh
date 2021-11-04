#!/usr/bin/env bash
#
# Remove extraneous packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Removing extraneous packages installed by debootstrap..."

# List of unwanted packages
list="cgmanager
      libcgmanager0
      libnih-dbus1
      libnih1
      systemd-shim"

# Build a list of unwanted packages that are installed and remove
packages=()
for package in ${list}
do
    if chroot /target dpkg --status "${package}" &>/dev/null; then
        echo "Found unwanted package: ${package}" > ${redirect}
        packages+=("${package}")
    fi
done

if [ ${#packages[@]} -gt 0 ]; then
    echo "Removing the following packages:" > ${redirect}
    echo "${packages[@]}" > ${redirect}

    LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
        apt-get --purge autoremove -y "${packages[@]}" > ${redirect} 2>&1
else
    echo "No unwanted packages found" > ${redirect}
fi

exit 0
