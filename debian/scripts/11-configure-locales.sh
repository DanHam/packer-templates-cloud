#!/usr/bin/env bash
#
# Configure and generate system locales
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring and generating system locales..."

localegen="/etc/locale.gen"
if [ ! -f "/target/${localegen}" ]; then
    # The locales package should create the /etc/locale.gen file
    if ! chroot /target dpkg -s locales &>/dev/null; then
        LANG=C.UTF-8 DEBIAN_FRONTEND="noninteractive" chroot /target \
            apt-get --no-install-recommends install -y locales > \
            ${redirect} 2>&1
    else
        echo "ERROR: Missing locale file under /target: /etc/locale.gen"
        exit 1
    fi
fi

# Locales defined in the Packer template and exported as environment
# variables will be used in preference to the default below
: ${LOCALES:="en_GB.UTF-8"}

# The locale.gen file lists locales that should be built. By default the
# file contains a commented list of all locales. We need to uncomment the
# locales we want the system to support and then run the command to
# generate the locales
for locale in ${LOCALES}
do
    if ! grep ${locale} /target/${localegen} &>/dev/null; then
        echo "ERROR: Unrecognised locale: ${locale}"
        exit 1
    fi
    echo "Configuring support for ${locale}" >${redirect}
    sed -i "/${locale}/ s/^# //g" /target/${localegen}
done
# Generate the locales
chroot /target locale-gen >${redirect} 2>&1

exit 0
