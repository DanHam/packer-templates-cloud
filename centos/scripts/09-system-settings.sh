#!/usr/bin/env bash
#
# Configure system settings
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring system settings..."

echo "Configuring tuned profile for virtual system" >${redirect}
echo "virtual-guest" > /target/etc/tuned/active_profile

echo "Disabling use of tmpfs for /tmp" >${redirect}
chroot /target systemctl mask tmp.mount >${redirect} 2>&1

echo "Configuring settings for kernel packages" >${redirect}
cat > /target/etc/sysconfig/kernel <<EOF
# Specify whether new-kernel-pkg should make new kernels the default
UPDATEDEFAULT=yes

# Specify the default kernel package type
DEFAULTKERNEL=kernel
EOF

echo "Configuring yum variable 'instance type markers' for cloud" >${redirect}
echo "genclo" > /target/etc/yum/vars/infra

echo "Generating system authentication resource config files" >${redirect}
chroot /target authconfig --updateall

exit 0
