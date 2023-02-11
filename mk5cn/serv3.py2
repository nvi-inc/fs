#!/usr/bin/python
#
# Copyright (c) 2021 NVI, Inc.
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
import sys


sleeptime = 0.010
# sleeptime = 0
sleeptime = 1

doTimeout = 0
try:
    myPort=int(sys.argv[1])
except:
    myPort = 9999
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('', myPort))
s.listen(5)

print "listening to the clients on port " + str(myPort)
connection, address = s.accept()

while True:
    try:
        rcvstr = connection.recv(4096)
    except:
        print "recv failed, listening to the clients on port " + str(myPort)
        connection, address = s.accept()
        continue
    print rcvstr,
    try:
        connection.send(rcvstr.strip() + " = 0 : " + str(myPort) + " ;\n")
    except:
        print "send failed, listening to the clients on port " + str(myPort)
        connection, address = s.accept()
        continue
