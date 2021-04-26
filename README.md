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
> PIN code is not yet tested as i do not have a SIM card with a PIN code.

| APN | UserID | Password | Pincode | Output |
| --- | --- | --- | --- | --- |
| 3gnet | - | - | - | `./quectel-CM -s 3gnet` |
| 3gnet | carl | - | - | `./quectel-CM -s 3gnet carl`  |
| 3gnet | carl | 1234 | - | `./quectel-CM -s 3gnet carl 1234`  |
| 3gnet | carl | 1234 | 1234 | `./quectel-CM -s 3gnet carl 1234 0 -p 1234` |

<br>

> The output of ``` ./quectel-CM ``` is non-ending as long as the connection is up.
* Expected output of ``` sudo ./quectel-CM -s <APN> ``` :
```shell
[01-29_11:47:14:867] Quectel_QConnectManager_Linux_V1.6.0.12
[01-29_11:47:14:868] Find /sys/bus/usb/devices/1-1.1 idVendor=0x2c7c idProduct=0x125, bus=0x001, dev=0x007
[01-29_11:47:14:869] Auto find qmichannel = /dev/cdc-wdm0
[01-29_11:47:14:869] Auto find usbnet_adapter = wwan0
[01-29_11:47:14:869] netcard driver = qmi_wwan, driver version = 22-Aug-2005
[01-29_11:47:14:869] ioctl(0x89f3, qmap_settings) failed: Operation not supported, rc=-1
[01-29_11:47:14:870] Modem works in QMI mode
[01-29_11:47:14:888] cdc_wdm_fd = 7
[01-29_11:47:14:986] Get clientWDS = 17
[01-29_11:47:15:018] Get clientDMS = 1
[01-29_11:47:15:050] Get clientNAS = 3
[01-29_11:47:15:082] Get clientUIM = 2
[01-29_11:47:15:115] Get clientWDA = 1
[01-29_11:47:15:147] requestBaseBandVersion EG25GGBR07A07M2G
[01-29_11:47:15:274] requestGetSIMStatus SIMStatus: SIM_READY
[01-29_11:47:15:274] requestSetProfile[1] super///0
[01-29_11:47:15:338] requestGetProfile[1] super///0
[01-29_11:47:15:371] requestRegistrationState2 MCC: 286, MNC: 3, PS: Attached, DataCap: LTE
[01-29_11:47:15:401] requestQueryDataCall IPv4ConnectionStatus: DISCONNECTED
[01-29_11:47:15:402] ifconfig wwan0 down
[01-29_11:47:15:418] ifconfig wwan0 0.0.0.0
[01-29_11:47:15:467] requestSetupDataCall WdsConnectionIPv4Handle: 0x872eaae0
[01-29_11:47:15:595] change mtu 1500 -> 1360
[01-29_11:47:15:596] ifconfig wwan0 up
[01-29_11:47:15:609] busybox udhcpc -f -n -q -t 5 -i wwan0
udhcpc: started, v1.30.1
No resolv.conf for interface wwan0.udhcpc
udhcpc: sending discover
udhcpc: sending discover
udhcpc: no lease, failing
[01-29_11:47:31:235] ifconfig wwan0 down
[01-29_11:47:31:247] echo Y > /sys/class/net/wwan0/qmi/raw_ip
[01-29_11:47:31:248] ifconfig wwan0 up
[01-29_11:47:31:260] busybox udhcpc -f -n -q -t 5 -i wwan0
udhcpc: started, v1.30.1
No resolv.conf for interface wwan0.udhcpc
udhcpc: sending discover
udhcpc: sending select for 100.65.213.248
udhcpc: lease of 100.65.213.248 obtained, lease time 7200
Too few arguments.
Too few arguments.
```

<br>

* While ``` ./quectel-CM ``` is running, switch to another terminal window with: ``` CTRL + ALT + F2 ```

<br>

> Check for an actual IP address with: ``` ifconfig wwan0 ```

