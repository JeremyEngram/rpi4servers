#!/bin/bash

# Function to backup a file
backup_file() {
    local file=$1
    if [[ -f $file ]]; then
        sudo cp "$file" "$file.bak"
    fi
}

# Function to restore a file from backup
restore_file() {
    local file=$1
    local backup_file="$file.bak"
    if [[ -f $backup_file ]]; then
        sudo cp "$backup_file" "$file"
        sudo rm "$backup_file"
    fi
}

# Install BIND9 DNS server
sudo apt update
sudo apt install -y bind9

# Backup the original BIND configuration files
backup_file "/etc/bind/named.conf.local"
backup_file "/etc/bind/named.conf.options"

# Configure BIND9
cat <<EOF | sudo tee /etc/bind/named.conf.local
zone "yourdomain.com" {
    type master;
    file "/etc/bind/db.yourdomain.com";
};
EOF

cat <<EOF | sudo tee /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
    auth-nxdomain no;    # conform to RFC1035
    listen-on-v6 { any; };
};
EOF

# Create a new DNS zone file
sudo tee /etc/bind/db.yourdomain.com > /dev/null <<EOF
\$TTL 604800
@       IN      SOA     ns1.yourdomain.com. admin.yourdomain.com. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.yourdomain.com.
@       IN      A       192.168.1.159
ns1     IN      A       192.168.1.159
EOF

# Restart BIND9 service
sudo systemctl restart bind9

# Check if BIND9 started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start BIND9 DNS server. Rolling back changes..."
    restore_file "/etc/bind/named.conf.local"
    restore_file "/etc/bind/named.conf.options"
    exit 1
fi

# Enable BIND9 service at boot
sudo systemctl enable bind9

echo "BIND9 DNS server is successfully configured."

