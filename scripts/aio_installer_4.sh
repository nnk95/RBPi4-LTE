#!/bin/sh

# All-In-One Installer for:
# https://github.com/nnk95/RBPi4-LTE

# Stage 4

echo "Starting Stage 4"

sudo sed -i 's/aio_installer_4/aio_installer_5' /home/pi/.bashrc
sleep 5s

cd /home/pi/installers
sudo ./install_auto_connect.sh

sudo systemctl status qmi_reconnect.service
