#!/usr/bin/env bash
#
# Configure network time
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring network time..."

# Ensure ed is installed on the local system
if ! rpm -q ed >/dev/null; then
    echo "Installing ed on local system" >${redirect}
    yum install -y ed >${redirect} 2>&1
fi

# Ensure chrony is installed into the chroot
if ! chroot /target rpm -q chrony >/dev/null; then
    echo "Installing chrony" >${redirect}
    chroot /target yum install -y chrony >${redirect} 2>&1
fi

# Configure chrony
conf="/etc/chrony.conf"

# Use the Amazon Time Sync service as the preferred time source
ed /target/${conf} &>/dev/null<<-EOF
1i
# Use the Amazon Time Sync Service if available
server 169.254.169.123 prefer iburst

.
wq
EOF

# With virtual or cloud based instances interaction with a RTC is not
# desirable and can cause issues
#
# Disable automatic synchronisation of the system and RTC
sed -i "s/^\(rtcautotrim\)/#\1/" /target/${conf}
# Since we don't want to interact with the RTC we can comment out the name
# of the device file used to access it
sed -i "s/^\(rtcdevice\)/#\1/" /target/${conf}
# Since we don't want to interact with the RTC we don't need to track its
# accuracy in a file
sed -i "s/^\(rtcfile\)/#\1/" /target/${conf}
# Do not assume that the RTC is on UTC
sed -i "s/^\(rtconutc\)/#\1/" /target/${conf}
# Disable copying of system time to the RTC
sed -i "s/^\(rtcsync\)/#\1/" /target/${conf}

# Disable logging of measurements, statistics, tracking etc
sed -i "s/^\(log.* \)/#\1/" /target/${conf}

# Virtual instances should never be used as a reliable time source
sed -i "s/^\(allow\)/#\1/" /target/${conf}
cat >> /target/${conf} <<EOF

# Disable use of this machine as a time server
deny all
EOF

exit 0
