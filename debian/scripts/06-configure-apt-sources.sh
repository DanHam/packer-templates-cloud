#!/usr/bin/env bash
#
# Configure APT sources
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring APT sources..."

# Determine the codename for the release
codename="$(sed -n -e 's/VERSION=".*(\(.*\))"/\1/p' /target/etc/os-release)"
echo "Creating sources.list file for Debian ${codename}" >${redirect}

# The mirror defined in the Packer template and exported as environment
# variables will be used in preference to the default below
: ${APT_MIRROR:="http://httpredir.debian.org"}

sources="/etc/apt/sources.list"
cat > /target/${sources} << EOF
deb ${APT_MIRROR}/debian ${codename} main
deb http://security.debian.org/debian-security ${codename}/updates main
deb ${APT_MIRROR}/debian ${codename}-updates main
EOF

exit 0
