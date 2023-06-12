#!/bin/bash

# Update the package list
sudo apt update

# Install Apache web server
sudo apt install -y apache2

# Install MySQL server
sudo apt install -y mariadb-server

# Secure the MySQL installation
sudo mysql_secure_installation

# Install PHP and required modules
sudo apt install -y php libapache2-mod-php php-mysql

# Configure Apache to use PHP module
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf

# Restart Apache web server
sudo systemctl restart apache2

# Enable Apache and MySQL services at boot
sudo systemctl enable apache2
sudo systemctl enable mariadb

# Print MySQL root password for reference
echo "MySQL root password:"
sudo cat /etc/mysql/debian.cnf | grep password | head -n 1 | awk '{print $3}'
