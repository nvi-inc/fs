#!/bin/sh
#Met Client Startup file.
file=/usr2/st/metclient/metclient
# Change the following parameter to reflect your changes.
#############
metlog=/usr2/st/metclient/metlog.ctl
#############
# Determine if it exist.
if [ -f ${file} ]
then
	${file} ${metlog} &
fi
exit 0
