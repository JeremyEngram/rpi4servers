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

# Install DHCP server
sudo apt install -y isc-dhcp-server

# Configure DHCP server
sudo sed -i '/INTERFACESv4/d' /etc/default/isc-dhcp-server
echo "INTERFACESv4=\"eth0\"" | sudo tee -a /etc/default/isc-dhcp-server

sudo mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option routers 192.168.1.1;
  option domain-name-servers 8.8.8.8;
}
EOF

# Start DHCP server and rollback on failure
sudo systemctl start isc-dhcp-server
if [[ $? -ne 0 ]]; then
  echo "Failed to start ISC DHCP server. Rolling back changes..."
  sudo apt purge -y isc-dhcp-server
  sudo mv /etc/dhcp/dhcpd.conf.backup /etc/dhcp/dhcpd.conf
  sudo systemctl restart apache2
  exit 1
fi

sudo systemctl enable isc-dhcp-server

# Update /etc/hosts file
sudo sed -i '/datacenter/d' /etc/hosts
echo "192.168.1.159 datacenter" | sudo tee -a /etc/hosts
