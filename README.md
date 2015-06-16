piLogger
========
This is the piLogger. The main focus is to log temperatures with Raspberry Pi and 1wire devices.

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

The installation is easy. Just clone this repository, run `./configure` then `./setup.sh`. The result is an `etc/piLogger.conf` file, which is ready to go for most configurations. After the initial installation, set up eventual aliases in the `etc/aliases.conf` file.


Installation of the software
----------------------------
1. Get yourself a Raspberry Pi

2. Install an SD card with the latest version of Raspbian and execute the following commands after power on
     - Set an IP address in `/etc/network/interfaces`
     - Expand the filesystem with the `sudo raspi-config` utility
     - Set the correct time zone with the `sudo raspi-config` utility
     - Update sources `sudo apt-get update`
     - Upgrade the system `sudo apt-get -y dist-upgrade`
     - Reboot `sudo reboot`

3. Optional environment config

    ```
    sudo update-alternatives --set editor /usr/bin/vim.tiny
    ```

4. Fetch the piLogger software from GitHub

    ```
    git clone https://github.com/maglub/piLogger
    cd piLogger
    ```

5. Configure the installation
   ```
   ./configure
   ``` 
   or, if you have the AbioWire interface (http://www.axiris.eu/en/index.php/one-wire/abiowire) use 
   ```
   ./configure --withAbioWire --withLocale
   ```

6. Run `./setup.sh` which will install necessary packages (this will take ca 5 - 10 minutes)

7. `sudo reboot` since the install of owfs will not work before

Configuration of your setup
---------------------------

1. Quick setup (skip this step if you really want to understand what is happening)

   ```
   cd ~/piLogger/bin
   ./dbSetup --setup
   ```

   This will: 

   * Create any missing tables in the database
   * Scan the 1wire filesystem for sensor devices
   * Setup the "default" plot group with all found devices
   * Setup three plot configurations for the web gui
      - 12h
      - 24h
      - 168h

   Now you will have a setup that is ready to be used through the web gui. Note that you have not set up any aliases for your devices yet. See 3. below.

2. Scan for devices (into `~/piLogger/etc/devices.scanned`)

   ```
   cd ~/piLogger/bin
   ./dbTool --setup --db
   ./dbTool --scan
   ```
   This should show your connected devices and add them to `~/piLogger/etc/devices.scanned`, and show you what `./dbTool` commands to run to add the devices to the configuration database.

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

   Add your devices by copy/paste the `./dbTool` rows into your shell.

   Check that the devices were added to the database:
   ```
   ./dbTool -d
   ```
   
3. Set up aliases for your devices

   Check the current aliases 
   ```
   ./dbTool -a
   ```
   If the aliases are the same as the device id's, you can set an alias by running the following command:
   ```
   ./dbTool --add -a --deviceId XXXX --deviceAlias your_alias
   ```
   To speed things up, you can use the following command to help you create the aliases:

   ```
   ./dbTool -d | xargs -L1 -IX echo ./dbTool -a --add --deviceId X --deviceAlias YYY
   ```

4. Set up a "default" plot group with all devices:

   ```
   ./dbTool -d | xargs -L1 -I X ./dbTool --add -pg --plotGroup default --deviceId X
   ```

5. Set up a default web gui layout/plot config

   ```
   ./dbTool -pc --add --plotConfig default --plotGroup default --timeSpan 12h --plotWidth 6 --plotPriority 1
   ./dbTool -pc --add --plotConfig default --plotGroup default --timeSpan 24h --plotWidth 6 --plotPriority 2
   ./dbTool -pc --add --plotConfig default --plotGroup default --timeSpan 168h --plotWidth 12 --plotPriority 3
   ```

6. Test that the logging works, and that new rrd files are created.

   ```
   ~/piLogger/bin/logAll --db
   ```
   Check that the RRD files are created properly, one per device connected to your 1wire interface.

   ```
   pi@raspberrypi ~/piLogger/bin $ ls -la /var/lib/piLogger/db
   total 20264
   drwxr-xr-x 2 pi pi     4096 Feb  7 14:28 .
   drwxr-xr-x 5 pi pi     4096 Feb  7 14:21 ..
   -rw-r--r-- 1 pi pi 10370124 Feb  7 14:28 28.12ED2F040000.rrd
   -rw-r--r-- 1 pi pi 10370124 Feb  7 14:28 28.90EC2F040000.rrd
   ```
7. Refresh the cache files

   ```
   ~/piLogger/bin/refreshCaches
   ```

8. And lastly, set up cron so that you log and create the caches at a regular basis

   ```
   (crontab -l 2>/dev/null ;cat ~/piLogger/etc/cron/crontab.txt ) | crontab -
   ```

   Your crontab should look something like this:

   ```
   # m h  dom mon dow   command
   */1 * * * * base=/home/pi/piLogger ; $base/bin/logAll --db >/dev/null 2>&1 ; $base/bin/refreshCaches 12h ;    $base/bin/refreshCaches sensors
   */10 * * * * /home/pi/piLogger/bin/refreshCaches 24h 
   4 * * * * /home/pi/piLogger/bin/refreshCaches 48h
   5 */6 * * * /home/pi/piLogger/bin/refreshCaches 168h
   ```
   
9. Done! Test your webgui by entering the IP address of your Raspberry Pi in the address field in your browser.

Upgrade from previous version
=====================================================

If you upgrade from a previous version please follow the steps below:

1. fetch the missing commits from the github repo:
   ```
   git pull
   ```

2. run the upgrade script:
   ```
   ~/piLogger/bin/upgrade.sh --doIt
   ```


Notes and references
=====================================================

* Data files are found in `/var/lib/piLogger`

* Log files are found in `/var/log/piLogger`

* Config files are found in `/etc/piLogger.d`, which is conveniently symlinked to `~/piLogger/etc` 

* bash autocompletion is set up for most important scripts. This means that you can press <TAB> twice to see parameters and devices for most commands in `~/piLogger/bin`

* By setting the variable `debug=true` in `~/piLogger/etc/piLogger.conf` file, you will get more output on the screen and in the logfiles in `/var/log/piLogger`

* The debug=true can also be set in the URL for more information (i.e device info in the footer), http://your.server.name/?debug=true

* You can list your devices at any time by running the following commands, which will NOT alter any config files:
  ```
  ~/piLogger/bin/listDevices
  ~/piLogger/bin/listDevices --aliasFile
  ```
  
* You can rescan your devices, and automatically update the database with new devices by issuing the following command:
   ```
   ~/piLogger/bin/dbTool --scan
   ```

   Copy and paste the output into the terminal window to add the new devices.

* Backup / Recovery

   Backup to /var/lib/piLogger/backup

   ```
   ~/piLogger/bin/backup.sh
   ```

   For a recovery, do a fresh install on new SD card, then copy content of the backup.tgz file into /var/lib/piLogger/db.  Run ~/piLogger/bin/refreshCaches

