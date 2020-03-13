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
import socket
import struct
import sys
import time

if len(sys.argv) == 2:

	ip = sys.argv[1]
        port = 9050
	server_address = (ip,port)

        msg = "updown 0000.0 0 0 0 0\n"

	try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.connect(server_address)
		time.sleep(2)
                sock.sendall(msg)
 		time.sleep(2)
                data = sock.recv(4096)
                print data
                sock.close()

        except KeyboardInterrupt:
                print ''
                print 'Client Terminated by User - closing open sockets'


        except IndexError:
                print 'Server address not specified'

        except socket.error:
                print 'Server not reachable'

        finally:
                try:
                        sock.close()
                        #print >>sys.stderr, 'socket closed'
                except NameError:
			print 'socket not open'
elif len(sys.argv) == 5:

	ip = sys.argv[1]
	port = 9050
	freq = sys.argv[2]
	f = '%.1f' % (float(freq))
	ga = sys.argv[3]
	gb = sys.argv[4]
	server_address = (ip,port)

	msg = "updown " + f + " " + ga + " " + gb + " 0 0\n"

	try:
		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.connect(server_address)
		time.sleep(2)
		sock.sendall(msg)
		time.sleep(2)
		data = sock.recv(4096)
		print data
		sock.close()

	except KeyboardInterrupt:
		print ''
		print 'Client Terminated by User - closing open sockets'	
	

	except IndexError:
		print 'Server address not specified'

	except socket.error:
		print 'Server not reachable'

	finally:
		try:
			sock.close()
			#print >>sys.stderr, 'socket closed'
		except NameError:
			print 'socket not open'
else:
	print "\n usage: udceth0.py <ip address> <freq> <ga> <gb>\n"
