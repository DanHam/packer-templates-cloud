#!/usr/bin/env bash
#
# Configure network time
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring network time..."

# Ensure ed is installed on the local system
if ! dpkg -s ed &>/dev/null; then
    echo "Installing ed on local system" >${redirect}
    DEBIAN_FRONTEND=noninteractive apt-get install -y ed >${redirect} 2>&1
fi

# Ensure chrony is installed into the chroot
if ! chroot /target dpkg -s chrony &>/dev/null; then
    echo "Installing chrony" >${redirect}
    chroot /target apt-get update >${redirect} 2>&1
    chroot /target DEBIAN_FRONTEND=noninteractive \
        apt-get --no-install-recommends install -y chrony >${redirect} 2>&1
fi

# Configure chrony
conf="/etc/chrony/chrony.conf"

# Use the Amazon Time Sync service as the preferred time source
ed /target/${conf} &>/dev/null<<-EOF
3i

# Use the Amazon Time Sync Service if available
server 169.254.169.123 prefer iburst

# If the Amazon Time Sync Service is unavailable for any reason, use the
# debian NTP pool
.
\$a

# Disable use of this machine as a time server
deny all
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
# Since we don't want to interact with the RTC we won't want to parse the
# file specified with the hwclockfile directive for RTC info
sed -i "s/^\(hwclockfile\)/#\1/" /target/${conf}

# Disable logging of measurements, statistics, tracking etc but preserve
# any configured setting for the logdir directive
sed -i "/^log[^dir]/ s/^\(log.* \)/#\1/" /target/${conf}

# Virtual instances should never be used as a reliable time source
sed -i "s/^\(allow\)/#\1/" /target/${conf}

exit 0
