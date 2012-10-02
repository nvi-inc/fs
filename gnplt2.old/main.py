#!/usr/bin/python
from Tkinter import *
from NumericTools import NumericTools
from Coordinate import Coordinate
from AutoBreakMenu import AutoBreakMenu
from PrintCanvas import PrintCanvas
import string, os, tkFileDialog

class Gui(Frame):
    #class variables
    highlighted_points = ""
    included_points = ""
    selected_points = ""
    total_points = ""
    scaling_mode = ''
    #IO Setup variables:
    fs_dir = '/usr2/fs/log' #'/users/ptg/gnplt/'
    rxg_dir = '/usr2/control/rxg_files' #'/users/ptg/gnplt/'
    gndat_output = '/tmp/gnplot2_output' #'/users/ptg/gnplt/output1'
    
    def __init__(self, parent = None, **kw):
        Frame.__init__(self, parent, **kw)
        self.pack(expand = YES, fill = BOTH)
        self.bind_all('r', lambda event: self.prepPlot(1))
        self.database = {}
        
        Gui.scaling_mode = IntVar()
        
        global COLOR_LIST
        COLOR_LIST = ['red', 'blue', 'black', 'green', 'yellow']
        
        self.numTools = NumericTools()
        self.automatic_replot = 1
        
        self.selectedX = StringVar()
        self.selectedY = StringVar()
        #menubar
        menubar = Menu(self.master)
        self.master.config(menu = menubar)
        
        #menus:
        filemenu = Menu(menubar, tearoff = 0)
        filemenu.add_command(label = 'New', command = lambda: self.open())
        filemenu.add_command(label = 'I/O Setup', command = lambda: self.iosetup())
        filemenu.add_separator()
        filemenu.add_command(label = 'Print', command = lambda: self.printCanvas())
        filemenu.add_separator()
        filemenu.add_command(label = 'Quit', command = lambda: self.quit())
        menubar.add_cascade(label = 'File', underline = 0, menu = filemenu)
        
        self.editmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Edit', underline = 0, menu = self.editmenu)
        
        self.xaxismenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'X-Axis', underline = 0, menu = self.xaxismenu)
        
        self.yaxismenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Y-axis', underline = 0, menu = self.yaxismenu)
        
        self.sourcemenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Source', underline = 0, menu = self.sourcemenu)
        
        self.frequenciesmenu = AutoBreakMenu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Frequencies', underline = 0, menu = self.frequenciesmenu)
        
        toolsmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Tools', underline = 0, menu = toolsmenu)
        
        scalingmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Scaling', underline = 0, menu = scalingmenu)
        scalingmenu.add_radiobutton(label = 'Autoscale not including deleted', command = lambda: self.scale('without_deleted'))
        scalingmenu.add_radiobutton(label = 'Autoscale including deleted', command = lambda: self.scale('with_deleted'))
        scalingmenu.add_radiobutton(label = 'Manual', command = lambda: self.scale('manual'))
        
        
        self.status = StringVar()
        Label(self, textvariable = self.status, relief = RIDGE, anchor = W).pack(expand = 0, fill = X, side = BOTTOM)
        self.status.set('Idle')
        
        topframe = Frame(self)
        topframe.pack(expand = 1, fill = BOTH, side = BOTTOM)
        
        self.rightSide(Frame(topframe)).pack(side = RIGHT, padx = 20, expand = 1)
        
        self.plot = Plot(topframe, width = 700, height = 600, closeenough = 0, confine = 0)
        self.plot.pack(expand = 1, fill = BOTH, side = RIGHT)
        self.plot.bind('<Motion>', self.setRightSideLabels)
        
        devtools = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'For dev. only', menu = devtools)
        devtools.add_command(label = '...')
        
        
    
    def rightSide(self, frame):
        """rightSide builds the rightside of the application 
        with a source legend, info about the dot under the mouse pointer
        and a counter for points included and deleted. 
        """
        self.legend_frame = LabelFrame(frame, text = 'Source Legend')
        self.legend_frame.grid(row = 0, column = 0, pady = 35)
        
        info_frame = Frame(frame)
        info_frame.grid(row = 1, column = 0, pady = 35)
        self.mouse_over_source = StringVar()
        self.mouse_over_frequency = StringVar()
        self.mouse_over_polarization = StringVar()
        self.mouse_over_azimuth = StringVar()
        self.mouse_over_elevation = StringVar()
        self.mouse_over_time = StringVar()
        
        Label(info_frame, text = 'Source...:').grid(row = 0, column = 0)
        Label(info_frame, textvariable = self.mouse_over_source).grid(row = 0, column = 1)
        Label(info_frame, text = 'Frequency:').grid(row = 1, column = 0)
        Label(info_frame, textvariable = self.mouse_over_frequency).grid(row = 1, column = 1)
        Label(info_frame, text = 'Polarization:').grid(row = 2, column = 0)
        Label(info_frame, textvariable = self.mouse_over_polarization).grid(row = 2, column = 1)
        Label(info_frame, text = 'Azimuth:').grid(row = 3, column = 0)
        Label(info_frame, textvariable = self.mouse_over_azimuth).grid(row = 3, column = 1)
        Label(info_frame, text = 'Elevation:').grid(row = 4, column = 0)
        Label(info_frame, textvariable = self.mouse_over_elevation).grid(row = 4, column = 1)
        Label(info_frame, text = 'Time....:').grid(row = 5, column = 0)
        Label(info_frame, textvariable = self.mouse_over_time).grid(row = 5, column = 1)
        
        count_points_frame = LabelFrame(frame)
        count_points_frame.grid(row = 2, column = 0, pady = 35)
        
        Gui.highlighted_points = IntVar()
        Gui.included_points = IntVar()
        Gui.selected_points = IntVar()
        Gui.total_points = IntVar()
        
        Label(count_points_frame, text = 'Highlighted points:').grid(row = 0, column = 0)
        Label(count_points_frame, textvariable = Gui.highlighted_points).grid(row = 0, column = 1)
        Label(count_points_frame, text = 'Included points:').grid(row = 1, column = 0)
        Label(count_points_frame, textvariable = Gui.included_points).grid(row = 1, column = 1)
        Label(count_points_frame, text = 'Selected points:').grid(row = 2, column = 0)
        Label(count_points_frame, textvariable = Gui.selected_points).grid(row = 2, column = 1)
        Label(count_points_frame, text = 'Total points:').grid(row = 3, column = 0)
        Label(count_points_frame, textvariable = Gui.total_points).grid(row = 3, column = 1)
        return frame

    def setRightSideLabels(self, event):
        """setRightSideLabels is binded to <Motion>
        and updates the labels on the right side of the application. 
        """
        #find point at xy-coord
        x = event.x
        y = event.y
        item = self.plot.find_overlapping(x+1,y+1,x-1,y-1)
        if len(item)>0:
            item = item[-1]
            taglist = self.plot.gettags(item)
            if 'plotted' in taglist and self.plot.type(item)=='oval':
                index = int(taglist[0])
                #all info is in self.database.get(...)[index]
                self.mouse_over_source.set(self.database.get('Source')[index])
                self.mouse_over_frequency.set(self.database.get('Frequency')[index])
                self.mouse_over_polarization.set(self.database.get('Polarization')[index])
                self.mouse_over_azimuth.set(self.database.get('Azimuth')[index])
                self.mouse_over_elevation.set(self.database.get('Elevation')[index])
                self.mouse_over_time.set(self.database.get('Timestamp')[index])
        
    def buildPlotMenu(self, items):
        """buildPlotMenu builds the menus with stuff to plot for 
        the x and y axis. 
        """
        #clear old menus:
        self.xaxismenu.delete(0, END)
        self.yaxismenu.delete(0, END)
        #build new menu:
        for name in items:
            self.xaxismenu.add_radiobutton(label = name, variable = self.selectedX, command = lambda: self.prepPlot())
            self.yaxismenu.add_radiobutton(label = name, variable = self.selectedY, command = lambda: self.prepPlot())
    
    def buildFrequenciesMenu(self):
        """buildFrequenciesMenu builds the menu containing frequencies that the 
        user can click on to select the corresponding frequencies in the plot. 
        """
        #clear old menu
        self.frequenciesmenu.delete(0, END)
        self.frequenciesmenu.add_radiobutton(label = 'All', command = lambda: self.selectData(None, 'Frequency'))
        self.frequenciesmenu.add_separator()
        
        #build list with frequency, detector and polarization
        freqs = self.database.get('Frequency')
        detectors = self.database.get('Detector')
        polar = self.database.get('Polarization')
        fdp = []
        for i in range(len(freqs)):
            fdp.append('%s %s %s' % (freqs[i], detectors[i], polar[i]))
        #make it unique
        fdp = self._getUnique(fdp)
        #add items to menu
        for name in fdp:
            frequency = float(name.split(' ')[0])
            self.frequenciesmenu.add_radiobutton(label = name, command = lambda frequency = frequency: self.selectData(frequency, 'Frequency'))
    
    def buildEditMenu(self):
        """buildEditMenu builds the edit menu containg tools to 
        delete data with different sources/dates/frequencies and also with
        bad gain curve, outside of plot etc. 
        """
        #first select sources
        sourcemenu = Menu(self.editmenu, tearoff = 0)
        self.editmenu.add_cascade(label = 'Select Sources', menu = sourcemenu)
        #source menu
        sourcemenu.add_separator()
        #find sources
        sources = self._getUnique(self.database.get('Source'))
        global SOURCES_LIST
        SOURCES_LIST = sources
        
        sourcelist = []
        self.sources_chosen = {}
        for source in sources:
            self.sources_chosen[source] = {}
            tmp_sourcelist = []
            sourcelist.append(AutoBreakMenu(sourcemenu, tearoff = 0))
            sourcemenu.add_cascade(label = source, menu = sourcelist[-1])
            #fill each list
            sourcelist[-1].add_command(label = 'All', command = lambda source = source: self.selectAllSources(source, 1))
            sourcelist[-1].add_command(label = 'None', command = lambda source = source: self.selectAllSources(source, 0))
            sourcelist[-1].add_separator()
            times = self.database.get('Timestamp')
            for i, time in enumerate(times):
                if self.database.get('Source')[i]==source:
                    tmp_sourcelist.append(time)
            tmp_sourcelist = self._getUnique(tmp_sourcelist)
            for time in tmp_sourcelist:
                self.sources_chosen[source][time] = IntVar()
                self.sources_chosen[source][time].set(1)
                sourcelist[-1].add_checkbutton(label = time, variable = self.sources_chosen[source][time])
        
        #Left and right polarization menus
        leftpolmenu = AutoBreakMenu(self.editmenu, tearoff = 0)
        rightpolmenu = AutoBreakMenu(self.editmenu, tearoff = 0)
        
        leftpolmenu.add_command(label = 'All left', command = lambda: self.selectAllFrequencies('l', 1))
        leftpolmenu.add_command(label = 'No left', command = lambda: self.selectAllFrequencies('l', 0))
        leftpolmenu.add_command(label = 'No left or right', command = lambda: self.selectAllFrequencies('both', 0))
        leftpolmenu.add_separator()
        
        rightpolmenu.add_command(label = 'All right', command = lambda: self.selectAllFrequencies('r', 1))
        rightpolmenu.add_command(label = 'No right', command = lambda: self.selectAllFrequencies('r', 0))
        rightpolmenu.add_command(label = 'No left or right', command = lambda: self.selectAllFrequencies('both', 0))
        rightpolmenu.add_separator()
        
        self.editmenu.add_cascade(label = 'Left Polarization', menu = leftpolmenu)
        self.editmenu.add_cascade(label = 'Right Polarization', menu = rightpolmenu)
        #get frequencies and detector and polarization
        freqs = self.database.get('Frequency')
        detectors = self.database.get('Detector')
        polar = self.database.get('Polarization')
        fdp = []
        for i in range(len(freqs)):
            fdp.append('%s %s %s' % (freqs[i], detectors[i], polar[i]))
        #make it unique
        fdp = self._getUnique(fdp)
        #add items to menu
        self.frequencies_chosen = {}
        for name in fdp:
            self.frequencies_chosen[name] = IntVar()
            self.frequencies_chosen[name].set(1)
            pol = name.split(' ')[-1]
            label = name[:-len(pol)].strip()
            if pol == 'l':
                leftpolmenu.add_checkbutton(label = label, variable = self.frequencies_chosen[name])
            elif pol == 'r':
                rightpolmenu.add_checkbutton(label = label, variable = self.frequencies_chosen[name])
        
        
        self.editmenu.add_command(label = 'Replot(r)', command = lambda: self.prepPlot(True))
        autoreplotmenu = Menu(self.editmenu, tearoff = 0)
        rpl = IntVar()
        rpl.set(1)
        autoreplotmenu.add_radiobutton(label = 'Yes', variable = rpl, value = 1, command = lambda :self.setAutoReplot(1))
        autoreplotmenu.add_radiobutton(label = 'No', variable = rpl, value = 0, command = lambda :self.setAutoReplot(0))
        self.editmenu.add_cascade(label = 'Auto Replot', menu = autoreplotmenu)
        rpl.set(self.automatic_replot)
        self.editmenu.add_separator()
        
        self.editmenu.add_command(label = 'Undelete All For This Selection (s)')
        self.editmenu.add_command(label = 'Undelete All Points In Log', command = lambda: self.unDeleteAll())
        self.editmenu.add_command(label = 'Delete Points With Bad GC', command = lambda: self.deleteBadGC())
        self.editmenu.add_command(label = 'Delete Points Outside Plot', command = lambda: self.deleteOutsidePlot())
        
        self.editmenu.add_separator()
        
    
    def selectAllSources(self, source, set):
        """setlectAllSources selects all checkbuttons with the source 'source'.  
        """
        for time in self.sources_chosen[source].keys():
            self.sources_chosen[source][time].set(set)
    
    def selectAllFrequencies(self, pol, set):
        """selectAllFrequencies selects all frequencies with 
        the polarization 'pol'. 
        """
        if pol == 'both':
            self.selectAllFrequencies('l', set)
            self.selectAllFrequencies('r', set)
        for fdp in self.frequencies_chosen.keys():
            if fdp.split(' ')[-1] == pol:
                self.frequencies_chosen[fdp].set(set)
    
    def setAutoReplot(self, set):
        """setAutoReplot sets automatic replot on/off. 
        """
        self.automatic_replot = set
                
    def buildSourcesMenu(self):
        #find sources:
        sources = self._getUnique(self.database.get('Source'))
        selected_source = StringVar()
        self.sourcemenu.delete(0, END)
        self.sourcemenu.add_radiobutton(label = 'All Sources', variable = selected_source, command = lambda: self.selectData(None, 'Source'))
        self.sourcemenu.add_separator()
        
        for source in sources:
            self.sourcemenu.add_radiobutton(label = source, variable = selected_source, command = lambda source = source: self.selectData(source, 'Source'))
        self.sourcemenu.add_separator()
        
        display_menu = Menu(self.sourcemenu, tearoff = 0)
        self.sourcemenu.add_cascade(label = 'Select Display', menu = display_menu)
        display_menu.add_radiobutton(label = 'Points', variable = self.plot.display_mode, value = 0)
        display_menu.add_radiobutton(label = 'Letters', variable = self.plot.display_mode, value = 1)
        display_menu.add_radiobutton(label = 'Points and Letters', variable = self.plot.display_mode, value = 2)
    
    def selectData(self, source, data):
        select_list = []
        source_list = self.database.get(data)[:]
        if source:
            for index, source_in_list in enumerate(source_list):
                if source_in_list == source:
                    select_list.append(index)
        else: #if select all
            end_index = len(source_list)
            select_list = [i for i in range(end_index)]

        Gui.highlighted_points.set(len(select_list))
        self.plot.selectPoint(select_list)
    
    def deleteBadGC(self):
        self.bad_gc_top = Toplevel()
        
        Label(self.bad_gc_top, text = 'Lower limit:').grid(row = 0, column = 0)
        lower = Entry(self.bad_gc_top)
        lower.grid(row = 0, column = 1)
        Label(self.bad_gc_top, text = 'Upper limit:').grid(row = 1, column = 0)
        upper = Entry(self.bad_gc_top)
        upper.grid(row = 1, column = 1)
        Button(self.bad_gc_top, text = 'OK', command = lambda: self._deleteBadGC_ok(lower.get(), upper.get())).grid(row = 2, column = 0)
        Button(self.bad_gc_top, text = 'Cancel', command = lambda: self.bad_gc_top.destroy()).grid(row = 2, column = 1)
        
        lower.insert(0, 0.95)
        upper.insert(0, 1.05)
    
    def _deleteBadGC_ok(self, lower, upper):
        lower = float(lower)
        upper = float(upper)
        self.bad_gc_top.destroy()
        GC_list = self.database.get('Assumed Gain Curve')
        index_list = []
        for i,gc in enumerate(GC_list):
            if (gc<=upper) and (gc>=lower):
                index_list.append(i)
        
        #self.deletePoint requires an item, not the tagnumber, so it needs to be found. 
        for item in self.plot.find_withtag('plotted'):
            index = int(self.plot.gettags(item)[0])
            if index in index_list:
                self.plot.deletePoint(item)
    
    def deleteOutsidePlot(self):
        for item in self.plot.find_withtag('outside_zoom'):
            self.plot.deletePoint(item)
    
    def unDeleteAll(self):
        for item in self.plot.find_withtag('plotted'):
            index = int(self.plot.gettags(item)[0])
            if index in self.plot.deleted_list:
                self.plot.deletePoint(item)
    
    def fetchData(self, name):
        """Filters requested data according to user's selections regarding source, 
        frequency, polarization etc. 
        """
        #start with all data, subract data not selected. 
        data = self.database.get(name)[:]
        #return_data = data[:]
        data_indices = [i for i in range(len(self.database.get(name)))]
        for i in range(len(data)):
            source = self.database.get('Source')[i]
            time = self.database.get('Timestamp')[i]
            frequency = self.database.get('Frequency')[i]
            polarization = self.database.get('Polarization')[i]
            detector = self.database.get('Detector')[i]
            
            fdp = '%s %s %s' % (frequency, detector, polarization)
            
            if not self.sources_chosen[source][time].get() or not self.frequencies_chosen[fdp].get():
                #return_data.remove(data[i])
                data_indices.remove(i)
        
        #return return_data
        return data_indices
        
    
    def prepPlot(self, force_plot = False): #bound to keypress r
        if self.selectedX.get() and self.selectedY.get():
            data_indices = self.fetchData(self.selectedX.get())
            if self.automatic_replot or force_plot:
                Gui.selected_points.set(len(data_indices))
                Gui.included_points.set(len(data_indices))
                #delete zoom list
                self.plot.outside_zoom_list = []
                self.plot.plot(data_indices, self.selectedX.get(), self.selectedY.get())
            else:
                self.status.set('Replot(r) needed')
    
    def open(self):
        logfile = tkFileDialog.askopenfilename(initialdir = Gui.fs_dir)
        if logfile:
            output_file = Gui.gndat_output
            pid = 0#os.getpid()
            rxg_directory = Gui.rxg_dir
            gndat = '/usr2/fs/bin/gndat'
            cmdline = '%s %s %s %s %s' % (gndat, logfile, output_file, pid, rxg_directory)
            os.popen(cmdline)
            file = open(output_file, 'r')
            #sections:
            _antenna = 0
            _dpfu = 0
            _gain = 0 
            _label = 0
            _data = 0
            
            labels = []
            no_plot_list = []
            
            for line in file.readlines():
                if line[0] != '*':
                    if line[:-1] == '$ANTENNA':
                        _antenna = 1
                        _dpfu = 0
                        _gain = 0 
                        _label = 0
                        _data = 0
                    elif line[:-1] == '$DPFU':
                        _antenna = 0
                        _dpfu = 1
                        _gain = 0 
                        _label = 0
                        _data = 0
                    elif line[:-1] == '$GAIN':
                        _antenna = 0
                        _dpfu = 0
                        _gain = 1 
                        _label = 0
                        _data = 0
                    elif line[:-1] == '$LABELS':
                        _antenna = 0
                        _dpfu = 0
                        _gain = 0 
                        _label = 1
                        _data = 0
                    elif line[:-1] == '$DATA':
                        _antenna = 0
                        _dpfu = 0
                        _gain = 0 
                        _label = 0
                        _data = 1
                    elif line[0] == '$':
                        #something else
                        _antenna = 0
                        _dpfu = 0
                        _gain = 0 
                        _label = 0
                        _data = 0
                    else: #header data
                        if _label == 1: 
                            labels.append(line[:-1])
                        elif _data == 1:
                            data = line.split(' ')
                            for i, d in enumerate(data):
                                key = labels[i]
                                if key == 'Time':
                                    key = 'Timestamp'
                                    try:
                                        self.database[key].append(d)
                                    except KeyError:
                                        self.database[key] = [d]
                                    d = self.numTools.timeStamp(d)
                                    if not key in no_plot_list:
                                        no_plot_list.append(key)
                                    key = 'Time'
                                    try:
                                        self.database[key].append(d)
                                    except KeyError:
                                        self.database[key] = [d]
                                    continue
                                try:
                                    d = float(d)
                                except ValueError: #the data is not to be plotted, i.e frequency, polarization etc.
                                    if not key in no_plot_list:
                                        no_plot_list.append(key)
                                try:
                                    self.database[key].append(d)
                                except KeyError:
                                    self.database[key] = [d]
            #print database
            file.close()
            #build menus:
            plot_list = self.database.keys()
            #items in no_plot_list are not to be plotted
            for l in no_plot_list:
                plot_list.remove(l)
            self.buildPlotMenu(plot_list)
    
            #Frequencies
            self.buildFrequenciesMenu()
            
            #Edit menu
            self.buildEditMenu()
            
            #Sources menu
            self.buildSourcesMenu()
            
            #set legend
            self.setLegend()
            
            self.plot.database = self.database
            
            #set total number of points
            for key in self.database.keys():
                Gui.total_points.set(len(self.database.get(key)))
                break
        
    def setLegend(self):
        """set the source legend for the plots.
        Called from open.  
        """
        #remove old info
        self.legend_frame.forget()
        
        for i,source in enumerate(SOURCES_LIST):
            j = SOURCES_LIST.index(source)
            k = min(j, len(COLOR_LIST))
            color = COLOR_LIST[k]
            g = min(26,j)
            letter = string.ascii_uppercase[g]
            Label(self.legend_frame, text = letter, fg = color).grid(row = i, column = 0)
            Label(self.legend_frame, text = source).grid(row = i, column = 1)
        
    def _getUnique(self, seq, idfun = None):
        """receives a list with data, and returns the list with only one occurrence of every data.
        _getUnique is order preserving 
        """
        # order preserving
        if idfun is None:
            def idfun(x): 
                return x
        seen = {}
        result = []
        for item in seq:
            marker = idfun(item)
            # in old Python versions:
            # if seen.has_key(marker)
            # but in new ones:
            if marker in seen: 
                continue
            seen[marker] = 1
            result.append(item)
        return result

    def scale(self, mode):
        if mode == 'with_deleted':
            Gui.scaling_mode.set(1)
            self.plot.reDrawAll()
        elif mode == 'without_deleted':
            Gui.scaling_mode.set(0)
            self.plot.reDrawAll()
        elif mode == 'manual':
            Gui.scaling_mode.set(2)
            self.manual_top = Toplevel()
            Label(self.manual_top, text = 'X min').grid(row = 0, column = 0)
            xmin = Entry(self.manual_top)
            xmin.grid(row = 0, column = 1)
            Label(self.manual_top, text = 'X max').grid(row = 1, column = 0)
            xmax = Entry(self.manual_top)
            xmax.grid(row = 1, column = 1)
            Label(self.manual_top, text = 'Y min').grid(row = 2, column = 0)
            ymin = Entry(self.manual_top)
            ymin.grid(row = 2, column = 1)
            Label(self.manual_top, text = 'Y max').grid(row = 3, column = 0)
            ymax = Entry(self.manual_top)
            ymax.grid(row = 3, column = 1)
            button_row = Frame(self.manual_top)
            button_row.grid(row = 4, column = 0, columnspan = 2)
            xmin.insert(0, self.plot.minX)
            xmax.insert(0, self.plot.maxX)
            ymin.insert(0, self.plot.minY)
            ymax.insert(0, self.plot.maxY)
            Button(button_row, text = 'Ok', command = lambda: self.setManualScale(xmin.get(), xmax.get(), ymin.get(), ymax.get())).pack(side = LEFT)
            Button(button_row, text = 'Cancel', command = lambda: self.manual_top.destroy()).pack(side = LEFT)
        
    def setManualScale(self, xmin, xmax, ymin, ymax):
        self.manual_top.destroy()
        xmin = float(xmin)
        xmax = float(xmax)
        ymin = float(ymin)
        ymax = float(xmax)
        self.plot.reDrawAll(xmin, xmax, ymin, ymax)
    
    def iosetup(self):
        iosetup_top = Toplevel()
        file_parsing_frame = LabelFrame(iosetup_top, text = 'Log file parsing')
        file_parsing_frame.pack()
        Label(file_parsing_frame, text = 'Default directory for FS log files:').grid(row = 0, column = 0)
        fs_dir = Entry(file_parsing_frame)
        fs_dir.grid(row = 0, column = 1)
        fs_dir.insert(0, Gui.fs_dir)
        Label(file_parsing_frame, text = 'Default directory for .rxg files:').grid(row = 1, column = 0)
        rxg_dir = Entry(file_parsing_frame)
        rxg_dir.grid(row = 1, column = 1)
        rxg_dir.insert(0, Gui.rxg_dir)
        Label(file_parsing_frame, text = 'Output file for gndat:').grid(row = 2, column = 0)
        gndat_output = Entry(file_parsing_frame)
        gndat_output.grid(row = 2, column = 1)
        gndat_output.insert(0, Gui.gndat_output)
        buttonrow = Frame(iosetup_top)
        buttonrow.pack()
        Button(buttonrow, text = 'Ok', command = lambda: self.setIO(fs_dir.get(), rxg_dir.get(), gndat_output.get(), iosetup_top.destroy())).pack(side = LEFT)
        Button(buttonrow, text = 'Cancel', command = lambda: iosetup_top.destroy()).pack(side = LEFT)
    
    def setIO(self, fs_dir, rxg_dir, gndat_output, _a = None):
        Gui.fs_dir = fs_dir
        Gui.rxg_dir = rxg_dir
        Gui.gndat_output = gndat_output
    
    def printCanvas(self):
        """printCanvas sets the settings for printing. On OK it calls startPrint"""
        self.print_top = Toplevel()
        self.print_top.focus_set()
        settingsframe = LabelFrame(self.print_top)
        settingsframe.pack(side = TOP, pady = 10, padx = 10)
        _bframe = Frame(self.print_top, relief = RAISED)
        _bframe.pack(side = TOP, anchor = E)
        Button(_bframe, text = 'Cancel', command = lambda: self.print_top.destroy()).pack(side = RIGHT, anchor = E)
        

        Label(settingsframe, text = 'Destination:').grid(row = 0, column = 0, pady =5, sticky = W)
        destination = IntVar()
        destination.set(0)
        Radiobutton(settingsframe, text = 'Printer', variable = destination, value = 0).grid(row = 0, column = 1, pady = 5, sticky = W)
        Radiobutton(settingsframe, text = 'File', variable = destination, value = 1).grid(row = 0, column = 2, pady = 5, sticky = W)
        Radiobutton(settingsframe, text = 'Display', variable = destination, value = 2).grid(row = 0, column = 3, pady = 5, sticky = W)
              
        Label(settingsframe, text = 'Print command:').grid(row = 1, column = 0, pady =5, sticky = W)
        printcommand = IntVar()
        Radiobutton(settingsframe, text = 'lpr', variable = printcommand, value = 0).grid(row = 1, column = 1, pady = 5, sticky = W)
        Radiobutton(settingsframe, text = 'psprint', variable = printcommand, value = 1).grid(row = 1, column = 2, pady = 5, sticky = W)
        printcommand.set(0)
               
        Label(settingsframe, text = 'Output filename:').grid(row = 2, column = 0, pady =5, sticky = W)
        filename = Entry(settingsframe)
        filename.grid(row=2, column =1, columnspan = 2, sticky = W)
        
        output_format = StringVar(settingsframe)
        output_format.set('EPS')
        formats = ['EPS', 'PDF','BMP', 'JPG', 'TIFF', 'GIF', 'PNG']
        fm = OptionMenu(settingsframe, output_format, 'EPS', 'PDF', 'BMP', 'JPG', 'TIFF', 'GIF', 'PNG', command = lambda format = output_format.get(): filename.insert(0,self._setOutputFilename(format, filename.get(), filename.delete(0, END))))
        fm.grid(row = 2, column = 3, pady = 5)
        
        filename.insert(0, 'output.PS')
        Label(settingsframe, text = 'Output printer:').grid(row = 3, column = 0, pady =5, sticky = W)
        printer = Entry(settingsframe)
        
        printer.grid(row=3, column =1, columnspan = 3, sticky = W)
        
        set_ratio = IntVar()
        
        Checkbutton(settingsframe, text = 'Set height/width ratio', variable = set_ratio).grid(row = 4, column = 0, sticky = W, pady =5)
        Label(settingsframe, text = 'Leave printer name blank for default printer.').grid(row=5, column = 0, pady=5, columnspan = 4, sticky = W)
        Label(settingsframe, text = 'The font is NOT preserved when saving plot as a non postscript file').grid(row=6, column = 0, pady=5, columnspan = 4, sticky = W)
        set_ratio.set(1)
        
        wxh_frame = Frame(settingsframe)
        wxh_frame.grid(row = 4, column = 1, columnspan = 3, sticky = W, pady = 5)
        
        width = Entry(wxh_frame, width = 5)
        width.pack(side = LEFT)
        Label(wxh_frame, text = 'x').pack(side = LEFT)
        height = Entry(wxh_frame, width = 5)
        height.pack(side = LEFT)
        
        width.insert(0, '8.5')
        height.insert(0, '11')
        
        Button(_bframe, text = 'Print', command = lambda: self.startPrint(destination = destination.get(), printcommand = printcommand.get(), filename = filename.get(), printer = printer.get(), set_ratio = set_ratio.get(), width = width.get(), height = height.get(), file_format = output_format.get())).pack(side = RIGHT, anchor = E) 

    def startPrint(self,**kw):
        """startPrint is called by printCanvas. Thereafter it calls CanvasConstructor, which does the printing."""
        try:
            self.print_top.destroy()
        except AttributeError:
            pass #print_top not initiated..... probably in batch mode
        
        if kw.get('set_ratio'):
            self.setToDim(kw.get('width'), kw.get('height'))

        width = self.plot.cget('width')
        height = self.plot.cget('heigh')
        printer = PrintCanvas(width = width, height = height, plots = 1)
            #canvas_out.scale(ALL, -info_box,0,0.5,0.5)
            #cv.move(ALL,-75,0)
        printer.addCanvas(self.plot, 0)
        
        #cConstruct.addCanvases(cvlist)
        
        ####################PRINTING#####################
        if kw.get('destination')==1: #print to file
            filename = kw.get('filename')
            format = 'EPS'
            if kw.has_key('file_format'):
                format = kw.get('file_format')
            else: #from batch_mode
                formats = ['EPS', 'PDF', 'BMP', 'JPG', 'TIFF', 'GIF', 'PNG', 'PS']
                for _format in formats:
                    if filename[-len(_format):].upper()==_format:
                        format = _format
            if format.upper() == 'JPG':
                format = 'JPEG'
            elif format.upper() == 'PS':
                format = 'EPS'
            try:
                status = printer.printCanvas(filename, format)
            except IOError: #PIL might cause IO-error
                pass#self.status_text.set('Error: File error while printing to file. Check write permissions')
            else:
                if status == 1: #PIL Error
                    pass#self.status_text.set('Error: Python Imaging Library (PIL) not correctly installed. Can only send output to postscript!')
                else:
                    pass#self.status_text.set('Output sent to %s' % filename)
            printer.destroy()
        elif kw.get('destination')==0: #printer
            if not kw.get('printcommand')==1:
                printcmd = 'lpr'
            else:
                printcmd = 'psprint'
            printer.printCanvas(None, None, printcmd, kw.get('printer'))
            printer.destroy()
    
    def _setOutputFilename(self, suffix, old_name, *novar):
        if suffix == 'EPS':
            suffix = 'PS'
        last_dot = old_name.rfind('.')
        new_name = old_name[:last_dot+1]+suffix
        return new_name

    def setToDim(self, width=8.5, height= 11.0):
        """setToDim is a help function for the printing tools. 
        It sets the plots to fit a certain geometry. Default is
        letter size (8.5in x 11in)
        """
        x = float(width)/float(height)*1.03
        #let plot height be fixed...
        plot_width = int(self.plot.cget('width'))
        plot_height = int(self.plot.cget('height'))
        side_width = self.winfo_width() - plot_width
        
        tot_height = plot_height
        #MainGUI.plot_width = int(x*tot_height)#1.6
        new_width = int(x*tot_height)
        new_tot_width = side_width+new_width
        height = int(self.winfo_height())
        self.plot.config(width = new_width)
        self.master.geometry('%sx%s' % (new_tot_width, height))
        
        #self.plot.reScaleAll()
        #self.changeHeightWidth(None)
    
