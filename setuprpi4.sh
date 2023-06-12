#!/bin/bash

# Set static IP address
cat <<EOF | sudo tee /etc/dhcpcd.conf
interface eth0
static ip_address=192.168.1.159/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8
EOF

# Restart networking service
sudo systemctl restart networking

# Install Certbot for SSL certificate generation
sudo apt update
sudo apt install -y certbot

# Obtain SSL certificate for Apache
sudo certbot certonly --standalone -d datacenter.local

# Configure Apache with SSL
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo systemctl restart apache2

# Update /etc/hosts file
sudo sed -i '/datacenter/d' /etc/hosts
echo "192.168.1.159 datacenter" | sudo tee -a /etc/hosts
