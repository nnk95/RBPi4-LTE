#!/bin/sh

# Simple file to download the easy power management Python scripts

mkdir /home/pi/runners/
cd /home/pi/runners

wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE/main/scripts/reboot_hard.py
chmod +x reboot_hard.py
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE/main/scripts/poweroff_hard.py
chmod +x poweroff_hard.py

echo " "
echo "Downloads completed."

rm /home/pi/runners/power_aio.sh & exit 0
