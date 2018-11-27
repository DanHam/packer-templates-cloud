#!/usr/bin/env bash
#
# Configure cloud packages
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Only configure if installation was enabled in the Packer template
[ "$ENABLE_CLOUD_INIT" = true ] || exit 0

# Packer logging
echo "Configuring cloud packages for EC2..."

# Configuration files for cloud-init
cloud_conf="/etc/cloud/cloud.cfg"
cloud_datasrc="/etc/cloud/cloud.cfg.d/90_dpkg.cfg"

# By default the Debian cloud-init package disables collection of EC2
# metadata. Since the target cloud platform is Amazons EC2 we want to
# enable it. Note that we also require the cloud-guest-utils package that
# contains the ec2metadata script
echo "Enabling cloud-init collection of EC2 metadata" >${redirect}
sed -i "/disable-ec2-metadata/ d" /target/${cloud_conf}

# Since the target platform is Amazons EC2 we can speed up processing by
# only running the cloud-init code for the Amazon EC2 datasource
echo "Disabling all cloud-init datasources except EC2" >${redirect}
sed -i "/^datasource_list:/ s/\[.*\]/\[ Ec2 \]/g" /target/${cloud_datasrc}

exit 0
