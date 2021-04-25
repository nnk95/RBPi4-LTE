# RBPi4-LTE
## Setting up of a Raspberry Pi 4 (4GB) for LTE to WiFi routing

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