```
wwan0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST> mtu 1360
        inet 100.68.68.134  netmask 255.255.255.252  destination 100.68.68.134
        inet6 fe80::8d13:6f5:cbb6:cb4  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 1000  (UNSPEC)
        RX packets 16  bytes 2216 (2.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 55  bytes 7136 (6.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

<br>

> Then ping the wider internet with: ``` ping -I wwan0 -c 5 8.8.8.8 ```
```
PING 8.8.8.8 (8.8.8.8) from 100.65.213.248 wwan0: 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=110 time=222 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=110 time=194 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=110 time=193 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=110 time=194 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=110 time=195 ms

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 8ms
rtt min/avg/max/mdev = 192.947/199.606/221.875/11.168 ms
```

<br>

* Now stop ``` ./quectel-CM ``` by switching back to the first terminal window with ``` CTRL + ALT + F1 ``` then ``` CTRL + C ```

<br>


> Installing the auto-reconnect on boot service
1. _Backup script at: ( https://raw.githubusercontent.com/nnk95/RBPi4-LTE/main/scripts/install_auto_connect.sh )_
```shell
wget https://raw.githubusercontent.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/master/tutorials/QMI_tutorial/install_auto_connect.sh
sudo chmod +x install_auto_connect.sh
sudo ./install_auto_connect.sh
```
2. Script will ask for APN information. Enter in your APN information as follows:
> PIN code is not yet tested as i do not have a SIM card with a PIN code.

| APN | UserID | Password | Pincode | Output |
| --- | --- | --- | --- | --- |
| 3gnet | - | - | - | `3gnet` |
| 3gnet | carl | - | - | `3gnet/carl`  |
| 3gnet | carl | 1234 | - | `3gnet/carl/1234`  |
| 3gnet | carl | 1234 | 1234 | `3gnet/carl/1234/0/1234` |

<br>

```
What is the APN?
<YOUR_APN>
--2020-12-03 12:07:39--  https://raw.githubusercontent.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/master/tutorials/QMI_tutorial/reconnect_service
Resolving raw.githubusercontent.com
...
Saving to: 'qmi_reconnect.service'

qmi_reconnect.service 100%[=========================================================>] 
264  --.-KB/s    in 0s      

2020-12-03 12:07:39 (2.63 MB/s) - 'qmi_reconnect.service' saved [264/264]
...
Saving to: 'qmi_reconnect.sh'

qmi_reconnect.sh 100%[=========================================================>]
224  --.-KB/s    in 0s      

2020-12-03 12:07:40 (1.32 MB/s) - 'qmi_reconnect.sh' saved [224/224]

Created symlink /etc/systemd/system/multi-user.target.wants/qmi_reconnect.service → /etc/systemd/system/qmi_reconnect.service.
DONE
```

<br>

3. Check if the service is running correctly with: ``` sudo systemctl status qmi_reconnect.service ```
> Name of the service is: ``` qmi_reconnect.service ```
```
● qmi_reconnect.service - QMI Auto Connection
   Loaded: loaded (/etc/systemd/system/qmi_reconnect.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2021-01-29 12:15:25 GMT; 2min 4s ago
 Main PID: 2730 (sh)
    Tasks: 4 (limit: 3861)
   CGroup: /system.slice/qmi_reconnect.service
           ├─ 2730 /bin/sh /usr/src/qmi_reconnect.sh
           ├─13529 sudo ./quectel-CM -s super
           └─13530 ./quectel-CM -s super
```

<br>

> Useful commands to manage the service: ``` qmi_reconnect.service ```

| Type | Input |
| --- | --- |
| Status | ``` sudo systemctl status qmi_reconnect.service ``` |
| Start | ``` sudo systemctl start qmi_reconnect.service ``` |
| Stop | ``` sudo systemctl stop qmi_reconnect.service ``` |
| Restart | ``` sudo systemctl restart qmi_reconnect.service ``` |
| Uninstall | ``` sudo systemctl stop qmi_reconnect.service ``` <br> ``` sudo systemctl disable qmi_reconnect.service ``` |

<br>

4. Reboot device and check for internet connectivity.
> Note that the modem takes a little while to start up so run through ``` ifconfig wwan0 ``` until you get an IP address, then ``` ping -I wwan0 -c 5 8.8.8.8 ``` as usual.

<br>

---

<br>




## Sources (and thanks)

* https://sixfab.com/
* https://power.sixfab.com/
* https://www.zerotier.com/
* https://github.com/Souravgoswami/termclock/
* https://www.chrisjhart.com/Windows-10-ssh-copy-id/
* https://www.ramoonus.nl/2021/04/10/how-to-install-python-3-9-4-on-raspberry-pi/
