#!/usr/bin/env bash
#
# Clean and prepare target volume prior to AMI creation
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Cleaning target volume and preparing for use in AMI..."

echo "Cleaning package cache, yum and rpm artifacts" >${redirect}
rm -rf /target/var/cache/yum
rm -f /target/var/lib/rpm/__db.*
rm -f /target/var/lib/yum/uuid

echo "Removing all temp files" >${redirect}
rm -rf /target/tmp/*
rm -rf /target/var/tmp/*

echo "Removing all log files" >${redirect}
find /target/var/log -type f | xargs -I FILE rm -f FILE > ${redirect} 2>&1
# ...but recreate 'lastlog' otherwise we get errors about it being absent
touch /target/var/log/lastlog

echo "Deleting bash history for all users" >${redirect}
roots_hist="$(find /target/root -type f -name .bash_history)"
users_hist="$(find /target/home -type f -name .bash_history | tr -s '\n' ' ')"
rm -f ${roots_hist} ${users_hist}

echo "Deleting the machine id" >${redirect}
sysd_id="/target/etc/machine-id"
dbus_id="/target/var/lib/dbus/machine-id"
# Remove and recreate (and so empty) the machine-id file under /etc
if [ -e ${sysd_id} ]; then
    rm -f ${sysd_id} && touch ${sysd_id}
fi
# Remove the machine-id file under /var/lib/dbus if it is not a symlink
if [[ -e ${dbus_id} && ! -h ${dbus_id} ]]; then
    rm -f ${dbus_id}
fi

exit 0
