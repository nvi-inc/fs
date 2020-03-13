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
from Settings import Settings
from IOSettings import IOSettings
import tkFileDialog, tkMessageBox
import os

class SettingsWindow(Toplevel):
    def __init__(self, parent = None):
        self.hash = 0
        self.filename = ''
        Toplevel.__init__(self,parent)
        self.title('Settings')
        self.focus_set()
        self.reload = 0
        #build file menu
        menubar = Menu(self)
        filemenu = Menu(menubar, tearoff = 0)
        filemenu.add_command(label='New', command = lambda: self.newFile(), underline = 0)
        filemenu.add_command(label='Open', command = lambda:self.openFile(), underline = 0)
        filemenu.add_separator()
        filemenu.add_command(label='Save', command = lambda:self.saveFile(), underline = 0)
        filemenu.add_command(label='Save As', command = lambda:self.saveFile(1), underline = 5)
        filemenu.add_separator()
        filemenu.add_command(label='Cancel', command = lambda:self.quit(), underline = 5)
        filemenu.add_command(label='Close and use new settings', command = lambda:self.quit(1), underline = 0)
        menubar.add_cascade(label='File', menu = filemenu, underline = 0)
        self.config(menu=menubar)

        #frames:
        topframe = Canvas(self, height = 20, bd = 0)
        topframe.pack(anchor = NW, fill = X)
        
        labelframe = Frame(self, padx = 5, relief = GROOVE, bd = 2, highlightthickness = 0)
        labelframe.pack(expand = 1, fill = BOTH, anchor = NW)
        labelframe.rowconfigure(0, weight = 1)
        
        yscrollbar = Scrollbar(labelframe, orient = VERTICAL)
        self.sframe = Canvas(labelframe, yscrollcommand = yscrollbar.set, scrollregion = (0,0,0,15), bd = 0, highlightthickness = 0)
        self.sframe.pack(side = LEFT, fill = BOTH, expand = 1)
        #self.sframe.rowconfigure(1, weight = 1)
        yscrollbar.config(command = self.sframe.yview)
        yscrollbar.pack(side = LEFT, fill = Y)
        
        
        hframe = Frame(self, relief = RIDGE)
        hframe.pack(expand = 0, fill = BOTH, anchor = NW)
        bframe = Frame(self, relief = RIDGE)
        bframe.pack(expand = 0, fill = BOTH, anchor = NW)
        
        
        self.minsize(width = 680, height = 440)
        self.resizable(width = 0, height = 1)

        #Labels:
        anchorw = NW
        anchorl = W
        y=5
        topframe.create_window(10,y, window = Label(topframe, text = 'Command', anchor = anchorl), anchor = anchorw, width = 55)
        topframe.create_window(80,y, window = Label(topframe, text = 'Div. Character', anchor = anchorl), anchor = anchorw, width = 85)
        topframe.create_window(180,y, window = Label(topframe, text = 'Description', anchor = anchorl), anchor = anchorw, width = 65)
        topframe.create_window(325,y, window = Label(topframe, text = 'Parameter', anchor = anchorl), anchor = anchorw, width = 65)
        topframe.create_window(395,y, window = Label(topframe, text = 'String', anchor = anchorl), anchor = anchorw, width = 65)
        topframe.create_window(470,y, window = Label(topframe, text = 'Group Name', anchor = anchorl), anchor = anchorw, width = 65)
        topframe.create_window(622,y, window = Label(topframe, text = 'Select', anchor = anchorl), anchor = anchorw, width = 65)
        
        #Buttons:
        Button(bframe, text = 'Add Single Command', command = lambda:self.addLine()).grid(row = 0, column = 0)
        Button(bframe, text = 'Add Command Pair', command = lambda:self.addPair()).grid(row = 0, column = 1)
        Button(bframe, text = 'Remove Selected Command', command = lambda:self.removeLine()).grid(row = 0, column = 2)
        
        #help labels
        Label(hframe, text = 'Descriptions must be unique').pack()
        Label(hframe, text = 'Fields may contain blank spaces and double quotes (no need to add extra quotes)').pack()
        Label(hframe, text = 'First description in command pair must begin with a $-sign and the second must end with a $-sign').pack()
        Label(hframe, text = 'A whitespace is indicated with (space) or a blankspace').pack()
        #Create settings object
        self.settings = Settings()
        self.entry_key = []
        self.entry_description = []
        self.entry_char = []
        self.entry_char_menu = []
        self.entry_offset = []
        self.entry_string = []
        self.entry_group = []
        self.radiobuttons = []
        self.select_row = IntVar()
        
        #get default settings-file and open it
        init_file = IOSettings.default_control_file
        try:
            self.openFile(init_file)
        except (IOError, IndexError):
            self.newFile()

    def quit(self, useCurrent = False):
        if useCurrent:
            self.reload = 1
            self.settings.clearSettings()
            omitted_rows = []
            for i in range(len(self.entry_key)):
                if self.entry_char[i].get().strip()=='(space)':
                    char = ' '
                else:
                    char = self.entry_char[i].get()
                try:
                    if self.entry_description[i].get() and self.entry_key[i].get() and self.entry_offset[i].get():
                        self.settings.setSettings(self.entry_description[i].get(),[self.entry_key[i].get(), char, self.entry_offset[i].get(), self.entry_string[i].get(), self.entry_group[i].get(), i+1])
                    else:
                        omitted_rows.append(i+1)
                except TypeError:
                    print 'Error: Value not list'
            if omitted_rows:
                tkMessageBox.showwarning('Error', 'Incorrect settings! Description, command and \noffset fields may NOT be empty.\n row %r has been omitted. ' % (omitted_rows))
        newhash = self.createHash()
        if not newhash == self.hash:
            answer = tkMessageBox.askyesno('Save?', 'The settings has been updated. Do you wish to save \nthe updates to the control file (%s)?' % (self.filename))
            if answer:
                self.saveFile()
        self.destroy()
    
    def setLabels(self, settings_dict):
        _row = 0
        keylist = []
        for key in settings_dict.keys():
            row = settings_dict.get(key)[5]
            keylist.append([row, key])
        keylist.sort()
        for _key in keylist:
            key = _key[1]
            _row += 1
            anchor = W
            self.addLine()
            self.entry_key[-1].insert(0, settings_dict.get(key)[0])
            
            if settings_dict.get(key)[1] == ' ': #if space:
                self.entry_char[-1].set('(space)')
            else:
                self.entry_char[-1].set(settings_dict.get(key)[1])
            
            self.entry_offset[-1].insert(0, settings_dict.get(key)[2])
            
            if key[0]=='$': #1st in command pair:
                self.entry_description[-1].bind('<FocusOut>', (lambda event, _row = _row: self.onFocusOut(event, _row)))
                self.entry_group[-1].config(state = DISABLED)
            self.entry_description[-1].insert(0, key)
            if key[-1]=='$': #2nd in command pair
                self.entry_description[-1].config(state = DISABLED)

            
            self.entry_string[-1].insert(0, settings_dict.get(key)[3])
            self.entry_group[-1].insert(0, settings_dict.get(key)[4])

    def openFile(self, init_file = None):
        if not init_file:
            _filename = tkFileDialog.askopenfilename(initialdir = '.')
            IOSettings.default_control_file = _filename
        else:
            _filename = init_file
        if _filename:
            settings_dict = self.settings.readSF(_filename)
            self.filename = _filename
            self.setLabels(settings_dict)
            #set hash
            self.hash = self.createHash()
            #set default controlfile
            IOSettings.default_control_file= _filename
    
    def createHash(self):
        text = ''
        for i in range(len(self.entry_key)):
            text += self.entry_key[i].get()+self.entry_char[i].get() + self.entry_description[i].get() + self.entry_offset[i].get() + self.entry_string[i].get() + self.entry_group[i].get() 
        
        hash = text.__hash__()
        return hash
    
    def addLine(self):
        ymax = self.sframe.cget('scrollregion').split(' ')[3]
        ymax = int(ymax) + 25
        self.sframe.configure(scrollregion = (0,0,0,ymax))
        
        _row = len(self.entry_key)+1
        y = _row*25-15
        anchor = W
        self.entry_key.append(Entry(self.sframe, width = 15))
        cw = self.sframe.create_window(1,y, window = self.entry_key[-1], anchor = anchor, width = 65)
        
        x = self.sframe.bbox(cw)[2] + 10
        self.entry_char.append(StringVar())
        self.entry_char[-1].set(',')
        self.entry_char_menu.append(OptionMenu(self.sframe, self.entry_char[-1], ',','(space)'))
        cw = self.sframe.create_window(x,y, window = self.entry_char_menu[-1], anchor = anchor, width = 75)
        self.entry_char_menu[-1].children['menu'].add_command(label = 'other...', command = lambda obj = self.entry_char[-1] : obj.set(self.getCustom()))
        
        x = self.sframe.bbox(cw)[2] + 10
        self.entry_description.append(Entry(self.sframe, width = 25))
        cw = self.sframe.create_window(x,y, window = self.entry_description[-1], anchor = anchor)

        x = self.sframe.bbox(cw)[2] + 10
        self.entry_offset.append(Entry(self.sframe, width = 5))
        cw = self.sframe.create_window(x,y, window = self.entry_offset[-1], anchor = anchor)
        
        x = self.sframe.bbox(cw)[2] + 10
        self.entry_string.append(Entry(self.sframe, width = 10))
        cw = self.sframe.create_window(x,y, window = self.entry_string[-1], anchor = anchor)

        x = self.sframe.bbox(cw)[2] + 10
        self.entry_group.append(Entry(self.sframe, width = 25))
        cw = self.sframe.create_window(x,y, window = self.entry_group[-1], anchor = anchor)
        
        x = self.sframe.bbox(cw)[2] + 10
        self.radiobuttons.append(Radiobutton(self.sframe, variable = self.select_row, value = _row))
        cw = self.sframe.create_window(x,y, window = self.radiobuttons[-1], anchor = anchor)
        
    def newFile(self):
        #clear all old entries
        self.sframe.delete(ALL)
        self.sframe.config(scrollregion = (0,0,0,25))
        self.entry_key = []
        self.entry_char = []
        self.entry_char_menu = []
        self.entry_description = []
        self.entry_offset = []
        self.entry_group = []
        self.entry_string = []
        self.radiobuttons = []
    
    def getCustom(self):
        top = Toplevel()
        top.title('')
        top.resizable(width = 0, height = 0)
        Label(top, text = 'Dividing character:').pack()
        entry = StringVar()
        entr = Entry(top, textvariable = entry, width = 5, justify = CENTER)
        entr.pack(padx = 5, pady = 3)
        Button(top, text = 'Ok', command = lambda: top.destroy()).pack()
        top.wait_window()
        try:
            sign = entry.get()[0]
        except IndexError:
            sign = ','
        return sign
    
    def addPair(self):
        #add a regular line, then add customline, also, binds ordinary description line
        self.addLine()
        self.entry_description[-1].insert(0,'$')
        _row = len(self.entry_key)
        self.addLine()
        self.entry_description[_row].config(state = DISABLED)
        self.entry_group[_row-1].config(state = DISABLED)
        self.entry_description[_row-1].bind('<FocusOut>', (lambda event, _row = _row: self.onFocusOut(event, _row)))
    
    def onFocusOut(self, event=None, row = -1):
        self.entry_description[row].config(state = NORMAL)
        self.entry_description[row].delete(0,END)
        self.entry_description[row].insert(0,self.entry_description[row-1].get()[1:]+'$')
        self.entry_description[row].config(state = DISABLED)
    
    def saveFile(self, saveAs = 0):
        #save by using Settings()
        #description is description+string, label = group name [4]
        self.settings.clearSettings()
        for i in range(len(self.entry_key)):
            if self.entry_char[i].get().strip()=='(space)':
                char = ' '
            else:
                char = self.entry_char[i].get()
            try:
                self.settings.setSettings(self.entry_description[i].get(),[self.entry_key[i].get(), char, self.entry_offset[i].get(), self.entry_string[i].get(), self.entry_group[i].get(), i+1])
            except TypeError:
                print 'Error: Value not list'
        if saveAs==1 or not self.filename:
            _filename = tkFileDialog.asksaveasfilename()
        else:
            _filename = self.filename
        #write the new settings:
        if _filename:
            self.filename = _filename
            self.settings.writeSF(_filename)
        
        self.hash = self.createHash()

    def removeLine(self):
        pos = self.select_row.get()-1
        self.entry_key[pos].configure(state = DISABLED)
        self.entry_key.pop(pos)
        self.entry_char_menu[pos].configure(state = DISABLED)
        self.entry_char_menu.pop(pos)
        self.entry_char.pop(pos)
        self.entry_description[pos].configure(state = DISABLED)
        self.entry_description.pop(pos)
        self.entry_offset[pos].configure(state = DISABLED)
        self.entry_offset.pop(pos)
        self.entry_string[pos].configure(state = DISABLED)
        self.entry_string.pop(pos)
        self.entry_group[pos].configure(state = DISABLED)
        self.entry_group.pop(pos)
        self.radiobuttons[pos].configure(state = DISABLED)
        self.radiobuttons.pop(pos)
        #reconfigure radiobuttons
        for row,rb in enumerate(self.radiobuttons):
            rb.config(value = (row+1))

if __name__=='__main__':
    top = SettingsWindow()
    top.mainloop()
