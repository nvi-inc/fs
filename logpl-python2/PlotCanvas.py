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
#LogPlotter/PlotCanvas.py
##########################
#Used in LogPlotter. 
#Accepts canvas from mainGUI
#Function plotData receives a list
#of points, sends them to Coordinates.py
#to convert them and plots them in the canvas
##########################
from Coordinate import Coordinate
from PlotManager import PlotManager
from Tkinter import *
import math
import operator, random, tkFont

class PlotCanvas:

###################Class variables used for zooming:
    xaxismin = 0
    xaxismax = 0
    
    font = None
    
###################init: defines some variables and also binds left mouse button to delete data points    
    
    def __init__(self, canvas):
        if not PlotCanvas.font:    
            PlotCanvas.font = tkFont.Font(font = ("Helvetica 8 normal"))
        self.xyPlot = False
        self.canvas = canvas
        #setting font
        #self.canvas.option_add("*Font", PlotCanvas.font)
        self.xaxis = ''
        #delete/add dot
        self.canvas.bind('<Double-Button-3>', self.onDotClick)
        self.deleted_list=[]
        #remembers zoom
        self.zoomCount = 0
        #sets color and shape
        self.color = 0
        #connect points on/off
        self.connectPoints = 0
        #abs or relative Timas
        self.absTime = 0
        #log scale on/off
        self.logScale = 0
        #invert scale on/off
        self.invert = 0
        #if grid = 1, a grid is drawn
        self.grid = 0
        #if average = 1, a line displaying the mean value is drawn
        self.average = 0
        #list to save superimposed plots
        self.superImposeList = {}
        self.deleted_list_si = {}
        self.colorlist = {0: ['#000000', 5], 1: ['#ff0000', 0], 2: ['#00ff00', 1], 3: ['#0000ff', 2], 4: ['#00ffff', 3], 5: ['#a0aff0', 4]}

        
    def plotData(self, datalist, **kw):
        #go through settings:
        for key in kw.keys():
            if key == 'superimpose' and kw.get(key)==1:
                self.color +=1
            if key == 'connectPoints':
                self.connectPoints=kw.get(key)
            
        #self.colorlist = ['black', 'red', 'magenta', 'blue', 'darkred', 'DarkMagenta', 'green4', 'Gold4', 'green', 'navy', 'blue']
        
        #save datalist as instance variable
        self.datalist = datalist[:]
        #save datalist to be able to handle superimposed plots:
        description = datalist[0][0]
        if description:
            self.superImposeList[description]=datalist[:]
        if not self.deleted_list_si.has_key(description): #first access
            self.deleted_list_si[description] = [None]*len(self.datalist)
        self.deleted_list=self.deleted_list_si.get(description)
        minX = float(datalist[0][1])
        minY = float(datalist[0][3])
        maxX = float(datalist[0][2])
        maxY = float(datalist[0][4])
        if self.logScale:
            #check if logscale possible, otherwise turn logscale off
            #if min Y and maxY possible, the entire series is possible
            try:
                minY = math.log10(minY)
                maxY = math.log10(maxY)
            except (ValueError, OverflowError): #negative value
                minY = float(datalist[0][3])
                maxY = float(datalist[0][4])
                self.logScale = False
        if self.invert: #flip max and min...
            _a = minY
            minY = maxY
            maxY = _a       
        #set width of area with graph description
        self.info_box = 150
        plotX = int(self.canvas.cget('width')) - self.info_box
        plotY = int(self.canvas.cget('height'))
        deltaX = maxX - minX
        deltaY = maxY - minY
        self.offset = 10
        self.coord = Coordinate([plotX, plotY],[deltaX, deltaY],[minX, minY], self.offset, self.info_box)
        self.dotlist = []
        #check for color spec.
        if not self.color<len(self.colorlist.keys()): #color does not exist
            r = random.randrange(0,256)
            g = random.randrange(0,256)
            b = random.randrange(0,256)
            color = '#%02x%02x%02x' % (r,g,b)
            shape = random.randrange(0,6)
            self.colorlist[self.color] = [color, shape]
        
        index = self.color
        color = self.colorlist.get(index)[0]
        average_list = []
        for i in range(1,len(self.datalist)):
                if self.datalist[i]: #if not deleted, otherwise, i is in deleted_list
                    xcoord = self.datalist[i][2]
                    ycoord = self.datalist[i][0]
                    if self.logScale:
                        try:
                            ycoord = math.log10(ycoord)
                        except (ValueError, OverflowError): #Value not in plot! Set it to -1
                            ycoord = -1
                    if i<(len(self.datalist)-1):
                        j=1
                        try:
                            while not self.datalist[i+j]:
                                j +=1
                        except IndexError:
                            pass
                        else:
                            xnextcoord = self.datalist[i+j][2]
                            ynextcoord = self.datalist[i+j][0]
                            if self.logScale:
                                try:
                                    ynextcoord = math.log10(ynextcoord)
                                except (ValueError, OverflowError): #Value not in plot! Set it to -1
                                    ynextcoord = -1
                    try:
                        x=self.coord.getCanvasXY([xcoord,ycoord])[0]
                        y=self.coord.getCanvasXY([xcoord,ycoord])[1]
                        try:
                            xnext=self.coord.getCanvasXY([xnextcoord,ynextcoord])[0]
                            ynext=self.coord.getCanvasXY([xnextcoord,ynextcoord])[1]
                        except UnboundLocalError: #if no nextcoord, for instance, after a zoom
                            xnext=x
                            ynext=y
                        x1=x-2
                        x2=x+2
                        y1=y-2
                        y2=y+2
                    except TypeError:
                        pass#Coordinate sent None back because object out of bounds, or ZeroDivision error
                    else:
                        self.plotDot(x1, y1, x2, y2, color, ('datadot', i, description), index)
                        if self.connectPoints:
                            self.canvas.create_line(x,y,xnext,ynext)
                        if self.average: 
                            average_list.append(y)
                else: #plot deleted_dot
                    xcoord = self.deleted_list[i][2]
                    ycoord = self.deleted_list[i][0]
                    try:
                        x=self.coord.getCanvasXY([xcoord,ycoord])[0]
                        y=self.coord.getCanvasXY([xcoord,ycoord])[1]
                    except (TypeError, UnboundLocalError):
                        pass#out of bounds
                    else:
                        x1=x-2
                        x2=x+2
                        if y<0:
                            y1 = 0
                            y2 = 4
                        elif y>int(self.canvas.cget('height')):
                            y1 = int(self.canvas.cget('height'))
                            y2 = int(self.canvas.cget('height'))-4
                        else:
                            y1 = y-2
                            y2= y+2
                        self.plotDot(x1, y1, x2, y2, 'white', ('deleted_dot', i, description), index)
        
        if average_list:
            self.ymean = sum(average_list)/len(average_list)
            self.canvas.create_line(self.info_box+1, self.ymean, self.canvas.cget('width'), self.ymean, fill = color, width = 3, dash = (4,4))
        #create layout of plot    
        self.setLayout()
        ypos_list = []
        #create text at ticks:
        for ypos in self.yticks:
            ycart = self.coord.getCartesianXY([0,ypos])[1]
            if self.logScale:
                ycart = 10**ycart
            ypos_list.append(ycart)
        try:
            ypos_list = self.engNumber(ypos_list)
        except (IndexError, ValueError):
            pass #(ypos_list = ypos_list)
        i=0
        _height = int(self.canvas.cget('height'))
        for ypos in self.yticks:
                ypos = ypos + self.color*15
                xpos = self.info_box-8-self.color*15
                if xpos<30:
                    xpos = self.info_box-8
                #number of digits:
                _text = str(ypos_list[i])
                i+=1
                #text = _text.split('.')
                #if len(text)>1: #if decimal number
                if not ypos> (_height - self.offset):
                    self.canvas.create_text(xpos,ypos, anchor = E, text = _text, fill = color, font = PlotCanvas.font)
    
    def plotDot(self, x1,y1,x2,y2, fill, tags,index):
        color = self.colorlist.get(index)[0]
        shape = self.colorlist.get(index)[1]
        if shape == 0: #create rectangles
            self.canvas.create_rectangle(x1,y1,x2,y2, tags = tags, width = 1, outline = color, fill = fill)
        elif shape == 1: #triangle up
            self.canvas.create_polygon(x1,y2,x2,y2,x1+2,y1, tags = tags, width = 1, outline = color, fill = fill)
        elif shape ==2: #triangle down
            self.canvas.create_polygon(x1,y1,x2,y1,x1+2,y2, tags = tags, width = 1, outline = color, fill = fill)
        elif shape == 3: #triangle left
            self.canvas.create_polygon(x2,y1,x2,y2,x1,y1+2, tags = tags, width = 1, outline = color, fill = fill)
        elif shape == 4: #triangle right
            self.canvas.create_polygon(x1,y1,x1,y2,x2,y1+2, tags = tags, width = 1, outline = color, fill = fill)
        else:
            self.canvas.create_oval(x1,y1,x2,y2, tags = tags, width = 1, outline = color, fill = fill)
    
    def onDotClick(self, event = None, item = None):
        #find closest dot. Move to corner. Pop from datalist, redraw!
        #find closest tag. item_index (the TAG!!!!!) corresponds to 1 in datalist!
        if event:
            item = self.canvas.find_closest(event.x, event.y)
            item = item[0]
        dot_list = self.canvas.find_withtag('datadot')
        del_list = self.canvas.find_withtag('deleted_dot')

        if (item in dot_list): #if clicked canvas object is data dot
            item_index = int(self.canvas.gettags(item)[1])
            key = self.canvas.gettags(item)[2]
            #change color
            self.canvas.itemconfig(item, fill = 'white')
            #move to corner
            #x1=event.x-1
            #x2=x1=event.x+1
            #self.canvas.coords(item, x1,1,x2,3)
            #delete tag: datadot
            self.canvas.dtag(item)
            #add tag: deleted_dot
            self.canvas.itemconfig(item, tags = ('deleted_dot', item_index, key))
            #copy item data from datalist to deleted_list, preserve position
            self.deleted_list_si.get(key)[item_index]=self.superImposeList.get(key)[item_index][:]
            #delete item from datalist
            self.superImposeList.get(key)[item_index]=None
            #recompute datalists max and min
            tlist = self.superImposeList.get(key)[:] 
            tlist = self.maxmin(tlist)
            self.superImposeList[key]=tlist[:]
        elif (item in del_list):
            item_index = int(self.canvas.gettags(item)[1])
            key = self.canvas.gettags(item)[2]
            #change color
            color = self.canvas.itemcget(item, 'outline')
            self.canvas.itemconfig(item, fill = color)
            #delete tag: deleted_dot
            self.canvas.dtag(item)
            #add tag: datadot
            self.canvas.itemconfig(item, tags = ('datadot', item_index, key))
            #copy item data to datalist from deleted_list
            self.superImposeList.get(key)[item_index] = self.deleted_list_si.get(key)[item_index][:]
            #delete item from deleted_list
            self.deleted_list_si.get(key)[item_index]=None
            #recompute datalists max and min
            tlist = self.superImposeList.get(key)[:] 
            tlist = self.maxmin(tlist)
            self.superImposeList[key]=tlist[:]


    #set initial coordinates for Zoom Box
    def setZoomRect(self,event, fill_color = 'yellow'):
        self.startZoomRectX = event.x
        self.startZoomRectY = event.y
        #create rectangle
        self.canvas.create_rectangle((self.startZoomRectX, self.startZoomRectY)*2, dash = (1,5), width = 2, tags = 'Zoom_Rectangle', stipple = "gray12", fill = fill_color)

    #draw zoom box
    def onDrag(self,event):
        xpos = event.x
        ypos = event.y
        #zoomRect = self.canvas.find_withtag('Zoom_Rectangle')
        zoomRect = 'Zoom_Rectangle' #tag name
        try:
            self.canvas.coords(zoomRect, self.startZoomRectX, self.startZoomRectY, xpos, ypos)
        except AttributeError:
            pass

    #delete the zoombox and do the zooming
    def onZoom(self,event=None, minX=None, maxX=None, minY = None, maxY = None):
        #keep track of zooming, in order to be able to zoom out
        self.zoomCount +=1
        if self.zoomCount == 1: #save datalist
            #clear old backup
            self.backup_data = {}
            self.backup_data.clear()
            self.backup_data = self.superImposeList.copy()
        
        if minX and maxX:
            minX = float(minX)
            maxX = float(maxX)
            try:
                startX = self.coord.getCanvasXY([minX,0])[0]
            except TypeError: #if none
                startX = self.info_box
            try:
                endX = self.coord.getCanvasXY([maxX, 0])[0]
            except TypeError: #if none
                endX = int(self.canvas.cget('width'))
            startY = 0
            endY = int(self.canvas.cget('height'))
        elif minY and maxY:
            minY = float(minY)
            maxY = float(maxY)
            endY = self.coord.getCanvasY(minY)
            startY = self.coord.getCanvasY(maxY)
            startX = self.info_box
            endX = int(self.canvas.cget('width'))
        else:
            try:
                startX = self.startZoomRectX
                startY = self.startZoomRectY
                endX = event.x
                endY = event.y
            except AttributeError:
                startX = startY = endX = endY = 0
                  
            self.canvas.delete('Zoom_Rectangle')
        
        if not PlotManager.active_plots == 1:
            startX = self.info_box
            endX = int(self.canvas.cget('width'))

        #collect items in bbox
        zoom_list = self.canvas.find_enclosed(startX,startY,endX,endY)
        #make datalist only contain these objects
        data_dict = {}
        count = 0
        for item in zoom_list:
            try:
                tag = int(self.canvas.gettags(item)[1])
                key = self.canvas.gettags(item)[2]
            except IndexError:
                #item is not a datapoint
                pass
            else:
                if (self.canvas.gettags(item)[0]=='datadot'):
                    count +=1
                    try:
                        data_dict[key].append(self.superImposeList.get(key)[tag])
                    except KeyError:
                        data_dict[key]=[]
                        data_dict[key].append(self.superImposeList.get(key)[tag])
        if count>1: #require at least 2 points for zoom...
            #send _datalist to plot. Zoom is done!
            #delete old plot
            self.canvas.delete(ALL)
            #make new plot
            if len(data_dict.keys())>1:
                si = 1
                #reset colors:
                self.color=-1
            else:
                si = 0
            for key in data_dict.keys():
                #recompute max/min
                data_dict.get(key).insert(0, [None]*5)
                #insert description
                data_dict[key][0][0]=key
                tmplist = data_dict.get(key)[:] 
                tmplist = self.maxmin(data_dict.get(key), 1)
                if PlotManager.active_plots>1:
                    #max and min x:
                    tmplist[0][1] = self.superImposeList.get(key)[0][1]
                    tmplist[0][2] = self.superImposeList.get(key)[0][2]
                self.plotData(tmplist, superimpose = si)
            #self.plotData(_datalist)
            #update x-axis if only 1 plot
            if PlotManager.active_plots==1:
                self.xaxis.delete(ALL)
                self.createXaxis(self.xaxis, self.xyPlot, self.absTime)
                
    def onDelete(self, event):
        #points to delete:
        delete_list = self.canvas.find_enclosed(self.startZoomRectX,self.startZoomRectY,event.x,event.y)
        self.canvas.delete('Zoom_Rectangle')
        for item in delete_list:
            self.onDotClick(None, item)
    
    #zooms data to current xaxis
    def zoomToAxis(self):
        #set max/min X to axisminX, axisminY
        self.datalist[0][1] = PlotCanvas.xaxismin
        self.datalist[0][2] = PlotCanvas.xaxismax
        #redraw
        self.canvas.delete(ALL)
        if len(self.superImposeList.keys())>1:
            si = 1
            self.color = -1
        else:
            si = 0 
        for key in self.superImposeList.keys():
            self.plotData(self.superImposeList.get(key), superimpose = si)
        

    def maxmin(self,datalist, do_x = 0):
        #first, build list without None
        _list=[]
        for i in range(1,len(datalist)):
            if datalist[i]:
                _list.append(datalist[i])

        #don't resize xdata if not do_x, only ydata        
        ydata = map(operator.itemgetter(0), _list)
        try:
            datalist[0][3] = min(ydata)
            datalist[0][4] = max(ydata)
        except ValueError: #empty sequence
            datalist[0][3] = datalist[0][4] = 0

        if do_x:
            xdata = map(operator.itemgetter(2), _list)
            datalist[0][1] = min(xdata)
            datalist[0][2] = max(xdata)
            
        return datalist
    
    def createXaxis(self, xaxis, YY_plot = False, absTime = 0):
        #set width
        width = self.canvas.master.winfo_width()
        xaxis.config(width = width)
        absTime = self.absTime
        self.xyPlot = YY_plot
        minX = float(self.datalist[0][1])
        #assign min/max values to class variable minmax
        PlotCanvas.xaxismin = self.coord.getCartesianXY([self.xticks[0],0])[0]
        PlotCanvas.xaxismax = self.coord.getCartesianXY([self.xticks[-1],0])[0]
        #self.xaxis.bind('<Button-3>', self.setZoomRect)
        #self.xaxis.bind('<B3-Motion>', self.onDrag)
        #self.canvas.bind('<ButtonRelease-3>', self.onZoom)
        i=0
        if YY_plot:
            xpos_list = []
            for xpos in self.xticks:
                xcart = self.coord.getCartesianXY([xpos,0])[0]
                xpos_list.append(xcart)
            try:
                xpos_list = self.engNumber(xpos_list)
            except (IndexError, ValueError):
                pass #(ypos_list = ypos_list)
        for xpos in self.xticks:
            i += 1
            timeStamp = self.coord.getCartesianXY([xpos,0])[0]
            if not absTime:
                if not YY_plot:
                    xtext = self.convertTime(timeStamp)
                else: #use eng. number
                    xtext = xpos_list[i-1]#timeStamp
            else:
                #first date
                firstday = int(self.datalist[1][1][5:8])
                year = int(self.datalist[1][1][:4])
                try:
                    if self.backup_data:
                        for key in self.backup_data.keys():
                            firstday = int(self.backup_data.get(key)[1][1][5:8])
                            year = int(self.backup_data.get(key)[1][1][:4])
                            break
                except (AttributeError, ), e: #no backup data (no zoom)
                    pass
                xtext = self.reverseTimeStamp(timeStamp, firstday, year)
            xaxis.create_text(xpos, 10, text = xtext, anchor = E, font = PlotCanvas.font)
        self.xaxis = xaxis
        
    def reverseTimeStamp(self, xpos, firstday, year = None):
        #xpos in hours
        _days = xpos / 24.0 + firstday
        days = int(_days)
        _hours = (_days - days)*24
        days_per_year = 365
        if year:
            if year % 4 == 0: #leap year
                days_per_year = 366
        years = days/days_per_year
        days = days - years * days_per_year
        hours = int(_hours)
        _minutes = (_hours-hours)*60
        minutes = int(_minutes)
        timeStamp = '%s.%.2d:%.2d' % (days,hours,minutes)
        if year:
            year = year+1*years
            timeStamp = '%s.' % (year) + timeStamp
        return timeStamp
    
    def convertTime(self, timeStamp, precision = None):
        #timeStamp comes floating number of hours
        #check deltaX to decide appropriate unit
        minX = float(self.datalist[0][1])
        maxX = float(self.datalist[0][2])
        deltaX = maxX - minX
        if precision: #shows minutes and hours eventhough only hours on scale. 
            deltaX = min(10,deltaX)
        timeStamp -= minX
        timeStamp = max(timeStamp, 0)
        #if difference is larger than 10 hours, display only hours
        #if deltaX>1 hour, display hours and minutes
        #if deltaX<1 hour, display only minutes
        #if deltaX<10 min, display min and seconds
        #if deltaX<1 min, display seconds with 1 decimal
        hours = int(timeStamp)
        _time = str(timeStamp).split('.')
        
        minutes_full = (float(timeStamp)-hours)*60
        minutes = int(minutes_full)
        
        seconds_full = (minutes_full-minutes)*60
        seconds = int(seconds_full)

        if deltaX>10:
            xtext = str(hours) + ' h'
        elif deltaX>1:
            xtext = str(hours) + ' h ' + str(minutes) + ' min'
        elif deltaX>1.0/6.0:
            xtext = str(minutes) + ' min'
        elif deltaX>1.0/60.0:
            xtext = str(minutes) + ' min ' + str(seconds) + ' s'
        else:
            xtext = str(seconds_full)[:3] + ' s'
        return xtext

    def redraw(self, width = None, height = None):
        #note that variable plots is not used....
        #diff = 59-31 = 28
         
        #delete all objects in canvas:
        self.canvas.delete(ALL)
        
        plots = PlotManager.active_plots
        xaxis_height = 25
        
        total_height = float(self.canvas.master.winfo_height()-xaxis_height)
        setheight = total_height/PlotManager.active_plots
        #the last plot takes the amount of space that is left. 
        #most of the time it will have the same height as the other plots, but 
        #it might differ by a few pixels. This is to avoid an ugly loop
        
        if not height:
            height = int(total_height - setheight*(PlotManager.active_plots-1))
        
        if not width:
            width = self.canvas.master.winfo_width()
        
        self.canvas.configure(height = height, width = width)
        
        if len(self.superImposeList.keys())>1:
            si = 1
            self.color=-1
        else:
            si = 0
        for key in self.superImposeList.keys():
            self.plotData(self.superImposeList.get(key), superimpose = si)

        
    def setLayout(self):
        _height = int(self.canvas.cget('height'))
        _width = int(self.canvas.cget('width'))
        self.setBorder()
        #ticks:
        #x-axis
        self.xticks = []
        _length = _width-2*self.offset-self.info_box
        for i in range(self.offset+self.info_box, _width-self.offset, _length/4):
            #if too close
            if (_width-self.offset-i)<30:
                break
            self.canvas.create_line(i, _height-1, i, _height-7)
            if self.grid:
                self.canvas.create_line(i, _height-7, i, 0, fill = '#b9b9b9', dash = (4,4))
            self.xticks.append(i)
        #set at last position:
        self.canvas.create_line(_width-self.offset, _height-1,_width-self.offset, _height-7)
        if self.grid:
                self.canvas.create_line(_width-self.offset, _height-7, _width-self.offset, 0, fill = '#b9b9b9', dash = (4,4))
        self.xticks.append(_width-self.offset)
        #y-axis
        self.yticks = []
        _length = max(100,_height/4)
        for i in range(_height-self.offset,self.offset, -_length):
            #if too close:
            if (i-self.offset)<30:
                break
            if self.logScale:
                maxlog = math.log10(_height-self.offset)
                i = math.log10(i)/maxlog*(_height-self.offset)
            self.canvas.create_line(1+self.info_box, i, 7+self.info_box, i)
            if self.grid:
                self.canvas.create_line(7+self.info_box, i, _width, i, fill = '#b9b9b9', dash = (4,4))
            self.yticks.append(i)
        #at last pos
        self.canvas.create_line(1+self.info_box, self.offset, 7+self.info_box, self.offset)
        if self.grid:
                self.canvas.create_line(7+self.info_box, self.offset, _width, self.offset, fill = '#b9b9b9', dash = (4,4))
        self.yticks.append(self.offset)
        #create logscale-ticks:
        #set labels:
        #self.canvas.create_text(5,1, anchor = NW, text = 'Plot: ' + str(PlotManager.active_plots))
            
    
    def setBorder(self, color = 'black'):
        _height = int(self.canvas.cget('height'))
        _width = int(self.canvas.cget('width'))
        self.canvas.create_rectangle(self.info_box+1,0,_width-1, _height-1, outline = color, tags = ('border'))

    def remove(self, plots):
        try:
            if plots == 0 or self.xyPlot:
                self.xaxis.destroy()
        except AttributeError:
            pass
        self.canvas.destroy()

    def identifyCanvas(self,event_addr):
        if event_addr == self.canvas.event_info.im_self:
            return True
        else:
            return False

    def getHeader(self):
        return self.datalist[0]

    def getPlot(self):
        #return self.canvas.postscript()
        filename = 'canvas2.ps'
        #myfile = open(filename, 'wb')
        self.canvas.postscript(file = filename, colormode = 'color')

    def engNumber(self, number_list): #receives a list of numbers and returns it with proper number of digits, print with powers 10 exponents multiples of 3
        number_list = map(float, number_list)
        min_number = min(number_list)
        max_number = max(number_list)
        abs_number = max(abs(min_number),abs(max_number))
        deltanumber = max_number - min_number
        if abs_number > 1e-323:
            exp0=math.log10(abs_number)
            if deltanumber/abs_number > 1e-14:
                digits=int(math.log10(deltanumber/abs_number))
                digits=-digits+2
            else:
                digits=3
            if exp0 > 0:
                exp=int(exp0)
                exp1=(exp/3)*3
                digits=digits-(exp-exp1)
            else:
                exp=int(exp0-1)
                exp1=((-exp+2)/3)*-3
                digits=digits-(exp-exp1)
            if digits < 3:
                digits = 3;
            form = '%.' + str(digits) + 'f'
        return_list = []
        for number in number_list:
            if abs_number > 1e-323:
                numbers = form % (number/math.pow(10,exp1))
                if exp1 != 0:
                    numbers = numbers + ('e%-d' % exp1)
            else:
                numbers = "%g" % number
            return_list.append(numbers)
        return return_list
      

    def getAverage(self):
        try:
            _mean = self.coord.getCartesianXY([0,self.ymean])[1]
            if self.logScale:
                _mean = 10**_mean
            _mean = str(_mean)
        except AttributeError:
            _mean = 'invalid'
        return _mean
        



        
                
    






        
        
