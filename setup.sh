#!/bin/bash

this_dir=$(cd `dirname $0`; pwd)
binDir=$this_dir/bin
logDir=/var/log/piLogger
dataDir=/var/piLogger
oneWireDir=/mnt/1wire
configDir=$this_dir/etc
configFile=$configDir/piLogger.conf

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

echo "  - i2c config in /etc/modprobe.d/raspi-blacklist.conf"
#--- comment out the blacklist of i2c
sudo sed -ie 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf 
echo "  - adding i2c-dev to /etc/modules"
[ -z "$(grep i2c-dev /etc/modules)" ] && sudo sh -c "echo i2c-dev >> /etc/modules"


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
[ ! -d "$oneWireDir" ] && sudo mkdir -p "$oneWireDir"

#================================
# Check for dependencies
#================================

echo "  - Interface: $interface"

#--------------
# OWFS
#--------------
sudo dpkg -s owfs >/dev/null 2>&1 || { echo "  - Installing owfs" ; sudo apt-get -y install owfs ; }
[ ! -h /etc/init.d/start1wire ] && sudo ln -s $this_dir/etc/init.d/start1wire /etc/init.d/
[ ! -h /etc/rc2.d/S02start1wire ] && sudo update-rc.d start1wire defaults

#--------------
# OWS
#--------------
case $interface in
    AbioWire)
      abioDir=$this_dir/AbioWire
      [ ! -d /opt/owf ] && {
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
