#!/bin/sh

# Simple file to download the easy power management Python scripts

mkdir /home/pi/runners/
cd /home/pi/runners

wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/reboot_hard.py
sudo chmod +x reboot_hard.py
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/poweroff_hard.py
sudo chmod +x poweroff_hard.py

echo " "
echo "Downloads completed."

rm /home/pi/runners/power_aio.sh & exit 0
