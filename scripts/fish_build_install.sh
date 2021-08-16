#!/bin/bash

# This is a quick installer
# script I made to build and install the latest version of
# fish on my Raspberry Pi.
#
# Use at your own risk as I have made no effort to make
# this install safe!

clear
set -e
current_dir=$(pwd)

echo ("***** BEGIN FISH INSTALLATION *****")

FISH_VERSION=$(curl -s https://api.github.com/repos/fish-shell/fish-shell/releases | grep -o 'tag/[v.0-9]*' | awk -F/ '
{print $2}' | head -1)
echo (" ")
echo ("FISH version to be installed: " +$FISH_VERSION)

# Install dependencies
echo "Installing dependencies.."
sudo apt-get install build-essential cmake ncurses-dev libncurses5-dev libpcre2-dev gettext
clear
echo ("Dependencies installation complete.")
echo (" ")

# Create a build directory
echo ("Now making a build directory")
mkdir fish-install
cd fish-install

# Download and extract the latest build
echo ("Downloading latest FISH build..")
wget https://github.com/fish-shell/fish-shell/releases/download/$FISH_VERSION/fish-$FISH_VERSION.tar.xz
tar -xvf fish-$FISH_VERSION.tar.xz
cd fish-$FISH_VERSION
echo (" ")

# Build and install
echo ("Now starting CMAKE for FISH..")
cmake .
make
sudo make install
clear

# Add to shells
echo ("Now adding fish to /etc/shells..")
echo /usr/local/bin/fish | sudo tee -a /etc/shells
echo (" ")

# Set as user's shell
echo ("Now setting fish as user's shell..")
chsh -s /usr/local/bin/fish
echo (" ")

# Delete build directory
cd ../../
echo ("Deleting build directory..")
rm -rf fish-install
cd $initial_dir
echo ("Deleting install script..")
rm -f fish_build_install.sh
echo(" ")

echo ("***** END FISH INSTALLATION *****")