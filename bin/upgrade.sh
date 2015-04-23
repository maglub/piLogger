#!/bin/bash

this_dir=$(cd `dirname $0`; pwd)
this_script=$(basename $0)

. $this_dir/../etc/piLogger.conf
. $this_dir/functions
. $this_dir/functions-sqlite3
. $this_dir/functions-upgrade

#============================================
# This script is meant to do file system maintenance, database
# updates/changes between versions
#
# The script will try and do step-wise actions if needed, for example
# if there has been a number of releases since last upgrade, and if a change between version 20150401-001
# and 2015-0402 requires certain steps to be taken, this should be reflected
# 
#
#============================================

piLogger_setupVersionsTable

currentVersion=$(piLogger_getCurrentVersion)
installedVersion=$(piLogger_getInstalledVersion)

#--------------------------------------------
# Installed version started to be marked 2015-04-23
# any release before that will return "20150422"
#--------------------------------------------

cat<<EOT
Current version: $currentVersion
Installed version: $installedVersion
EOT

#--------------------------------------------
#--- if this is a brand new install, do nothing
#--------------------------------------------

[ "$currentVersion" = "$installedVersion" ] && { echo "No upgrade needed" ; exit 0 ; }

[[ -n "$1" && "$1" = "--doIt" ]] && doIt=true

[ -z "$doIt" ] && { echo "No --doIt flag passed to this script, so no action will be taken" ; exit 0 ; }

fromVersion="20150422-001"
  toVersion="20150423-001"
[ "$installedVersion" = "$fromVersion" ] && piLogger_upgrade "$fromVersion" "$toVersion"
installedVersion=$(piLogger_getInstalledVersion)

fromVersion="20150423-001"
  toVersion="20150423-002"
[ "$installedVersion" = "$fromVersion" ] && piLogger_upgrade "$fromVersion" "$toVersion"
installedVersion=$(piLogger_getInstalledVersion)

fromVersion="20150423-002"
  toVersion="20150423-003"
[ "$installedVersion" = "$fromVersion" ] && piLogger_upgrade "$fromVersion" "$toVersion"
installedVersion=$(piLogger_getInstalledVersion)



