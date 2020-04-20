#!/bin/bash
# This script is meant to be run on a fresh installation of the 
# latest version of latest Raspian Lite.
# Usage: If you have internet, get the latest version from:
#     wget https://URL | sudo bash
# Run this as ROOT!
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   echo "Please use sudo."
   exit 1
fi
# Config or interactive?  
# In any case, create a log file AND a config save that can be used as a
# config file.

# Run updates.
apt update -y
apt upgrade -y

# Set hostname

# Create an Admin User

# Set up DNS (Local and caching)
# including .local as default.

# Set up DHCP

# Set up WiFi 

# Install LAMP stack

# Install WordPress
#    WP-multi? https://wordpress.org/support/article/create-a-network/

# Install Media Wiki

# Install NextCloud

# Install Email?

# Install a social media network....
#    OSSN? https://www.opensource-socialnetwork.org/
#    ELGG/PLIGG?
#    BuddyPress? 
#    Dolphin?
#    b2evo?
