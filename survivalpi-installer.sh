#!/bin/bash
# This script is meant to be run on a fresh installation of the 
# latest version of latest Raspian Lite.
# Usage: If you have internet, get the latest version from:
#     wget https://URL | sudo bash
# Run this as ROOT!
#
# Some day this will be more interactive, but till then, edit the variables as 
# needed.
THISHOST=survivor
THISDOMAIN=survive.local
MYADMIN=administrator
THISNET="10.1.0.0/24"
THISWIFI=survivalnet
THISWIFIPASS=WeAreAlive

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   echo "Please use sudo."
   exit 1
fi



# Run updates.
echo "Installing updates..."
apt update -y
apt upgrade -y

# Set hostname
echo "Setting Hostname to $THIDHOST.$THISDOMAIN"
hostnamectl set-hostname $THIDHOST.$THISDOMAIN
sed 's/raspberry/$THISHOST $THISHOST.$THISDOMAIN/g' /etc/hosts


# Create an Admin User
echo "Adding admin user, $MYADMIN"
adduser $MYADMIN -g wheel
echo "Please enter a password for $MYADMIN. "
passwd $MYADMIN


# Set up DNS (Local and caching)
# including .local as default.

# Set up DHCP

# Set up WiFi 

# Install LAMP/s stack
apt-get install apache2 -y
apt-get install php7.3 php7.3-gd sqlite php7.3-sqlite3 php7.3-curl php7.3-zip php7.3-xml php7.3-mbstring php-ldap -y
service apache2 restart
a2enmod rewrite
sed 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
apt-get install php libapache2-mod-php -y
apt-get install mariadb-server mariadb-client php-mysql -y
mkdir /etc/apache2/ssl
echo "Setting up SSL for your server:"
openssl req -x509 -nodes -days 1095 -newkey rsa:2048 -out /etc/apache2/ssl/server.crt -keyout /etc/apache2/ssl/server.key
a2enmod ssl
sed 's/<\/VirtualHost>/SSLCertificateFile    \/etc\/apache2\/ssl\/server.crt\nSSLCertificateKeyFile \/etc\/apache2\/ssl\/server.key/g' /etc/apache2/sites-enabled/000-default-ssl.co1f
service apache2 restart

# Install WordPress
cd /var/www/html
wget http://wordpress.org/latest.tar.gz

tar xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
echo "To complete the WordPress setup, please direct your web browser to:"
echo "https://$THISHOST.$THISDOMAIN/"
echo "You need to create a MySQL user and database for WordPress:"
echo "Here are the commands you'll need: "
echo "sudo mysql"
echo "create user 'wordpress'@'localhost' identified by '[enter password]';"
echo "create database wordpress;"
echo "grant all privileges on wordpress.* to 'wordpress'@'localhost';"
echo "flush privileges;"
echo "exit;"
echo ""


#    WP-multi? https://wordpress.org/support/article/create-a-network/

# Install Media Wiki

# Install NextCloud
cd /var/www/html
mkdir nextcloud
cd nextcloud
wget  https://download.nextcloud.com/server/installer/setup-nextcloud.php
cd ..
chown -R www-data.www-data nextcloud
echo "To complete the NextCloud setup, please direct your web browser to:"
echo "https://$THISHOST.$THISDOMAIN/nextcloud/"


# Install Email?

# Install a social media network....
#    OSSN? https://www.opensource-socialnetwork.org/
#    ELGG/PLIGG?
#    BuddyPress? 
#    Dolphin?
#    b2evo?
