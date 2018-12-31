#!/bin/bash

if [ "$UID" -ne 0 ]; then
	echo "This script has to be run as root."
	exit
fi

# Kill existing HM2MQTT
# Kill existing HM2MQTT
if pgrep -f loxmatic/hm2mqtt/index.js > /dev/null 2>&1 ; then
        pkill -f loxmatic/hm2mqtt/index.js
        sleep 1
        pkill -9 -f loxmatic/hm2mqtt/index.js

fi

# Create a new entry for the logfile (for logmanager)
. $LBHOMEDIR/libs/bashlib/loxberry_log.sh
PACKAGE=loxmatic
NAME=hm2mqtt
FILENAME=REPLACELBPLOGDIR/hm2mqtt.log
APPEND=1
LOGSTART "HM2MQTT daemon started."
LOGOK "HM2MQTT daemon started."
LOGEND

# Loglevel
DEBUG=$(jq -r '.Debug' REPLACELBPCONFIGDIR/loxmatic.json)
if [ "$DEBUG" = "true" ] || [ "$DEBUG" = "1" ]; then
	LEVEL="debug"
else
	LEVEL="info"
fi

# MQTT Parameters
BROKER=$(jq -r '.Broker' REPLACELBPCONFIGDIR/loxmatic.json)
NAMES=$(jq -r '.Names' REPLACELBPCONFIGDIR/loxmatic.json)
if [ -e $NAMES ] && [[ $NAMES != "" ]]; then
	$JSONNAME="-j $NAMES"
else
	$JSONNAME=""
fi

# Start HM2MQTT
REPLACELBPDATADIR/hm2mqtt/index.js -d -m mqtt://$BROKER -a 127.0.0.1 -v $LEVEL $JSONNAME >> REPLACELBPLOGDIR/hm2mqtt.log 2>&1 &
