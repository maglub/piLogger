piLogger
========

This is the piLogger.

The main focus is to log temperatures with Raspberry Pi and 1wire devices.

Supported controllers:

* AbioWire
* DS9490R

Features:

* Simple configuration
* Simple management of devices
* Automated gathering of temperature data at configurable intervals
* RRDtool generated graphs

Installation
============

The installation is easy. Just clone this repository, run ./configure then ./setup.sh. The result is an etc/piLogger.conf file, which is ready to go for most configurations. After the initial installation, set up eventual aliases in the etc/aliases.conf file.

* Installation

1) Get yourself a Raspberry Pi
2) Install an SD card with the latest version of Raspbian
     - Set an IP address
     - Expand the filesystem
     - Set the correct time zone
     - Update the system
     - Reboot
     
#-- ip address in /etc/network/interfaces
#-- fs expand
sudo raspi-config

#-- update system
sudo apt-get update
sudo apt-get -y upgrade
sudo reboot
     

3) Create your .ssh directory and ssh-keys

mkdir ~/.ssh
cd ~/.ssh
ssh-keygen -t dsa

4) Fetch the piLogger software from GitHub

ssh git@github.com
git clone https://github.com/maglub/piLogger
cd piLogger

./configure
or
./configure [--withAbioWire] [--withLocale]

./setup.sh

5) Reboot

sudo reboot

* Configuration

1) Scan for devices (into ~/piLogger/etc/devices.scanned)

~/piLogger/bin/listDevices --scan

2) Set up aliases

To generate an alias file from scratch:

~/piLogger/bin/listDevices --alias > ~/piLogger/etc/aliases.conf

Edit this file and give your devices names that you like better.

3) Set up the 



