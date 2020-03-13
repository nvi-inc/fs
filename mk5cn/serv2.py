#!/usr/bin/python
#
# Copyright (c) 2020 NVI, Inc.
#
# This file is part of VLBI Field System
# (see http://github.com/nvi-inc/fs).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# -*- coding: iso-8859-1 -*-

# this code should be pretty much identical to the server code in mark5cEmu.py

import socket
import time

sleeptime = 0.010
# sleeptime = 0
sleeptime = 1

doTimeout = 0
myPort = 9999
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('', myPort))
s.listen(5)

print "listening to the clients on port " + str(myPort)
connection, address = s.accept()

sfile = s.makefile()
rcvstr = connection.recv(4096)
connection.send("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ; ")
time.sleep(sleeptime);
connection.send("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb ")
time.sleep(sleeptime);
if not doTimeout:
	connection.send("cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc\n")
	time.sleep(sleeptime)
	connection.send("dddddddddddddddd\n")
	rcvstr = connection.recv(4096)
	time.sleep(sleeptime)
	connection.send("eeeeeeeeeeeeeee\n")
else:
	connection.send(" should time out, no newline!")
	time.sleep(10)
s.close()
