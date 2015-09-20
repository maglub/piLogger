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

  $this_script [ -h | --bare ]

Examples:

  $this_script
  $this_script -h
  $this_script --bare

Description:

The default action is to make a tar/gz dump of the database directory $dbDir.


If run with the --bare flag, this script will make a rrdtool dump of all rrd-files into xml files,
bundled into a tar file, so that they can be imported into a different system that might
have a different cpu endian. (i.e x86). The script will also include the app.sqlite3 file.  
The output file will be placed in $backupDir

EOT

}

function normalBackup(){
  cd /
  tar cvzf $backupDir/$backupFile $dbDir
}

function bareMetal(){
  TS=$(date "+%Y%m%d_%H%M%S")
  tmpDir=$(mktemp -d $backupDir/rrdDump.tmpDir.XXXXXX)
  outputFile="$backupDir/rrdDump.$TS.tar"
 
  [ -n "$1" ] && { usage ; exit 0 ; }

  [ ! -d $backupDir ] && mkdir -p $backupDir
  [ ! -d $backupDir ] && { echo "ERROR: No directory $backupDir" 1>&2 ; exit 1 ; }

  echo "* Exporting application data"
  echo "  - all rrd-files in $dbDir into temporary directory $tmpDir, final tar-file: $outputFile"
  echo
  
  #--- rrdtool dump
  ls -1 $dbDir/*.rrd | xargs -L1 basename | xargs -P4 -L1 -IXXXX sh -c "echo exporting XXXX ; rrdtool dump $dbDir/XXXX | gzip > $tmpDir/XXXX.xml.gz"

  echo
  echo "  - Copying $dbDir/app.sqlite3 into $tmpDir, final tar-file: $outputFile"
  
  cp $dbDir/app.sqlite3 $tmpDir

  echo "  - Backup directory: $tmpDir"
  echo
  ls -la $tmpDir
  echo
  
  #--- packaging it into a tar-file
  echo "  - Tar/gz of $tmpDir, final tar-file: $outputFile"
  echo
  cd $tmpDir
  tar cvf $outputFile *
  cd -

  echo
  echo "  - Removing $tmpDir"
  echo "* Resulting output file: $outputFile"
  rm -rf $tmpDir

}

#=====================================================
# MAIN
#=====================================================

[ -z "$1" ] && { normalBackup ; exit 0 ; }

while [ -n "$1" ]
do
  case $1 in
    --bare*)
      bareMetal
      exit 0
      ;;
    *)
      usage
      exit
      ;;
  esac
done
