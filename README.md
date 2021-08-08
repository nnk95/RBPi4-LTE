# RBPi4-LTE: RASPBERRY PI OS - LITE

## Setting up of a Raspberry Pi 4 (4GB) for LTE to WiFi/Ethernet routing

---

![Lines of code](https://img.shields.io/tokei/lines/github/reikolydia/RBPi4-LTE_RASPBIAN-LITE?label=Lines%20Written&style=for-the-badge) ![GitHub last commit](https://img.shields.io/github/last-commit/reikolydia/RBPi4-LTE_RASPBIAN-LITE?style=for-the-badge)

---

### Task List

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
- [x] WiFi hotspot
- [ ] Atcom for SMS handling
- [ ] \(Idea): setting up fail-over routes
- [ ] Bluetooth keyboard connectivity
- [ ] Installing Docker
- [ ] Setting up Grafana dashboard
- [ ] Clean up this page adding links etc

---

<br>

## Initial Setup

1. Disconnect Sixfab bettery connector, connect USB-C power directly to the Pi4.
2. Connect also: keyboard, ethernet.

3. After first boot:

Initial username:

```shell
pi
```

Initial password:

```shell
raspberry
```

Once you log in:

```shell
sudo raspi-config
```

a. System:

- Password
- Hostname: RBPi4-LTE
- Boot and auto-login to CLI
- Network at boot: no

b. Interface:

- Enable SSH

c. Localisation:

- Change to en_sg UTF8
- WLAN country: USA

d. Advanced

- Expand filesystem

e. Finish

- Reboot

After the Pi reboots:

```shell
sudo apt-get update
sudo apt update
sudo apt upgrade -y
```

f. Optional
After a update, Fish shell can be installed with: (Fish cmake takes time!)

```shell
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/fish_build_install.sh
chmod +x fish_build_install.sh
./fish_build_install.sh
```

Set up Fish shell with:

```shell
cd .config/fish
nano config.fish

clear
echo " "
neofetch

cd functions
nano fish_greeting.fish

function fish_greeting

echo " "
echo "Welcome. It is:" (date +%d)" "(date +%B)" "(date +%Y)", "(date +%T)" (GMT "(date +%Z)")"
echo " "

end
```

Start Fish shell with:

```shell
fish
```

Could also install Neofetch:

```shell
sudo apt install neofetch
```

<br>

---

<br>

## Install initial programs

<br>

### Installing SixfabPower

1. Log in to: [SixfabPower](https://power.sixfab.com/)
2. Add a device and note down the token words.

```shell
curl https://install.power.sixfab.com | sudo sh -s <token words>
```

<br>

### Installing ZeroTier

```shell
curl -s https://install.zerotier.com/ | sudo bash
sudo zerotier-cli join <network ID>
```

> Within [ZeroTier](https://my.zerotier.com/), allow access to this new device and set the IP to desired.

<br>

### Generating SSH Keys

> On the Pi (choose one type to upload to the remote host):

```shell
ssh-keygen -t rsa -b 4096 -t ecdsa -b 521
ssh-copy-id -i ~/.ssh/id_rsa.pub user@<REMOTE ip address>
ssh-copy-id -i ~/.ssh/id_ecdsa.pub user@<REMOTE ip address>
```

> On another Linux machine (choose one type):

```shell
ssh-keygen -t rsa -b 4096 -t ecdsa -b 521
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@<PI ip address>
ssh-copy-id -i ~/.ssh/id_ecdsa.pub pi@<PI ip address>
```

> From a remote Windows machine (choose one type):

```shell
ssh-keygen.exe -t rsa -b 4096 -t ecdsa -b 521
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh pi@<PI ip address> "cat >> .ssh/authorized_keys"
type $env:USERPROFILE\.ssh\id_ecdsa.pub | ssh pi@<PI ip address> "cat >> .ssh/authorized_keys"
```

<br>

---

<br>

## Converting USB C to OTG mode

1. Edit the file: `/boot/config.txt`

```shell
sudo nano /boot/config.txt
```

2. Adding to the end:

```shell
dtoverlay=dwc2,dr_mode=host
```

> Experimental: `otg_mode=1` 3. Save and close the file with:

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

> Installing a different version of Python that is not yet available for the Pi <br> (MIGHT BREAK SIXFAB'S POWER_API)

```shell
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/python_install.sh
sudo chmod +x python_install.sh
sudo ./python_install.sh
echo "alias python=/usr/local/opt/python-3.9.4/bin/python3.9" | sudo tee -a ~/.bash_aliases
. ~/.bash_aliases
```

<br>

> Adding new aliases

```shell
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/aliases_addition.sh
sudo chmod +x aliases_addition.sh
./aliases_addition.sh
```

<br>

> Adding easy reboot/poweroff commands

```shell
mkdir runners
cd runners
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/reboot_hard.py
sudo chmod +x reboot_hard.py
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/poweroff_hard.py
sudo chmod +x poweroff_hard.py
```

> Or a all-in-one power commands download:

```shell
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/power_aio.sh
sudo chmod +x power_aio.sh
./power_aio.sh
```

<br>

> Install Sixfab's QMI

1. _Backup script at: ( https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/qmi_install.sh )_

```shell
cd /home/pi/installers
sudo apt-get install raspberrypi-kernel-headers
wget https://raw.githubusercontent.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/master/tutorials/QMI_tutorial/qmi_install.sh
sudo chmod +x qmi_install.sh
sudo ./qmi_install.sh
```

2. Press `ENTER` to reboot as required and have your APN settings ready.
3. **Power OFF** and connect the USB cable from the Sixfab LTE HAT to the USB C port on the Pi.
4. **Power ON** and check for the visibility of the HAT with: `lsusb`.
5. You should expect to see an entry with:
   `Bus 00x Device 00x: ID 2c7c:0125 Quectel Wireless Solutions Co., Ltd. EC25 LTE modem`
6. And with: `dmesg | grep ttyUSB`

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

- Command usage is: `./quectel-CM [-s [apn [user password auth]]] [-p pincode] [-f logfilename] -s [apn [user password auth]]`
- Examples:
  > PIN code is not yet tested as i do not have a SIM card with a PIN code.

| APN   | UserID | Password | Pincode | Output                                      |
| ----- | ------ | -------- | ------- | ------------------------------------------- |
| 3gnet | -      | -        | -       | `./quectel-CM -s 3gnet`                     |
| 3gnet | carl   | -        | -       | `./quectel-CM -s 3gnet carl`                |
| 3gnet | carl   | 1234     | -       | `./quectel-CM -s 3gnet carl 1234`           |
| 3gnet | carl   | 1234     | 1234    | `./quectel-CM -s 3gnet carl 1234 0 -p 1234` |

<br>

> The output of `./quectel-CM` is non-ending as long as the connection is up.

- Expected output of `sudo ./quectel-CM -s <APN>` :

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

- While `./quectel-CM` is running, switch to another terminal window with: `CTRL + ALT + F2`

<br>

> Check for an actual IP address with: `ifconfig wwan0`

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

> Then ping the wider internet with: `ping -I wwan0 -c 5 8.8.8.8`

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

- Now stop `./quectel-CM` by switching back to the first terminal window with `CTRL + ALT + F1` then `CTRL + C`

<br>

> Installing the auto-reconnect on boot service

1. _Backup script at: ( https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/install_auto_connect.sh )_

```shell
wget https://raw.githubusercontent.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/master/tutorials/QMI_tutorial/install_auto_connect.sh
sudo chmod +x install_auto_connect.sh
sudo ./install_auto_connect.sh
```

2. Script will ask for APN information. Enter in your APN information as follows:
   > PIN code is not yet tested as i do not have a SIM card with a PIN code.

| APN   | UserID | Password | Pincode | Output                   |
| ----- | ------ | -------- | ------- | ------------------------ |
| 3gnet | -      | -        | -       | `3gnet`                  |
| 3gnet | carl   | -        | -       | `3gnet/carl`             |
| 3gnet | carl   | 1234     | -       | `3gnet/carl/1234`        |
| 3gnet | carl   | 1234     | 1234    | `3gnet/carl/1234/0/1234` |

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

3. Check if the service is running correctly with: `sudo systemctl status qmi_reconnect.service`
   > Name of the service is: `qmi_reconnect.service`

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

> Useful commands to manage the service: `qmi_reconnect.service`

| Type      | Input                                                                                           |
| --------- | ----------------------------------------------------------------------------------------------- |
| Status    | `sudo systemctl status qmi_reconnect.service`                                                   |
| Start     | `sudo systemctl start qmi_reconnect.service`                                                    |
| Stop      | `sudo systemctl stop qmi_reconnect.service`                                                     |
| Restart   | `sudo systemctl restart qmi_reconnect.service`                                                  |
| Uninstall | `sudo systemctl stop qmi_reconnect.service` <br> `sudo systemctl disable qmi_reconnect.service` |

<br>

4. Reboot device and check for internet connectivity.
   > Note that the modem takes a little while to start up so run through `ifconfig wwan0` until you get an IP address, then `ping -I wwan0 -c 5 8.8.8.8` as usual.

<br>

5. At times the HAT will just stop responding. Does not respond to: `AT` commands, `ifconfig wwan0` might not show IP address, or even the whole `wwan0` interface is missing. Here we will introduce a semi working hack to get it back online, although immediate connections might be interrupted, but this script hopefully will restart the HAT once it detects the HAT is not responding.

```shell
cd /home/pi/runners
wget https://raw.githubusercontent.com/reikolydia/RBPi4-LTE_RASPBIAN-LITE/main/scripts/lte_restart.py
chmod +x lte_restart.py
cd /usr/src
sudo nano qmi_reconnect.sh
```

> Change the line that reads: `sudo ./quectel-CM -s #APN` to:

```shell
cd /home/pi/runners
./lte_restart.py
```

<br>

6. GPIO Layout (Pi 4B)

![4B GPIO](/images/GPIO-Pinout.png)

| NAME             | PIN | PIN | NAME               |
| ---------------- | --- | --- | ------------------ |
| 3V3 POWER        | 1   | 2   | 5V POWER           |
| GPIO 2 (SDA)     | 3   | 4   | 5V POWER           |
| GPIO 3 (SCL)     | 5   | 6   | GROUND             |
| GPIO 4 (GPCLK0)  | 7   | 8   | GPIO 14 (TXD)      |
| GROUND           | 9   | 10  | GPIO 15 (RXD)      |
| GPIO 17          | 11  | 12  | GPIO 18 (PCM_CLK)  |
| GPIO 27          | 13  | 14  | GROUND             |
| GPIO 22          | 15  | 16  | GPIO 23            |
| 3V3 POWER        | 17  | 18  | GPIO 24            |
| GPIO 10 (MOSI)   | 19  | 20  | GROUND             |
| GPIO 9 (MISO)    | 21  | 22  | GPIO 25            |
| GPIO 11 (SCLK)   | 23  | 24  | GPIO 8 (CE0)       |
| GROUND           | 25  | 26  | GPIO 7 (CE1)       |
| GPIO 0 (ID_SD)   | 27  | 28  | GPIO 1 (ID_SC)     |
| GPIO 5           | 29  | 30  | GROUND             |
| GPIO 6           | 31  | 32  | GPIO 12 (PWM0)     |
| GPIO 13 (PWM1)   | 33  | 34  | GROUND             |
| GPIO 19 (PCM_FS) | 35  | 36  | GPIO 16            |
| GPIO 26          | 37  | 38  | GPIO 20 (PCM_DIN)  |
| GROUND           | 39  | 40  | GPIO 21 (PCM_DOUT) |

> GPIO 26 is used to trigger the power of/off cycles of the LTE HAT.

- To get a full list of what GPIO is on your system, you can install the `GPIOZERO` library and run the command `pinout`.

```
sudo apt install python3-gpiozero
pinout
```

<br>

---

<br>

## Setting up WiFi hotspot

<br>

> Basic layout of intended function

```
                 +-- Router ---+
                 | Firewall    |          +----- RPi ----+           +--- Laptop ----+
(Internet)--WWAN-+ DHCP server +-->-->-->--+  10.X.X.2   |           | 192.168.10.10 |
                 |  10.X.X.X   |          |   WLAN AP   +--)))   (((--+  WLAN CLIENT |
                 +-------------+          | 192.168.10.1 |           +---------------+
                                          +--------------+
```

<br>

1. Install: `hostapd dnsmasq netfilter-persistent iptables-persistent`

```shell
sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo apt install dnsmasq
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
```

<br>

2. Configure static IP addtess for: `wlan0`

> `sudo nano /etc/dhcpcd.conf`

```shell
denyinterfaces wwan0 eth0
interface wlan0
static ip_address=192.168.10.1/24
static domain_name_servers=192.168.10.1 1.1.1.1
nohook wpa_supplicant
```

<br>

3. Enable routing/forwarding

> `sudo nano /etc/sysctl.d/routed-ap.conf`

```shell
net.ipv4.ip_forward=1
```

<br>

4. Enable IP masquerading

```shell
sudo iptables -t nat -A POSTROUTING -o wwan0 -j MASQUERADE
sudo netfilter-persistent save
```

<br>

5. Configure DHCP for: `wlan0`

> Backup old `dnsmasq.conf` file

```shell
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
```

> Add to the new empty `dnsmasq.conf` file:

```shell
sudo nano /etc/dnsmasq.conf

interface=wlan0
dhcp-range=192.168.10.10,192.168.10.250,255.255.255.0,1h

domain=wlan
address=/gw.wlan/192.168.10.1
```

<br>

6. Unblock WiFi
   > `sudo rfkill unblock wlan`

<br>

7. Create and configure: `hostapd.conf`

> `sudo nano /etc/hostapd/hostapd.conf`

```shell
country_code=US
interface=wlan0
ssid=RBPi4-LTE
hw_mode=1
channel=44
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=<enter your desired network password here>
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

<br>

8. Reboot the Pi and the SSID should be visible after boot, connecting to the SSID, you should be routed to the internet.

<br>

---

<br>

## ATCOM / MINICOM

<br>

### Differences between `ATCOM` and `MINICOM`

<br>

| ATCOM        | MINICOM           |
| ------------ | ----------------- |
| PYTHON BASED | SERIAL PORT BASED |

<br>

1. Installation

> `ATCOM`

`pip3 install atcom`

> `MINICOM`

`sudo apt install minicom`

<br>

2. Usage

> First identify the serial ports on your system: `dmesg | grep tty`

```shell
[    0.000000] Kernel command line: coherent_pool=1M 8250.nr_uarts=0 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1  smsc95xx.macaddr=DC:A6:32:49:FB:39 vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000  console=ttyS0,115200 console=tty1 root=PARTUUID=9c0c76f5-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
[    0.001546] printk: console [tty1] enabled
[    1.193107] fe201000.serial: ttyAMA0 at MMIO 0xfe201000 (irq = 29, base_baud = 0) is a PL011 rev2
[   35.807711] usb 1-1.1: GSM modem (1-port) converter now attached to ttyUSB0
[   35.808358] usb 1-1.1: GSM modem (1-port) converter now attached to ttyUSB1
[   35.808916] usb 1-1.1: GSM modem (1-port) converter now attached to ttyUSB2
[   35.810673] usb 1-1.1: GSM modem (1-port) converter now attached to ttyUSB3
```

> Usually the modem is on: `/dev/ttyUSB2`

Settings to take note of:

| Program | Port / Device          | Baud Rate |
| ------- | ---------------------- | --------- |
| ATCOM   | <b>-p</b> /dev/ttyUSB2 | 115200    |
| MINICOM | <b>-D</b> /dev/ttyUSB2 | 115200    |

<br>

Command Lines to use:

| Program | Command Line                                                                                                |
| ------- | ----------------------------------------------------------------------------------------------------------- |
| ATCOM   | `sudo atcom -p /dev/ttyUSB2 <command>`                                                                      |
| MINICOM | MINICOM is different that it is a separate standalone program <br> `sudo minicom -b 115200 -D /dev/ttyUSB2` |

<br>

3. Sending commands

> For full list of commands, check out: [AT_Commands_Manual](https://sixfab.com/wp-content/uploads/2020/10/Quectel_EC25EC21_AT_Commands_Manual_V1.3.pdf) <i>(PDF)</i>

<br>

---

<br>

## Sources (and thanks)

- https://sixfab.com/
- https://power.sixfab.com/
- https://docs.sixfab.com/
- https://www.zerotier.com/
- https://github.com/Souravgoswami/termclock/
- https://www.chrisjhart.com/Windows-10-ssh-copy-id/
- https://www.ramoonus.nl/2021/04/10/how-to-install-python-3-9-4-on-raspberry-pi/
- https://www.raspberrypi.org/documentation/
- https://shields.io/
