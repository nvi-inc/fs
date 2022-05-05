#!/bin/bash
##
## Copyright (c) 2020 NVI, Inc.
##
## This file is part of VLBI Field System
## (see http://github.com/nvi-inc/fs).
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.
##
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
