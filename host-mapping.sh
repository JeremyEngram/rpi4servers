#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Backup the original /etc/hosts file
cp /etc/hosts /etc/hosts.bak

# Define the hostname-IP mappings
declare -A host_mappings=(
    ["datacenter.local"]="192.168.1.159"
    ["csi.local"]="192.168.1.74"
    ["penetratingnu.local"]="192.168.1.82"
    ["masterserver.local"]="192.168.1.63"
)

# Add the mappings to the /etc/hosts file
for hostname in "${!host_mappings[@]}"; do
    ip_address="${host_mappings[$hostname]}"
    echo "$ip_address $hostname" >> /etc/hosts
done

echo "Local DNS and static IP configuration updated."

