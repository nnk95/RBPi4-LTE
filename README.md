# RBPi4-LTE
## Setting up of a Raspberry Pi 4 (4GB) for LTE to WiFi/Ethernet routing

- [x] Initial Setup
- [x] Initial programs
- [x] SSH
- [x] USB C OTG
- [x] Termclock
- [x] Python 3.9.4
- [x] Hard reboot/poweroff scripts
- [x] Installing QMI
- [x] Checking connectivity from LTE
- [x] Setting up auto-reconnect LTE at boot
- [ ] WiFi hotspot
- [ ] Suggestion: setting up fail-over routes
- [ ] Bluetooth keyboard connectivity
- [ ] Installing Docker
- [ ] Setting up Grafana dashboard

### Initial Setup
1. Disconnect Sixfab bettery connector, connect USB-C power directly to the Pi4.
2. Connect also: keyboard, ethernet.

3. After first boot:
```shell
sudo raspi-config
```

a. System:
* Password
* Hostname: RBPi4-LTE
* Boot and auto-login to CLI
* Network at boot: no

b. Interface:
* Enable SSH

c. Localisation:
* Change to en_sg UTF8
* WLAN country: USA

d. Advanced
* Expand filesystem

e. Finish
* Reboot

After the Pi reboots:
```shell
sudo apt-get update
sudo apt update
sudo apt upgrade -y
```

### If you've installed the full OS
(UNTESTED - PLEASE USE LITE VERSION FOR MAX COMPATIBILITY since we dont need a GUI anyway)
```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/lite_changer.sh
sudo chmod +x lite_changer.sh
sudo ./lite_changer.sh
```

### Install initial programs
#### Installing SixfabPower
1. Log in to: [SixfabPower](https://power.sixfab.com)
2. Add a device and note down the token words.
3. ``` curl https://install.power.sixfab.com | sudo sh -s <token words>```

#### Installing ZeroTier
```shell
curl -s https://install.zerotier.com/ | sudo bash
sudo zerotier-cli join <network ID>
```
Within ZeroTier, allow access to this new device and set the IP to desired.

#### Generating SSH Keys
On the Pi:
```shell
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub user@<ip address>
```
From a remote Windows machine:
```shell
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh pi@10.242.6.63 "cat >> .ssh/authorized_keys"
```

### Converting USB C to OTG mode
```shell
sudo nano /boot/config.txt
```
Adding to the end:
```shell
dtoverlay=dwc2,dr_mode=host
```
CTRL + O > ENTER > CTRL + X

Reboot the Pi.
Remove the USB C power from the Pi and connect it to SixfabPower HAT.

### Installing secondary programs

#### Installing a different version of Python that is not yet available for the Pi
```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/python_install.sh
sudo chmod +x python_install.sh
sudo ./python_install.sh
```

#### Adding new aliases
```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/aliases_addition.sh
sudo chmod +x aliases_addition.sh
./aliases_addition.sh
```

#### Adding easy reboot/poweroff commands
```shell
mkdir runners
cd runners
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/reboot_hard.py
sudo chmod +x reboot_hard.py
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/poweroff_hard.py
sudo chmod +x poweroff_hard.py
```

## Sources (and thanks)

https://power.sixfab.com/
https://www.zerotier.com/
https://github.com/Souravgoswami/termclock/
https://www.chrisjhart.com/Windows-10-ssh-copy-id/
https://www.ramoonus.nl/2021/04/10/how-to-install-python-3-9-4-on-raspberry-pi/
