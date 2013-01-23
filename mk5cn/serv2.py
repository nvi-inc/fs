#!/usr/bin/python
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
