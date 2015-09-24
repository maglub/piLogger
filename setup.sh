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


#================================
# Check that required variables are set
#================================

[ -z "$interface" ] && errorExit "_interface_ variable in $configDir/piLogger.conf not set, please run $this_dir/configure"

#================================
# Minimize install
#================================

[ -n "$minimizeInstall" ] && {
  sudo rm -rf python_games
  sudo apt-get -y autoremove x11-common
  sudo apt-get -y autoremove midori
  sudo apt-get -y autoremove python*
  sudo apt-get -y autoremove lxde-icon-theme
  sudo apt-get -y autoremove omxplayer
  sudo apt-get -y autoremove wolfram-engine  
  sudo apt-get -y autoremove -y scratch
  sudo apt-get -y autoremove -y dillo
  sudo apt-get -y autoremove -y galculator
  sudo apt-get -y autoremove -y netsurf-common
  sudo apt-get -y autoremove -y netsurf-gtk
  sudo apt-get -y autoremove -y lxde-common
  sudo apt-get -y autoremove -y lxdeterminal
  sudo apt-get -y autoremove -y hicolor-icon-theme 
  sudo apt-get -y autoremove
  sudo apt-get -y clean
  sudo rm -rf /usr/share/icons/*
  sudo rm -rf /opt/vc/src/*
  sudo rm -rf /usr/share/icons/*
  sudo rm -rf /usr/share/wallpapers
  sudo rm -rf /usr/share/themes
  sudo rm -rf /usr/share/kde4

  echo "sudo find / -name *.wav -exec rm {} \\; " ; # 29.80MB
  echo "sudo find / -name *.mp3 -exec rm {} \\; " ; # 1.94MB
}

#================================
# enable i2c kernel modules
#================================

#--- enable i2c_arm and i2c1 options
echo "  - enabling i2c config in /boot/config.txt"
sudo sed -ie 's/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/' /boot/config.txt
sudo sed -ie 's/^#dtparam=i2c1=on/dtparam=i2c1=on/' /boot/config.txt

echo "  - adding i2c-dev to /etc/modules"
[ -z "$(grep i2c-dev /etc/modules)" ] && { sudo sh -c "echo i2c-dev >> /etc/modules" ; needReboot=true ; }


#================================
# correctly configure locales
#================================

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

#================================
# setup directories
#================================
[ ! -d "$logDir" ]     && { echo "Creating logDir: $logDir"         ; sudo mkdir -p "$logDir"     ; }
[ ! -d "$dataDir" ]    && { echo "Creating dataDir: $dataDir"       ; sudo mkdir -p "$dataDir"    ; }
[ ! -d "$dbDir" ]      && { echo "Creating dbDir: $dbDir"           ; sudo mkdir -p "$dbDir"      ; }
[ ! -d "$graphDir" ]   && { echo "Creating graphDir: $graphDir"     ; sudo mkdir -p "$graphDir"   ; }
[ ! -d "$cacheDir" ]   && { echo "Creating cacheDir: $cacheDir"     ; sudo mkdir -p "$cacheDir"   ; }
[ ! -d "$oneWireDir" ] && { echo "Creating oneWireDir: $oneWireDir" ; sudo mkdir -p "$oneWireDir" ; }
[ ! -d "$backupDir" ]  && { echo "Creating backupDir: $backupDir"   ; sudo mkdir -p "$backupDir"  ; }
[ ! -d "$dataDir/remote-logging-enabled" ]  && { echo "Creating remote-logging-enabled: $dataDir/remote-logging-enabled"   ; sudo mkdir -p "$dataDir"/remote-logging-enabled  ; }

myUser=$(id -u)
myGroup=$(id -g)

sudo chown ${myUser}:${myGroup} "$dataDir"
sudo chown ${myUser}:${myGroup} "$logDir"
sudo chown ${myUser}:${myGroup} "$dbDir"
sudo chown ${myUser}:${myGroup} "$graphDir"
sudo chown ${myUser}:${myGroup} "$cacheDir"
sudo chown ${myUser}:${myGroup} "$backupDir"

[ ! -h $this_dir/html/cache ] && { ln -s $cacheDir $this_dir/html/cache ; }
[ ! -d $this_dir/html/graphs ] && { ln -s $dataDir/graphs $this_dir/html/graphs ; }
[ ! -d $this_dir/html/xml ] && { mkdir $dataDir/xml ; ln -s $dataDir/xml $this_dir/html/xml ; }

#================================
# Make sure the latest updates are available
#================================
curTS=$(date "+%s")
aptTS=$(stat -c %Y /var/cache/apt/)

(( ageApt = $curTS - $aptTS ))
#--- one day  =  86400
#--- one week = 604800
[ $ageApt -gt 604800 ] && sudo apt-get update

#================================
# Check for dependencies
#================================

echo "  - Interface: $interface"

#--------------
# bc
#--------------
sudo dpkg -s bc >/dev/null 2>&1 || { echo "  - Installing bc" ; sudo apt-get -y install bc ; }
sudo dpkg -s dnsutils >/dev/null 2>&1 || { echo "  - Installing dnsutils" ; sudo apt-get -y install dnsutils ; }

#--------------
# OWFS
#--------------
sudo dpkg -s owfs >/dev/null 2>&1 || { echo "  - Installing owfs" ; sudo apt-get -y install owfs ; }
[ ! -h /etc/init.d/start1wire ] && { sudo ln -s $this_dir/etc/init.d/start1wire /etc/init.d/ ; needReboot=true ; }
[ ! -h /etc/rc2.d/S02start1wire ] && { sudo update-rc.d start1wire defaults ; needReboot=true ; }

#--- remove dummy devices from the config file /etc/owfs.conf
sudo sed -i 's/^server: FAKE/#server: FAKE/' /etc/owfs.conf 

#------------------
# RRDTool
#------------------
sudo dpkg -s rrdtool >/dev/null 2>&1 || { echo "  - Installing rrdtool" ; sudo apt-get -y install rrdtool ; }

#------------------
# Lighttpd
#------------------
sudo dpkg -s lighttpd >/dev/null 2>&1 || { echo "  - Installing lighttpd" ; sudo apt-get -y install lighttpd ; }

[ -f /etc/lighttpd/lighttpd.conf ]  && { sudo mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org ; sudo ln -s $configDir/lighttpd/lighttpd.conf /etc/lighttpd ; }
[ ! -h /etc/lighttpd/conf-enabled/10-accesslog.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-accesslog.conf /etc/lighttpd/conf-enabled
[ ! -h /etc/lighttpd/conf-enabled/10-dir-listing.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-dir-listing.conf /etc/lighttpd/conf-enabled
[ ! -h /etc/lighttpd/conf-enabled/10-cgi.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-cgi.conf /etc/lighttpd/conf-enabled


#----------------------
# sqlite3
#----------------------
sudo dpkg -s sqlite3 >/dev/null 2>&1 || { echo "  - Installing sqlite3" ; sudo apt-get -y install sqlite3 ; }

#--- setup the sqlite3 config database
[ ! -f $appDbFile ] && {
  echo "  - Setting upp $appDbFile database" 
  $binDir/dbTool --setup --db 
  currentVersion=$(cat $baseDir/currentVersion | grep -vE "#|^$")
  echo "  - Setting the installed version to $currentVersion" 
  piLogger_setInstalledVersion $currentVersion 
}


#----------------------
# php5
#----------------------
sudo dpkg -s php5 >/dev/null 2>&1 || { echo "  - Installing php5" ; sudo apt-get -y install php5 php5-sqlite php5-cgi php5-cli php5-rrd ; }

#================================
# Setup index.html
#================================
[ ! -f $this_dir/html/index.html ] && ln -s index.html.template $this_dir/html/index.html

#================================
# alias.conf file template
#================================
[ ! -f $configDir/aliases.conf ] && {
cat>$configDir/aliases.conf<<EOT
#-----------------------------------------------
# aliases.conf
#
# Example:
# indoor1;1wire;/mnt/1wire/bus.12/28.12ED2F040000
#-----------------------------------------------
# alias ; type ; path
EOT
}

#================================
# Set up bash completion by linking shellFunctions to /etc/bash_completion.d/piLogger
#================================
echo "  - Setting up bash completion"
[ ! -h /etc/bash_completion.d/piLogger ] && { sudo ln -s $this_dir/bin/shellFunctions /etc/bash_completion.d/piLogger ; needReboot=true ; }

#================================
# /etc/piLogger.conf link to installation directory
#================================
[[ ! -d /etc/piLogger.d && ! -h /etc/piLogger.d ]] && sudo ln -s $configDir /etc/piLogger.d

#================================
# Setup logrotate
#================================
[[ ! -r /etc/logrotate.d/piLogger ]] && sudo cp $configDir/logrotate.d/piLogger /etc/logrotate.d/piLogger

#================================
# Setup sudoers
#================================
sudo cp $configDir/sudoers.d/piLogger /etc/sudoers.d/piLogger ; sudo chown root:root /etc/sudoers.d/piLogger ; sudo chmod 0440 /etc/sudoers.d/piLogger 

#================================
# Show info about timezones
#================================
  echo "* If your timezone is not set, you can do so by running:"
  echo "sudo cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime"
#================================
# Run the upgrade script
#================================

$this_dir/bin/upgrade.sh --doIt

#================================
# Run composer
#================================
cd $this_dir/include
curl -s https://getcomposer.org/installer | php
./composer.phar install
cd -

#================================
# End
#================================
[ -n "$needReboot" ] && {
  echo "* Done, please reboot!"
  echo "  sudo shutdown -r now"
}

