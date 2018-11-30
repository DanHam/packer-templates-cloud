#!/usr/bin/env bash
#
# Configure cloud packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[ "$DEBUG" = true ] && redirect="/dev/stdout" || redirect="/dev/null"

# Only configure if installation was enabled in the Packer template
[ "$ENABLE_CLOUD_INIT" = true ] || exit 0

# Logging for packer
echo "Configuring cloud packages for EC2..."

# Configuration files for cloud-init
cloud_conf="/etc/cloud/cloud.cfg"
cloud_override="/etc/cloud/cloud.cfg.d/01_centos_cloud.cfg"
cloud_confd="/etc/cloud/cloud.cfg.d"

# By default the CentOS cloud-init package disables collection of EC2
# metadata. Since the target cloud platform is Amazons EC2 we want to
# enable it
echo "Enabling cloud-init collection of EC2 metadata" >${redirect}
sed -i "/disable-ec2-metadata/ d" /target/${cloud_conf}

# Since the target platform is Amazons EC2 we can speed up processing by
# only running the cloud-init code for the Amazon EC2 datasource
echo "Disabling all cloud-init datasources except EC2" >${redirect}
cat <<EOF >/target/${cloud_confd}/90_datasources.cfg
# Configure data sources from which to pull metadata
datasource_list: [ Ec2 ]
EOF

# Configure sensible settings/overrides for cloud-init
# By default cloud-init sets the default locale to en_US.UTF-8 on first
# boot. The settings below will override this behaviour setting the system
# locale to the value configured in the Packer template or to the default
# defined below if unset
: ${LOCALE:="en_GB.UTF-8"}
echo "Setting sensible defaults and overrides for cloud-init" >${redirect}
cat > /target/${cloud_override} <<EOF
locale: ${LOCALE}
manage_etc_hosts: true
system_info:
  default_user:
    name: admin
    groups: wheel
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    gecos: CentOS Administrator
    lock_passwd: true
EOF

exit 0
