#!/bin/bash

this_dir=$(cd `dirname $0`;pwd)

. $this_dir/../etc/piLogger.conf
. $this_dir/functions

TS=$(date "+%Y%m%d_%H%M%S")
backupFile=${TS}.tgz

[ -z "$backupDir" ] && { logIt "Error: backupDir is not set in $this_dir/../etc/piLogger.conf, exiting." ; exit 1 ; }
[ ! -d $backupDir ] && mkdir -p $backupDir
[ ! -d $backupDir ] && { logIt "Error: $backupDir does not exist, and is not possible to create, exiting"; exit 1; }

#-------------------------
# make the backup
#-------------------------
cd /
tar cvzf $backupDir/$backupFile $dbDir
