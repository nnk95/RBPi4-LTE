#!/bin/sh

sudo apt update
sudo apt purge -y x11-common bluez gnome-menus gnome-icon-theme gnome-themes-standard hicolor-icon-theme gnome-themes-extra-data bluealsa cifs-utils desktop-base desktop-file-utils
sudo apt autoremove -y
