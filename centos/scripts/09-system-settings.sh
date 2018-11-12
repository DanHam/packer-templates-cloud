#!/usr/bin/env bash
#
# Configure system settings
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for packer
echo "Configuring system settings..."

# Configure tuned for virtual system
echo "virtual-guest" > /target/etc/tuned/active_profile

# Disable use of tmpfs for /tmp
chroot /target systemctl mask tmp.mount > ${redirect} 2>&1

# Kernel package settings
cat > /target/etc/sysconfig/kernel <<EOF
# Specify whether new-kernel-pkg should make new kernels the default
UPDATEDEFAULT=yes

# Specify the default kernel package type
DEFAULTKERNEL=kernel
EOF

# Configure yum variable 'instance type markers' for cloud
echo "genclo" > /target/etc/yum/vars/infra


exit 0
