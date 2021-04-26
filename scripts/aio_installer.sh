#!/bin/sh

# All-In-One Installer for:
# https://github.com/nnk95/RBPi4-LTE

# Stage 1

echo "Setting up RASPI-CONFIG"

grep -E -v -e '^\s*#' -e '^\s*$' <<END | \
sed -e 's/$//' -e 's/^\s*/\/usr\/bin\/raspi-config nonint /' | bash -x -

do_boot_wait 0
do_ssh 1
do_boot_behaviour B2 
do_configure_keyboard
do_hostname RBPi4-LTE
do_wifi_country US
do_change_timezone Asia/Singapore
do_change_locale en_SG.UTF-8

END

echo " "
echo "Enter new Raspberry Pi Password: "
passwd

echo " "
echo "Updating Packages"
apt-get update && apt update && apt upgrade -y
apt install -y ruby ruby-dev gcc make fonts-noto-color-emoji raspberrypi-kernel-headers
gem install termclock

echo " "
echo "Installing SixfabPower using token:"
echo "Creme-Apple-Most-Chair-Carve-Fend-Stud-Crawl-Evil-Relax-Drone-Fifty-Stunt-Ripen-Vegan-Skies-Stain-Drum"
curl https://install.power.sixfab.com | sudo sh -s Creme-Apple-Most-Chair-Carve-Fend-Stud-Crawl-Evil-Relax-Drone-Fifty-Stunt-Ripen-Vegan-Skies-Stain-Drum

echo " "
echo "Installing ZeroTier"
curl -s https://install.zerotier.com/ | bash
zerotier-cli join 8850338390d6e944

touch /home/pi/.bash_aliases
echo "alias apt='sudo apt'" | sudo tee -a /home/pi/.bash_aliases
echo "alias apt-get='sudo apt-get'" | sudo tee -a /home/pi/.bash_aliases
echo "alias chmod='sudo chmod +x'" | sudo tee -a /home/pi/.bash_aliases
echo "alias ls='ls -alF --color=auto'" | sudo tee -a /home/pi/.bash_aliases
echo "alias termclock='termclock -af -nl -tf=%H:%M:%S'" | sudo tee -a /home/pi/.bash_aliases
echo "alias gem='sudo gem'" | sudo tee -a /home/pi/.bash_aliases
echo "alias hardreboot='python /home/pi/runners/reboot_hard.py'" | sudo tee -a /home/pi/.bash_aliases
echo "alias hardpoweroff='python /home/pi/runners/poweroff_hard.py'" | sudo tee -a /home/pi/.bash_aliases
. /home/pi/.bash_aliases

mkdir /home/pi/installers
mkdir /home/pi/runners

wget -P /home/pi/runners https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/reboot_hard.py
chmod reboot_hard.py
wget -P /home/pi/runners https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/poweroff_hard.py
chmod poweroff_hard.py

wget -P /home/pi/installers https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/qmi_install.sh
chmod qmi_install.sh

wget -P /home/pi/installers https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/install_auto_connect.sh
chmod install_auto_connect.sh

# Getting files for: stage 2
wget -P /home/pi/installers https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/aio_installer_2.sh
chmod /home/pi/installers/aio_installer_2.sh
wget -P /home/pi/installers https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/aio_installer_3.sh
chmod /home/pi/installers/aio_installer_3.sh

#echo "/home/pi/installers/aio_installer_2.sh" | sudo tee -a /home/pi/.bashrc

read -p "Press ENTER key to power off pi" ENTER
poweroff
