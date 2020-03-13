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
"""
Gnplt throws importerror if there is one import Gui or/and tkinter. It
also handles arguments and passes those on to Gui.__init__

gnplt.py also handles major error that causes the program to crash...
"""
import sys
try:
    from main import Gui
    from Tkinter import *
except ImportError,e:
    print 'Error: GnPlt could not find all required packages. \nTkinter, numpy and Python 2.4 or newer is required.\nError message: %s' %e
    sys.exit(1)
    
args = sys.argv[1:]
kw = {}
while args:
    try:
        if args[0] == '-log':
            kw['log'] = args[1]
            args = args[2:]
        else:
            print 'Argument %s is not recognized. Use argument -help for instructions' % args[0]
            break
    except IndexError:
        print 'Incorrect use of arguments. Use argument -help for instructions'
        break

#cycle through arguments.....

#launch gnplt
root = Tk()
try:
    Gui(root, **kw)
    root.mainloop()
except TclError, e:
    print 'The LogPlotter GUI crashed! \nError message:\n', e
except (KeyboardInterrupt): #ctrl-c
        pass

