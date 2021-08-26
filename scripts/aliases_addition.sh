#!/bin/sh

# Appending new aliases to ~/.bash_aliases
# simply just for future convenience

echo "alias apt='sudo apt'" | sudo tee -a ~/.bash_aliases
echo "alias apt-get='sudo apt-get'" | sudo tee -a ~/.bash_aliases
echo "alias chmod='sudo chmod +x'" | sudo tee -a ~/.bash_aliases
echo "alias ls='ls -alF --color=auto'" | sudo tee -a ~/.bash_aliases
echo "alias termclock='termclock -af -nl -tf=%H:%M:%S'" | sudo tee -a ~/.bash_aliases
echo "alias gem='sudo gem'" | sudo tee -a ~/.bash_aliases
echo "alias hardreboot='python /home/pi/runners/reboot_hard.py'" | sudo tee -a ~/.bash_aliases
echo "alias hardpoweroff='python /home/pi/runners/poweroff_hard.py'" | sudo tee -a ~/.bash_aliases
echo "alias lteoff='python /home/pi/runners/lte_off.py'" | sudo tee -a ~/.bash_aliases
echo "alias lteon='python /home/pi/runners/lte_on.py'" | sudo tee -a ~/.bash_aliases
echo "alias lterestart='python /home/pi/runners/lte_restart.py'" | sudo tee -a ~/.bash_aliases

. ~/.bash_aliases
