#!/bin/sh
#TACD Client Startup file.
file=/usr2/st/tacdclient/tacdclient
# Change the following parameter to reflect your changes.
#############
tacdlog=/usr2/st/tacdclient/tacdlog.ctl
#############
# Determine if it exist.
if [ -f ${file} ]
then
	${file} ${tacdlog} &
fi
exit 0
