#!/usr/bin/env bash
#
# Install packages of benefit when running as a cloud instance
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Only install and configure cloud-init if configured to do so in the
# Packer template
[ "$ENABLE_CLOUD_INIT" = true ] || exit 0

# Packer logging
echo "Installing cloud packages for EC2..."

# Install cloud-init and associated utils
packages="policykit-1 cloud-init cloud-guest-utils"
chroot /target apt-get update >${redirect} 2>&1
DEBIAN_FRONTEND="noninteractive" chroot /target \
    apt-get --no-install-recommends -y install ${packages} \
    >${redirect} 2>&1

# Configure cloud-init
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
