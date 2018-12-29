#!/bin/bash

if [ "$UID" -ne 0 ]; then
	echo "This script has to be run as root."
	exit
fi

export HM_HOME=REPLACELBPDATADIR/occu/arm-gnueabihf/packages-eQ-3/RFD
export LD_LIBRARY_PATH=$HM_HOME/lib

# GPIO18 is needed for resetting
if [ ! -e /sys/class/gpio/gpio18 ]; then
	echo 18 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio18/direction

# Start rfd
if pgrep rfd > /dev/null 2>&1 ; then
	killall rfd
	sleep 1
fi

# Create a new entry for the logfile (for logmanager)
. $LBHOMEDIR/libs/bashlib/loxberry_log.sh
PACKAGE=loxmatic
NAME=rfd
FILENAME=${LBPLOG}/REPLACELBPPLUGINDIR/rfd.log
APPEND=1
LOGSTART
LOGOK "RFD daemon started."
LOGEND

# Loglevel
DEBUG=$(jq '.Debug' REPLACELBPCONFIGDIR/loxmatic.json)
if [ "$DEBUG" = "true" ] || [ "$DEBUG" = "1" ]; then
	LEVEL="0"
else
	LEVEL="2"
fi

$HM_HOME/bin/rfd -d -l $LEVEL -f REPLACELBPCONFIGDIR/rfd.conf > /dev/null 2>&1
