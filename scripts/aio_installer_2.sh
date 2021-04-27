#!/bin/sh

# All-In-One Installer for:
# https://github.com/nnk95/RBPi4-LTE

# Stage 2

echo "Starting Stage 2"

sudo sed -i 's/aio_installer_2/aio_installer_3' /home/pi/.bashrc

ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub user@10.242.23.181

echo "dtoverlay=dwc2,dr_mode=host" | sudo tee -a /boot/config.txt

cd /home/pi/installers
sudo ./qmi_install.sh
