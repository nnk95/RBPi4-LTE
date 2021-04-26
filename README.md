# RBPi4-LTE

## Setting up of a Raspberry Pi 4 (4GB) for LTE to WiFi/Ethernet routing
---
### Task List:

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
- [ ] \(Idea): setting up fail-over routes
- [ ] Bluetooth keyboard connectivity
- [ ] Installing Docker
- [ ] Setting up Grafana dashboard

---

<br>

## Initial Setup
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

<br>

---

<br>

## If you've installed the full OS

<br>

> UNTESTED!<br>
> PLEASE USE LITE VERSION FOR MAX COMPATIBILITY<br>
> We dont actually need a full GUI anyway

<br>

```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/lite_changer.sh
sudo chmod +x lite_changer.sh
sudo ./lite_changer.sh
```

<br>

---

<br>

## Install initial programs

<br>

### Installing SixfabPower
1. Log in to: [SixfabPower](https://power.sixfab.com/)
2. Add a device and note down the token words.
3. ``` curl https://install.power.sixfab.com | sudo sh -s <token words>```

<br>

### Installing ZeroTier
```shell
curl -s https://install.zerotier.com/ | sudo bash
sudo zerotier-cli join <network ID>
```
> Within [ZeroTier](https://my.zerotier.com/), allow access to this new device and set the IP to desired.

<br>

### Generating SSH Keys
> On the Pi:
```shell
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub user@<ip address>
```
> From a remote Windows machine:
```shell
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh pi@10.242.6.63 "cat >> .ssh/authorized_keys"
```

<br>

---

<br>

## Converting USB C to OTG mode

1. Edit the file: ``` /boot/config/txt ``` 
```shell
sudo nano /boot/config.txt
```
2. Adding to the end:
```shell
dtoverlay=dwc2,dr_mode=host
```
3. Save and close the file with:
```
CTRL + O
ENTER
CTRL + X
```
4. Reboot the Pi to make sure it still boots.
5. Power off the Pi, remove the USB C power from the Pi and connect it to SixfabPower HAT.

<br>

---

<br>

## Installing secondary programs

<br>

>Installing a different version of Python that is not yet available for the Pi
```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/python_install.sh
sudo chmod +x python_install.sh
sudo ./python_install.sh
```

<br>

> Adding new aliases
```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/aliases_addition.sh
sudo chmod +x aliases_addition.sh
./aliases_addition.sh
```

<br>

> Adding easy reboot/poweroff commands
```shell
mkdir runners
cd runners
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/reboot_hard.py
sudo chmod +x reboot_hard.py
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/poweroff_hard.py
sudo chmod +x poweroff_hard.py
```

> Or a all-in-one power commands download:
```shell
wget https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/power_aio.sh
sudo chmod +x power_aio.sh
./power_aio.sh
```
<br>

> Install Sixfab's QMI
1. _Backup script at: ( https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/qmi_install.sh )_
```shell
cd /home/pi/installers
sudo apt-get install raspberrypi-kernel-headers
wget https://raw.githubusercontent.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/master/tutorials/QMI_tutorial/qmi_install.sh
sudo chmod +x qmi_install.sh
sudo ./qmi_install.sh
```
2. Press ``` ENTER ``` to reboot as required and have your APN settings ready.
3. **Power OFF** and connect the USB cable from the Sixfab LTE HAT to the USB C port on the Pi.
4. **Power ON** and check for the visibility of the HAT with: ``` lsusb ```.
5. You should expect to see an entry with:
``` Bus 00x Device 00x: ID 2c7c:0125 Quectel Wireless Solutions Co., Ltd. EC25 LTE modem ```
6. And with: ``` dmesg | grep ttyUSB ```
```
[  154.014341] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB0
[  154.015183] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB1
[  154.015632] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB2
[  154.015994] usb 3-1: GSM modem (1-port) converter now attached to ttyUSB3
```
7. Now we can check if the LTE modem HAT is working and for a valid LTE internet connection.
```
cd /home/pi/files/quectel-CM
sudo ./quectel-CM -s <APN> <UserID> <Password>
```
* Command usage is: ``` ./quectel-CM [-s [apn [user password auth]]] [-p pincode] [-f logfilename] -s [apn [user password auth]] ```
* Examples:

| APN | UserID | Password | Pincode | Output |
| --- | --- | --- | --- | --- |
| 3gnet | - | - | - | `./quectel-CM -s 3gnet` |
| 3gnet | carl | - | - | `./quectel-CM -s 3gnet carl`  |
| 3gnet | carl | 1234 | - | `./quectel-CM -s 3gnet carl 1234`  |
| 3gnet | carl | 1234 | 1234 | `./quectel-CM -s 3gnet carl 1234 0 -p 1234` |

<br>

> Installing the auto-reconnect on boot service
1. Backup script at: ( )


## Sources (and thanks)

* https://sixfab.com/
* https://power.sixfab.com/
* https://www.zerotier.com/
* https://github.com/Souravgoswami/termclock/
* https://www.chrisjhart.com/Windows-10-ssh-copy-id/
* https://www.ramoonus.nl/2021/04/10/how-to-install-python-3-9-4-on-raspberry-pi/
