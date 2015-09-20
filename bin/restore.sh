#!/bin/bash

this_dir=$(cd `dirname $0`;pwd)

. $this_dir/../etc/piLogger.conf
. $this_dir/functions

TS=$(date "+%Y%m%d_%H%M%S")
backupFile=${TS}.tgz

[ -z "$backupDir" ] && { logIt "Error: backupDir is not set in $this_dir/../etc/piLogger.conf, exiting." ; exit 1 ; }
[ ! -d $backupDir ] && mkdir -p $backupDir
[ ! -d $backupDir ] && { logIt "Error: $backupDir does not exist, and is not possible to create, exiting"; exit 1; }

#=====================================================
# Functions
#=====================================================
function usage(){
cat<<EOT

Usage:

  $this_script [ -l | --list | -h | --bare ]

Examples:

  $this_script                            # this help screen
  $this_script -h                         # this help screen
  $this_script --bare /path/to/file       # restore bare metal dump (rrdtool restore, app.sqlite3), normally used to
                              # set up a new development environment
  $this_script --list                     # list files in $backupDir

Description:


EOT

}

function listFiles(){

	echo "* Listing of files in $backupDir"
	echo
	
	ls -lA $backupDir
}


function restoreBareMetal(){

	restoreFile="$1"
    tmpDir=$(mktemp -d $backupDir/rrdDump.tmpDir.XXXXXX)

	echo "* Restoring from bare metal backup file: $restoreFile"
	
	[ ! -f "$restoreFile" ] && { echo "ERROR: file $restoreFile not found" 1>&2 ; exit 1 ; }
	echo "  - Creating tmp dir $tmpDir"

	cd $tmpDir

	echo "  - Extracting tar file $restoreFile"
	echo
	tar xf $restoreFile
	ls -1 *.gz | xargs -L1 -P4 -IXXXX sh -c "echo extracting XXXX ; gunzip XXXX "


	echo
	echo "  - Removing old rrd files in $dbDir"
	rm $dbDir/*.rrd

	echo "  - Importing xml files"
	echo
    ls -1 *.xml | xargs -L1 -IX basename X .rrd.xml | xargs -L1 -P4 -IXXXX sh -c "echo restoring XXXX.rrd.xml to $dbDir/XXXX.rrd; rrdtool restore XXXX.rrd.xml $dbDir/XXXX.rrd -f" 	

	echo
	echo "  - Restoring app.sqlite3"
	cp app.sqlite3 $dbDir/app.sqlite3
	
	echo "  - Removing tmpDir: $tmpDir"
	echo
	echo "  - Running $baseDir/bin/refreshCaches"
	$baseDir/bin/refreshCaches
	
	echo
	echo " * Done"
	rm -rf $tmpDir
	
}
#=====================================================
# MAIN
#=====================================================

[ -z "$1" ] && { usage ; exit 0 ; }

while [ -n "$1" ]
do
  case $1 in
    --bare*)
      restoreBareMetal "$2"
      exit 0
      ;;
	--list)
	  listFiles
	  exit 0
	  ;;
    *)
      usage
      exit
      ;;
  esac
done
