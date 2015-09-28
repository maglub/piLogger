# Introduction

This directory contains a couple of check scripts that can be used to monitor the piLogger application.

# Installation

Requisite: libnagios-plugin-perl nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-common nagios-plugins-contrib nagios-plugins-standard 

```
sudo apt-get install libnagios-plugin-perl nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-common nagios-plugins-contrib nagios-plugins-standard 
```

* Note, you will have to set the "allowed_hosts" to the IP address of your monitoring server in the configuration file /etc/nagios/nrpe.cfg

```
sudo ln -s /home/pi/piLogger/etc/nagios/nrpe.d/piLogger.cfg /etc/nagios/nrpe.d/
sudo service nagios-nrpe-server restart
```

