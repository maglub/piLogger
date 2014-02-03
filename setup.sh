#!/bin/bash

this_dir=$(cd `dirname $0`; pwd)
binDir=$this_dir/bin
logDir=/var/log/piLogger
dataDir=/var/piLogger
dbDir=$dataDir/db
graphDir=$dataDir/graphs
oneWireDir=/mnt/1wire
configDir=$this_dir/etc
configFile=$configDir/piLogger.conf

needReboot=""

#=============================
# functions
#=============================
errorExit(){
  echo "ERROR: $@"
  exit 1
}


#================================
# 
#================================

#--- fetch config file
# Variables:
#  - interface

[ ! -f $configFile ] && errorExit "No config file $configFile, please run $this_dir/configure"
. $configDir/piLogger.conf

#================================
# Check that required variables are set
#================================

[ -z "$interface" ] && errorExit "_interface_ variable in $configFile not set, please run $this_dir/configure"

#================================
# Update some system files
#================================


#--- comment out the blacklist of i2c
echo "  - i2c config in /etc/modprobe.d/raspi-blacklist.conf"
sudo sed -ie 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf 

echo "  - adding i2c-dev to /etc/modules"
[ -z "$(grep i2c-dev /etc/modules)" ] && { sudo sh -c "echo i2c-dev >> /etc/modules" ; needReboot=true ; }


#--- setting up the locale
[ -n "$piLoggerLocale" ] && {
  echo "  - setting up locale (if not already set up)"
  [[ -z "$(grep -v '^#' /etc/locale.gen | grep 'en_US.UTF-8')" ]] && {
    sudo sed -ie  's/^# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    sudo locale-gen
  }

  [[ -z "$(grep 'LANGUAGE=' ~/.bash_profile)" ]] && {
    cat>>~/.bash_profile<<EOT
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
. ~/.bashrc
EOT
  }
}

#================================
# setup directories
#================================
[ ! -d "$logDir" ] && { sudo mkdir -p "$logDir" ; chown pi:pi "$logDir" ; }
[ ! -d "$dataDir" ] && sudo mkdir -p "$dataDir"
[ ! -d "$dbDir" ] && sudo mkdir -p "$dbDir"
[ ! -d "$graphDir" ] && sudo mkdir -p "$graphDir"
[ ! -d "$oneWireDir" ] && sudo mkdir -p "$oneWireDir"

sudo chown pi:pi "$dataDir"
sudo chown pi:pi "$dbDir"
sudo chown pi:pi "$graphDir"
#================================
# Check for dependencies
#================================

echo "  - Interface: $interface"

#--------------
# OWFS
#--------------
sudo dpkg -s owfs >/dev/null 2>&1 || { echo "  - Installing owfs" ; sudo apt-get -y install owfs ; }
[ ! -h /etc/init.d/start1wire ] && { sudo ln -s $this_dir/etc/init.d/start1wire /etc/init.d/ ; needReboot=true ; }
[ ! -h /etc/rc2.d/S02start1wire ] && { sudo update-rc.d start1wire defaults ; needReboot=true ; }

#--------------
# OWS
#--------------
case $interface in
    AbioWire)
      abioDir=$this_dir/AbioWire
      [ ! -d /opt/ows ] && {
         [ ! -d $this_dir/AbioWire ] && {
           echo "  - Fetching AbioWire owfs from http://www.axiris.eu/en/index.php/one-wire/one-wire-software"
           echo "    - creating directory $this_dir/AbioWire"
           mkdir -p $this_dir/AbioWire
           cd $this_dir/AbioWire
           wget http://www.axiris.eu/download/ows/1.3.2/ows-1.3.2-linux-armel.tar.gz
           tar xvzf ows-1.3.2-linux-armel.tar.gz
         }
         cd $this_dir/AbioWire/ows-1.3.2-linux-armel
         ./install.sh
         cd $this_dir
         exit

      }
      ;;
    *)
      echo "  - No special interfaces"
      ;;
esac

#------------------
# RRDTool
#------------------
sudo dpkg -s rrdtool >/dev/null 2>&1 || { echo "  - Installing rrdtool" ; sudo apt-get -y install rrdtool ; }

#------------------
# Lighttpd
#------------------
sudo dpkg -s lighttpd >/dev/null 2>&1 || { echo "  - Installing lighttpd" ; sudo apt-get -y install lighttpd ; }
#[ ! -h /etc/lighttpd/conf-enabled/10-dir-listing.conf ] && sudo ln -s /etc/lighttpd/conf-available/10-dir-listing.conf /etc/lighttpd/conf-enabled

[ -f /etc/lighttpd/lighttpd.conf ]  && { sudo mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org ; sudo ln -s $configDir/lighttpd/lighttpd.conf /etc/lighttpd ; }
[ ! -h /etc/lighttpd/conf-enabled/10-accesslog.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-accesslog.conf /etc/lighttpd/conf-enabled
[ ! -h /etc/lighttpd/conf-enabled/10-dir-listing.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-dir-listing.conf /etc/lighttpd/conf-enabled
[ ! -h /etc/lighttpd/conf-enabled/10-cgi.conf ] && sudo ln -s $configDir/lighttpd/conf-enabled/10-cgi.conf /etc/lighttpd/conf-enabled

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
# /etc/piLogger.conf link to installation directory
#================================
echo "  - Setting up bash completion"
[ ! -h /etc/bash_completion.d/piLogger ] && { sudo ln -s $this_dir/bin/shellFunctions /etc/bash_completion.d/piLogger ; needReboot=true ; }

#================================
# /etc/piLogger.conf link to installation directory
#================================
[[ ! -d /etc/piLogger.d && ! -h /etc/piLogger.d ]] && sudo ln -s $configDir /etc/piLogger.d


#================================
# End
#================================
[ -n "$needReboot" ] && {
  echo "* Done, please reboot!"
  echo "  sudo shutdown -r now"
}

