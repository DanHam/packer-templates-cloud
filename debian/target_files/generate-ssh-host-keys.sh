#!/usr/bin/env bash
#
# Generate ssh host keys for the system if required.
types="rsa ecdsa ed25519" # Recommended types
for type in ${types}
do
    keyfile="/etc/ssh/ssh_host_${type}_key"
    if [ ! -f "${keyfile}" ]; then
        echo "Generating SSH ${type^^} key"
        /usr/bin/ssh-keygen -t "${type}" -q -N '' -f "${keyfile}"
    fi
done

exit 0
