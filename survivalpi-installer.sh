#!/bin/bash
# This script is meant to be run on a fresh installation of the 
# latest version of latest Raspian or Raspbian Lite.
#
# Usage: If you have internet, get the latest version from:
#     wget https://URL | sudo bash
# Run this as ROOT!
#
# Some day this will be more interactive, but till then, edit the variables as 
# needed.
# COMINGSOON: Load from config file
# COMINGSOON: Interactive
# 
THISHOST=survivor
THISDOMAIN=survive.local
MYADMIN=administrator
THISNET="10.1.0.0/24" # DHCP net
THISWIFI=survivalnet
THISWIFIPASS=WeAreAlive

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   echo "Please use sudo."
   exit 1
fi

# Set the stage! (Find out where we are in the install process)
STAGE=0
if [ -f /etc/survivalpi/survivalpi.env ]; then
    if grep -q STAGE= /etc/survivalpi/survivalpi.env ; then
        source /etc/survivalpi/survivalpi.env
        echo "Extracted STAGE=""$STAGE"" (counter) from /etc/survivalpi/survivalpi.env"
        if ! [ "$STAGE" -eq "$STAGE" ] 2> /dev/null; then
            echo -e "\nEXITING: STAGE (counter) value == ""$STAGE"" is non-integer in /etc/survivalpi/survivalpi.env"
            exit 1
        elif [ "$STAGE" -lt 0 ] || [ "$STAGE" -gt 9 ]; then
            echo -e "\nEXITING: STAGE (counter) value == ""$STAGE"" is out-of-range in /etc/survivalpi/survivalpi.env"
            exit 1
        fi
    fi

    if $($REINSTALL); then
        STAGE=0
        #ARGS="$ARGS"" --extra-vars reinstall=True"
        ARGS="$ARGS,\"reinstall\":True"    # Needs boolean not string so use JSON list
        sed -i 's/^STAGE=.*/STAGE=0/' /etc/survivalpi/survivalpi.env
        echo "Wrote STAGE=0 (counter) to /etc/survivalpi/survivalpi.env"
    elif [ "$STAGE" -ge 2 ] && $($DEBUG); then
        STAGE=2
        sed -i 's/^STAGE=.*/STAGE=2/' /etc/survivalpi/survivalpi.env
        echo "Wrote STAGE=2 (counter) to /etc/survivalpi/survivalpi.env"
    elif [ "$STAGE" -eq 9 ]; then
        echo -e "\n\e[1mEXITING: STAGE (counter) in /etc/survivalpi/survivalpi.env shows Stage 9 Is Already Done.\e[0m"
        usage
        exit 0    # Allows rerunning https://download.iiab.io/install.txt
    fi
fi
if [ "$STAGE" -lt 2 ] && $($DEBUG); then
    echo -e "\n'--debug' *ignored* as STAGE (counter) < 2."
fi


echo -e "\nTRY TO RERUN './iiab-install' IF IT FAILS DUE TO CONNECTIVITY ISSUES ETC!\n"

if  [ "$STAGE" -eq 0 ]; then
# Set hostname
echo "Setting Hostname to $THIDHOST.$THISDOMAIN"
hostnamectl set-hostname $THIDHOST.$THISDOMAIN
sed 's/raspberry/$THISHOST $THISHOST.$THISDOMAIN/g' /etc/hosts

# Create an Admin User
echo "Adding admin user, $MYADMIN"
adduser $MYADMIN -g wheel
echo "Please enter a password for $MYADMIN. "
passwd $MYADMIN
STAGE=1
sed -i 's/^STAGE=.*/STAGE=1/' /etc/survivalpi/survivalpi.env
echo "Wrote STAGE=1 (counter) to /etc/survivalpi/survivalpi.env"
fi
# STAGE=1

if  [ "$STAGE" -le 1 ]; then
# Start with fresh software and such
apt-get update
apt-get upgrade
STAGE=2
sed -i 's/^STAGE=.*/STAGE=2/' /etc/survivalpi/survivalpi.env
echo "Wrote STAGE=2 (counter) to /etc/survivalpi/survivalpi.env"
fi
# STAGE=2

# Menu to select features:
# Networking:
#    Connect to existing network
#    Act as Accesspoint
#    Both
#
# Services:
#    Wifi Accesspoint
#    DNS
#    DHCP
#    Authentication (LDAP) Server
#    Proxy
#    Webserver
#    Email Server
#    Chat Server
#    Voice Phone (SIP)
#    Video Conferencing
#    Social Media Server
#    
# Components::
#    WordPress
#    OwnCloud/NextCloud
#    Webmail
#    Kiwiki
#    eBooks
#    Moodle/LMS
#    Map/GEO apps
#    TAK server
#    Ham Pi
#    

##### START with Salt so it can control everything else.

### Install Salt as a masterless minion. 
# Ensure keyrings dir exists
mkdir -p /etc/apt/keyrings
# Download public key
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
# Create apt repo target configuration
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources
sudo apt-get install salt-minion
sudo systemctl enable salt-minion && sudo systemctl start salt-minion
mkdir -p /etc/salt
printf "# File: /etc/salt/minion" > /etc/salt/minion
printf "file_client: local" >> /etc/salt/minion
mkdir -p /srv/salt
printf "" >> /etc/salt/minion
printf "file_roots:"  >> /etc/salt/minion
printf "  base:"  >> /etc/salt/minion
printf "    - /srv/salt"  >> /etc/salt/minion
# Now set up the Salt State Tree, top file, and SLS modules in the same way that they would be set up on a master. 

BHC TODO LEFT OFF HERE


sudo salt-call --local state.apply
# To run a specific state (e.g., webserver.sls):
# bash
# sudo salt-call --local state.apply webserver








# Next we add RaspAP (which includes dnsmasq and a few other things...
curl -sL https://install.raspap.com | bash




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




# RE-Warn user to re-run installer if the machine reboots.


# Run updates.
echo "Installing updates..."
apt update -y
apt upgrade -y
