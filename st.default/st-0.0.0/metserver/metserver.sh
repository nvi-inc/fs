#!/bin/sh
#Met Server
file=/usr2/st/metserver/metserver
#
#Ports for MET3 and Wind Sensor
metp=/dev/null
windp=/dev/null
#
# Determine if it exist.
if [ -f ${file} ]
then
	${file} ${metp} ${windp} &
fi
exit 0
