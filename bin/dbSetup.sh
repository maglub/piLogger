#!/bin/bash

this_dir=$(cd `dirname $0`; pwd)
this_script=$(basename $0)

. $this_dir/../etc/piLogger.conf

#--------------------------------
# usage()
#--------------------------------
usage(){
  cat<<EOT

This script will perform an initial setup of the database, doing the following:

* Create any missing tables in the database
* Scan the 1wire filesystem for sensor devices
* Setup the "default" plot group with all found devices
* Setup three plot configurations for the web gui
  - 12h
  - 24h
  - 168h

Uage:

  $this_script { --db } [options]

Actions:
  --setup   - Setup the application database the first time

Example:
  ./$this_script --setup

EOT
}

#--------------------------------
# doInitialSetupDb()
#--------------------------------
function doInitialSetupDb(){
  $this_dir/dbTool --setup --db
  $this_dir/dbTool --scan
  $this_dir/dbTool --scan | grep "^./dbTool" | xargs -L1 -IX sh -c "X"
  $this_dir/dbTool -d | xargs -L1 -I X ./dbTool --add -pg --plotGroup default --deviceId X
  $this_dir/dbTool -pc --add --plotConfig default --plotGroup default --timeSpan 12h --plotWidth 6 --plotPriority 1
  $this_dir/dbTool -pc --add --plotConfig default --plotGroup default --timeSpan 24h --plotWidth 6 --plotPriority 2
  $this_dir/dbTool -pc --add --plotConfig default --plotGroup default --timeSpan 168h --plotWidth 12 --plotPriority 3

  $this_dir/logAll --db
  $this_dir/refreshCaches
}

#=========================================
# MAIN
#=========================================

[ -z "$1" ] && { usage ; exit 0 ; }

case $1 in
  --setup)
    doInitialSetupDb
    exit 0
    ;;
esac
