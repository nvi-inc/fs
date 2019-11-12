#!/bin/bash
#
# metserver MET server for gathering weather information.
#
DAEMON=/usr2/st/metserver/metserver
#MET=/dev/null
MET=/dev/ttyS1
#WIND=/dev/null
WIND=/dev/ttyS0
PORT=50001
#REMOTE=local
REMOTE=remote
#DEVICE=MET4
DEVICE=MET4A
FLAGS=0x3
#FLAGS=0x0

$DAEMON $MET $WIND $PORT $REMOTE $DEVICE $FLAGS
