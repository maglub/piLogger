#!/bin/bash


########################################################
# this is the remote logging plugin for piLogger Cloud
# to get things up and running you will have to do the 
# following changes to your environment:
#
# 1. turn on remote logging if you dont have yet
#    you can do this by editing ~/piLogger/etc/piLogger.conf
#    and change remoteLogging=true
#
# 2. enable the piLogging Cloud Plugin by creating the following
#    symlink: cd /var/lib/piLogger/remote-logging-enabled
#             ln -s ~/piLogger/etc/piLogger-cloud.sh
#
# 3. add the authToken of your user to the piLogger.conf
#    this should then looks like below:
#    authToken=e8c1458438ead3c34974bc0be3a03ed6
########################################################

#--------------------
# variables
#--------------------
this_dir=$(cd `dirname $0`;pwd)
configDir=$this_dir/../etc

#--------------------
# MAIN
#--------------------

# first parse the piLogger config file
. $configDir/piLogger.conf

# now do the HTTP PUT request to the REST API
response=$(curl -H 'Content-Type: application/json' -X PUT \
                --write-out %{http_code} --silent --output /dev/null \
                -d "{\"probeTime\": \"$PILOGGER_METRIC_TIMESTAMP\",\"probeValue\": \"$PILOGGER_METRIC_VALUE\",\"authToken\": \"$authToken\"}" \
                http://52.17.39.163/api/sensor/$PILOGGER_DEVICE )

# check the HTTP response header code
if [ "$response" -eq "200" ]; then
   echo "successfully sent measurement to piLogger cloud"
else
   echo "error: did get HTTP status code $response from REST api - something went wrong"
fi
