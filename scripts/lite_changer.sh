#!/bin/sh

# UNTESTED SCRIPT, its better to start with the lite version instead.
# https://downloads.raspberrypi.org/raspbian_lite/images/
# choose the latest date, flash that to micro SD card

apt update
apt purge -y x11-common bluez gnome-menus gnome-icon-theme gnome-themes-standard hicolor-icon-theme gnome-themes-extra-data bluealsa cifs-utils desktop-base desktop-file-utils
apt autoremove -y
