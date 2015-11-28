#!/bin/bash

this_dir=$(cd `dirname $0`; pwd)
binDir=$this_dir/bin
configDir=$this_dir/etc

[ ! -f $configDir/piLogger.conf ] && errorExit "No config file $configDir/piLogger.conf, please run $this_dir/configure"
. $configDir/piLogger.conf
. $baseDir/bin/functions-upgrade

needReboot=""

#=============================
# functions
#=============================
errorExit(){
  echo "ERROR: $@"
  exit 1
}

cat<<EOT
#================================
# Check that required variables are set
#================================
EOT

[ -z "$interface" ] && errorExit "_interface_ variable in $configDir/piLogger.conf not set, please run $this_dir/configure"

cat<<EOT
#================================
# Minimize install
#================================
EOT

[ -n "$minimizeInstall" ] && {
  sudo rm -rf python_games
  sudo apt-get -y autoremove x11-common
  sudo apt-get -y autoremove midori
  sudo apt-get -y autoremove python*
  sudo apt-get -y autoremove lxde-icon-theme
  sudo apt-get -y autoremove omxplayer
  sudo apt-get -y autoremove wolfram-engine  
  sudo apt-get -y autoremove scratch
  sudo apt-get -y autoremove dillo
  sudo apt-get -y autoremove galculator
  sudo apt-get -y autoremove netsurf-common
  sudo apt-get -y autoremove netsurf-gtk
  sudo apt-get -y autoremove lxde-common
  sudo apt-get -y autoremove lxdeterminal
  sudo apt-get -y autoremove hicolor-icon-theme 
  sudo apt-get -y autoremove libreoffice
  sudo apt-get -y autoremove libreoffice-core
  sudo apt-get -y autoremove
  sudo apt-get -y clean
  sudo rm -rf /usr/share/icons/*
  sudo rm -rf /opt/vc/src/*
  sudo rm -rf /usr/share/icons/*
  sudo rm -rf /usr/share/wallpapers
  sudo rm -rf /usr/share/themes
  sudo rm -rf /usr/share/kde4

  # remove some folders from a clean debian jessie installation
  sudo rm -rf /home/pi/Music
  sudo rm -rf /home/pi/Pictures
  sudo rm -rf /home/pi/Desktop
  sudo rm -rf /home/pi/Documents
  sudo rm -rf /home/pi/Downloads
  sudo rm -rf /home/pi/Public
  sudo rm -rf /home/pi/Templates
  sudo rm -rf /home/pi/Videos

  echo "sudo find / -name *.wav -exec rm {} \\; " ; # 29.80MB
  echo "sudo find / -name *.mp3 -exec rm {} \\; " ; # 1.94MB
}

cat<<EOT
#================================
# enable i2c kernel modules
#================================
EOT

#--- enable i2c_arm and i2c1 options
echo "  - enabling i2c config in /boot/config.txt"
sudo sed -ie 's/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/' /boot/config.txt
sudo sed -ie 's/^#dtparam=i2c1=on/dtparam=i2c1=on/' /boot/config.txt

echo "  - adding i2c-dev to /etc/modules"
[ -z "$(grep i2c-dev /etc/modules)" ] && { sudo sh -c "echo i2c-dev >> /etc/modules" ; needReboot=true ; }


cat<<EOT
#================================
# correctly configure locales
#================================
EOT

#--- setting up the locale
[ -n "$piLoggerLocale" ] && {
  echo "  - setting up locale (if not already set up)"
  [[ -z "$(grep -v '^#' /etc/locale.gen | grep 'en_US.UTF-8')" ]] && {
    sudo sed -ie  's/^# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    sudo locale-gen
    sudo update-locale LANG=en_US.UTF-8
    sudo update-locale LANGUAGE=en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8
  }
}

cat<<EOT
#================================
# setup directories
#================================
EOT
[ ! -d "$logDir" ]     && { echo "Creating logDir: $logDir"         ; sudo mkdir -p "$logDir"     ; }
[ ! -d "$dataDir" ]    && { echo "Creating dataDir: $dataDir"       ; sudo mkdir -p "$dataDir"    ; }
[ ! -d "$dbDir" ]      && { echo "Creating dbDir: $dbDir"           ; sudo mkdir -p "$dbDir"      ; }
[ ! -d "$graphDir" ]   && { echo "Creating graphDir: $graphDir"     ; sudo mkdir -p "$graphDir"   ; }
[ ! -d "$cacheDir" ]   && { echo "Creating cacheDir: $cacheDir"     ; sudo mkdir -p "$cacheDir"   ; }
[ ! -d "$oneWireDir" ] && { echo "Creating oneWireDir: $oneWireDir" ; sudo mkdir -p "$oneWireDir" ; }
[ ! -d "$backupDir" ]  && { echo "Creating backupDir: $backupDir"   ; sudo mkdir -p "$backupDir"  ; }
[ ! -d "$dataDir/remote-logging-enabled" ]  && { echo "Creating remote-logging-enabled: $dataDir/remote-logging-enabled"   ; sudo mkdir -p "$dataDir"/remote-logging-enabled  ; }
[ ! -d "$spoolDir" ]  && { echo "Creating spoolDir: $spoolDir"   ; sudo mkdir -p "$spoolDir"  ; }

myUser=$(id -u)
myGroup=$(id -g)

sudo chown ${myUser}:${myGroup} "$dataDir"
sudo chown ${myUser}:${myGroup} "$logDir"
sudo chown ${myUser}:${myGroup} "$graphDir"
sudo chown ${myUser}:${myGroup} "$cacheDir"
sudo chown ${myUser}:${myGroup} "$backupDir"
sudo chown ${myUser}:${myGroup} "$dataDir/remote-logging-enabled"
sudo chown ${myUser}:${myGroup} "$spoolDir"
sudo chmod 777 $spoolDir

sudo chown ${myUser}:www-data "$dbDir"
sudo chmod 775 $dbDir

[ ! -h $this_dir/html/cache ] && { ln -s $cacheDir $this_dir/html/cache ; }
[ ! -d $this_dir/html/graphs ] && { ln -s $dataDir/graphs $this_dir/html/graphs ; }
[ ! -d $this_dir/html/xml ] && { mkdir $dataDir/xml ; ln -s $dataDir/xml $this_dir/html/xml ; }

cat<<EOT
#================================
# Make sure the latest updates are available
#================================
EOT
curTS=$(date "+%s")
aptTS=$(stat -c %Y /var/cache/apt/)

(( ageApt = $curTS - $aptTS ))
#--- one day  =  86400
#--- one week = 604800
[ $ageApt -gt 604800 ] && sudo apt-get update

cat<<EOT
#================================
# Check for dependencies
#================================
EOT

echo "  - Interface: $interface"

cat<<EOT
#================================
# bc
#================================
EOT
sudo dpkg -s bc >/dev/null 2>&1 || { echo "  - Installing bc" ; sudo apt-get -q -y install bc ; }
sudo dpkg -s dnsutils >/dev/null 2>&1 || { echo "  - Installing dnsutils" ; sudo apt-get -q -y install dnsutils ; }

cat<<EOT
#================================
# OWFS
#================================
EOT
sudo dpkg -s owfs >/dev/null 2>&1 || { echo "  - Installing owfs" ; sudo apt-get -q -y install owfs ; }
[ ! -h /etc/init.d/start1wire ] && { sudo ln -s $this_dir/etc/init.d/start1wire /etc/init.d/ ; needReboot=true ; }
[ ! -h /etc/rc2.d/S02start1wire ] && { sudo update-rc.d start1wire defaults ; needReboot=true ; }

#--- remove dummy devices from the config file /etc/owfs.conf
sudo sed -i 's/^server: FAKE/#server: FAKE/' /etc/owfs.conf 

#--- disable owftpd, owhttpd and owserver
sudo update-rc.d owftpd disable > /dev/null
sudo update-rc.d owhttpd disable > /dev/null
sudo update-rc.d owserver disable > /dev/null

cat<<EOT
#================================
# RRDTool
#================================
EOT
sudo dpkg -s rrdtool >/dev/null 2>&1 || { echo "  - Installing rrdtool" ; sudo apt-get -q -y install rrdtool ; }

cat<<EOT
#================================
# sqlite3
#================================
EOT
sudo dpkg -s sqlite3 >/dev/null 2>&1 || { echo "  - Installing sqlite3" ; sudo apt-get -q -y install sqlite3 ; }

#--- setup the sqlite3 config database
[ ! -f $appDbFile ] && {
  echo "  - Setting upp $appDbFile database" 
  $binDir/dbTool --setup --db 
  currentVersion=$(cat $baseDir/currentVersion | grep -vE "#|^$")
  echo "  - Setting the installed version to $currentVersion" 
  piLogger_setInstalledVersion $currentVersion 
}


cat<<EOT
#================================
# php5
#================================
EOT
curInstallPackages=""
for package in php5-cgi php5 php5-sqlite php5-cli php5-rrd
do
  sudo dpkg -s $package >/dev/null 2>&1 || { echo "  - Adding package $package to the install list" ; curInstallPackages="$curInstallPackages $package" ; }
done

[ -n "$curInstallPackages" ] && { echo "  - Installing packages: $curInstallPackages" ; sudo apt-get -q -y install $curInstallPackages ; }

cat<<EOT
#================================
# Lighttpd
#================================
EOT
sudo dpkg -s lighttpd >/dev/null 2>&1 || { echo "  - Installing lighttpd" ; sudo apt-get -q -y install lighttpd ; }

[ -f /etc/lighttpd/lighttpd.conf ]  && { sudo mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org ; sudo ln -s $configDir/lighttpd/lighttpd.conf /etc/lighttpd ; }
[ ! -h /etc/lighttpd/conf-enabled/10-accesslog.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-accesslog.conf /etc/lighttpd/conf-enabled
[ ! -h /etc/lighttpd/conf-enabled/10-dir-listing.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-dir-listing.conf /etc/lighttpd/conf-enabled
[ ! -h /etc/lighttpd/conf-enabled/10-cgi.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-cgi.conf /etc/lighttpd/conf-enabled

#--- make sure Apache2 is disabled
sudo service apache2 stop
sudo update-rc.d apache2 disable > /dev/null
sudo service lighttpd restart

cat<<EOT
#================================
# Set up bash completion by linking shellFunctions to /etc/bash_completion.d/piLogger
#================================
EOT
echo "  - Setting up bash completion"
[ ! -h /etc/bash_completion.d/piLogger ] && { sudo ln -s $this_dir/bin/shellFunctions /etc/bash_completion.d/piLogger ; needReboot=true ; }

cat<<EOT
#================================
# /etc/piLogger.conf link to installation directory
#================================
EOT
[[ ! -d /etc/piLogger.d && ! -h /etc/piLogger.d ]] && sudo ln -s $configDir /etc/piLogger.d

cat<<EOT
#================================
# Setup logrotate
#================================
EOT
[[ ! -r /etc/logrotate.d/piLogger ]] && sudo cp $configDir/logrotate.d/piLogger /etc/logrotate.d/piLogger

cat<<EOT
#================================
# Setup sudoers
#================================
EOT
sudo cp $configDir/sudoers.d/piLogger /etc/sudoers.d/piLogger ; sudo chown root:root /etc/sudoers.d/piLogger ; sudo chmod 0440 /etc/sudoers.d/piLogger 

cat<<EOT
#================================
# Show info about timezones
#================================
EOT
  echo "* If your timezone is not set, you can do so by running:"
  echo "sudo cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime"

cat<<EOT
#================================
# Setup admin password (setting the default password to "admin")
#================================
EOT
$this_dir/bin/resetPassword admin

cat<<EOT
#================================
# Run the upgrade script
#================================
EOT

$this_dir/bin/upgrade.sh --doIt

cat<<EOT
#================================
# Run composer
#================================
EOT
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
cd $this_dir
composer install
cd -

cat<<EOT
#================================
# End
#================================
EOT
[ -n "$needReboot" ] && {
  echo "* Done, please reboot!"
  echo "  sudo shutdown -r now"
}

