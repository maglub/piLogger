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

====================================================
= Installation of the software
====================================================

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

5) Configure the installation

./configure

or, if you have the AbioWire interface (http://www.axiris.eu/en/index.php/one-wire/abiowire)

./configure --withAbioWire --withLocale

6) Run setup, which will install necessary packages (this will take ca 5 - 10 minutes)

./setup.sh

7) Reboot - since the install of owfs will not work before

sudo reboot

====================================================
= Configuration of your setup
====================================================

1) Scan for devices (into ~/piLogger/etc/devices.scanned)

cd ~/piLogger/bin
./dbTool --scan

This should show your connected devices and add them to ~/piLogger/etc/devices.scanned, and show you what ./dbTool commands to run to add the devices to the configuration database.

Example:

```
./dbTool --scan
20150112_184949;dbTool;  - Scanning for devices into /home/pi/piLogger/bin/../etc/devices.scanned
/mnt/1wire/28.263943050000
/mnt/1wire/28.41622F050000
/mnt/1wire/28.EFBB4E050000
Add devices not yet in the database by copy/paste the following:

./dbTool --add -d --deviceType 1wire --deviceId 28.263943050000 --devicePath /mnt/1wire/28.263943050000
./dbTool --add -d --deviceType 1wire --deviceId 28.41622F050000 --devicePath /mnt/1wire/28.41622F050000
./dbTool --add -d --deviceType 1wire --deviceId 28.EFBB4E050000 --devicePath /mnt/1wire/28.EFBB4E050000
```

Add your devices by copy/paste the "./dbTool" rows into your shell.

Check that the devices were added to the database:

./dbTool -d

2) Set up aliases for your devices

Check the current aliases.

./dbTool -a

If the aliases are the same as the device id's, you can set an alias by running the following command:

./dbTool --add -a --deviceId XXXX --deviceAlias your_alias

3) Set up a "default" plot group with all devices:

./dbTool -d | xargs -L1 -I X ./dbTool --add -p --plotGroup default --deviceId X

3) Set up the capture file by adding the aliases you want to log. The easiest way is to take all aliases in aliases.conf

pi@raspberrypi ~/piLogger/bin $ cat ~/piLogger/etc/aliases.conf | cut -d";" -f1 > ~/piLogger/etc/capture.conf

pi@raspberrypi ~/piLogger/bin $ cat ~/piLogger/etc/capture.conf 
tabletop
under-table

4) Test that the logging works, and that new rrd files are created.

~/piLogger/bin/logAll ~/piLogger/etc/capture.conf 

Check that the RRD files are created properly, one per device connected to your 1wire interface.

pi@raspberrypi ~/piLogger/bin $ ls -la /var/piLogger/db
total 20264
drwxr-xr-x 2 pi pi     4096 Feb  7 14:28 .
drwxr-xr-x 5 pi pi     4096 Feb  7 14:21 ..
-rw-r--r-- 1 pi pi 10370124 Feb  7 14:28 28.12ED2F040000.rrd
-rw-r--r-- 1 pi pi 10370124 Feb  7 14:28 28.90EC2F040000.rrd

5) If the logAll command works, you can setup the default plot group

cp ~/piLogger/etc/capture.conf ~/piLogger/etc/graph.default.conf

6) Refresh the cache files

~/piLogger/bin/refreshCaches

pi@s1wire ~/piLogger $ ls -la ~/piLogger/html/cache/
total 28
drwxr-xr-x 2 pi pi 4096 Feb  8 14:25 .
drwxr-xr-x 6 pi pi 4096 Feb  8 14:26 ..
-rw-rw-rw- 1 pi pi  138 Feb  8 14:25 sensorAllInfo.json
-rw-rw-rw- 1 pi pi  901 Feb  8 14:25 sensorData.12h.json
-rw-rw-rw- 1 pi pi  217 Feb  8 14:25 sensorData.168h.json
-rw-rw-rw- 1 pi pi 1075 Feb  8 14:25 sensorData.24h.json
-rw-rw-rw- 1 pi pi 1075 Feb  8 14:25 sensorData.json


7) And lastly, set up cron so that you log and create the caches at a regular basis

(crontab -l 2>/dev/null ;cat ~/piLogger/etc/cron/crontab.txt ) | crontab -

Your crontab should look something like this:

# m h  dom mon dow   command*/1 * * * *
base=/home/pi/piLogger ; $base/bin/logAll $base/etc/capture.conf >/dev/null 2>&1 ; $base/bin/refreshCaches 12h ; $base/bin/refreshCaches sensors
*/10 * * * * /home/pi/piLogger/bin/refreshCaches 24h 
4 * * * * /home/pi/piLogger/bin/refreshCaches 48h
5 */6 * * * /home/pi/piLogger/bin/refreshCaches 168h

8) Done! Test your webgui by entering the IP address of your Raspberry Pi in the address field in your browser.




=====================================================
= Notes and references
=====================================================

* Data files are found in /var/piLogger

* Log files are found in /var/log/piLogger

* Config files are found in /etc/piLogger.d, which is conveniently symlinked to ~/piLogger/etc 

* bash autocompletion is set up for most important scripts. This means that you can press <TAB> twice to see parameters and devices for most commands in ~/piLogger/bin

* By setting the variable "debug=true" in ~/piLogger/etc/piLogger.conf file, you will get more output on the screen and in the logfiles in /var/log/piLogger


* You can list your devices at any time by running the following commands, which will NOT alter any config files:
  -> ~/piLogger/bin/listDevices
  -> ~/piLogger/bin/listDevices --aliasFile

* You can rescan your devices, and automatically update the ~/piLogger/etc/devices.conf file with:
  -> ~/piLogger/bin/listDevices --scan

* Almost always, you want the same aliases in your caputre.conf file as in your aliases.conf file. You can easily do this by running:
  -> cat ~/piLogger/etc/aliases.conf | cut -d";" -f1 > ~/piLogger/etc/capture.conf

* Almost always, you want the same aliases in your graph.default.conf file. You can easily do this by running:
  -> cp ~/piLogger/etc/capture.conf ~/piLogger/etc/graph.default.conf


