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
from Tkinter import *

class AutoBreakMenu(Menu):
   """
   Automatically adds the 'columnbreak' option on menu entries to make
   sure that the menu won't get too high.
   """

   MAX_ENTRIES = 20

   def add(self, itemType, cnf={}, **kw):
     entryIndex =  1 + (self.index(END) or 0)
     if entryIndex % AutoBreakMenu.MAX_ENTRIES == 0:
       cnf.update(kw)
       cnf['columnbreak'] = 1
       kw = {}
     return Menu.add(self, itemType, cnf, **kw)