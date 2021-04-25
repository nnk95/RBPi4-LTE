# RBPi4-LTE
## Setting up of a Raspberry Pi 4 (4GB) for LTE to WiFi routing

- [x] Initial Setup
- [x] Initial programs
- [x] SSH
- [x] USB C OTG
- [ ] Termclock
- [ ] Python 3.9.4
- [ ] Hard reboot/poweroff scripts
- [ ] Installing QMI
- [ ] Checking connectivity from LTE
- [ ] Setting up auto-reconnect
- [ ] Setting up WiFi hotspot

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
sudo apt update
sudo apt purge -y x11-common bluez gnome-menus gnome-icon-theme gnome-themes-standard
sudo apt purge -y hicolor-icon-theme gnome-themes-extra-data bluealsa cifs-utils
sudo apt purge -y desktop-base desktop-file-utils
sudo apt autoremove -y
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
