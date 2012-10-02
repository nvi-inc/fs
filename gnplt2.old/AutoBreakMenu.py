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