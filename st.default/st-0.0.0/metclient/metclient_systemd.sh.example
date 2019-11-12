#!/bin/bash
#
# metclient MET client for gathering weather information.
#
DAEMON=/usr2/st/metclient/metclient
LFILE=/usr2/st/metclient/metlog.ctl || exit 0
PORT=50001
HOST=localhost

test -x $DAEMON || exit 0
test -f $LFILE || exit 0

$DAEMON $LFILE $PORT $HOST
