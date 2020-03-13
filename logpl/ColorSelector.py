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
import random

class ColorSelector(Toplevel):
    def __init__(self, setups = {}):
        self.setups = setups
        self.applyToAll = 0
        self.applyToSelected = 0
        Toplevel.__init__(self, None)
        topFrame = Frame(self)
        topFrame.pack(anchor = NW)
        self.resizable(width = 0, height = 0)
        
        self.setupsBox(LabelFrame(topFrame, text = 'Setups', padx = 3)).pack(side = LEFT, anchor = NW, fill = BOTH, padx = 2)
        self.colorBox(LabelFrame(topFrame, text = 'Color', padx = 3)).pack(side = LEFT, anchor = NW, fill = BOTH, padx = 2)
        self.shapesBox(LabelFrame(topFrame, text = 'Shape')).pack(side = LEFT, anchor = NW, fill = BOTH, padx = 2)
        
        bottomframe = Frame(self, relief = GROOVE, bd = 2)
        bottomframe.pack(anchor = E, fill = X)
        Button(bottomframe, text = 'Cancel', command = lambda: self.destroy()).pack(side = RIGHT)
        Button(bottomframe, text = 'Apply to all plots', command = (lambda: self.apply('all'))).pack(side = RIGHT)
        Button(bottomframe, text = 'Apply to selected plot', command = (lambda: self.apply())).pack(side = RIGHT)
        
        self.setupList.selection_set(0, 0)
        event = C()
        self._selectSetup(event, self.setupList.curselection())
        
    def apply(self, all = None):
        self.applyToAll = self.applytoSelected = 0
        if all:
            self.applyToAll = 1
        else:
            self.applyToSelected = 1
        self.destroy()

    def setupsBox(self, parent):
        yscrollbar = Scrollbar(parent, orient = VERTICAL)
        yscrollbar.grid(row = 0, column = 1, sticky = N+S)
        self.setupList = Listbox(parent, exportselection = 0, yscrollcommand = yscrollbar.set)
        self.setupList.grid(row = 0, column = 0)
        self.setupList.bind('<<ListboxSelect>>', (lambda event : self._selectSetup(event, self.setupList.curselection())))
        yscrollbar.config(command = self.setupList.yview)
        Button(parent, text = 'Add new setup', command = (lambda : self.setupList.insert(END, 'setup %s' % (self._addSetup())))).grid(row = 1, column =0, columnspan = 2)
        
        #set init values:
        self.setups.keys().sort()
        for labels in self.setups.keys():
            self.setupList.insert(END, 'setup %s' % (labels))
        
        return parent
    
    def _selectSetup(self, event, curselection):
        curselection = int(curselection[0])
        #set color
        color = self.setups.get(curselection)[0]
        shape = self.setups.get(curselection)[1]
        
        rgb = []
        for i in range(1,7,2):
            rgb.append(int(color[i:i+2], 16))
        
        ymax = 10
        redbox.coords('indicator', rgb[0],0, rgb[0], ymax)
        greenbox.coords('indicator', rgb[1],0, rgb[1], ymax)
        bluebox.coords('indicator', rgb[2],0, rgb[2], ymax)
        
        self.colorbox.config(bg = color)
        event.x = 90
        event.y = 30+25*shape
        #select shape
        self._selectShape(event)
    
    def _addSetup(self):
        number = len(self.setups.keys())
        r = random.randrange(0,256)
        g = random.randrange(0,256)
        b = random.randrange(0,256)
        color = '#%02x%02x%02x' % (r,g,b)
        shape = random.randrange(0,6)
        self.setups[number] = [color, shape]
        return number
    
    def colorBox(self, parent):
        ymax = 10
        Label(parent, text = 'Red:').pack(anchor = W)
        global redbox,greenbox,bluebox
        redbox = Canvas(parent, width = 256, height = ymax, highlightthickness = 0)
        redbox.pack(pady = 5)
        Label(parent, text = 'Green:').pack(anchor = W)
        greenbox = Canvas(parent, width = 256, height = ymax, highlightthickness = 0)
        greenbox.pack(pady = 5)
        Label(parent, text = 'Blue:').pack(anchor = W)
        bluebox = Canvas(parent, width = 256, height = ymax, highlightthickness = 0)
        bluebox.pack(pady = 5)
        
        
        redstart = 150
        greenstart = 100
        bluestart = 250
        self.hexcode = StringVar()
        
        Label(parent, textvariable = self.hexcode).pack(anchor = W)
        self.colorbox = Canvas(parent, width = 50, height = 50, bg = '#%02x%02x%02x' % (redstart,greenstart,bluestart), highlightthickness = 0)
        self.hexcode.set('Color code: %s' % self.colorbox.cget('bg').upper())
        self.colorbox.pack()
    
        for red in range(0,256):
            color = '#%02x%02x%02x' %(red, 0, 0)
            redbox.create_line(red,0, red, ymax, fill = color)
        for green in range(0,256):
            color = '#%02x%02x%02x' %(0, green, 0)
            greenbox.create_line(green,0, green, ymax, fill = color)
        for blue in range(0,256):
            color = '#%02x%02x%02x' %(0, 0, blue)
            bluebox.create_line(blue,0, blue, ymax, fill = color)
            
        red_indicator = redbox.create_line(redstart,0,redstart,ymax, fill = 'white', width = 2, tags = ('indicator'))
        redbox.bind('<B1-Motion>', (lambda event: redbox.coords(red_indicator, self._setColor(event.x)[0], 0, self._setColor(event.x)[0], ymax)))
        green_indicator = greenbox.create_line(greenstart,0,greenstart,ymax, fill = 'white', width = 2, tags = ('indicator'))
        greenbox.bind('<B1-Motion>', (lambda event: greenbox.coords(green_indicator, self._setColor(None, event.x)[1], 0, self._setColor(None, event.x)[1], ymax)))            
        blue_indicator = bluebox.create_line(bluestart,0,bluestart,ymax, fill = 'white', width = 2, tags = ('indicator'))
        bluebox.bind('<B1-Motion>', (lambda event: bluebox.coords(blue_indicator, self._setColor(None, None, event.x)[2], 0, self._setColor(None, None, event.x)[2], ymax)))
    
        return parent

    def _setColor(self, red = None, green = None, blue = None):
        oldcolor = self.colorbox.cget('bg')
        newcolor = None
        if red and red>=0 and red<256:
            newcolor = '#%02x%s' %(red, oldcolor[3:])
        if green and green>=0 and green<256:
            newcolor = '%s%02x%s' %(oldcolor[:3], green, oldcolor[5:])
        if blue and blue>=0 and blue<256:
            newcolor = '%s%02x' %(oldcolor[:5], blue)
        try:
            if newcolor:
                self.colorbox.config(bg = newcolor)
                self.hexcode.set('Color code: %s' % newcolor.upper())
        except TclError: #color doesn't exist:
            pass
        else:
            try:
                self.setups[int(self.setupList.curselection()[0])][0] = newcolor
            except IndexError: #no setup selected
                pass
        return (red, green, blue)

    def shapesBox(self, parent):
        self.shapes_window = Canvas(parent, width = 150, height = 200, highlightthickness = 0)
        self.shapes_window.bind('<Button-1>', (lambda event : self._selectShape(event)))
        self.shapes_window.pack()
        fill = 'black'
        color = fill
        (x1, x2, y1, y2) = (88, 92, 28, 32)
        font = ('Helvetica', 8, 'bold')
        #create rectangles
        self.shapes_window.create_text(5, y1+3, text = 'Rectangle:', anchor = W, font = font)
        self.shapes_window.create_rectangle(x1,y1,x2,y2, width = 1, outline = color, fill = fill, tags = ('shape'))
        y1 += 25
        y2 += 25
        #triangle up
        self.shapes_window.create_text(5, y1+3, text = 'Triangle up:', anchor = W, font = font)
        self.shapes_window.create_polygon(x1,y2,x2,y2,x1+2,y1, width = 1, outline = color, fill = fill, tags = ('shape'))
        y1 += 25
        y2 += 25
        #triangle down
        self.shapes_window.create_text(5, y1+3, text = 'Triangle down:', anchor = W, font = font)
        self.shapes_window.create_polygon(x1,y1,x2,y1,x1+2,y2, width = 1, outline = color, fill = fill, tags = ('shape'))
        y1 += 25
        y2 += 25
        #triangle left
        self.shapes_window.create_text(5, y1+3, text = 'Triangle left:', anchor = W, font = font)
        self.shapes_window.create_polygon(x2,y1,x2,y2,x1,y1+2, width = 1, outline = color, fill = fill, tags = ('shape'))
        y1 += 25
        y2 += 25
        #triangle right
        self.shapes_window.create_text(5, y1+3, text = 'Triangle right:', anchor = W, font = font)
        self.shapes_window.create_polygon(x1,y1,x1,y2,x2,y1+2, width = 1, outline = color, fill = fill, tags = ('shape'))
        y1 += 25
        y2 += 25
        #circle
        self.shapes_window.create_text(5, y1+3, text = 'Circle:', anchor = W, font = font)
        self.shapes_window.create_oval(x1,y1,x2,y2, width = 1, outline = color, fill = fill, tags = ('shape'))
        
        return parent
    
    def _selectShape(self, event):
        item = self.shapes_window.find_closest(event.x, event.y)
        try:
            if self.shapes_window.gettags(item)[0] == 'shape':
                self.shapes_window.delete('Select_rectangle')
                rect_coords = list(self.shapes_window.bbox(item))
                #enlarge rectangle:
                rect_coords[0]-=6
                rect_coords[1]-=6
                rect_coords[2]+=6
                rect_coords[3]+=6
                self.shapes_window.create_rectangle(rect_coords, dash = (1,3), tags = ('Select_rectangle'))
                #save the shape
                try:
                    currentsetup = int(self.setupList.curselection()[0])
                    shape = int((event.y-30)/25.0) 
                    self.setups[currentsetup][1] = shape
                except IndexError:
                    pass
        except IndexError:
            pass

class C(object):
    pass        
        
if __name__ == '__main__':
    root = Tk()
    setups = {}
    setups[0] = ['#ff00ff', 0]
    setups[1] = ['#00ff00', 1]
    setups[2] = ['#00ffff', 2]
    ColorSelector(setups)
    root.mainloop()