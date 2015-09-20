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
#============================================
# Functions
#============================================

function usage(){
  cat<<EOT

Usage: $this_script [ --doIt | --dryRun ]

EOT
}

#============================================
# Setup
#============================================
piLogger_setupVersionsTable

currentVersion=$(piLogger_getCurrentVersion)
installedVersion=$(piLogger_getInstalledVersion)


#==========================================
# MAIN
#==========================================

while [ -n "$1" ]
do
  case $1 in
    --doIt)
      doIt=true
      shift
      ;;
    --dryRun)
      dryRun=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown parameter $1" 1>&2
      usage
      exit 0
      ;;
  esac
done

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

[ -z "$doIt" ] && { echo "No --doIt flag passed to this script, so no action will be taken" ; }
[ -n "$dryRun" ] && { echo "This will show what steps that will be taken, without performing any upgrade." ; }


[[ -z "$doIt" && -z "$dryRun" ]] && { echo "Neither --doIt or --dryRun was passed as parameter, exiting." 1>&2 ; exit 0 ; }

versions="20150422-001
20150423-001
20150423-002
20150423-003
20150425-001
20150427-001
20150508-001
20150509-001
20150615-001
20150628-001
20150823-001
20150916-001
20150918-001
20150920-001"

fromVersion=""
for toVersion in $versions
do
  if [ -n "$fromVersion" ]
  then
    . $this_dir/../etc/piLogger.conf
    [ "$installedVersion" = "$fromVersion" ] && piLogger_upgrade "$fromVersion" "$toVersion"
    installedVersion=$(piLogger_getInstalledVersion)
  fi
    fromVersion=$toVersion
done
