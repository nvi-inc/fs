#!/usr/bin/python
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

