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
#LogPlotter/IOSettings
from Tkinter import *
import os

class IOSettings(Toplevel):
    default_directory = '/usr2/log/'
    #default_control_file = '/p3/home/ptg/logpl.ctl' #if lacerta (my development computer...)
    default_control_file = '/usr2/control/logpl.ctl' #if mv-3 or other fs computer
    
    def __init__(self, parent = None):
        self.iosettings = {}
        self.iosettings['default_control_file'] = IOSettings.default_control_file
        self.iosettings['default_directory'] = IOSettings.default_directory
    
    def gui(self, parent = None):
        Toplevel.__init__(self, parent)
        mainframe = LabelFrame(self, text = 'I/O Settings')
        mainframe.pack(side=TOP, fill = BOTH, expand = 1)
        buttonframe = Frame(self)
        buttonframe.pack(side = TOP, fill = X, expand =1)
        Button(buttonframe, text = 'Cancel', command = lambda: self.destroy()).pack(side = RIGHT)
        ####default directory:
        Label(mainframe, text = 'Default directory for FS log files: ').grid(row = 0, column = 0, padx = 10, pady = 15)
        def_dir = Entry(mainframe)
        def_dir.grid(row=0, column =1, padx = 10, pady = 15 )
        #set label
        def_dir.delete(0, END)
        if IOSettings.default_directory:
            def_dir.insert(0, IOSettings.default_directory)
        else: #is None
            def_dir.insert(0, '')
        ####default control file:
        Label(mainframe, text = 'Default control file: ').grid(row = 1, column = 0, padx = 10, pady = 15)
        def_ctrl_file = Entry(mainframe)
        def_ctrl_file.grid(row=1, column =1, padx = 10, pady = 15 )
        def_ctrl_file.delete(0, END)
        if IOSettings.default_control_file:
            def_ctrl_file.insert(0, IOSettings.default_control_file)
        else:
            def_ctrl_file.insert(0, '')
        ###OK
        Button(buttonframe, text = 'OK', command = lambda: self.ok(def_dir.get(),def_ctrl_file.get())).pack(side = RIGHT)
    
    def ok(self, def_dir, def_ctrl_file, def_tmp_ps):
        IOSettings.default_directory = def_dir
        IOSettings.default_control_file = def_ctrl_file
        IOSettings.destroy(self)