#!/bin/sh

# All-In-One Installer for:
# https://github.com/nnk95/RBPi4-LTE

# Stage 3

echo "Starting Stage 3"

sudo sed -i 's/aio_installer_3/aio_installer_4' /home/pi/.bashrc
sleep 10s

lsusb

cd /home/pi/files/quectel-CM
sudo ./quectel-CM -s sunsurf 65 user123

cd /home/pi/installers
sudo ./install_auto_connect.sh

sudo systemctl status qmi_reconnect.service

hardreboot
