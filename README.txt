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


git clone https://github.com/maglub/piLogger
cd piLogger

./configure
or
./configure [--withAbioWire] [--withLocale]

./setup.sh

* Configuration

To generate an alias file from scratch:

~/piLogger/bin/listDevices --alias