class Plot(Canvas, Coordinate):    
    def __init__(self, master, **kw):
        self.database = []
        self.deleted_list = []
        self.outside_zoom_list = []
        self.display_mode = IntVar()
        self.display_mode.set(2)
        Canvas.__init__(self, master, **kw)
        
        self.numTools = NumericTools()
        self.xname = ''
        self.yname = ''
        
        _width = self.cget('width')
        _height = self.cget('height')
        
        Coordinate.__init__(self, (_width, _height))
        
        #bind for resize
        self.bind('<Configure>', self.reScaleAll)
        #bind for delte
        self.bind('<Button-1>', self.clickPoint)
        #bind for selection
        self.bind('<B1-Motion>', self.expandRect)
        #zoom
        self.bind('<ButtonRelease-1>', self.zoom)
        #delete selection
        self.bind('<B3-Motion>', self.expandRect)
        self.bind('<ButtonRelease-3>', self.deleteSelection)
        
        #margins:
        self.x_margin = 50
        self.y_margin = 50
        
        self.grid = 1
        self.logScale = 0
        #make axis:
        self.makeAxis()
        
    def getList(self, name, indices):
        return_data = []
        for i in indices:
            return_data.append(self.database.get(name)[i])
        return return_data
    
    def plot(self, data_indices, xname, yname, autoscale = True):
        #delete old
        self.delete('plotted')
        
        #save info for redraw
        self.data_indices = data_indices
        self.xname = xname
        self.yname = yname
        
        
        #fetch data:
        xlist = self.getList(xname, data_indices)
        ylist = self.getList(yname, data_indices)
        x_del_list = self.getList(xname, self.deleted_list)
        y_del_list = self.getList(yname, self.deleted_list)
        
        self.pixelsX = float(self.cget('width'))
        self.pixelsY = float(self.cget('height'))
        if Gui.scaling_mode.get() == 1:
            _xlist = xlist + x_del_list
            _ylist = ylist + y_del_list
        else:
            _xlist = xlist
            _ylist = ylist
        
        if autoscale:
            self.minX = min(_xlist)
            self.minY = min(_ylist)
            self.maxX = max(_xlist)
            self.maxY = max(_ylist)
        kw = {}
        assert len(xlist)==len(ylist)
        for i in range(len(xlist)):
            tagnumber = data_indices[i]
            tags = (tagnumber, 'plotted')
            self.plotDot(xlist[i], ylist[i], tags, 'white', tagnumber)
        
        for i in range(len(x_del_list)):
            tagnumber = self.deleted_list[i]
            tags = (tagnumber, 'plotted', 'deleted')
            self.plotDot(x_del_list[i], y_del_list[i], tags, 'red', tagnumber)
        
        #plot dots outside zoom on border with cyan fill
        
        x_outside_zoom = self.getList(xname, self.outside_zoom_list)
        y_outside_zoom = self.getList(yname, self.outside_zoom_list)         
        
        for i in range(len(x_outside_zoom)):
            tagnumber = self.outside_zoom_list[i]
            tags = (tagnumber, 'plotted', 'outside_zoom')
            self.plotDot(x_outside_zoom[i], y_outside_zoom[i], tags, 'cyan', tagnumber)
            
        self.setLabels()
        self.setXYTicks()
    
    def plotDot(self, x,y, tags, fill, tagnumber):
        kw = {}
        kw['fill'] = fill
        source = self.database.get('Source')[tagnumber]
        j = SOURCES_LIST.index(source)
        k = min(j, len(COLOR_LIST))
        outline_color = COLOR_LIST[k]
        g = min(26,j)
        letter = string.ascii_uppercase[g]
        
        kw['tags'] = tags
        kw['width'] = 1
        kw['outline'] = 'black'#outline_color
        
        [x, y] = self.getCanvasXY([x, y])
        #self.create_oval(x-1, y-1, x+1, y+1, **kw)
        if self.display_mode.get() == 2:
            self.create_oval(x-2,y-2, x+2, y+2, **kw)
            self.create_text(x,y, anchor = W, text = '  ' + letter, fill = outline_color, tags = tags)
        elif self.display_mode.get() == 1:
            self.create_text(x,y, anchor = W, text = letter, fill = outline_color, tags = tags)
        elif self.display_mode.get() == 0:
            self.create_oval(x-2,y-2, x+2, y+2, **kw)
    
    def clickPoint(self, event):
        items = self.find_overlapping(event.x-1, event.y-1, event.x+1, event.y+1) #find_closest only finds one dot....
        for item in items:
            if 'plotted' in self.gettags(item):
                self.deletePoint(item)
    
    def deletePoint(self, item):
        tags = self.gettags(item)
        if self.type(item) == 'oval':
            index = int(tags[0])
            if 'deleted' in tags:
                self.itemconfig(item, fill = 'white')
                Gui.included_points.set(Gui.included_points.get()+1)
                self.dtag(item, 'deleted')
                self.deleted_list.remove(index)
                self.data_indices.append(index)
            else:
                self.addtag_withtag('deleted', item)
                self.itemconfig(item, fill = 'red')
                Gui.included_points.set(Gui.included_points.get()-1)
                if 'outside_zoom' in tags:
                    self.outside_zoom_list.remove(index)
                else:
                    self.data_indices.remove(index)
                self.deleted_list.append(index)
        
    def reScaleAll(self, event = None):
        """reScaleAll is called when the plotting window is resized. 
        The layout is completely redrawn, but the data is only moved, because that 
        procedure is faster. Only use reScaleAll when the window is resized!
        """
        #new_width = float(event.width)-2
        new_width = float(self.winfo_width())-2
        #new_height = float(event.height)-2
        new_height = float(self.winfo_height())-2
        old_width = float(self.cget('width'))
        old_height = float(self.cget('height'))
        x_aux = 2*self.xoffset + 2*self.x_margin
        y_aux = 2*self.yoffset + 2*self.y_margin
        xfactor = (new_width-x_aux)/(old_width-x_aux)
        yfactor = (new_height-x_aux)/(old_height-x_aux)
        
        self.config(width = new_width, height = new_height)
        
        #Canvas.scale can unfortunately not be used since it changes the size of the circles...
        
        #fix layout
        self.delete('layout')
        self.makeAxis()
        self.setXYTicks()
        
        #fix data
        for item in self.find_withtag('plotted'):
            coords = self.coords(item)
            if len(coords) == 4:
                [x1, y1, x2, y2] = coords
                x = (x1+x2)/2.0
                y = (y1+y2)/2.0
            elif len(coords) == 2:
                [x, y] = coords
            if x == self.x_margin: #left side
                dx = 0
            elif x > (old_width - self.x_margin-self.xoffset): #right side #might differ 1 or 2 points, therefore no equality
                dx = new_width-old_width
            else:
                dx = x - (self.x_margin+self.xoffset)
                dx *= (xfactor-1)
            
            if y == self.y_margin:
                dy = 0
            elif y > (old_height - self.y_margin - self.yoffset):
                dy = new_height - old_height
            else:
                dy =y - (self.y_margin+self.yoffset)
                dy *= (yfactor-1)
            
            self.move(item,dx,dy)
        
        #fix labels
        self.coords('xy_label', new_width/2, 10)
        self.coords('x_label', new_width-self.x_margin, new_height-self.y_margin+30)
        self.coords('pol_label', new_width - self.x_margin, self.y_margin-10)
        
        
        #set geometry to avoid infinite resizing...
        #topframe is self.master, gui is topframe.master and root is gui.master....
        root = self.master.master.master
        height = root.winfo_height()
        width = root.winfo_width()
        #explicit geometry:
        root.geometry('%sx%s' % (width, height))

        return 'break'
    
    def reDrawAll(self, xmin = None, xmax = None, ymin = None, ymax = None):
        """reDrawAll redraws the entire plot. It is however not used on resizing because it is a bit slow. 
        """
        self.delete(ALL)
        if xmin and xmax and ymin and ymax:
            self.minX = xmin
            self.maxX = xmax
            self.minY = ymin
            self.maxX = ymax
            autoscale = False
        else:
            autoscale = True
        try:
            self.plot(self.data_indices, self.xname, self.yname, autoscale)
        except AttributeError: #occurs when resizing without a plot
            pass
        self.makeAxis()
        self.setXYTicks()
    
    def makeAxis(self):
        """makeAxis sets the layout for the plot. If grid is on, it draws the grid. 
        Also, a box surrounding the plot and tick marks are drawn. 
        """
        tags = ('layout')
        _width = int(self.cget('width'))
        _height = int(self.cget('height'))
        
        #tags = ('layout',)
        
        self.create_rectangle(self.x_margin,self.y_margin, _width-self.x_margin, _height-self.y_margin, tags = tags)
        self.xticks = []
        _length = _width
        
        #x
        start = self.xoffset+self.x_margin
        end = _width-self.x_margin-self.xoffset
        diff = (end - start)/4
        for i in range(start, end+1, diff):
            self.create_line(i, _height-self.y_margin+4, i, _height-3-self.y_margin, tags = tags)
            if self.grid:
                self.create_line(i, _height-3-self.y_margin, i, self.y_margin, fill = '#b9b9b9', dash = (4,4), tags = tags)
            self.xticks.append(i)

        #y
        self.yticks = []
        _length = _height
        start = _height-self.yoffset-self.y_margin
        end = self.y_margin+self.yoffset
        diff = (end-start)/4
        for i in range(start, end-2, diff):
            if self.logScale:
                maxlog = math.log10(_height-self.offset)
                i = math.log10(i)/maxlog*(_height-self.yoffset)
            self.create_line(self.x_margin-3, i, 4+self.x_margin, i, tags = tags)
            if self.grid:
                self.create_line(4+self.x_margin, i, _width-self.x_margin, i, fill = '#b9b9b9', dash = (4,4), tags = tags)
            self.yticks.append(i)
    
    def setLabels(self):
        """setLabels sets all labels in the margin of the plot. 
        On resize, don't call setLabels again. Instead, use tags ('labels') to move them. 
        """
        self.delete('labels')
        tags = ('labels',)
        width = int(self.cget('width'))
        middle = width/2
        height = int(self.cget('height'))
        #xy-label
        self.create_text(middle, 10, text = 'Plotting %s vs. %s' %(self.xname, self.yname), tags = tags + ('xy_label',))
        #y-label
        self.create_text(self.x_margin, self.y_margin-10, text = 'y: %s' % self.yname, anchor = W, tags = tags + ('y_label',))
        #x-label
        self.create_text(width-self.x_margin, height-self.y_margin+30, text = 'x: %s' % self.xname, anchor = E, tags = tags + ('x_label',))
        #find polarization. Either left, right or both.
        pol_list = [] 
        for index in self.data_indices:
            pol_list.append(self.database.get('Polarization')[index])
        if 'l' in pol_list and 'r' in pol_list:
            text = 'Both Polarizations'
        elif 'l' in pol_list :
            text = 'Left Polarization'
        else:
            text = 'Right Polarization'
        self.create_text(width - self.x_margin, self.y_margin - 10, text = text, anchor = E, tags = tags + ('pol_label',))
        
    
    def setXYTicks(self):
        """setXYTicks updates the x and y axis. It is called whenever the plot is redrawn. 
        """
        width = float(self.cget('width'))
        height = float(self.cget('height'))
        self.pixelsX = width
        self.pixelsY = height
        #at self.yticks/self.xticks, set axis labels:
        #y-ticks
        self.delete('y_ticks')
        self.delete('x_ticks')
        for y in self.yticks:
            text_y = self.getCartesianY(y)
            if self.yname == 'Time':
                y_label = self.numTools.revTimeStamp(text_y)
            else:
                y_label = self.roundNumber(text_y, self.maxY-self.minY)
            self.create_text(self.x_margin-5, y, text = y_label, anchor = E, tags = ('y_ticks',))
        #x-ticks
        for x in self.xticks:
            text_x = self.getCartesianX(x)
            if self.xname == 'Time':
                x_label = self.numTools.revTimeStamp(text_x)
            else:
                x_label = self.roundNumber(text_x, self.maxX-self.minY)
            self.create_text(x, height-self.y_margin+10, text = x_label, tags = ('x_ticks',))
    
    def roundNumber(self, unrounded, delta):
        """roundNumber receives a number and the percentage change of max and min in the series the number comes from. 
        Returns the number with appropriate number of digits"""
        try:
            number_of_digits = len(str(int(1/delta)))+1
        except ZeroDivisionError:
            number_of_digits = 2 #if delta is zero, this number is pretty irrelevant, so 2 is as good as any. 
        unrounded = str(unrounded)
        num = len(unrounded.split('.'))
        if num == 1:
            return unrounded
        else:
            expr = '%.' + str(number_of_digits) +'f'
            return expr % float(unrounded)
    
    def expandRect(self, event):
        """expands selection rectangle if there is one, else create it. 
        """
        rect_name = 'Selection_Rectangle' #tag name
        if not self.find_withtag(rect_name):
            self._selection_rectangle_x = event.x
            self._selection_rectangle_y = event.y
            #create rectangle
            self.create_rectangle((self._selection_rectangle_x, self._selection_rectangle_y)*2, dash = (1,5), width = 2, tags = 'Selection_Rectangle', stipple = "gray12", fill = 'blue')
        else:
            xnew = event.x
            ynew = event.y
            self.coords(rect_name, self._selection_rectangle_x, self._selection_rectangle_y, xnew, ynew)
        
    def zoom(self, event):
        """zooms in on selection_rectangle
        """
        bbox = self.coords('Selection_Rectangle')
        self.delete('Selection_Rectangle')
        try:
            item_list = self.find_enclosed(*bbox)
        except TypeError: #if bbox not tuple of 4
            item_list = []
        zoom_list = []
        
        for item in item_list:
            if 'plotted' in self.gettags(item) and self.type(item) == 'oval':
                index = int(self.gettags(item)[0])
                if not 'deleted' in self.gettags(item):
                    zoom_list.append(index)
        if len(zoom_list)>1:
            self.outside_zoom_list = list(set(self.data_indices).union(set(self.outside_zoom_list))-set(zoom_list))
            self.plot(zoom_list, self.xname, self.yname)
    
    def deleteSelection(self, event):
        bbox = self.coords('Selection_Rectangle')
        self.delete('Selection_Rectangle')
        try:
            item_list = self.find_enclosed(*bbox)
        except TypeError:
            item_list = []
        for item in item_list:
            if 'plotted' in self.gettags(item) and self.type(item) == 'oval':
                self.deletePoint(item)
    
    def selectPoint(self, index_list):
        #print 'item is %s, index is %s and tags are %s' % (item, index, self.gettags(item))
        for item in self.find_withtag('plotted'):
            if self.type(item) == 'oval':
                index = int(self.gettags(item)[0])
                if index in index_list:
                    self.itemconfig(item, fill = 'black')
                    #index_list.remove(index)
                else:
                    self.itemconfig(item, fill = 'white')
        
if __name__ == '__main__':
    root = Tk()
    root.minsize(width = 300, height = 300)
    Gui(root)
    root.mainloop()