from Tkinter import *
from NumericTools import NumericTools
from Coordinate import Coordinate
#from Simulation import Simulation #Hans
from AutoBreakMenu import AutoBreakMenu
from PrintCanvas import PrintCanvas
from GndatReader import GndatReader
from GnPltError import *
import string, os, tkFileDialog, tkFont, math, tkMessageBox, time, random

class Gui(Frame):
    #class variables
    highlighted_points = ""
    included_points = ""
    selected_points = ""
    total_points = ""
    rejected_points = ""
    scaling_mode = ''
    #IO Setup variables:
    fs_dir = '/usr2/log' 
    rxg_dir = '/usr2/control/rxg_files' 
    gndat_output = '/tmp/gnplot2_output.%s' % os.getpid()
    automatic_redraw = 1
    #opacity corrections:
    opacity_correction = {}
    delete_points_display = 1
    
    def __init__(self, parent = None, **args):
        """initializes the GUI, sets some variables..
        """
        Frame.__init__(self, parent)
        self.master.title('Gain Plot 2')
	font_size = os.getenv('FS_GNPLT_FONTSIZE', '8')
        fontb = tkFont.Font(font = ("Helvetica %s bold" % font_size))
        self.master.option_add("*Font", fontb)
        self.master.minsize(width = 300, height = 300)
        
        Gui.automatic_redraw = IntVar()
        Gui.automatic_redraw.set(1)
        
        self.master.protocol('WM_DELETE_WINDOW', lambda: self.cleanupAndExit())    
        self.pack(expand = YES, fill = BOTH)
        self.database = {}
        #self.lastTatm = 273
        
        Gui.scaling_mode = IntVar()
        
        self.numTools = NumericTools()
        
        self.selectedX = StringVar()
        self.selectedY = StringVar()
        
        #Flags to see if data was generated
        self.simulation = IntVar()
        self.sim_useTcal = IntVar()
        self.do_not_plot = IntVar()
        
        #default Tatm:
        self.default_Tatm = IntVar()
        self.default_Tatm.set(273)
        
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
        filemenu.add_command(label = 'Update RXG File(s)', command = lambda: self.cleanUp())
        filemenu.add_command(label = 'Quit', command = lambda: self.cleanupAndExit())
        menubar.add_cascade(label = 'File', underline = 0, menu = filemenu)
        
        self.editmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Edit', underline = 0, menu = self.editmenu)
        
        #Hans
        self.simulationmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Simulation', underline = 0, menu = self.simulationmenu)
        
        self.xaxismenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'X-Axis', underline = 0, menu = self.xaxismenu)
        
        self.yaxismenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Y-axis', underline = 0, menu = self.yaxismenu)
        
        self.sourcemenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Source', underline = 0, menu = self.sourcemenu)
        
        self.frequenciesmenu = AutoBreakMenu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Frequencies', underline = 0, menu = self.frequenciesmenu)
        
        self.toolsmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Tools', underline = 0, menu = self.toolsmenu)
        
        scalingmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Scaling', underline = 0, menu = scalingmenu)
        Gui.scaling_mode.set(0)
        scalingmenu.add_radiobutton(label = 'Autoscale not <ncluding deleted', variable = Gui.scaling_mode, value = 0, command = lambda: self.scale('without_deleted'))
        scalingmenu.add_radiobutton(label = 'Autoscale including deleted', variable = Gui.scaling_mode, value = 1, command = lambda: self.scale('with_deleted'))
        scalingmenu.add_radiobutton(label = 'Manual', variable = Gui.scaling_mode, value = 2, command = lambda: self.scale('manual'))
        
        
        self.status = StringVar()
        Label(self, textvariable = self.status, relief = RIDGE, anchor = W).pack(expand = 0, fill = X, side = BOTTOM)
        self.status.set('Idle')
        
        topframe = Frame(self)
        topframe.pack(expand = 1, fill = BOTH, side = BOTTOM)
        
        self.rightSide(Frame(topframe)).pack(side = RIGHT, padx = 20, expand = 1)
        
        self.plot = Plot(topframe, width = 700, height = 600)#, closeenough = 0, confine = 0)
        self.plot.pack(expand = 1, fill = BOTH, side = RIGHT)
        self.plot.bind('<Motion>', self.setRightSideLabels)
        
        plot_options = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Plot Options', menu = plot_options)
        disp_del_points = IntVar()
        disp_del_points.set(1)
        
        
        del_points = Menu(menubar, tearoff = 0)
        plot_options.add_cascade(label = 'Deleted Points Symbol', menu = del_points)
        Gui.delete_points_display = IntVar()
        del_points.add_radiobutton(label = 'Filled Circles', variable = Gui.delete_points_display, value = 0, command = lambda: self.redrawPlot())
        del_points.add_radiobutton(label = 'Crosses', variable = Gui.delete_points_display, value = 1, command = lambda: self.redrawPlot())
        sources_display_menu = Menu(self.sourcemenu, tearoff = 0)
        plot_options.add_cascade(label = 'Select Display', menu = sources_display_menu)
        sources_display_menu.add_radiobutton(label = 'Points', variable = self.plot.display_mode, value = 0, command = lambda: self.redrawPlot())
        sources_display_menu.add_radiobutton(label = 'Letters', variable = self.plot.display_mode, value = 1, command = lambda: self.redrawPlot())
        sources_display_menu.add_radiobutton(label = 'Points and Letters', variable = self.plot.display_mode, value = 2, command = lambda: self.redrawPlot())
        plot_options.add_checkbutton(label = 'Display Deleted Points', variable = disp_del_points, command = lambda:self.plot.setDisplayDeletedPoints(disp_del_points.get()))
        
        helpmenu = Menu(menubar, tearoff = 0)
        menubar.add_cascade(label = 'Help', menu = helpmenu)
        helpmenu.add_command(label = 'Shortcuts', command = lambda: self.shortcuts())
        helpmenu.add_command(label = 'About', command = lambda: self.about())
        
        self.bind_all('s', lambda event: self.unDeleteAll(True))
        self.bind_all('r', lambda event: self.prepPlot())
        self.bind_all('q', lambda event: self.cleanupAndExit())
        
        self.plot.bind('<Control-Button-1>', self._addVirtPointClick)
        
#        devtools = Menu(menubar, tearoff = 0)
#        menubar.add_cascade(label = 'dev', menu = devtools)
#        devtools.add_command(label = 'aaa', command = lambda: self.setToDim(8.5, 11))
##        #devtools.add_command(label = 'bbb', command = lambda: self.computeOpacityFactor())
        
##################argument section: cycle through arguments in args
        if args.has_key('log'):
            self.open(0, args.get('log'))
        
    
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
        self.mouse_over_x_label = StringVar()
        self.mouse_over_y_label = StringVar()
        self.mouse_over_x = StringVar()
        self.mouse_over_y = StringVar()
        
        Label(info_frame, textvariable = self.mouse_over_x_label, anchor = W).grid(row = 0, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_x, width = 20).grid(row = 0, column = 1)
        Label(info_frame, textvariable = self.mouse_over_y_label, anchor = W).grid(row = 1, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_y, width = 20).grid(row = 1, column = 1)
        
        Label(info_frame, text = 'Source', anchor = W).grid(row = 2, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_source).grid(row = 2, column = 1)
        Label(info_frame, text = 'Frequency', anchor = W).grid(row = 3, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_frequency).grid(row = 3, column = 1)
        Label(info_frame, text = 'Polarization', anchor = W).grid(row = 4, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_polarization).grid(row = 4, column = 1)
        Label(info_frame, text = 'Azimuth', anchor = W).grid(row = 5, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_azimuth).grid(row = 5, column = 1)
        Label(info_frame, text = 'Elevation', anchor = W).grid(row = 6, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_elevation).grid(row = 6, column = 1)
        Label(info_frame, text = 'Time', anchor = W, width = 16).grid(row = 7, column = 0, sticky = W)
        Label(info_frame, textvariable = self.mouse_over_time, width = 20).grid(row = 7, column = 1)

        count_points_frame = LabelFrame(frame)
        count_points_frame.grid(row = 2, column = 0, pady = 35)
        
        Gui.highlighted_points = IntVar()
        Gui.included_points = IntVar()
        Gui.selected_points = IntVar()
        Gui.total_points = IntVar()
        Gui.rejected_points = IntVar()
        
        Label(count_points_frame, text = 'Highlighted points:').grid(row = 0, column = 0)
        Label(count_points_frame, textvariable = Gui.highlighted_points).grid(row = 0, column = 1)
        Label(count_points_frame, text = 'Included points:').grid(row = 1, column = 0)
        Label(count_points_frame, textvariable = Gui.included_points).grid(row = 1, column = 1)
        Label(count_points_frame, text = 'Selected points:').grid(row = 2, column = 0)
        Label(count_points_frame, textvariable = Gui.selected_points).grid(row = 2, column = 1)
        Label(count_points_frame, text = '-'*30).grid(row = 3, column = 0, columnspan = 2)
        Label(count_points_frame, text = 'Total points:').grid(row = 4, column = 0)
        Label(count_points_frame, textvariable = Gui.total_points).grid(row = 4, column = 1)
        Label(count_points_frame, text = 'Rejected points:').grid(row = 5, column = 0)
        Label(count_points_frame, textvariable = Gui.rejected_points).grid(row = 5, column = 1)
        return frame

    def setRightSideLabels(self, event):
        """setRightSideLabels is binded to <Motion>
        and updates the labels on the right side of the application. 
        """
        #find point at xy-coord
        x = event.x
        y = event.y
        item_list = self.plot.find_overlapping(x+1,y+1,x-1,y-1)
        item = None
        while item_list:
            if self.plot.type(item_list[-1])=='oval':
                item = item_list[-1]
                break
            else:
                item_list = item_list[:-1]
        
        if item:
            taglist = self.plot.gettags(item)
            if 'plotted' in taglist and self.plot.type(item)=='oval':
                index = int(taglist[0])
                #all info is in self.database.get(...)[index]
                xname = self.plot.xname
                yname = self.plot.yname
                self.mouse_over_x_label.set(xname)
                self.mouse_over_y_label.set(yname)
                if xname == 'Time':
                    xname = 'Timestamp'
                if yname == 'Time':
                    yname = 'Timestamp'
                
                if not xname == 'Timestamp':
                    xout = '%.4g' % self.database.get(xname)[index]
                else:
                    xout = '%s' % self.database.get(xname)[index]
                if not yname == 'Timestamp':
                    yout = '%.4g' % self.database.get(yname)[index]
                else:
                    yout = '%s' % self.database.get(yname)[index]
                self.mouse_over_x.set(xout)
                self.mouse_over_y.set(yout)
                self.mouse_over_source.set(self.database.get('Source')[index])
                self.mouse_over_frequency.set('%s %s' % (self.database.get('Frequency')[index],self.database.get('Detector')[index]))
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
        #x: (hardwired)
        first_x = 'Time'
        xitems = ['Time', 'Elevation', 'Frequency', 'Azimuth', 'Airmass']
        for name in xitems:
            self.xaxismenu.add_radiobutton(label = name, variable = self.selectedX, command = lambda: self.prepPlot())
        #y:
        #remove x-items from items, which is only y-items:
        removelist = ['LO', 'Trec', 'IF Channel', 'Tspill']
        for item in (removelist+xitems):
            try:
                items.remove(item)
            except ValueError: #value not in list
                pass
            
        #add xitems again, so they are at the bottom of the list
        items.extend(xitems)
        
        
        #items = list(set(items)-set(xitems))
    
        assumed = Menu(self.yaxismenu, tearoff = 0)
        calculated = Menu(self.yaxismenu, tearoff = 0)
        
        opac_cor_menu = Menu(self.yaxismenu, tearoff = 0)
        opac_cor_menu.add_command(label = 'Set Tatm', command = lambda: self.setTatm())
        
        for rxg in self.rxg_file_information.keys():
            info = self.rxg_file_information.get(rxg)
            lo_range = info[7]
            lo_low = lo_range[0]
            lo_high = lo_range[1]
            if lo_range[-1] == 'fixed':
                label = '%s,%s' % (lo_low, lo_high)
                mode = 'fixed'
            else:
                label = '%s-%s' % (lo_low, lo_high)
                mode = 'range'
            opac_cor_by_band = Menu(opac_cor_menu, tearoff = 0)
            opac_cor_menu.add_cascade(label = label, menu = opac_cor_by_band)
        
            opac_cor_by_band.add_radiobutton(label = 'Both', variable = Gui.opacity_correction[rxg], value = 'both', command = lambda: self.computeOpacityFactor())
            opac_cor_by_band.add_radiobutton(label = 'Gain', variable = Gui.opacity_correction[rxg], value = 'gain', command = lambda: self.computeOpacityFactor())
            opac_cor_by_band.add_radiobutton(label = 'TCal(K)', variable = Gui.opacity_correction[rxg], value = 'tcal', command = lambda: self.computeOpacityFactor())
            opac_cor_by_band.add_radiobutton(label = 'None', variable = Gui.opacity_correction[rxg], value = 'none', command = lambda: self.computeOpacityFactor())
        
        weather_data = Menu(self.yaxismenu, tearoff = 0)
        
        for name in items:
            if name[:7] == 'Assumed':
                assumed.add_radiobutton(label = name[8:], variable = self.selectedY, value = name, command = lambda: self.prepPlot())
            elif name == 'Pressure' or name == 'Temperature' or name == 'Humidity' or name == 'Wind Speed' or name == 'Wind Azimuth':
                weather_data.add_radiobutton(label = name, variable = self.selectedY, command = lambda: self.prepPlot())
            elif name == first_x:
                self.yaxismenu.add_separator()
                self.yaxismenu.add_radiobutton(label = name, variable = self.selectedY, command = lambda: self.prepPlot())
            else:
                self.yaxismenu.add_radiobutton(label = name, variable = self.selectedY, command = lambda: self.prepPlot())
        
        if 'Airmass' and 'Tsys-Tspill' in self.database.keys():
            calculated.add_radiobutton(label = 'Zenith Opacity', variable = self.selectedY, command = lambda: self.computeZenithOpacity())
            
        self.yaxismenu.add_separator()
        self.yaxismenu.add_cascade(label = 'non ONOFF data', menu = weather_data)
        self.yaxismenu.add_cascade(label = 'Assumed items', menu = assumed)
        self.yaxismenu.add_cascade(label = 'Calculated items', menu = calculated)
        self.yaxismenu.add_separator()
        self.yaxismenu.add_cascade(menu = opac_cor_menu, label = 'Opacity Correction')
    
    def buildFrequenciesMenu(self):
        """buildFrequenciesMenu builds the menu containing frequencies that the 
        user can click on to select the corresponding frequencies in the plot. 
        """
        #clear old menu
        self.frequenciesmenu.delete(0, END)
        self.frequenciesmenu.add_radiobutton(label = 'Deselect All', command = lambda: self.selectData(None, 'Frequency'))
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
        fdp.sort()
        #add items to menu
        for name in fdp:
            [frequency, detector, pol] = name.split()
            self.frequenciesmenu.add_radiobutton(label = name, command = lambda frequency = float(frequency), detector = detector, pol = pol: self.selectData(frequency, 'Frequency', detector, pol))
    
    def buildEditMenu(self):
        """buildEditMenu builds the edit menu containg tools to 
        delete data with different sources/dates/frequencies and also with
        bad gain curve, outside of plot etc. 
        """
        self.editmenu.delete(0, END)
        #first select sources
        sourcemenu = Menu(self.editmenu, tearoff = 0)
        self.editmenu.add_cascade(label = 'Select Sources', menu = sourcemenu)
        #find sources
        sources = self._getUnique(self.database.get('Source'))
        global SOURCES_LIST
        SOURCES_LIST = sources
        #source menu
        #sourcemenu.add_command(label = 'All Calibrators')
        #sourcemenu.add_command(label = 'All Calibrators & Pointing')
        sourcemenu.add_command(label = 'All', command = lambda source = SOURCES_LIST: self.selectAllSources(source, 1))
        sourcemenu.add_command(label = 'None', command = lambda source = SOURCES_LIST: self.selectAllSources(source, 0))
        sourcemenu.add_separator()
        
        sourcelist = []
        self.sources_chosen = {}
        for source in sources:
            self.sources_chosen[source] = {}
            tmp_sourcelist = []
            sourcelist.append(AutoBreakMenu(sourcemenu, tearoff = 0))
            sourcemenu.add_cascade(label = source, menu = sourcelist[-1])
            #fill each list
            sourcelist[-1].add_command(label = 'All', command = lambda source = source: self.selectAllSources([source], 1))
            sourcelist[-1].add_command(label = 'None', command = lambda source = source: self.selectAllSources([source], 0))
            sourcelist[-1].add_separator()
            times = self.database.get('Timestamp')
            for i, time in enumerate(times):
                if self.database.get('Source')[i]==source:
                    tmp_sourcelist.append(time)
            tmp_sourcelist = self._getUnique(tmp_sourcelist)
            for time in tmp_sourcelist:
                self.sources_chosen[source][time] = IntVar()
                self.sources_chosen[source][time].set(1)
                sourcelist[-1].add_checkbutton(label = time, variable = self.sources_chosen[source][time], command = lambda: self.prepPlot())
        
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
        
        for info in self.rxg_file_information.values():
            lo_range = info[7]
            if lo_range[-1] == 'fixed':
                label = '%s,%s' % (lo_range[0], lo_range[1])
                mode = 'fixed'
            else:
                label = '%s-%s' % (lo_range[0], lo_range[1])
                mode = 'range'
            source = SOURCES_LIST
            leftpolmenu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = source, pol = 'l' : self.plotShortcutLO(pol, source, mode, lo_low, lo_high))
            rightpolmenu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = source, pol = 'r' : self.plotShortcutLO(pol, source, mode, lo_low, lo_high))
        
        leftpolmenu.add_separator()
        rightpolmenu.add_separator()
        
        self.editmenu.add_cascade(label = 'Left Polarization', menu = leftpolmenu)
        self.editmenu.add_cascade(label = 'Right Polarization', menu = rightpolmenu)
        #get frequencies and detector and polarization
        freqs = self.database.get('Frequency')
        detectors = self.database.get('Detector')
        polar = self.database.get('Polarization')
        type = self.database.get('SourceType')
        fdp = []
        for i in range(len(freqs)):
            fdp.append(['%s %s %s' % (freqs[i], detectors[i], polar[i]),type[i]])
        #make it unique
        fdp = self._getUnique(fdp, lambda x: x[0])
        fdp.sort()
        #add items to menu
        self.frequencies_chosen = {}
        for _name in fdp:
            name = _name[0]
            self.frequencies_chosen[name] = IntVar()
            self.frequencies_chosen[name].set(1)
            pol = name.split()[-1]
            label = name[:-len(pol)].strip()
            if pol == 'l':
                leftpolmenu.add_checkbutton(label = label, variable = self.frequencies_chosen[name], command = lambda: self.prepPlot())
            elif pol == 'r':
                rightpolmenu.add_checkbutton(label = label, variable = self.frequencies_chosen[name], command = lambda: self.prepPlot())
        
        self.editmenu.add_command(label = 'Replot(r)', command = lambda: self.prepPlot())
        autoreplotmenu = Menu(self.editmenu, tearoff = 0)
        autoreplotmenu.add_radiobutton(label = 'Yes', variable = Gui.automatic_redraw, value = 1, command = lambda: self.prepPlot())
        autoreplotmenu.add_radiobutton(label = 'No', variable = Gui.automatic_redraw, value = 0)
        self.editmenu.add_cascade(label = 'Auto Replot', menu = autoreplotmenu)
        self.editmenu.add_separator()
        
        self.editmenu.add_command(label = 'Undelete All For This Selection (s)', command = lambda: self.unDeleteAll(True))
        self.editmenu.add_command(label = 'Undelete All Points In Log', command = lambda: self.unDeleteAll())
        self.editmenu.add_command(label = 'Delete Points With Bad GC', command = lambda: self.deleteBadGC())
        self.editmenu.add_command(label = 'Delete Points With (Ts-Tr-Tspill) < 0', command = lambda: self.deleteBadTemp())
        self.editmenu.add_command(label = 'Delete Points Outside Plot', command = lambda: self.deleteOutsidePlot())
        
        self.editmenu.add_separator()
        
        #shortcuts:
        gain_elev_shortcuts = Menu(self.editmenu, tearoff = 0)
        self.editmenu.add_cascade(label = 'Gain vs. Elev. Shortcuts', menu = gain_elev_shortcuts)
        
        tcal_freq_shortcuts = Menu(self.editmenu, tearoff = 0)
        self.editmenu.add_cascade(label = 'TCal vs. Freq. Shortcuts', menu = tcal_freq_shortcuts)
        
        tsys_tspill_airmass_shortcuts = Menu(self.editmenu, tearoff = 0)
        self.editmenu.add_cascade(label = 'Tsys-Tspill vs. Airmass Shortcuts', menu = tsys_tspill_airmass_shortcuts)

        for i, master_menu in enumerate([gain_elev_shortcuts, tcal_freq_shortcuts, tsys_tspill_airmass_shortcuts]):
            shortcut = [('Elevation', 'Gain'), ('Frequency', 'TCal(K)'), ('Airmass', 'Tsys-Tspill')][i]
            #first, add left and right
            left = Menu(master_menu, tearoff = 0)
            if 'l' in self.database.get('Polarization'):
                master_menu.add_cascade(label = 'Left', menu = left)
            right = Menu(master_menu, tearoff = 0)
            if 'r' in self.database.get('Polarization'):
                master_menu.add_cascade(label = 'Right', menu = right)
            
            for side, menu in enumerate([left, right]):
                side = ['l', 'r'][side]
                sources_menu_list = []
                sources_menu_list.append(AutoBreakMenu(menu, tearoff = 0))
                
                calib_menu = AutoBreakMenu(menu, tearoff = 0)
                calib_and_point_menu = AutoBreakMenu(menu, tearoff = 0)
                
                menu.add_cascade(label = 'All Calibrators', menu = calib_menu)
                menu.add_cascade(label = 'All Calibrators & Pointing', menu = calib_and_point_menu)
                menu.add_cascade(label = 'All', menu = sources_menu_list[-1])
                
                menu.add_separator()
                
                if not shortcut == ('Frequency', 'TCal(K)'):
                    calib_menu.add_command(label = 'All Frequencies', command = lambda fdp = 'all_%s' % side, source = 'All', shortcut = shortcut, type = 'c': self.plotShortcut(fdp, source, shortcut, type))
                    calib_menu.add_separator()
                    calib_and_point_menu.add_command(label = 'All Frequencies', command = lambda fdp = 'all_%s' % side, source = 'All', shortcut = shortcut, type = 'p': self.plotShortcut(fdp, source, shortcut, type))
                    calib_and_point_menu.add_separator()
                    
                    for freq_type in fdp:
                        [freq, type] = freq_type
                        pol = freq[-1]
                        freq_detector = freq[:-2]
                        source = 'All'
                        if (pol == 'l' and menu == left) or (pol == 'r' and menu == right):
                            if type == 'c':
                                calib_menu.add_command(label = freq_detector, command = lambda fdp = freq, source = source, shortcut = shortcut: self.plotShortcut(fdp, source, shortcut))
                            if type == 'c' or type == 'p':
                                calib_and_point_menu.add_command(label = freq_detector, command = lambda fdp = freq, source = source, shortcut = shortcut: self.plotShortcut(fdp, source, shortcut))
                else:
                    for info in self.rxg_file_information.values():
                        lo_range = info[7]
                        if lo_range[-1] == 'fixed':
                            label = '%s,%s' % (lo_range[0], lo_range[1])
                            mode = 'fixed'
                        else:
                            label = '%s-%s' % (lo_range[0], lo_range[1])
                            mode = 'range'
                        if menu == left:
                            pol = 'l'
                            if type == 'c':
                                calib_menu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = SOURCES_LIST, pol = pol, type = type : self.plotShortcutLO(pol, source, mode, lo_low, lo_high, type, 'Frequency', 'TCal(K)'))
                            if type == 'c' or type == 'p':
                                calib_and_point_menu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = SOURCES_LIST, pol = pol, type = type : self.plotShortcutLO(pol, source, mode, lo_low, lo_high, type, 'Frequency', 'TCal(K)'))
                        elif menu == right:
                            pol = 'r'
                            if type == 'c':
                                calib_menu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = SOURCES_LIST, pol = pol, type = type : self.plotShortcutLO(pol, source, mode, lo_low, lo_high, type, 'Frequency', 'TCal(K)'))
                            if type == 'c' or type == 'p':
                                calib_and_point_menu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = SOURCES_LIST, pol = pol, type = type : self.plotShortcutLO(pol, source, mode, lo_low, lo_high, type, 'Frequency', 'TCal(K)'))
                    
                for source in SOURCES_LIST:
                    sources_menu_list.append(AutoBreakMenu(menu, tearoff = 0))
                    menu.add_cascade(label = source, menu = sources_menu_list[-1])
                
                for i,freqmenu in enumerate(sources_menu_list):
                    slist = [SOURCES_LIST,]
                    slist.extend(SOURCES_LIST)
                    source = slist[i]
                    
                    
                    if not shortcut == ('Frequency', 'TCal(K)'):
                        freqmenu.add_command(label = 'All Frequencies', command = lambda fdp = 'all_%s' % side, source = source, shortcut = shortcut: self.plotShortcut(fdp, source, shortcut))
                        freqmenu.add_separator()
                        for freq_type in fdp:
                            [freq, type] = freq_type
                            pol = freq[-1]
                            freq_detector = freq[:-2]

                            if (pol == 'l' and menu == left) or (pol == 'r' and menu == right):
                                freqmenu.add_command(label = freq_detector, command = lambda fdp = freq, source = source, shortcut = shortcut: self.plotShortcut(fdp, source, shortcut))
                                
                    else: #add LO-range
                        for info in self.rxg_file_information.values():
                            lo_range = info[7]
                            if lo_range[-1] == 'fixed':
                                label = '%s,%s' % (lo_range[0], lo_range[1])
                                mode = 'fixed'
                            else:
                                label = '%s-%s' % (lo_range[0], lo_range[1])
                                mode = 'range'
                            if menu == left:
                                freqmenu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = source, pol = 'l' : self.plotShortcutLO(pol, source, mode, lo_low, lo_high, None, 'Frequency', 'TCal(K)'))
                            elif menu == right:
                                freqmenu.add_command(label = label, command = lambda mode = mode, lo_low = lo_range[0], lo_high = lo_range[1], source = source, pol = 'r' : self.plotShortcutLO(pol, source, mode, lo_low, lo_high, None, 'Frequency', 'TCal(K)'))
    
    def buildSimulationMenu(self): #Hans
    	"""builds the menu for Simulation"""
    	global simMenuFlag
    	try:
    		if simMenuFlag.get() == 0:
			self.simulationmenu.add_command(label = 'New Simulation', command = lambda: self.preStartSimulation())    			
			simMenuFlag.set(1)
    	except:
    		simMenuFlag = IntVar()
    		simMenuFlag.set(0)
    		self.buildSimulationMenu()
		   
    def buildGainElevToolsMenu(self):
        """builds the menu to display the tools available for Gain vs. Elevation plots. 
        """
        self.toolsmenu.add_command(label = 'Gain Curve From Working File', command = lambda: self.drawGainElevWorkingFile())
        polyfit_menu = Menu(self.toolsmenu, tearoff = 0)
        self.toolsmenu.add_cascade(label = 'Fit To', menu = polyfit_menu)
        
        #polyfit menu
        polyfit_menu.add_command(label = 'New DPFU', command = lambda: self.fitPolyWithComputedDPFU())
        #get mode:
        mode = GAIN_ELEV_POLY[1]
        degree = len(GAIN_ELEV_POLY[0])-1
 
        polyfit_menu.add_command(label = 'Gain Curve and DPFU', command = lambda: self._fitGainAndElevOptions(degree, mode))
        polyfit_menu.add_command(label = 'Scale TCal(K)', command = lambda: self.updateTCalTable())
        
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Update Working File', command = lambda: self.updateWorkingFile('gain_elev'))
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Show Statistics', command = lambda: self.showStatistics())
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Add Virtual Point', command = lambda: self.addVirtualPoint())
    
    def buildTcalFreqToolsMenu(self):
        """builds the menu to display the tools available for TCal(K) vs. Frequency plots
        """
        self.toolsmenu.add_command(label = 'TCal(K) Curve From File', command = lambda: self.drawTcalFreqWorkingfile())
        
        fit_menu = Menu(self.toolsmenu, tearoff = 0)
        self.toolsmenu.add_cascade(label = 'Fit for TCal(K)', menu = fit_menu)
        
        fit_menu.add_command(label = 'Average at each frequency', command = lambda: self.fitTcalFreq('average'))
        fit_menu.add_command(label = 'Median at each frequency', command = lambda: self.fitTcalFreq('median'))
        
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Update Working File', command = lambda: self.updateWorkingFile('tcal_freq'))
        #self.toolsmenu.add_separator()
        #self.toolsmenu.add_command(label = 'Show Statistics', command = lambda: self.showStatistics())
    
    def buildTsysTspillAirmassToolsMenu(self):
        """builds the menu to display the tools available for Tsys-Tspill vs. Airmass plots
        """
        self.toolsmenu.add_command(label = 'Mark Trec from file', command = lambda: self.markTrecFromFile())
        
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Fit for Trec', command = lambda: self._fitTrecOptions())
        self.toolsmenu.add_command(label = 'Recalculate Trec', command = lambda: self.recalcTrec())
        
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Update Working File', command = lambda: self.updateWorkingFile('tsys-tspill_airmass'))
        self.toolsmenu.add_separator()
        self.toolsmenu.add_command(label = 'Show Statistics', command = lambda: self.showStatistics())
    
    def buildTcalRatioToolsMenu(self):
        """builds the menu to display the tools available for plots with Tcal Ratio (vs. anything)
        """
        self.toolsmenu.add_command(label = 'Draw line at unity', command = lambda: self.drawTcalRatioUnity())
    
    def getPolarization(self):
        """getPolarization checks the polarization of the currently plotted data
        and returns 'l' if the data is left polarized, 'r' if right polarized or
        None if both polarizations occur. 
        """
        polarization = self.plot.polarization
        if polarization == 'Left Polarization':
            pol = 'l'
        elif polarization == 'Right Polarization':
            pol = 'r'
        else:
            pol = None
        
        return pol
        
    
    def drawGainElevWorkingFile(self):
        """drawGainElevWorkingFile draws the Gain vs Elevation polynomial for the matching 
        rxg file. 
        """
        self.plot.delete('gain_elev_poly')
        polarization = self.getPolarization()
        if polarization == 'l':
            DPFU = DPFU_L
        elif polarization == 'r':
            DPFU = DPFU_R
        else:
            raise RuntimeError
        poly = GAIN_ELEV_POLY[0]
        mode = GAIN_ELEV_POLY[1] == 'ALTAZ'
        #scale with DPFU
        poly = map(lambda x: x*DPFU, poly)
        self.plot.drawFittedLine(poly, fill = 'green', complement_angle = mode, tags = ('gain_elev_poly',))
        
        cpoly = poly[:]
        cpoly.reverse()
        
        stat = 'Coefficients:\t'
        for k,coeff in enumerate(cpoly):
            stat += 'x^%s : %.3g\n\t\t' % (len(cpoly)-k-1,coeff)
        stat += '\nDPFU:\t%.3g\n\n' % DPFU
        
        self.statistics.set(stat)
        
        if OPACITY_CORRECTED_POLY:
            self.plot.setOpacityLabel()
    
    def plotShortcut(self, fdp, source, shortcut, type = None):
        """plotShortcut is called from the shortcuts menu, and decides what was clicked and plots it
        by sending it to prepPlot. 
        """
        #no handling of type yet.... 
        
        #first, deselect all:
        self.selectAllSources(SOURCES_LIST, 0)
        self.selectAllFrequencies('both', 0)
        #then select source, fdp
        if source in SOURCES_LIST:
            self.selectAllSources([source], 1) #source
        else:
            for source in SOURCES_LIST:
                self.selectAllSources([source], 1)
        if fdp == 'all_l':
            self.selectAllFrequencies('l', 1)
        elif fdp == 'all_r':
            self.selectAllFrequencies('r', 1)
        else:
            self.frequencies_chosen[fdp].set(1)
        #select x and y. x=shortcut[0], y = shortcut[1]
        self.selectedX.set(shortcut[0])
        self.selectedY.set(shortcut[1])
        #and plot
        self.prepPlot()
    
    def plotShortcutLO(self, selected_pol, source, mode, min_LO, max_LO, sourcetype = None, selectx = None, selecty = None):
        """does the same thing as plotShortcut, but for LO-divided data, that is 
        TCal(K) vs. Frequency. 
        """
        #if type is not calibrator or pointing, set it to None (to indicate all)
        if sourcetype != 'c' or sourcetype != 'p':
            sourcetype = None
        if type == 'p':
            type2 = 'c'
        else:
            type2 = None
        #first, deselect all frequencies
        self.selectAllFrequencies('both', 0)
        
        self.selectAllSources(SOURCES_LIST, 0)
        
        if not (type(source) == list):# or type(source) == tuple):
            source = (source,)
        self.selectAllSources(source, 1)
        
        
        lo_list = self.database.get('LO')
        freq_list = self.database.get('Frequency')
        pol_list = self.database.get('Polarization')
        det_list = self.database.get('Detector')
        type_list = self.database.get('SourceType')
        
        
        for i in range(len(lo_list)):
            lo = lo_list[i]
            freq = freq_list[i]
            pol = pol_list[i]
            det = det_list[i]
            ref_type = type_list[i]
            fdp = '%s %s %s' % (freq, det, pol)
            if mode == 'range':
                if selected_pol == pol and lo <= max_LO and lo >= min_LO:
                    if (ref_type == sourcetype or ref_type == type2) or not sourcetype: #check type
                        self.frequencies_chosen[fdp].set(1)
            else: #mode == 'fixed'
                if selected_pol == pol and (lo==max_LO or lo==min_LO):
                    if (ref_type == sourcetype or ref_type == type2) or not sourcetype: #check type
                        self.frequencies_chosen[fdp].set(1) 
        
        if selectx and selecty:
            self.selectedX.set(selectx)
            self.selectedY.set(selecty)
        #and plot
        self.prepPlot()
        
    def selectAllSources(self, source_list, set):
        """setlectAllSources selects all check buttons with the source 'source'.  
        """
        for source in source_list:
            for time in self.sources_chosen[source].keys():
                self.sources_chosen[source][time].set(set)
            
        self.prepPlot()
        
    def selectAllFrequencies(self, pol, set):
        """selectAllFrequencies selects all frequencies with 
        the polarization 'pol'. 
        """
        if pol == 'both':
            self.selectAllFrequencies('l', set)
            self.selectAllFrequencies('r', set)
        for fdp in self.frequencies_chosen.keys():
            if fdp.split()[-1] == pol:
                self.frequencies_chosen[fdp].set(set)
        
        self.prepPlot()
                
    def buildSourcesMenu(self):
        """builds the menu with all sources. The user can select sources from this menu. 
        Also, the user can select how the data should be represented. The choices are point & letter, 
        and all iterations of those. (point & letter, point, letter) 
        """
        #find sources:
        sources = self._getUnique(self.database.get('Source'))
        selected_source = StringVar()
        self.sourcemenu.delete(0, END)
        self.sourcemenu.add_radiobutton(label = 'Deselect All Sources', variable = selected_source, command = lambda: self.selectData(None, 'Source'))
        self.sourcemenu.add_separator()
        
        for source in sources:
            self.sourcemenu.add_radiobutton(label = source, variable = selected_source, command = lambda source = source: self.selectData(source, 'Source'))
    
    def redrawPlot(self, force = 0):
        """redrawPlot is called by keypress r. 
        It calls plots function to redraw the plot. It is only done if force = True 
        or if automatic replot is turned on. 
        """
        if self.selectedX.get() and self.selectedY.get():
            if Gui.automatic_redraw.get() or force:
                try:
                    self.plot.reDrawAll()
                except ValueError:
                    pass
    
    def selectData(self, source, data, detector=None, pol=None):
        """selectData is called from the select source and select frequency menu.
        It selects that data in the plot by filling its circle black.  
        """
        select_list = []
        source_list = self.database.get(data)[:]
        if source:
            for index in self.plot.data_indices:
                source_in_list = source_list[index]
                if source_in_list == source:
                    if pol and detector:
                        if pol == self.database.get('Polarization')[index] and detector == self.database.get('Detector')[index]:
                            select_list.append(index)
                    else:
                        select_list.append(index)
        else: #if deselect all
            end_index = len(source_list)
            select_list = []#self.plot.data_indices

        Gui.highlighted_points.set(len(select_list))
        self.plot.selectPoint(select_list)
    
    def deleteBadGC(self):
        """deleteBadGC is the window to select options on how to delete points with 
        bad gain compression. 
        """
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
        """called from deleteBadGC. Deletes all points with Gain Compression outside of lower and upper limit. 
        """
        lower = float(lower)
        upper = float(upper)
        self.bad_gc_top.destroy()
        GC_list = self.database.get('Gain Compression')
        index_list = []
        for i,gc in enumerate(GC_list):
            if (float(gc)>upper) or (float(gc)<lower):
                self.plot.deleted_list.append(i)
        
        self.redrawPlot()
    
    def deleteBadTemp(self):
        """deleteBadTemp deletes all data in the log which has a Tsys-Tspill-Trec<0
        """
        TREC = 0
        trec_lo_list = self.getTrecLOList()
        tsys_tspill_list = self.database.get('Tsys-Tspill')

        for i,tsys_tspill in enumerate(tsys_tspill_list):
            LO = self.database.get('LO')[i]
            pol = self.database.get('Polarization')[i]
            for j in range(len(trec_lo_list)):
                [mode, LO_low, LO_high, trec_l, trec_r] = trec_lo_list[j]
                if (mode == 'fixed' and (LO == LO_low or LO == LO_high)) or (mode == 'range' and (LO<=LO_high and LO>= LO_low)):
                    if pol == 'l':
                        TREC = trec_l
                    else:
                        TREC = trec_r
                    break
            if tsys_tspill-TREC<0:
                self.plot.deleted_list.append(i)
        
        self.redrawPlot()
        
            
    def deleteOutsidePlot(self):
        """deletes all points in the selected dataset that are outside of plot boundaries. 
        """
        for item in self.plot.find_withtag('outside_zoom'):
            self.plot.deletePoint(item)
    
    def unDeleteAll(self, in_selection = False):
        """unDeletes all points. 
        The selected data for the plot will be replotted with the undeleted points. 
        """
        self.plot.data_indices.extend(self.plot.current_deleted)
        self.plot.deleted_list = list(set(self.plot.deleted_list) - set(self.plot.current_deleted))
        if not in_selection: 
            self.plot.deleted_list = []
        self.redrawPlot()
        
    
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
        
    
    def prepPlot(self, **kw):
        """prepares the plot, setting the right tools etc.
        """
            
        ##################################
        #reset tools
        self.toolsmenu.delete(0, END)
        self.plot.virtual_points_list = []
        self.plot.delete_old_trec()
        self.plot.delete('opacity_data')
        if self.selectedX.get() and self.selectedY.get():
            #data_indices0 = []
            if kw.get('data_indices'):
            	data_indices = kw.get('data_indices')[:]
            else:
            	data_indices = self.fetchData(self.selectedX.get())
            
            if self.selectedY.get() == 'TCal Ratio':
                self.buildTcalRatioToolsMenu()
            elif self.selectedY.get() == 'Gain' or self.selectedY.get() == 'TCal(K)':
                if not self.simulation.get():
                	self.computeOpacityFactor(data_indices)
                self.setOpacityMark()
            
            status = 'Plotting %s vs. %s' % (self.selectedY.get(), self.selectedX.get())
            self.status.set(status)
            self.statistics = StringVar()
            
            #delete zoom list
            self.plot.outside_zoom_list = []
            if data_indices:
                self.plot.plot(data_indices, self.selectedX.get(), self.selectedY.get())
                self.plot.delete('line')
                try:
                    self.matchRXG(data_indices)
                except RXGError:
                    status = "Error: The selected dataset's LO spans zero or several RXG-files. Tools not available"
                    self.status.set(status)
                else:
                    #set tools
                    if self.getPolarization(): #is None if both pol
                        if self.selectedX.get() == 'Elevation' and self.selectedY.get() == 'Gain':
                            self.buildGainElevToolsMenu()
                        elif self.selectedX.get() == 'Frequency' and self.selectedY.get() == 'TCal(K)':
                            self.buildTcalFreqToolsMenu()
                        elif self.selectedX.get() == 'Airmass' and self.selectedY.get() == 'Tsys-Tspill':
                            self.buildTsysTspillAirmassToolsMenu()
            else:
                status = 'Error: The requested data does not exist!'
                self.status.set(status)

    
    def getPol(self, ref_pol):
        """returns a list with all left or right (ref_pol) data
        """
        data = []
        for i, pol in enumerate(self.database.get('Polarization')):
            if pol == ref_pol:
                data.append(i)
        
        return data
    
    def open(self, pid = 0, logfile = None):
        """opens and reads the log file
        """
        if not logfile:
            types = (('Log Files','*.log'), ('All Files','*'))
            logfile = tkFileDialog.askopenfilename(initialdir = Gui.fs_dir, filetypes = types)
        if logfile:
            #clear database
            self.database.clear()
            
            self.open_logfile = logfile
            output_file = Gui.gndat_output
            #pid = 0#os.getpid()
            rxg_directory = Gui.rxg_dir
            gndat = 'gndat2' #change to gndat2 for the new version...
            cmdline = '%s %s %s %s %s' % (gndat, logfile, output_file, pid, rxg_directory)
            
            """catches input and output stream. Input stream is the temporary file, but the file handle is not used for anything
            Output stream is the temporary filename if no error, or the error message if there is one. 
            In the future, std_err might be used. In that case, use os.popen3 instead. 
            """
            [std_in, std_out] = os.popen2(cmdline)
            std_out_copy = std_out.read()
            std_in.close()
            std_out.close()

            #os.popen(cmdline) #not needed...
            
            if not os.path.isfile(output_file):
                status = 'Error: %s' % std_out_copy.strip()
                self.status.set(status)
            else:
                gndat_reader = GndatReader(output_file)
                gndat_reader.setDaemon(1)
                gndat_reader.start()
                
                #make progress bar:
                x0 = self.plot.x_margin
                width = int(self.plot.winfo_width())  
                x1 = width - self.plot.x_margin
                height = int(self.plot.winfo_height())
                y0 = int(self.plot.winfo_height())-self.plot.y_margin/2
                y1 = y0+8
                self.plot.create_rectangle(x0,y0,x1,y1, tags = ('progress_bar'))
                self.plot.update()
                color = '#2F9EFF'
                bar = self.plot.create_rectangle(x0,y0,x0,y1, tags = ('progress_bar'), fill = color)
                tot_x = x1-x0
    
                #gndat_reader.run()
                while gndat_reader.isAlive():
                    progress = gndat_reader.progress
                    new_x = x0 + progress * tot_x/100
                    self.plot.coords(bar, x0, y0, new_x, y1)
                    self.plot.update()
                
                #wait for thread..., not really needed 
                gndat_reader.join()
    
                self.plot.delete('progress_bar')
                [self.database, no_plot_list, rxg_list, number_of_bad_values] = gndat_reader.getData()
                
                Gui.rejected_points.set(number_of_bad_values)
                
                #If data was generated by simulation the last one should be in the database
                if self.simulation.get():
                	self.simGenerateData(sel_x = 1, sel_y=1)
                
                if not self.database:
                    status = 'Error: The dataset is empty! Check your rxg files!'
                    self.status.set(status)
                else:
                    global RXG_LIST
                    RXG_LIST = rxg_list
                    #create opacity corrected_list
                    Gui.opacity_correction.clear()
                    for rxg in RXG_LIST:
                        Gui.opacity_correction[rxg] = StringVar()
                    #read rxg-file
                    self.readRXG()
                    #print database
                    #build menus:
                    plot_list = self.database.keys()
                    #items in no_plot_list are not to be plotted
                    
                    
                    if not pid: #if not updating rxg...
                        for l in no_plot_list:
                            plot_list.remove(l)
                        self.buildPlotMenu(plot_list)
                
                        #Frequencies
                        self.buildFrequenciesMenu()
                        
                        #Edit menu
                        self.buildEditMenu()
                        
                        #Simulation menu - Hans
                        self.buildSimulationMenu()
                        
                        #Sources menu
                        self.buildSourcesMenu()
                        
                        #set legend
                        self.setLegend()
                        
                        #undelete all points:
                        self.plot.deleted_list = []
                        
                        #close previous plot
                        self.plot.closePlot()
                    
                    self.plot.database = self.database.copy()
                    
                    #set total number of points
                    for key in self.database.keys():
                        Gui.total_points.set(len(self.database.get(key)))
                        break
                    
                    status = '%s has been read successfully' % (logfile)
                    self.status.set(status)
                    
                    #delete temporary output
                    os.remove(output_file)
                    
                    #save pre_opacity_corrected_gain and tcal
                    self.pre_opacity_corrected_gain = self.database.get('Gain')[:]
                    self.pre_opacity_corrected_tcal = self.database.get('TCal(K)')[:]
                    self.pre_opacity_corrected_tcal_ratio = self.database.get('TCal Ratio')[:]
        
    def cleanupAndExit(self):
        """exits gnplt2
        """
        try:
            self.cleanUp(quit = 1)
        except NameError:
            pass
        self.quit()
    
    def cleanUp(self, **kw):
        """cleanUp is called when gnplt2 is terminated. 
        If there are any working rxg files, 
        the user will be asked wether to keep the changes.  
        """
        #all rxg names are in global variable RXG_LIST
        for orig_rxg in RXG_LIST:
            orig_rxg = self.getOriginalRXGName(orig_rxg)
            working_rxg = self.nameWorkingRXG(orig_rxg)

            if os.path.isfile(working_rxg):
                #working file exists                     
                if self.simulation.get():
                	if kw.get('quit'):
                		pass
                	else:
                		tkMessageBox.showinfo('Unwanted action', 'The working file was updated using simulated data. The RXG file can therefore not be updated.')
                else:
                	#ask the user to replace
                	answer = tkMessageBox.askyesno('Save?', 'Save updates made to %s?' % orig_rxg)
   	             	if answer:
  	                	os.remove(orig_rxg)
      	           		os.rename(working_rxg, orig_rxg)
            	try:
            		if self.simulation.get() and not kw.get('quit'):
                		pass
                	else:
                		os.remove(working_rxg)
            	except OSError: #if the working file was renamed to orig_rxg it doesnt exist anymore...
                	pass
    
    def nameWorkingRXG(self, name):
        """receives a rxg filename and returns the corresponding working filename. 
        """
        pid = os.getpid()
        suffix = '.work.%s' % pid
        i = len(suffix)
        if name[-i:] != suffix:
            name = name+suffix 
        return name
    
    def getOriginalRXGName(self, name):
        """receives a rxg filename and returns the corresponding original filename.
        """
        pid = os.getpid()
        suffix = '.work.%s' % pid
        i = len(suffix)
        if name[-i:] == suffix:
            name = name[:-i] 
        return name
    
    def setLegend(self):
        """set the source legend for the plots.
        Called from open.  
        """
        #remove old info
        
        legend_master = self.legend_frame.master
        self.legend_frame.destroy()
        self.legend_frame = LabelFrame(legend_master, text = 'Source Legend')
        self.legend_frame.grid(row = 0, column = 0, pady = 35)
        
        for i,source in enumerate(SOURCES_LIST):

            j = SOURCES_LIST.index(source)
            [color, letter] = self.plot.getColorAndLetter(j)
            
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
        """scale calls Plot.reDrawAll with the current scaling mode setting. 
        Gui.scaling_mode (Tk.IntVar) keeps track of the scaling mode setting. 
        """
        if mode == 'with_deleted':
            #Gui.scaling_mode.set(1)
            self.plot.reDrawAll()
        elif mode == 'without_deleted':
            #Gui.scaling_mode.set(0)
            self.plot.reDrawAll()
        elif mode == 'manual':
            #Gui.scaling_mode.set(2)
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
        """sets plot axises to xmin,xmax,ymin,ymax
        """
        self.manual_top.destroy()
        xmin = float(xmin)
        xmax = float(xmax)
        ymin = float(ymin)
        ymax = float(ymax)
        self.plot.reDrawAll(xmin, xmax, ymin, ymax)
    
    def iosetup(self):
        """dialog for changing io settings. 
        """
        iosetup_top = Toplevel()
        iosetup_top.title('I/O Setup')
        file_parsing_frame = LabelFrame(iosetup_top, text = 'Log file parsing')
        file_parsing_frame.pack(padx = 20, pady = 20)
        Label(file_parsing_frame, text = 'Default directory for FS log files:').grid(row = 0, column = 0, padx = 5, pady = 2)
        fs_dir = StringVar()
        fs_dir_entr = Entry(file_parsing_frame, textvariable = fs_dir, width = 30)
        fs_dir_entr.grid(row = 0, column = 1, padx = 5, pady = 2)
        fs_dir.set(Gui.fs_dir)
        Button(file_parsing_frame, text = '...', command = lambda: fs_dir.set(tkFileDialog.askdirectory(initialdir = Gui.fs_dir))).grid(row = 0, column = 2, padx = 5)
        
        Label(file_parsing_frame, text = 'Default directory for .rxg files:').grid(row = 1, column = 0, padx = 5, pady = 2)
        rxg_dir = StringVar()
        rxg_dir_entr = Entry(file_parsing_frame, textvariable = rxg_dir, width = 30)
        rxg_dir_entr.grid(row = 1, column = 1, padx = 5, pady = 2)
        rxg_dir.set(Gui.rxg_dir)
        Button(file_parsing_frame, text = '...', command = lambda: rxg_dir.set(tkFileDialog.askdirectory(initialdir = Gui.rxg_dir))).grid(row = 1, column = 2, padx = 5)
        
        Label(file_parsing_frame, text = 'Output file for gndat:').grid(row = 2, column = 0, padx = 5, pady = 2)
        gndat_output = Entry(file_parsing_frame, width = 30)
        gndat_output.grid(row = 2, column = 1, padx = 5, pady = 2)
        gndat_output.insert(0, Gui.gndat_output)
        buttonrow = Frame(iosetup_top)
        buttonrow.pack()
        Button(buttonrow, text = 'Ok', command = lambda: self.setIO(fs_dir.get(), rxg_dir.get(), gndat_output.get(), iosetup_top.destroy())).pack(side = LEFT)
        Button(buttonrow, text = 'Cancel', command = lambda: iosetup_top.destroy()).pack(side = LEFT)
    
    def setIO(self, fs_dir, rxg_dir, gndat_output, _a = None):
        """called by self.iosetup. Sets the actual I/O Settings
        """
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
                self.status.set('Error: File error while printing to file. Check write permissions')
            else:
                if status == 1: #PIL Error
                    self.status.set('Error: Python Imaging Library (PIL) not correctly installed. Can only send output to postscript!')
                else:
                    self.status.set('Output sent to %s' % filename)
            printer.destroy()
        elif kw.get('destination')==0: #printer
            if not kw.get('printcommand')==1:
                printcmd = 'lpr'
            else:
                printcmd = 'psprint'
            printer.printCanvas(None, None, printcmd, kw.get('printer'))
            printer.destroy()
    
    def _setOutputFilename(self, suffix, old_name, *novar):
        """help function for startPrint. Sets file suffix automatically. 
        """
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
        self.plot.update()
        
    
    def about(self):
        """displays tkMessageBox.showinfo with version number
        """
        title = 'About'
        message = 'GnPlt2 version 2.06'
        tkMessageBox.showinfo(title, message)
    
    def shortcuts(self):
        """displays toplevel window with explanation of all of gnplt2's keyboard and mouse shortcuts 
        """
        top = Toplevel()
        top.resizable(width = 0, height = 0)
        keyboard_shortcuts = LabelFrame(top, text = 'Keyboard shortcuts')
        keyboard_shortcuts.pack(padx= 50, pady=25)
        Label(keyboard_shortcuts, text = 'Replot', anchor = E).grid(row = 0, column = 0, pady = 2, padx = 10)
        Label(keyboard_shortcuts, text = 'r', anchor = W).grid(row = 0, column = 1, pady = 2, padx = 10)
        Label(keyboard_shortcuts, text = 'Quit', anchor = E).grid(row = 1, column = 0, pady = 2, padx = 10)
        Label(keyboard_shortcuts, text = 'q', anchor = W).grid(row = 1, column = 1, pady = 2, padx = 10)
        Label(keyboard_shortcuts, text = 'Undeletes all data in the current selection', anchor = E).grid(row = 2, column = 0, pady = 2, padx = 10)
        Label(keyboard_shortcuts, text = 's', anchor = W).grid(row = 2, column = 1, pady = 2, padx = 10)
        mouse_shortcuts = LabelFrame(top, text = 'Mouse shortcuts')
        mouse_shortcuts.pack(padx= 50, pady=25)
        Label(mouse_shortcuts, text = 'Left click while over/near point', anchor = E).grid(row = 0, column = 0, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Connects points with the same source and frequency', anchor = W).grid(row = 0, column = 1, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Hold shift while left clicking on a point', anchor = E).grid(row = 1, column = 0, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Deletes/Undeletes all points with the same time', anchor = W).grid(row = 1, column = 1, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Right click while over point', anchor = E).grid(row = 2, column = 0, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Deletes/Undeletes point', anchor = W).grid(row = 2, column = 1, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Left click and hold', anchor = E).grid(row = 3, column = 0, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Starts a box for zooming. Drag and release to zoom', anchor = W).grid(row = 3, column = 1, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Hold control while left clicking on the plot', anchor = E).grid(row = 4, column = 0, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'If Gain vs. Elevation is plotted, this will add \na "virtual point" att that position', anchor = W).grid(row = 4, column = 1, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Right click and hold', anchor = E).grid(row = 5, column = 0, pady = 2, padx = 10)
        Label(mouse_shortcuts, text = 'Starts a box to delete/undelete selection. \nDrag and release to set selection', anchor = W).grid(row = 5, column = 1, pady = 2, padx = 10)
        color_expl = LabelFrame(top, text = 'Color explanations')
        color_expl.pack(padx= 50, pady=25)
        Label(color_expl, text = 'White point', anchor = E, fg = 'white').grid(row = 0, column = 0, pady = 2, padx = 10)
        Label(color_expl, text = 'Point on the plot, not deleted', anchor = W).grid(row = 0, column = 1, pady = 2, padx = 10)
        Label(color_expl, text = 'Cyan point', anchor = E, fg = 'cyan').grid(row = 1, column = 0, pady = 2, padx = 10)
        Label(color_expl, text = 'Point off the plot, not deleted', anchor = W).grid(row = 1, column = 1, pady = 2, padx = 10)
        Label(color_expl, text = 'Red point', anchor = E, fg = 'red').grid(row = 2, column = 0, pady = 2, padx = 10)
        Label(color_expl, text = 'Point on or off the plot, deleted', anchor = W).grid(row = 2, column = 1, pady = 2, padx = 10)
        Label(color_expl, text = 'Green curve', anchor = E, fg = 'green').grid(row = 3, column = 0, pady = 2, padx = 10)
        Label(color_expl, text = 'Curve currently in the .rxg file', anchor = W).grid(row = 3, column = 1, pady = 2, padx = 10)
        Label(color_expl, text = 'Black curve', anchor = E, fg = 'black').grid(row = 4, column = 0, pady = 2, padx = 10)
        Label(color_expl, text = 'Curve as a result of a fit', anchor = W).grid(row = 4, column = 1, pady = 2, padx = 10)
        Button(top, text = 'Ok', command = lambda: top.destroy()).pack(pady = 4)
    
    def removeDoubleSpace(self, line):
        """help function for text parsers... Removes all blank spaces in a row > 1. 
        """
        while line.count('  ')>0:
            line = line.replace('  ',' ')
        return line.strip()
    
    def readRXG(self):
        """processes all RXG files, and finds tcal tables, trec and dpfu values, gain polynomials and lo ranges. 
        """
        #eventually find all rxg files in rxg file directory. 
        self.rxg_file_information = {}
        global GAIN_ELEV_POLY, DPFU_L, DPFU_R
        for filename in RXG_LIST.keys():
            global TCAL_TABLE_L, TCAL_TABLE_R
            TCAL_TABLE_L = TCAL_TABLE_R = TREC_L = TREC_R = DPFU_L = DPFU_R = polynomial = LO_RANGE = opacity_corrected_poly = 0
            path = Gui.rxg_dir
            TCAL_TABLE_L = {}
            TCAL_TABLE_R = {}
            #change cwd
            #old_cwd = os.getcwd()
            #os.chdir(path)
            rxg_file = open(filename, 'r')
            #os.chdir(old_cwd)
            #find LO range
            set_dpfu = 0
            read_dpfu = 0
            read_trec = 0
            opacity_corrected_poly = 0
            for line in rxg_file.readlines():
                line = self.removeDoubleSpace(line)
                if not line[0] == '*': #if not comment
                    if read_dpfu:
                        _line = line.split()
                        for i,k in enumerate(read_dpfu):
                            dpfu = _line[i]
                            if k == 'lcp':
                                DPFU_L = float(dpfu)
                            elif k == 'rcp':
                                DPFU_R = float(dpfu)
                        read_dpfu = 0
                    elif read_trec:
                        _line = line.split()
                        if len(_line) == 1:
                            TREC_R = TREC_L = float(_line[0])
                        else:
                            TREC_L = float(_line[0])
                            TREC_R = float(_line[1])
                        read_trec = 0
                    elif line[:5] == 'range':
                        _line = line.split()
                        if len(_line) == 3:
                            LO_RANGE = (float(_line[1].strip()), float(_line[2].strip()), 'range')
                        else:
                            LO_RANGE = (float(_line[1].strip()), float(_line[1].strip()), 'range')
                    elif line[:5] == 'fixed':
                        _line = line.split()
                        if len(_line) == 3:
                            LO_RANGE = (float(_line[1].strip()), float(_line[2].strip()), 'fixed')
                        else:
                            LO_RANGE = (float(_line[1].strip()), float(_line[1].strip()), 'fixed')
                    elif line[:9] == 'ELEV POLY':
                        _line = line[10:].split()
                        if _line[-1] == 'opacity_corrected':
                            _line.pop(-1)
                            Gui.opacity_correction[filename].set('both')
                            opacity_corrected_poly = 1
                        else:
                            Gui.opacity_correction[filename].set('none')
                        GAIN_ELEV_POLY = []
                        for i in _line:
                            GAIN_ELEV_POLY.append(float(i))
                        GAIN_ELEV_POLY.reverse()
                        polynomial = [GAIN_ELEV_POLY, 'ELEV']
                    elif line[:10] == 'ALTAZ POLY':
                        _line = line[11:].split()
                        if _line[-1] == 'opacity_corrected':
                            _line.pop(-1)
                            Gui.opacity_correction[filename].set('both')
                            opacity_corrected_poly = 1
                        else:
                            Gui.opacity_correction[filename].set('none')
                        GAIN_ELEV_POLY = []
                        for i in _line:
                            GAIN_ELEV_POLY.append(float(i))
                        GAIN_ELEV_POLY.reverse()
                        polynomial = [GAIN_ELEV_POLY, 'ALTAZ']
                    elif (line[:3] == 'lcp' or line[:3] == 'rcp') and not set_dpfu:
                        _line = line.split()
                        read_dpfu = _line
                        set_dpfu = 1
                    elif line[:3] == 'lcp':
                        _list = line.split()
                        if len(_list)==3:
                            freq = float(_list[1])
                            tcal = float(_list[2])
                            TCAL_TABLE_L[freq] = tcal
                    elif line[:3] == 'rcp':
                        _list = line.split()
                        if len(_list)==3:
                            freq = float(_list[1])
                            tcal = float(_list[2])
                            TCAL_TABLE_R[freq] = tcal
                    elif line[:14] == 'end_tcal_table':
                        #next thing is trec
                        read_trec = 1
            #save information
            self.rxg_file_information[filename] = [TCAL_TABLE_L, TCAL_TABLE_R, TREC_L, TREC_R, DPFU_L, DPFU_R, polynomial, LO_RANGE, opacity_corrected_poly]
            #Hans- adding this line because this is the way GAIN_ELEV_POLY is used later (matchRXG).
            GAIN_ELEV_POLY = polynomial
            
            rxg_file.close()
    
    def matchRXG(self, datalist):
        """matchRXG matches the data about to be plotted with the corresponding RXG file. 
        If it matches more than one rxg file (more than one band), an error is raised and no data is matched. 
        If it matches only one rxg, tcal tables, trec data, dpfu data etc. is set to what is in that rxg file. 
        """
        global TCAL_TABLE_L, TCAL_TABLE_R, TREC_L, TREC_R, DPFU_L, DPFU_R, GAIN_ELEV_POLY, LO_RANGE, OPACITY_CORRECTED_POLY
        current_LOs = self.plot.getList('LO', datalist)
        #match with LOs, find which file it is, the extract the information....
        RXGs = RXG_LIST.keys()
        for lo in current_LOs:
            for rxg in RXGs:
                value = RXG_LIST.get(rxg)
                mode = value[0]
                lower = value[1]
                upper = value[2]
                if mode == 'range':
                    if not (lower<=lo and lo<=upper):
                        RXGs.remove(rxg)
                elif mode == 'fixed':
                    if lo!= lower and lo!=upper:
                        RXGs.remove(rxg)
        
        if len(RXGs)!=1:
            raise RXGError
        else:
            global ORIGINAL_RXG_FILE, WORKING_RXG_FILE
            ORIGINAL_RXG_FILE = RXGs[0]
            WORKING_RXG_FILE = self.nameWorkingRXG(ORIGINAL_RXG_FILE) 
            data = self.rxg_file_information.get(RXGs[0])
            [TCAL_TABLE_L, TCAL_TABLE_R, TREC_L, TREC_R, DPFU_L, DPFU_R, GAIN_ELEV_POLY, LO_RANGE, OPACITY_CORRECTED_POLY] = data
            self.working_data = {}
            self.setOpacityMark()
        
    def setOpacityMark(self):
        """setOpacityMark calls Plot to draw a label if the data is opacity corrected. 
        """
        try:
            status = Gui.opacity_correction[ORIGINAL_RXG_FILE].get()
            self.plot.setOpacityLabelForData(status)
        except (NameError,KeyError,):
            pass
        
                    
    def _fitGainAndElevOptions(self, _degree, mode):
        """help function to set variables for the polynomial fit for the gain-elevation data
        """
        top = Toplevel()
        top.title('Polynomial degree choice')
        Label(top, text = 'Degree of polynomial:').grid(row = 0, column = 0, pady = 5, padx = 5)
        degree = Entry(top, width = 3)
        degree.grid(row = 0, column = 1, pady = 5, padx = 5)
        degree.insert(0, _degree)
        
        Label(top, text = 'Select type of gain curve:').grid(row = 1, column = 0, pady = 5, padx = 5)
        complement_angle = IntVar()
        Radiobutton(top, text = 'ELEV', variable = complement_angle, value = 0).grid(row = 1, column = 1, pady = 5, padx = 5)
        Radiobutton(top, text = 'ALTAZ', variable = complement_angle, value = 1).grid(row = 2, column = 1, pady = 5, padx = 5)
        if mode == 'ELEV':
            complement_angle.set(0)
        else:
            complement_angle.set(1)
        
        button_frame = Frame(top)
        button_frame.grid(row = 3, column = 0, columnspan = 2, pady = 10)
        
        Button(button_frame, text = 'Ok', command = lambda: self.fitGainAndElev(degree.get(), complement_angle.get(), top.destroy())).pack(side = LEFT, padx = 5)
        Button(button_frame, text = 'Cancel', command = lambda: top.destroy()).pack(side = LEFT, padx = 5)
    
    def fitGainAndElev(self, degree = 2, type = 0, _a = None):
        """fits gain and elevation by calling a polynomial fitter in NumericTools. 
        """
        self.working_data.clear()
        self.plot.delete('gain_elev_line')
        
        degree = int(degree)
        #first, get data
        xname = self.plot.xname
        yname = self.plot.yname
        pol = self.getPolarization()
        #all_pol = set(self.getPol(pol))
        #deleted = set(self.plot.deleted_list)
        indices = self.plot.data_indices
        xdata = []
        ydata = []
        for i in indices:
            if type:
                xdata.append(90 - self.database.get(xname)[i])
            else:
                xdata.append(self.database.get(xname)[i])
            ydata.append(self.database.get(yname)[i])
        
        #add virtual points:
        [x_virt, y_virt] = self.plot.getVirtualList()
        
        xdata.extend(x_virt)
        ydata.extend(y_virt)
        
        poly = self.numTools.polyfitData(xdata, ydata, degree) 
        dpfu = self.numTools.getDPFU(poly)
        #scale poly with dpfu, then add to working data...
        spoly = [k/dpfu for k in poly]
        if type:
            mode = 'ALTAZ'
        else:
            mode = 'ELEV'
        
        if Gui.opacity_correction[ORIGINAL_RXG_FILE].get() == 'both' or Gui.opacity_correction[ORIGINAL_RXG_FILE].get() == 'gain':
            opac_cor = 1
        else:
            opac_cor = 0
        
        self.working_data['gain_poly'] = [spoly,mode, opac_cor]
        self.working_data['dpfu'] = dpfu
        self.plot.drawFittedLine(poly, complement_angle = type, tags = ('gain_elev_line',))
        
        #get RMS
        #_xdata = self.database.get(xname)
        #_ydata = self.database.get(yname)
        RMS = self.numTools.getRMS(poly, xdata, ydata)
        dpfu_div_rms = RMS/dpfu
        
        cpoly = spoly[:]
        cpoly.reverse()
        #build statistics
        #stat = 'Polynomial: %s\nComputed DPFU: %s\nRMS/DPFU: %s' % (str(cpoly), dpfu, dpfu_div_rms)
        stat = 'Coefficients:\t'
        for k,coeff in enumerate(cpoly):
            stat += 'x^%s : %.3g\n\t\t' % (len(cpoly)-k-1,coeff)
        stat += '\nComputed DPFU:\t%.3g\n\n' % dpfu
        stat += '\nRMS/DPFU:\t%.3g' % dpfu_div_rms
        self.statistics.set(stat)
    
    def fitPolyWithComputedDPFU(self):
        self.working_data.clear()
        self.plot.delete('fitted_dpfu_line')
        DPFU = self.computeDPFU()
        self.working_data['dpfu'] = DPFU
        poly = GAIN_ELEV_POLY[0]
        cpoly = poly[:]
        cpoly.reverse()
        #scale with DPFU
        poly = map(lambda x: x*DPFU, poly)
        self.plot.drawFittedLine(poly, tags = ('fitted_dpfu_line',))
        stat = 'Coefficients:\t'
        for coeff in cpoly:
            stat += '%.3g\n\t\t' % coeff
        stat += '\nComputed DPFU:\t%.3g\n\n' % DPFU
        
        self.statistics.set(stat)
    
    def computeDPFU(self):
        #first, get all data except removed data
        xname = self.plot.xname
        yname = self.plot.yname
        #pol = self.getPolarization()
        #all_pol = set(self.getPol(pol))
        #deleted = set(self.plot.deleted_list)
        #indices = list(all_pol - deleted)
        indices = self.plot.data_indices

        xdata = []
        ydata = []
        for i in indices:
            xdata.append(self.database.get(xname)[i])
            ydata.append(self.database.get(yname)[i])
        
        #add virtual points:
        [x_virt, y_virt] = self.plot.getVirtualList()
        
        xdata.extend(x_virt)
        ydata.extend(y_virt)
        
        poly = GAIN_ELEV_POLY[0]
        c = self.numTools.evalPoly(poly,xdata)
        DPFU=self.numTools.getScale(ydata,c)
        return DPFU
    
    def updateTCalTable(self):
        self.working_data.clear()
        #the tcal table in the rxg file should increase with the increase of DPFU
        #therefore, we need the new DPFU
        new_dpfu = self.computeDPFU()
        polarization = self.getPolarization()
        if polarization == 'l':
            old_dpfu = DPFU_L
        elif polarization == 'r':
            old_dpfu = DPFU_R
        
        delta_dpfu = (new_dpfu-old_dpfu)/old_dpfu
        self.working_data['tcal_factor'] = delta_dpfu
        stat = 'DPFU: %s' % new_dpfu
        self.statistics.set(stat)
    
    def stringList(self, list):
        return_str = ''
        for x in list:
            return_str += str(x) + ' '
        return return_str.strip()
    
    def updateWorkingFile(self, mode):
        """mode is either gain_elev, tcal_freq, or tsys-tspill_airmass
        file to be written is global variable WORKING_RXG_FILE. If it doesn't exist (nothing written to it)
        it should be created, otherwise, the changes should only be appended to the file. 
        A hash of the working file should be created in order to compare this with the original file upon exit. 
        """
    
        #make a copy of ALL rxg files if they don't exist. Otherwise, Gndat won't interpret the log correctly on reload
        for rxg in RXG_LIST:
            rxg_work = self.nameWorkingRXG(rxg)
            if not os.path.isfile(rxg_work):
                self.copyRXGFile(rxg)
        
        """if mode is gain_elev, read tcal table from original rxg file and update the tcal-table in the working rxg file, 
        update the gain polynomial (if polyfit) and update the DPFUs
        
        if mode is tcal_freq, update tcal table at each frequency
        
        if mode is tsys-tspill_airmass, update trec
        """
        
        working_rxg = open(WORKING_RXG_FILE, 'r')
        working_rxg_data = working_rxg.readlines()#self.extractMostRecent(working_rxg.readlines())
        working_rxg.close()
        working_rxg_data_updated = working_rxg_data[:]
        
        pol = self.getPolarization()
        if pol == 'l':
            pol_id = 'lcp'
        elif pol == 'r':
            pol_id = 'rcp'
        
        dpfu_line_lr_found = 0
        dpfu_line_rl_found = 0
        
        dpfu_order = 0
        dpfu_line_set = 0
        trec_line_found = 0
        for (i,data) in enumerate(working_rxg_data):
            if data[0] != '*':
                try:
                    data = self.removeDoubleSpace(data)
                    if mode == 'gain_elev':
                        ##############update dpfu:
                        if self.working_data.has_key('dpfu') and dpfu_order:
                            dpfu = self.working_data.get('dpfu')
                            ldata = data.split()
                            for j,pol_in_rxg in enumerate(dpfu_order):
                                if pol_in_rxg == pol_id:
                                    ldata[j] = dpfu
                            working_rxg_data_updated[i] = self.stringList(ldata) + '\n'
                            working_rxg_data_updated[i] = '%s\n' % working_rxg_data_updated[i].strip()
                            dpfu_order = 0
                        elif (data[:3] == 'lcp' or data[:3] == 'rcp') and not dpfu_line_set:
                            dpfu_order = data.split()
                            dpfu_line_set = 1
                        ################update gain polynomial
                        if self.working_data.has_key('gain_poly') and (data[:9] == 'ELEV POLY' or data[:10] == 'ALTAZ POLY'):
                            gain_poly = self.working_data.get('gain_poly')[0]
                            mode = self.working_data.get('gain_poly')[1] #ELEV or ALTAZ
                            opac_cor = self.working_data.get('gain_poly')[2]
                            gain_poly.reverse()
                            #string polynomial
                            str_out = '%s POLY ' % mode
                            for poly in gain_poly:
                                str_out += str(poly) + ' '
                            str_out = str_out.strip()
                            if opac_cor:
                                str_out += ' opacity_corrected'
                            working_rxg_data_updated[i] = str_out + '\n'
                        #################update TCal table:
                        if self.working_data.has_key('tcal_factor') and (data[:3] == pol_id):
                            #check length, otherwise, might be 'lcp rcp'
                            ldata = data.split()
                            if len(ldata) == 3:
                                factor = self.working_data.get('tcal_factor')
                                old_tcal = float(ldata[2])
                                new_tcal = old_tcal/(1+factor)
                                working_rxg_data_updated[i] = '%s %s %s\n' %(ldata[0], ldata[1], new_tcal)
    
                    elif mode == 'tsys-tspill_airmass':
                        if self.working_data.has_key('trec') and trec_line_found:
                            ldata = data.split()
                            trec = self.working_data.get('trec')
                            if pol == 'l':
                                out = '%s %s\n' % (trec, ldata[1])
                            elif pol == 'r':
                                out = '%s %s\n' % (ldata[0], trec)
                            working_rxg_data_updated[i] = out
                            trec_line_found = 0
                        elif (working_rxg_data[i].strip() == 'end_tcal_table'):
                            trec_line_found = 1
                                
                except (IndexError, ), e:
                    pass
            
        if mode == 'tcal_freq':
            if self.working_data.has_key('tcal_freq_table'):
                m = len(working_rxg_data_updated)
                first_id = m
                for i in range(m):
                    if working_rxg_data[i][:3] == pol_id:
                        tmp = working_rxg_data[i].split()
                        if len(tmp) == 3:
                            working_rxg_data_updated.remove(working_rxg_data[i])
                            first_id = min(first_id, i)
                #insert tcal freq table starting at first_id
                freq_data = self.working_data.get('tcal_freq_table')[0]
                tcal_data = self.working_data.get('tcal_freq_table')[1]
                for i in range(len(freq_data)):
                    out = '%s %s %s\n' % (pol_id, freq_data[i], tcal_data[i])
                    working_rxg_data_updated.insert(first_id, out)
                    first_id += 1 
        
        working_rxg = open(WORKING_RXG_FILE, 'w')
        working_rxg.writelines(working_rxg_data_updated)
        working_rxg.close()
        
        #reload rxg-file
        pid = os.getpid()
        indices = self.plot.data_indices[:]
        self.open(pid, self.open_logfile)
        self.matchRXG(indices)
        #delete old fits
        self.plot.delete('line')
        #update plot
        self.prepPlot()
        
    def extractMostRecent(self, data):
        """extractMostRecent cycles through the rxg files. After the last non comment line, it stops. 
        Thus, all comments BEFORE the last non comment line will be saved. 
        """
        for i,line in enumerate(data):
            if line[0] != '*':
                stop_line = i
        return_data = data[:i+1]
        return return_data
    
    def copyRXGFile(self, rxg_filename):
        """Copies the original rxg file to a working copy with all information commented out. 
        """
        original_filename = self.getOriginalRXGName(rxg_filename)
        original_rxg = open(original_filename, 'r')
        working_filename = self.nameWorkingRXG(rxg_filename)

        working_rxg = open(working_filename, 'w')
        data = original_rxg.readlines()
        nonComments = self.extractMostRecent(data)
        for i in range(len(data)):
            if data[i][0] != '*':
                data[i] = data[i].rjust(len(data[i])+1, '*')
        
        #leave record in log
        todays_date = time.localtime()
        record = ['* RXG file updated by GnPlt2 on %s-%s-%s\n' % (todays_date[0], todays_date[1], todays_date[2])]
        final = record + nonComments + data
        working_rxg.writelines(final)
        original_rxg.close()
        working_rxg.close()
        
    def drawTcalFreqWorkingfile(self):
        if self.getPolarization() == 'l':
            tcal_table = TCAL_TABLE_L
        elif self.getPolarization() == 'r':
            tcal_table = TCAL_TABLE_R
        
        xdata = []
        ydata = []
        keys = tcal_table.keys() 
        keys.sort()
        
        for freq in keys:
            xdata.append(freq)
            ydata.append(tcal_table.get(freq))
        
        self.plot.drawValues(xdata, ydata, fill = 'green')
    
    def fitTcalFreq(self, mode):
        #mode == average or median
        self.plot.delete('Tcal_fit_line')
        indices = self.plot.data_indices
        tcal_table_unprocessed = {}
        
        for i in indices:
            tcal = self.database.get('TCal(K)')[i]
            freq = self.database.get('Frequency')[i]
            try:
                tcal_table_unprocessed[freq].append(tcal)
            except KeyError:
                tcal_table_unprocessed[freq] = [tcal]
      
        #keys in tcal_table_unprocessed are frequencies, values are all tcal data for that frequency
        tcal_table = {}
        
        xdata = []
        ydata = []
        keys = tcal_table_unprocessed.keys()
        keys.sort()
        
        for freq in keys:
            data = tcal_table_unprocessed.get(freq)
            if mode == 'median':
                tcal = self.numTools.getMedian(data)
            elif mode == 'average':
                tcal = self.numTools.getMean(data)
            xdata.append(freq)
            ydata.append(tcal)
            
        self.working_data['tcal_freq_table'] = [xdata, ydata]
        
        kw = {}
        kw['tags'] = ('Tcal_fit_line',)
        
        self.plot.drawValues(xdata, ydata, **kw)
        
    def showStatistics(self):
        top = Toplevel()
        top.resizable(width = 0, height = 0)
        Label(top, textvariable = self.statistics).pack(pady = 10, padx = 10)
        Button(top, text = 'Ok', command = lambda: top.destroy()).pack(pady = 2)    
    
    def fitTrec(self, Tatm, time_interval, tot_time_diff, _a = None):
        
        self.plot.delete_old_trec()
        
        time_interval = float(time_interval)
        tot_time_diff = float(tot_time_diff)
        Tatm = float(Tatm)
        number_of_segments = int(tot_time_diff/time_interval+1)
        
        xdata = []
        ydata = []
        for i in range(number_of_segments):
            xdata.append([])
            ydata.append([])
        
        first_time = self.database.get('Time')[self.plot.data_indices[0]] #first time
        segment = 0
        
        for i in self.plot.data_indices:
            timediff = self.numTools.getTimeDiff(self.database.get('Time')[i], first_time)
            if timediff>time_interval:
                first_time = self.database.get('Time')[i]
                segment += 1
            xdata[segment].append(self.database.get(self.plot.xname)[i])
            ydata[segment].append(self.database.get(self.plot.yname)[i])
        if self.getPolarization() == 'l':
            Trec = TREC_L
        elif self.getPolarization() == 'r':
            Trec = TREC_R
        
        trec_computed = []
        
        statistics = ''
        max_x = self.plot.maxX
        
        no_conv = 0
        
        for i in range(number_of_segments):
            if len(xdata[i])>2 and len(ydata[i])>2:
                xlist = xdata[i]
                ylist = ydata[i]
                
                try:
                    [Trec, tau, sigma_trec, sigma_tau, points] = self.numTools.solveForTrec(xlist, ylist, Tatm)
                    trec_computed.append(Trec)
                    y_fit = []
                    x= 0
                    xvec = []
                    
                    while x<max_x:
                        xvec.append(x)
                        y_fit.append(Trec + Tatm*(1-math.exp(-tau*x)))
                        x+=0.01
                    
                    self.plot.drawValues(xvec, y_fit, fill = 'black')
                    
                    statistics += 'Segment %s: Trec = %.1f, sigma = %.2f, #points = %s\n\n' % (i, Trec, sigma_trec, points)
                except NonConvergenceError:
                    no_conv = 1
                    self.status.set('Error: Segment %s did not converge' % i)
        
        for trec in trec_computed:
            self.plot.create_trec_point(trec)
        
        if not no_conv:
            if not trec_computed:
                status = 'Error: Trec has not been computed. Data set might be too small(<3). Try increasing time interval. '    
            else:
                status = 'Trec has succesfully been computed'
            
            self.status.set(status)
            
        self.statistics.set(statistics)
        
        self.recalcTrec()
    
    
    def recalcTrec(self):
        trec_list = []
        for item in self.plot.find_withtag('trec_point'):
            tags = self.plot.gettags(item)
            trec = float(tags[2])
            status = tags[1]
            if status == 'normal':
                trec_list.append(trec)
        if len(trec_list)>0:
            avg_trec = sum(trec_list)/len(trec_list)
            self.plot.delete('trec_marker')
            self.plot.delete('trec_text')
            self.plot.create_trec_marker(avg_trec)
            self.working_data['trec'] = avg_trec
            self.status.set('Average Trec: %.2f' % avg_trec)
            
    
    def _fitTrecOptions(self):
        #time_interval:
        timediff = StringVar()
        first_time = self.database.get('Time')[self.plot.data_indices[0]]
        last_time = self.database.get('Time')[self.plot.data_indices[-1]]
        time = self.numTools.getTimeDiff(last_time, first_time)
        timediff.set('%.2f hours' % (time))
        
        top = Toplevel()
        top.title('Select Interval and Tatm')
        
        Label(top, text = 'Please select Tatm (K)').grid(row = 0, column = 0, padx = 5, pady = 5)
        Label(top, text = 'Please select time interval for fit (hours):').grid(row = 1, column = 0, padx = 5, pady = 5)
        Label(top, text = 'Total time range of selected points').grid(row = 2, column = 0, padx = 5, pady = 5)
        Tatm = Entry(top, width = 5, textvariable = self.default_Tatm)
        Tatm.grid(row = 0, column = 1, padx = 5, pady = 5)
        time_interval = Entry(top, width = 5)
        time_interval.grid(row = 1, column = 1, padx = 5, pady = 5)
        time_interval.insert(0, 1)
        Label(top, textvariable = timediff).grid(row = 2, column = 1, padx = 5, pady = 5)
        bframe = Frame(top)
        bframe.grid(row = 3, column = 0, columnspan = 2)
        Button(bframe, text = 'Ok', command = lambda: self.fitTrec(Tatm.get(), time_interval.get(), time, top.destroy())).pack(side = LEFT)
        Button(bframe, text = 'Cancel', command = lambda: top.destroy()).pack(side = LEFT)
        
    def markTrecFromFile(self):
        """marks the Trec from the rxg file on the plot
        """
        pol = self.getPolarization()
        if pol == 'r':
            trec = TREC_R
        elif pol == 'l':
            trec = TREC_L
        
        self.plot.create_trec_marker(trec)
    
    def _addVirtPointClick(self, event):
        if self.selectedX.get() == 'Elevation' and self.selectedY.get() == 'Gain':
            canvx = event.x
            canvy = event.y
            x = self.plot.getCartesianX(canvx)
            y = self.plot.getCartesianY(canvy)
            self.addVirtualPoint(x,y)
    
    def addVirtualPoint(self, startx = 0.0, starty = 0.0):
        """addVirtualPoint adds an extra point to the plot to weight the polynomial a certain way. 
        The point is given an integer weight, which is the number of extra points added to the same x,y coordinates. 
        """
        top = Toplevel()
        top.resizable(width = 0, height = 0)
        Label(top, text = 'x:').grid(row = 0, column = 0, padx = 5, pady = 3)
        x = Entry(top, width = 8)
        x.grid(row = 0, column = 1, padx = 5, pady = 3)
        x.insert(0, startx)
        Label(top, text = 'y:').grid(row = 1, column = 0, padx = 5, pady = 3)
        y = Entry(top, width = 8)
        y.grid(row = 1, column = 1, padx = 5, pady = 3)
        y.insert(0, starty)
        Label(top, text = 'weight:').grid(row = 2, column = 0, padx = 5, pady = 3)
        weight = Spinbox(top, width = 6, from_ = 1, to = 1000)
        weight.grid(row = 2, column = 1, padx = 5, pady = 3)
        bframe = Frame(top)
        bframe.grid(row = 3, column = 0, columnspan = 2, padx = 2, pady = 3)
        Button(bframe, text = 'Ok', command = lambda: self.plot.drawVirtualPoint(x.get(), y.get(), weight.get(), top.destroy())).pack(side = LEFT, padx = 2)
        Button(bframe, text = 'Cancel', command = lambda: top.destroy()).pack(side = LEFT, padx = 2)
    
    def computeOpacityFactor(self, indices = None):
        try:
            Tatm = int(self.default_Tatm.get())
            if not indices:
                indices = self.plot.data_indices
        except ValueError:
            self.status.set('Error: Incorrect input for Tatm')
        except AttributeError:
            self.status.set('Error: No data selected. Please plot something to set data interval')
        else:
            #match indices with band:
            #cycle through data, get LO and polarization to match with the right trec
            TREC = 0
            #make sure pre_opacity_corrected_gain is used
            self.database['Gain'] = self.pre_opacity_corrected_gain[:]
            self.database['TCal(K)'] = self.pre_opacity_corrected_tcal[:]
            self.database['TCal Ratio'] = self.pre_opacity_corrected_tcal_ratio[:]

            for rxg in Gui.opacity_correction.keys():
                data = Gui.opacity_correction.get(rxg).get()
                info = self.rxg_file_information.get(rxg)
                trec_l = info[2]
                trec_r = info[3]
                lo_range = info[7]
                LO_low = lo_range[0]
                LO_high = lo_range[1]
                mode = lo_range[-1]
                
                for i in indices:
                    LO = self.database.get('LO')[i]
                    pol = self.database.get('Polarization')[i]
                    tsys_tspill = self.database.get('Tsys-Tspill')[i]
                    
                    if (mode == 'fixed' and (LO == LO_low or LO == LO_high)) or (mode == 'range' and (LO<=LO_high and LO>= LO_low)):
                        if pol == 'l':
                            TREC = trec_l
                        elif pol == 'r':
                            TREC = trec_r
                    
                        opacity_factor = self.numTools.getOpacity(tsys_tspill, TREC, Tatm)
                        #update database
                        if data == 'gain' or data == 'both':
                            self.database.get('Gain')[i]/=opacity_factor
                        if data == 'tcal' or data == 'both':
                            self.database.get('TCal(K)')[i]*=opacity_factor
                            self.database.get('TCal Ratio')[i]/opacity_factor
                    
            #copy corrections to plot
            self.plot.database = self.database
            #redraw if gain is plotted
            if self.plot.yname == 'Gain' or self.plot.yname == 'TCal(K)':
                self.plot.reDrawAll()
    
    def getTrecLOList(self, req_rxg_list = None):
        if not req_rxg_list:
            req_rxg_list = RXG_LIST    
        trec_lo_list = []
        for rxg in req_rxg_list:
            mode = RXG_LIST.get(rxg)[0]
            LO_low = RXG_LIST.get(rxg)[1]
            LO_high = RXG_LIST.get(rxg)[2]
            [trec_l, trec_r] = self.rxg_file_information.get(rxg)[2:4]
            trec_lo_list.append([mode, LO_low, LO_high, trec_l, trec_r])
        return trec_lo_list
    
    def drawTcalRatioUnity(self):
        """Draws a line in a tcal ratio vs anything plot at y=1. 
        If the tcal data is correct, the tcal ratio should be centered around the line at y=1. 
        """
        #draw line at y = 1
        poly = [1]
        self.plot.drawFittedLine(poly)
    
    def setTatm(self):
        top = Toplevel()
        top.resizable(width = 0, height = 0)
        Label(top, text = 'Set Tatm').pack(padx = 10, pady = 5)
        Tatm = Entry(top, width = 8, textvariable = self.default_Tatm)
        Tatm.pack(padx = 10, pady = 5)
        bframe = Frame(top)
        bframe.pack()
        Button(bframe, text = 'Ok', command = lambda: top.destroy()).pack(padx = 10, pady = 5)
    
    def computeZenithOpacity(self):
        try:
            Tatm = int(self.default_Tatm.get())
        except ValueError:
            Tatm = 290
        tsys_tspill_list = self.database.get('Tsys-Tspill')[:]
        trec_lo_list = self.getTrecLOList()
        zenith_opacity = []
        
        for i,tsys_tspill in enumerate(tsys_tspill_list):
            LO = self.database.get('LO')[i]
            pol = self.database.get('Polarization')[i]
            airmass = self.database.get('Airmass')[i]
            for j in range(len(trec_lo_list)):
                [mode, LO_low, LO_high, trec_l, trec_r] = trec_lo_list[j]
                if (mode == 'fixed' and (LO == LO_low or LO == LO_high)) or (mode == 'range' and (LO<=LO_high and LO>= LO_low)):
                    if pol == 'l':
                        TREC = trec_l
                    else:
                        TREC = trec_r
                    break
            opacity_factor = self.numTools.getOpacity(tsys_tspill, TREC, Tatm)
            #opacity factor is exp(tau*airmass)
            try:
                zenith_opacity.append(-math.log(opacity_factor)/airmass)
            except ValueError:
                try:
                    zenith_opacity.append(zenith_opacity[-1])
                except IndexError:
                    zenith_opacity.append(0.0)
            
        
        self.database['Zenith Opacity'] = zenith_opacity
        self.plot.database['Zenith Opacity'] = zenith_opacity
        
        self.prepPlot()
    
    
    def preStartSimulation(self):
    	""" Start simulation"""
    	try:
    		self.simWin.lift()
    	except:
    		self.startSimulation()	
    
    def startSimulation(self):
    	""" Creates simulation window """
    	self.simWin = Toplevel()
	self.simWin.title('Simulation')
    	
	global SIM_GAIN_ELEV_POLY
	SIM_GAIN_ELEV_POLY = []
	SIM_GAIN_ELEV_POLY.extend(GAIN_ELEV_POLY)
	self.al = StringVar()
    	self.bl = StringVar()
    	self.cl = StringVar()
    	self.dl = StringVar()
	self.simselectedX = StringVar()
	self.tcal_in_use = []
	
	Label(self.simWin, bg = 'white', relief = GROOVE, text = '\nWINDOW MUST BE OPENED DURING THE ENTIRE SIMULATION! \n\nThis window generates simulated data for Tcal(Jy). Select for which polarization, source and frequency you want the data to be generated. \n It is possible to select multiple sources and frequencies. Default the gain versus Elevation or Altaz will be plotted, \n but the TCal(Jy) can, if selected, be plotted as well. Default values in this window are from the RXG file.\n ').grid(row = 0, columnspan = 4, column = 0)
	Label(self.simWin, text = 'Plot:').grid(row = 1, column = 0)
	
	Label(self.simWin, text = 'Choose polynomial degree (n): ').grid(row = 3, columnspan = 1, column = 0)
	self.SIM_degree  = Entry(self.simWin)
	self.SIM_degree.grid(row = 3, column = 1)
	self.SIM_degree.insert(0, 2)
	self.SIM_degree.bind("<Return>", self.makePolyEntries)
	
 	Label(self.simWin, text = 'Choose left and right DPFU: ').grid(row =7, columnspan = 1, column = 0)
	self.SIM_dpfuL  = Entry(self.simWin)
	self.SIM_dpfuL.grid(row = 7, column = 1)
	self.SIM_dpfuR  = Entry(self.simWin)
	self.SIM_dpfuR.grid(row = 7, column = 2)
	self.resetDPFU()
		
	if SIM_GAIN_ELEV_POLY[1] == 'ELEV':
		self.selectedX.set('Elevation')
		self.simselectedX.set('Elevation')
	else:
		self.selectedX.set('Altaz')
		self.simselectedX.set('Altaz')
	radio1 = Radiobutton(self.simWin, text = 'Elevation', variable = self.simselectedX, value = 'Elevation')
	radio2 = Radiobutton(self.simWin, text = 'Altaz', variable = self.simselectedX, value = 'Altaz')
	Label(self.simWin, text = 'Polynomial form:').grid(row = 2, columnspan = 1, column = 0)
	radio1.grid(row = 2, column = 1 )
	radio2.grid(row = 2, column = 2)
	
	Label(self.simWin, text = 'Choose your gain curve polynomial; y = ax^(n) + bx^(n-1) +cx^(n-2)+ ...').grid(row = 4, columnspan = 2, column = 0)
			
	self.buildEntries()
			
	self.plotWhat = StringVar()
	Radiobutton(self.simWin, text = 'Gain', variable = self.plotWhat, value = 'Gain', anchor = W).grid(row = 1, column = 1)
	Radiobutton(self.simWin, text = 'TCal(K) \nvs. Frequency', variable = self.plotWhat, value = 'TCal(K)', anchor = E).grid(row = 1, column = 2)
	self.plotWhat.set('Gain')
	
	Label(self.simWin, text = 'Choose source/sources:').grid(row = 9, column = 0)
	self.sourceSelected = []
	self.sourceName = []
	name = StringVar()
	uniqueSource = sorted(self.getUnique(self.database['Source']))
	ii=0
	for i,source in enumerate(uniqueSource):
		if i >=3: ii = 1
		name = source
		source= IntVar()
		Checkbutton(self.simWin, text = name, variable = source).grid(row=9 +ii, column =  (i + 1 - 4*ii))
		self.sourceName.append(name)
		self.sourceSelected.append(source)
		source.set(1)
	
	self.polVar = StringVar()
	Label(self.simWin, text = 'Choose polarization:').grid(row = 8, column = 0)
	self.sim_lpol = Radiobutton(self.simWin, text = 'Left', variable = self.polVar, value = 'l')
	self.sim_rpol = Radiobutton(self.simWin, text = 'Right', variable = self.polVar, value = 'r')
	self.sim_lpol.grid(row = 8, column = 1)
	self.sim_rpol.grid(row = 8, column = 2)
	
	self.polVar.set('l')
	if not 'r' in self.database['Polarization']:	
		self.sim_rpol.config(state = DISABLED)
		self.polVar.set('l')
	if not 'l' in self.database['Polarization']:
		self.sim_lpol.config(state = DISABLED)
		self.polVar.set('r')
	
	self.selectAll = IntVar()
	Label(self.simWin, text = 'Select frequencies:').grid(row = 10 + ii, column = 0)
	Checkbutton(self.simWin, text = 'Select all/none frequencies available \nfor the choosen polarization ', variable = self.selectAll, anchor = N, command = lambda: self.selectAllFreq()).grid(row = 10 + ii, column = 1)
	Button(self.simWin, text = 'Select available frequencies \nfor the choosen polarization', command = lambda: self.chooseFreq(window=1)).grid(row = 10 + ii, column = 2)
	
	self.noise = IntVar()
	Checkbutton(self.simWin, text = 'Add noise (in percentage)', variable = self.noise).grid(row = 11  + ii, column = 0)
	self.SIM_noise  = Entry(self.simWin)
	self.SIM_noise.grid(row = 11 + ii, column = 1)
	self.SIM_noise.insert(0, 0)	
		
	Button(self.simWin, text = 'Generate and plot data', command = lambda: self.runSimulation()).grid(row = 15 + ii, column = 1)
	Button(self.simWin, text = 'Close', command = lambda: self.endSimulation()).grid(row = 15 + ii, column = 2)
	#Button(self.simWin, text = 'Reset DPFU', command = lambda: self.resetDPFU()).grid(row = 9, column = 1)
	Button(self.simWin, text = 'Edit TCal(K) table', command = lambda: self.editTCalTable()).grid(row = 15 + ii, column = 0)
	Button(self.simWin, text = 'Normalize polynomial', command = lambda: self.calcMaxGain()).grid(row = 3 , column = 2)
	
    def chooseFreq(self, window = None):
    	""" Window for choosing frequencies"""
    	if not self.polVar.get():
    		tkMessageBox.showinfo('Message', 'Please select a polarization.')
    		self.simWin.lift()
    	else:
	    	try:
    			self.simFreq.lift()
    			self.simFreq.focus_set()
    		except:
    			if window:
    				self.selectAll.set(0)
    			self.simFreq = Toplevel()	
    			self.simFreq.title('Choose Frequencies')
    			left = IntVar()
    			right = IntVar()
    			lfreq = []
    			rfreq = []
    			self.freqVariables = {}
    			uniqueFreq = sorted(self.getUnique(self.database['Frequency']))
			for freq in uniqueFreq:
				for i in range(len(self.database['Frequency'])):
					if freq == self.database['Frequency'][i]:
						if self.database['Polarization'][i] == 'l' and self.polVar.get() == 'l':
							left.set(1) 
						if self.database['Polarization'][i] == 'r' and self.polVar.get() == 'r':
							right.set(1)
				if right.get():
					rfreq.append(freq)
				if left.get():
					lfreq.append(freq)
				left.set(0)
				right.set(0)
			column = row =1
			freqList = []
			if self.polVar.get() == 'l':
				Label(self.simFreq, text = 'Left').grid(column = 1, row =0)
				freqList = lfreq[:]
			elif self.polVar.get() == 'r':
				Label(self.simFreq, text = 'Right').grid(column = 1, row =0)
				freqList = rfreq[:]
			for freq in freqList:
				name = freq
				freq = DoubleVar()
				if row == 15: 	
					column += 1
					row = 1
				Checkbutton(self.simFreq, text =name, variable = freq).grid(row = row, column = column)
				row += 1
				try:
					if self.simSelectedFreq:
						if name in self.simSelectedFreq:
							freq.set(1)
				except: pass
				if self.selectAll.get():
					freq.set(1)
				self.freqVariables[name] = freq
    			Button(self.simFreq, text = 'Ok', command = lambda: self.closeFreq()).grid(row = 31 , column = column)
    			if self.selectAll.get():
    				self.simFreq.destroy()
    				
    def selectAllFreq(self):
    	""" Selects all frequencies"""
    	if not self.selectAll.get():
		self.unselectAll()
    	self.chooseFreq()
	self.closeFreq()

    def unselectAll(self):
    	""" Unselects all frequencies"""
    	self.simSelectedFreq =[]
   	for freq in self.freqVariables.keys():
   		self.freqVariables[freq].set(0)
   		
    def closeFreq(self):
    	""" Saves the choice of frequencies"""
    	self.simSelectedFreq = []
    	try: 
    		for freq in self.freqVariables.keys():
    			if not self.selectAll.get():
    				if self.freqVariables.get(freq).get():
    					self.simSelectedFreq.append(freq)
    				if len(self.freqVariables.keys()) == len(self.simSelectedFreq):
    					self.selectAll.set(1)
    			else:
    				self.simSelectedFreq.append(freq)
    	except: 
    		self.selectAll.set(0)
    	try: self.simFreq.destroy()
    	except: pass
    	self.simWin.lift()    	

    def runSimulation(self):
    	"""Runs the simulation
    	"""
    	self.selectedX.set(self.simselectedX.get())
	self.database['Altaz'] = [0 for i in range(len(self.database.get('Elevation')))]
	self.plot.database['Altaz'] = [0 for i in range(len(self.database.get('Elevation')))]
	for i, angle in enumerate(self.database['Elevation']):
		self.database['Altaz'][i] = (90-angle)
		self.plot.database['Altaz'][i] = (90-angle)
	
	self.simGenerateData()
	if not self.do_not_plot.get():
		self.prepPlot()
	
    def endSimulation(self):
    	""" Quit """
    	if self.simulation.get():
    		if tkMessageBox.askyesno("Notification", "This will exit the simulation, delete all simulated data and reread the log file. Are you sure you want to continue?"):
    			self.focus_set()
   	     		self.simWin.destroy()
        		try: self.simTable.destroy()
        		except: pass
        		self.cleanUp(quit = 1)
       	 		self.simulation.set(0)
        		self.sim_useTcal.set(0)
        		self.open(0, self.open_logfile)
        	else: 
        		self.simWin.lift()
      	else:
      		self.focus_set()
   	     	self.simWin.destroy()
        	try: self.simTable.destroy()
        	except: pass
      
    def makePolyEntries(self, event):
    	self.buildEntries()	
    	
    def buildEntries(self):
    	""" Build entries for polynomial"""
    	try:
    		self.a.destroy()
    		self.b.destroy()
    		self.c.destroy()
    		self.d.destroy()
    	except:
    		pass
    	self.al.set(' ')
    	self.bl.set(' ') 
    	self.cl.set(' ')
    	self.dl.set(' ')
    	n = int(self.SIM_degree.get())
    	for i in range(n+1):
		if i == 0 :
			self.a = Entry(self.simWin)
			self.a.grid(column = (n-i), row = 6)
			self.al.set('a')
			try:
				if aLabel.winfo_exists():
					pass
			except:	
				aLabel = Label(self.simWin, textvariable = self.al).grid(row =5, column = 0)
			if (len(SIM_GAIN_ELEV_POLY[0])-1-i) >= 0:
				self.a.insert(0, SIM_GAIN_ELEV_POLY[0][len(SIM_GAIN_ELEV_POLY[0])-1-i])
			else:
				self.a.insert(0, 0)
		if i == 1:
			self.b = Entry(self.simWin)
			self.b.grid(column = (n-i), row = 6)
			self.bl.set('b')
			try:
				if bLabel.winfo_exists():
					pass
			except:	
				bLabel = Label(self.simWin, textvariable = self.bl).grid(row =5, column = 1)
			if (len(SIM_GAIN_ELEV_POLY[0])-1-i) >= 0:
				self.b.insert(0, SIM_GAIN_ELEV_POLY[0][len(SIM_GAIN_ELEV_POLY[0])-1-i])
			else:
				self.b.insert(0, 0)
		if i == 2:
			self.c = Entry(self.simWin)
			self.c.grid(column = (n-i), row = 6)
			self.cl.set('c')
			try:
				if cLabel.winfo_exists():
					pass
			except:	
				cLabel = Label(self.simWin, textvariable = self.cl).grid(row =5, column = 2)
			if (len(SIM_GAIN_ELEV_POLY[0])-1-i) >= 0:
				self.c.insert(0, SIM_GAIN_ELEV_POLY[0][len(SIM_GAIN_ELEV_POLY[0])-1-i])
			else:
				self.c.insert(0, 0)
		if i == 3:
			self.d = Entry(self.simWin)
			self.d.grid(column = (n-i), row = 6)
			self.dl.set('d')
			try:
				if dLabel.winfo_exists():
					pass
			except:	
				dLabel = Label(self.simWin, textvariable = self.dl).grid(row =5, column = 3)
			if (len(SIM_GAIN_ELEV_POLY[0])-1-i) >= 0:
				self.d.insert(0, SIM_GAIN_ELEV_POLY[0][len(SIM_GAIN_ELEV_POLY[0])-1-i])
			else:
				self.d.insert(0, 0)
		if i >= 4:	
			tkMessageBox.showinfo('Message', 'The max degree of polynomial is 3')
			self.SIM_degree.delete(0, END)
			self.SIM_degree.insert(0, 3)
			self.buildEntries()
			self.simWin.lift()
			break

 	#IS NOT USED
    def resetPoly(self):
    	""" Reset to what is in working file"""
     	del SIM_GAIN_ELEV_POLY[:]
	SIM_GAIN_ELEV_POLY.extend(GAIN_ELEV_POLY)
     	try:
     		self.a.delete(0, END)
		self.b.delete(0, END)
		self.c.delete(0, END)
	except:
		pass
     	self.SIM_degree.delete(0,END)
     	self.SIM_degree.insert(0, len(GAIN_ELEV_POLY[0]) - 1)
     	self.buildEntries() #poly = SIM_GAIN_ELEV_POLY)
     
     #IS NOT USED
    def resetDPFU(self):
    	""" Reset to what is in working file"""
    	self.SIM_DPFU_R = DPFU_R
	self.SIM_DPFU_L = DPFU_L
	self.SIM_dpfuL.delete(0,END)
	self.SIM_dpfuR.delete(0,END)
     	self.SIM_dpfuL.insert(0, self.SIM_DPFU_L)
     	self.SIM_dpfuR.insert(0, self.SIM_DPFU_R)
     
    def setSimPoly(self, **kw):
    	""" Set the polynomial to what's in the entry fields"""
    	SIM_GAIN_ELEV_POLY[0] = []
    	if kw.get('choice') == 'calc' :
    		SIM_GAIN_ELEV_POLY[0].extend(kw.get('poly'))
    		self.buildEntries() 
    	else:
    		try:
    			SIM_GAIN_ELEV_POLY[0].insert(0, float(self.a.get()))
         		SIM_GAIN_ELEV_POLY[0].insert(0, float(self.b.get()))
         		SIM_GAIN_ELEV_POLY[0].insert(0, float(self.c.get()))
         		SIM_GAIN_ELEV_POLY[0].insert(0, float(self.d.get()))
		except:
			pass
    
    def setDPFU(self):
    	""" Set the DPFU to what's in the entry fields"""
    	self.SIM_DPFU_L =  float(self.SIM_dpfuL.get())
    	self.SIM_DPFU_R = float(self.SIM_dpfuR.get())
    	
    def simGenerateData(self, sel_x = None, sel_y = None):
    	""" Generates the data.
    		"""
    	#Set a flag to know that it is generated data
    	self.simulation.set(1)
    	self.do_not_plot.set(0)
    	#Set what is going to be plotted
    	if sel_y:
    		pass
    	else:  		
    		self.selectedY.set(self.plotWhat.get())
    		if self.plotWhat.get() == 'TCal(K)':
    			self.selectedX.set('Frequency')
		elif self.plotWhat.get() == 'Gain':
			self.selectedX.set(self.simselectedX.get())
	#Look for what data choosen to be generated
	self.simSelectedData()
	#Set SIM_GAIN_ELEV_POLY to what the user has entered
	self.setSimPoly()
	#Set DPFU to what the user has entered
	self.setDPFU()
	## Generate the data  
	# Assumed TCal(K)
    	if self.sim_useTcal.get():
    		self.useTcalTable()
    	for i,index in enumerate(self.sim_data_indices):
    		#Gain
    		if self.database['Polarization'][index] == 'l':
    			dpfu = self.SIM_DPFU_L
    		elif self.database['Polarization'][index] == 'r':
			dpfu = self.SIM_DPFU_R	
    		data = self.plot.evalPoly(SIM_GAIN_ELEV_POLY[0], self.database[self.simselectedX.get()][index]) * dpfu 
    		self.database['Gain'][index] = data
    		self.plot.database['Gain'][index] = data
    		#TCal(Jy)
    		if self.noise.get(): 
    			data = self.database['Assumed TCal(K)'][index] / ( dpfu * self.plot.evalPoly(SIM_GAIN_ELEV_POLY[0], self.database[self.simselectedX.get()][index])) * (1 +  (random.random() * float(self.SIM_noise.get()) /100))
    			self.database['TCal(Jy)'][index] = data
    			self.plot.database['TCal(Jy)'][index] = data
    		else:
    			data = self.database['Assumed TCal(K)'][index] / ( dpfu * self.plot.evalPoly(SIM_GAIN_ELEV_POLY[0], self.database[self.simselectedX.get()][index]))
    			self.database['TCal(Jy)'][index] = data
    			self.plot.database['TCal(Jy)'][index] = data
    		#TCal(K)
    		data = self.database['TCal(Jy)'][index] * self.database['Assumed DPFU*Gain Curve'][index]
    		self.database['TCal(K)'][index] = data
    		self.plot.database['TCal(K)'][index] = data
    		#TCal Ratio
    		data = self.database['TCal(K)'][index]  / self.database['Assumed TCal(K)'][index]
    		self.database['TCal Ratio'][index] = data
    		self.plot.database['TCal Ratio'][index] = data
    		#Tsys
    		data = self.database['Tsys'][index] * self.database['TCal(K)'][index]  / self.database['Assumed TCal(K)'][index]
    		self.database['Tsys'][index] = data
    		self.plot.database['Tsys'][index] = data
    				
    def simSelectedData(self):
    	""" Sets indices based on GUI """
    	self.sim_data_indices =[]
    	try:
    		if self.simSelectedFreq == []:
    			tkMessageBox.showinfo('Message', 'Please select at least one frequency.')
    			self.simWin.focus_set()
    			self.simWin.lift()
    		temp = 0
   	 	for source in self.sourceSelected:
    			temp += source.get()
    		if not temp:	
    			tkMessageBox.showinfo('Message', 'Please select at least one source.')
    			self.simWin.focus_set()
    			self.simWin.lift()
    		pol = self.polVar.get()
    		for index in range(len(self.database['Frequency'])):
    			for i, source in enumerate(self.sourceSelected):
    				if self.database['Frequency'][index] in self.simSelectedFreq and source.get() and self.database['Source'][index] == self.sourceName[i]:
    					if self.database['Polarization'][index] == 'l' and pol == 'l':
    						self.sim_data_indices.append(index)
					elif self.database['Polarization'][index] == 'r' and pol == 'r':
    						self.sim_data_indices.append(index)
    					elif pol == 'both':
    						self.sim_data_indices.append(index)
		#set the indices for the program so that after a simulation, the program should plot the 
		#data just as it had been selected from the edit menu.
		self.selectAllSources(SOURCES_LIST, 0)
        	self.selectAllFrequencies('both', 0)
        
        	selectedSource = []
        	for i, source in enumerate(self.sourceSelected):
    			if source.get():
    				selectedSource.append(self.sourceName[i])
    				
        	self.selectAllSources(selectedSource, 1)
        	#Create a list with all detectors 
        	listDetectors = {}
        	for det in self.database['Detector']:
        		listDetectors[det] = 0
        	listDetectors = listDetectors.keys()		     
        	# Set the self.frequencies_chosen
        	for freq in self.simSelectedFreq:
        		for det in listDetectors:
        			try:
        				if pol == 'both':
        					try:
        						fdp = '%s %s %s' % (freq, det, 'r')
        						self.frequencies_chosen[fdp].set(1)
        					except:
        						pass
        					fdp = '%s %s %s' % (freq, det, 'l')
        					self.frequencies_chosen[fdp].set(1)
					else:
						fdp = '%s %s %s' % (freq, det, pol)
       	 					self.frequencies_chosen[fdp].set(1)                
        			except: pass
       	except:
    		tkMessageBox.showinfo('Message', 'Please select at least one frequency.')
    		self.do_not_plot.set(1)
    		self.simWin.focus_set()
    		self.simWin.lift()
    		
    def calcMaxGain(self):
    	""" Normalizes the polynomial"""
    	try: self.result.get()
    	except: self.result = StringVar()
    	polyList_weighted = []
    	polyList = []
    	self.setSimPoly()
    	polyList.extend(SIM_GAIN_ELEV_POLY[0])
    	for i in range(len(polyList)):
    		if polyList[i] == 0:
    			polyList.remove(i)
    		else:
    			break
    	if len(polyList) >= 3:
    		x, f = self.numTools.getMaxGain(polyList)
    		self.result.set('The polynomial has been updated. \nMaximum at x = %.1f; old f(x) = %.3f' %(x, f))
    	elif len(polyList) == 2:
    		if polyList[0] > 0:
    			freq = self.database[self.simselectedX.get()][:]
    			frequency = max(freq)
    		else:
    			freq = self.database[self.simselectedX.get()][:]
    			frequency = min(freq)
    		f = polyList[0] * frequency + polyList[1]
    		self.result.set('The polynomial has been scaled \n and updated below.')
    	elif len(polyList) == 1:
    		f = polyList[0]
    		self.result.set('The polynomial has been scaled \n and updated below.')		
    	
    	try:
    		if gainLabel.winfo_exists():
    	    		pass
    	except:
    		gainLabel = Label(self.simWin,fg="grey", bg = 'black' , textvariable = self.result).grid(row = 4, columnspan = 1, column =2)
    	
    	for i in  range(len(polyList)):
    		polyList_weighted.append(polyList[i] / f)
    	
    	self.setSimPoly(poly = polyList_weighted, choice = 'calc')
    					 
    def getUnique(self, list):
    	""" Returns an unique list"""
 	dict = {}
 	for i in list:
 		dict[i] = 0 
 	return dict.keys()
 	 
    def editTCalTable(self, freq_tcal_l = None, freq_tcal_r = None, workingfile = None):
    	""" Creates a window for editing the values of TCal(K)"""
    	global freqL, freqR, tcal_table_l, tcal_table_r
    	try: 
    		self.tcalListBoxR.delete(0, END)
    		self.tcalListBoxL.delete(0, END)
    	except:
    		self.simTable = Toplevel()
    		self.simTable.title('Edit TCal(K) table')
    	
    		Label(self.simTable, bg = 'white', relief = GROOVE, text = '\nThis window enables you to change the TCal(K) table that is used for calculating the TCal(Jy). \n The table below shows the values in use for data generation. The initial values are from the working file. \n To change these values either load a new TCal(K) file or save, edit in a text editor and load file.\n You can also re-get the values from the working file.\n').grid(row = 0, columnspan = 2, column = 0)
    		Label(self.simTable, text = 'Polarization  Frequency  TCal(K)').grid(row = 1, column = 0)
		Label(self.simTable, text = 'Polarization  Frequency  TCal(K)').grid(row = 1, column = 1)
	
		yScroll2  =  Scrollbar ( self.simTable, orient=VERTICAL )
    		yScroll2.grid ( row=2, column=1, sticky=E+N+S )
		self.tcalListBoxR = Listbox(self.simTable, selectmode = MULTIPLE, yscrollcommand = yScroll2.set) 
		self.tcalListBoxR.grid(row = 2, column = 1)
		yScroll2["command"]  =  self.tcalListBoxR.yview
		self.tcalListBoxR.config(width=26)
		
		yScroll  =  Scrollbar ( self.simTable, orient=VERTICAL )
    		yScroll.grid ( row=2, column=0, sticky=E+N+S )
		self.tcalListBoxL = Listbox(self.simTable, selectmode = MULTIPLE, yscrollcommand = yScroll.set) 
		self.tcalListBoxL.grid(row = 2, column = 0)
		yScroll["command"]  =  self.tcalListBoxL.yview
		self.tcalListBoxL.config(width=26)
		
	freqR = []
	freqL = []
	
	if self.tcal_in_use:
		freq_tcal_l = {}
		freq_tcal_r = {} 
		freq_tcal_l.update(self.tcal_in_use[0])
		freq_tcal_r.update(self.tcal_in_use[1])
				
	if (freq_tcal_l or freq_tcal_r) and not workingfile:
		freqR = freq_tcal_r.keys()[:]
		freqR.sort()	
		freqL = freq_tcal_l.keys()[:]
		freqL.sort()
		tcal_table_l = freq_tcal_l
		tcal_table_r = freq_tcal_r
	else:
		freqR = TCAL_TABLE_R.keys()[:]
		freqR.sort()	
		freqL = TCAL_TABLE_L.keys()[:]
		freqL.sort()
		tcal_table_l = TCAL_TABLE_L.copy()
		tcal_table_r = TCAL_TABLE_R.copy()
	
	for freq in freqL:
	 	string = 'lcp          %s          %s' %(freq, tcal_table_l.get(freq))
	 	self.tcalListBoxL.insert(END, string)
	for freq in freqR:
	 	string = 'rcp          %s          %s' %(freq, tcal_table_r.get(freq))
	 	self.tcalListBoxR.insert(END, string)
	
	Label(self.simTable, text = '\nYou can load a text file with a new TCal(K) table with the following format: \n Polarization Frequency TCal(K) \n e.g. lcp 4900.0 6.5. Every line started with a * will be considered as a comment. \n').grid(row = 3, column = 0, columnspan = 2)
	Button(self.simTable, text = 'Load table from file', command = lambda: self.loadTcalTable()).grid(row = 4, column = 0)  	
	Button(self.simTable, text = 'Save table to file', command = lambda: self.saveTcalTable(freqL, freqR, tcal_table_l, tcal_table_r)).grid(row = 4, column = 1) 
	Button(self.simTable, text = 'Get table from working file', command = lambda: self.getTcalTable()).grid(row = 5, column = 0)
	Button(self.simTable, text = 'OK', command = lambda: self.closeTcalTable()).grid(row = 5, column = 1) 	
	
    def closeTcalTable(self):
    	""" Closes tcal window"""
    	self.useTcalTable()
    	self.simTable.destroy()
    	self.simWin.focus_set()
    	self.simWin.lift()
    		
    def saveTcalTable(self, freqL, freqR, tcal_table_l, tcal_table_r):
    	""" Save tcal table"""
    	tcalFile = tkFileDialog.asksaveasfile(initialdir = Gui.rxg_dir)
    	if tcalFile:
    		path = tcalFile.name
    		names = path.split('/')    		
    		tcal_file = open(names[len(names)-1], 'w')
    		timeHere = time.localtime()
    		intro_text = '* Saved TCal(K) table %s-%s-%s %s:%s \n* Polarization Frequency TCal(K) \n' %(timeHere[1], timeHere[2], timeHere[0], timeHere[3], timeHere[4])
    		tcalFile.writelines(intro_text)
    		for freq in freqL:
    			line = 'lcp %s %s\n' %(freq, tcal_table_l.get(freq))
    			tcalFile.writelines(line)
    		for freq in freqR:
    			line = 'rcp %s %s\n' %(freq, tcal_table_r.get(freq))
    			tcalFile.writelines(line)
		tcal_file.close()    	
	self.simTable.lift()	

    def loadTcalTable(self):
    	""" Load tcal table"""
    	freqtcalL = {}
    	freqtcalR = {}
    	tcalFile = tkFileDialog.askopenfilename(initialdir = Gui.rxg_dir)
	if tcalFile:
		tcal_file = open(tcalFile, 'r')
		for line in tcal_file.readlines():
			if not line[0] == '*':
				line = line.split()
				try:
					if line[0] == 'lcp':
						freqtcalL[line[1]] = line[2]
					elif line[0] == 'rcp':
						freqtcalR[line[1]] = line[2]
				except: pass
		tcal_file.close()			
		self.tcal_in_use = [freqtcalL, freqtcalR]
		self.editTCalTable(freq_tcal_l = freqtcalL, freq_tcal_r = freqtcalR, workingfile=0)
	self.simTable.lift()	
	
    def useTcalTable(self):
    	""" Is called when you want to use the tcal table in the window""" 
   	self.sim_useTcal.set(1)
    	for index in range(len(self.database['Assumed TCal(K)'])):
    		if self.database['Polarization'][index] == 'l':
    			self.database['Assumed TCal(K)'][index] = self.getTCal(self.database['Frequency'][index], freqL,  tcal_table_l) 
     		elif self.database['Polarization'][index] == 'r':
     			self.database['Assumed TCal(K)'][index] = self.getTCal(self.database['Frequency'][index], freqR,  tcal_table_r)
    
    def getTCal(self, databaseFreq, freqList, tcal_table):
    	""" Interpolates the tcal value for the frequency in the log file"""
    	index = 0
    	data = 0
    	for i, freq in enumerate(freqList):
    		if databaseFreq <= float(freqList[0]):
    			return float(tcal_table.get(freqList[0]))
    		elif databaseFreq >= float(freqList[len(freqList)-1]):
    			return float(tcal_table.get(freqList[len(freqList)-1]))
    		
    		if (float(freq) > databaseFreq):
    			index = i - 1
			data = float(tcal_table.get(freqList[index])) + ((float(tcal_table.get(freqList[index+1])) - float(tcal_table.get(freqList[index]))) / (float(freqList[index +1]) - float(freqList[index]))) * ( databaseFreq - float(freqList[index]))  
			return data
	
    def getTcalTable(self):
    	""" Get the tcal table from the working file"""
    	self.tcal_in_use = []
	self.editTCalTable(freq_tcal_l = TCAL_TABLE_L, freq_tcal_r = TCAL_TABLE_R, workingfile=1 )
	
	
    
class Plot(Canvas, Coordinate):  
    """Everything drawn on top of the regular plotting should have the tag 'line' (because most of those objects will be lines...)
    Then they will be resized, when the window is. 
    """  
    
    def __init__(self, master, **kw):
        """
        EXPLANATION OF INSTANCE VARIABLES COMMONLY USED
        -----------------------------------------------
        
        All data lists contain indices so that the corresponding data can be fetched from self.database. I will however call 
        the indices data in this explanation.
        
        self.data_indices contains all non-deleted data selected by the user
        
        self.current_deleted contains all deleted data selected by the user
        
        self.original_data is all data selected, hence self.data_indices+self.current_deleted
        
        self.deleted_list is all the data deleted from the log.
         
        self.outside_zoom_list is the data selected by the user that is outside of the plot boundaries
        
        self.virtual_points is a list of tuple-pairs containing the (x,y)-values of any virtual point
        """
        Canvas.__init__(self, master, **kw)
        self.colors = {0:'red', 1:'blue', 2:'purple', 3:'green', 4:'yellow', 5:'cyan'}
        self.database = []
        self.deleted_list = []
        self.outside_zoom_list = []
        self.data_indices = []
        self.original_data = []
        self.display_mode = IntVar()
        self.current_deleted = []
        self.virtual_points_list = []
        self.display_mode.set(2)
        self.display_deleted_points = 1
        self.numTools = NumericTools()
        self.xname = ''
        self.yname = ''
        
        _width = self.cget('width')
        _height = self.cget('height')
        
        Coordinate.__init__(self, (_width, _height))
        
        #bind for resize
        self.bind('<Configure>', self.reScaleAll)
        #bind for delete
        self.bind('<Button-3>', self.clickPoint)
        self.bind('<Shift-Button-1>', lambda event, time_delete = 1:self.clickPoint(event, time_delete))
        #bind for selection
        self.bind('<B1-Motion>', self.expandRect)
        #zoom
        self.bind('<ButtonRelease-1>', self.zoom)
        #delete selection
        self.bind('<B3-Motion>', self.expandRect)
        self.bind('<ButtonRelease-3>', self.deleteSelection)
        self.bind('<Button-1>', self.findSameFreqSource)
        #margins:
        self.x_margin = 50
        self.y_margin = 50
        
        self.grid = 1
        self.logScale = 0
        #make axis:
        self.makeAxis()
        
    def getList(self, name, indices):
        return_data = []
        if len(self.database) > 0:
       	    for i in indices:
                 data = self.database.get(name)[i]
                 return_data.append(data)
        return return_data

    def checkDataCount(self):
        """makes sure that the counter of the data is correct...
        If other functions for instance uses deleted_lists and so on, it wont be counted, 
        but this function fixes that
        """
        Gui.included_points.set(len(self.data_indices))
        Gui.selected_points.set(len(self.original_data))
    
    def plot(self, data_indices, xname, yname, autoscale = True):
        
        
        #self.database = Gui.getDatabase()[:]
        self.original_data = data_indices
        
        #delete old
        self.delete('plotted')
        
        self.current_deleted = list(set(data_indices)&set(self.deleted_list)) #the stuff that should appear as deleted, i.e is not out of bounds
        data_indices = list(set(data_indices)-set(self.deleted_list))
        
        #fetch data:
        xlist = self.getList(xname, data_indices)
        ylist = self.getList(yname, data_indices)
        
        x_del_list = self.getList(xname, self.deleted_list)
        y_del_list = self.getList(yname, self.deleted_list)
        
        x_del_list_cur = self.getList(xname, self.current_deleted)
        y_del_list_cur = self.getList(yname, self.current_deleted)
        
        x_outside_zoom = self.getList(xname, self.outside_zoom_list)
        y_outside_zoom = self.getList(yname, self.outside_zoom_list)  
        
        self.pixelsX = float(self.cget('width'))
        self.pixelsY = float(self.cget('height'))
        if Gui.scaling_mode.get() == 1:
            _xlist = xlist + x_del_list_cur
            _ylist = ylist + y_del_list_cur
        else:
            _xlist = xlist
            _ylist = ylist
        
        if autoscale:
            #if there are any lines present in the plot, they might have a different max/min. 
            #The following function checks that:
            lines_present = 0
            for line in self.find_withtag('line'):
                xy = self.coords(line)
                xs = xy[::2]
                ys = xy[1::2]
                x1 = self.getCartesianX(max(xs))
                y1 = self.getCartesianY(max(ys))
                x2 = self.getCartesianX(min(xs))
                y2 = self.getCartesianY(min(ys))
                new_xmax = max(self.maxX,x1)
                new_ymax = max(self.maxY,y1)
                new_xmin = min(self.minX, x2)
                new_ymin = min(self.minY, y2)
                lines_present = 1
            try:
                if lines_present:
                    self.updateLineCoordinates(new_xmin, new_xmax, new_ymin, new_ymax)
                    self.minX = min(min(_xlist),new_xmin)
                    self.minY = min(min(_ylist),new_ymin)
                    self.maxX = max(max(_xlist),new_xmax)
                    self.maxY = max(max(_ylist),new_ymax)
                else:
                    self.minX = min(_xlist)
                    self.minY = min(_ylist)
                    self.maxX = max(_xlist)
                    self.maxY = max(_ylist)
            except (ValueError, ), e: #empty plot!
                self.minX = self.maxX = self.minY = self.maxY = 0
        
        
        
        kw = {}
        if len(xlist)==len(ylist):
        
            for i in range(len(xlist)):
                tagnumber = data_indices[i]
                tags = (tagnumber, 'plotted')
                self.plotDot(xlist[i], ylist[i], tags, 'white', tagnumber)
            
            
            if self.display_deleted_points:
                _a = self.create_oval
                if Gui.delete_points_display.get():
                        self.create_oval = self.create_cross
                for i in range(len(x_del_list)):
                    tagnumber = self.deleted_list[i]
                    if tagnumber in self.current_deleted:
                        tags = (tagnumber, 'plotted', 'deleted')
                        self.plotDot(x_del_list[i], y_del_list[i], tags, 'red', tagnumber)
                self.create_oval = _a
            #plot dots outside zoom on border with cyan fill       
            
            for i in range(len(x_outside_zoom)):
                tagnumber = self.outside_zoom_list[i]
                tags = (tagnumber, 'plotted', 'outside_zoom')
                self.plotDot(x_outside_zoom[i], y_outside_zoom[i], tags, 'cyan', tagnumber)
                
            #virtual points:
            for x_y_weight in self.virtual_points_list:
                [x,y,weight] = x_y_weight 
                self.drawVirtualPoint(x, y, weight)
    
            #save info for redraw
            self.data_indices = data_indices
            
            #if the log shouldn't be time ordered, this sort makes that happen...
            self.data_indices.sort(self.sortTime)
            
            self.xname = xname
            self.yname = yname
            
            self.checkDataCount()
            self.setLabels()
            self.setXYTicks()        
    
    def plotDot(self, x,y, tags, fill, tagnumber):
        BAD_WEATHER_DATA = -7000000.0 #if weather data = BAD_WEATHER_DATA it is bad... don't plot it (HAS TO BE FLOAT!!!)
        kw = {}
        kw['fill'] = fill
        source = self.database.get('Source')[tagnumber]
        j = SOURCES_LIST.index(source)

        [fill_color, letter] = self.getColorAndLetter(j)
        
        kw['tags'] = tags
        kw['width'] = 1
        kw['outline'] = 'black'#outline_color
        
        if x != BAD_WEATHER_DATA and y != BAD_WEATHER_DATA:
            [x, y] = self.getCanvasXY([x, y])
            if self.display_mode.get() == 2:
                self.create_oval(x-3,y-3, x+3, y+3, **kw)
                self.create_text(x,y, anchor = W, text = '  ' + letter, fill = fill_color, tags = tags + ('label',))
            elif self.display_mode.get() == 1:
                self.create_text(x,y, anchor = W, text = letter, fill = fill_color, tags = tags + ('label',))
            elif self.display_mode.get() == 0:
                self.create_oval(x-3,y-3, x+3, y+3, **kw)
    
    def create_cross(self, x1,y1,x2,y2, **kw):
        tags = kw.get('tags')
        outline = 'black'#kw.get('outline')
        
        y = (y1+y2)/2.0
        x = (x1+x2)/2.0
        item = self.create_text(x,y, text = '+', fill = outline, tags = tags, font = ('Helvetica', 10, 'bold'))
                
        return item
    
    def getColorAndLetter(self, k):
        """receives a number as an identifier and returns a color and a letter. 
        If the number>26, two letters are returned (A-Z, AA-AZ....)
        All colors and letters for every session is saved in a database, so the color 
        will remain the same every time. 
        """
        k = int(k)
        if self.colors.has_key(k):
            return_color = self.colors.get(k)
        else:
            random.seed(1234567890)	
            r =g = b= 0
            while (r+g+b)<50: #so it is not too close to black, which is reserved for fits
                r = random.randrange(0, 256)
                g = random.randrange(0, 256)
                b = random.randrange(0, 256)
            return_color = '#%02x%02x%02x' % (r,g,b)    
            self.colors[k] = return_color
        
        alphabet = string.ascii_uppercase
        n = min(k,len(alphabet)-1)
        return_letter = alphabet[n]
        
        return [return_color, return_letter]
    
    def drawValues(self, xvalues, yvalues, **kw):
        #self.delete('line')
        coord_list = []
        maxY = max(yvalues)
        minY = min(yvalues)
        minX = min(xvalues)
        
        if not maxY >= self.maxY:
            maxY = self.maxY
        if not minY <= self.minY:
            minY = self.minY
        if not minX <= self.minX:
            minX = self.minX
        
        self.reDrawAll(minX, self.maxX, minY, maxY)
        
        for i in range(len(xvalues)):
            coord_list.append(self.getCanvasXY([xvalues[i], yvalues[i]]))
        
        if kw.has_key('fill'):
            fill = kw.get('fill')
            dash = None
        else:
            fill = 'black'
            dash = (12, 8)
        tags = ('line',)
        
        if kw.has_key('tags'):
            tags += kw.get('tags')
        
        self.create_line(coord_list, dash = dash, width = 2, fill = fill, tags = tags)
    
    def drawFittedLine(self, poly, **kw):
        #self.delete('line')
        
        _x = self.minX
        endX = self.maxX
        delta = float(endX-_x)/100.0
        coord_list = []
        y_list = []
        x_list = []
        if kw.has_key('complement_angle'):
            complement_angle = kw.get('complement_angle')
        else:
            complement_angle = 0
        while _x < endX:
            if complement_angle:
                y_list.append(self.evalPoly(poly, 90 -_x))
            else:
                y_list.append(self.evalPoly(poly, _x))
            x_list.append(_x)
            _x += delta
        
        maxY = max(y_list)
        minY = min(y_list)
        
        if not maxY >= self.maxY:
            maxY = self.maxY
        if not minY <= self.minY:
            minY = self.minY
            
        self.reDrawAll(self.minX, self.maxX, minY, maxY)
            
        for i in range(len(y_list)):
            _y = y_list[i]
            _x = x_list[i]
            coord_list.append(self.getCanvasXY([_x, _y]))

        tags = ('line',)
        
        if kw.has_key('tags'):
            tags+=kw.get('tags')
        
        if kw.has_key('fill'):
            fill = kw.get('fill')
            dash = None
        else:
            fill = 'black'
            dash = (12, 8)

        self.create_line(coord_list, dash = dash, width = 2, fill = fill, tags = tags)
        
    def delete_old_trec(self):
        self.delete('trec_point')
        self.delete('trec_marker')
        self.delete('trec_text')
        self.delete('line')
    
    def create_trec_point(self, trec):
        [x,y] = self.getCanvasXY([0, trec])
        x = self.x_margin+4
        self.create_oval(x-4,y-4,x+4,y+4, tags = ('trec_point', 'normal', trec))
    
    def create_trec_marker(self, trec):
        [x,y] = self.getCanvasXY([0, trec])
        x = self.x_margin+4
        self.create_oval(x-4,y-4,x+4,y+4, fill = 'black', tags = ('trec_marker'))
        text = self.roundNumber(trec, 1, 0)
        self.create_text(x-6,y, text = text, anchor = E, tags = ('trec_text'))
        
        
    def evalPoly(self, poly, x):
        y = 0
        m = len(poly)-1
        for k in range(len(poly)):
            y += poly[k]*x**(m-k)
        return y
    
    def clickPoint(self, event, time_delete = 0):
        items = self.find_overlapping(event.x-1, event.y-1, event.x+1, event.y+1) #find_closest only finds one dot....
        for item in items:
            if 'plotted' in self.gettags(item):
                if time_delete:
                    self.deleteWithSameTime(item)
                else:
                    self.deletePoint(item)
            elif 'trec_point' in self.gettags(item):
                self.deleteTrec(item)
    
    def deleteTrec(self, item):
        tags = self.gettags(item)
        if 'normal' in tags:
            self.itemconfig(item, fill = 'red')
            tags = (tags[0], 'deleted', tags[2])
        elif 'deleted' in tags:
            self.itemconfig(item, fill = 'white')
            tags = (tags[0], 'normal', tags[2])
        self.itemconfig(item, tags = tags)
    
    def deletePoint(self, item):
        tags = self.gettags(item)
        oval = self.type(item) == 'oval'
        if 'virtual' in tags: #virtual point, simply delete it
            self.delete(item)
        elif not 'label' in tags:
            index = int(tags[0])
            if 'deleted' in tags:
                if Gui.delete_points_display.get():
                    [x, y] = self.coords(item)
                    self.delete(item)
                    item = self.create_oval(x-3,y-3, x+3, y+3, tags = tags, fill = 'white', outline = 'black')
                else:
                    if oval:
                        self.itemconfig(item, fill = 'white')
                self.dtag(item, 'deleted')
                if index in self.deleted_list:
                    self.deleted_list.remove(index)
                    self.data_indices.append(index)
            else:
                if Gui.delete_points_display.get():
                    if oval:
                        [x1,y1,x2,y2] = self.coords(item)
                        self.delete(item)
                        kw = {}
                        kw['tags'] = tags 
                        item = self.create_cross(x1, y1, x2, y2, **kw)
                else:
                    self.itemconfig(item, fill = 'red')
                self.addtag_withtag('deleted', item)
                if 'outside_zoom' in tags and index in self.outside_zoom_list:
                    self.outside_zoom_list.remove(index)
                elif index in self.data_indices:
                    self.data_indices.remove(index)
                self.deleted_list.append(index)
                self.current_deleted.append(index)
            
            Gui.included_points.set(len(self.data_indices))
        
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
        
        x_side = self.x_margin+self.xoffset
        y_side = self.y_margin+self.yoffset
        
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
            elif x > (old_width - x_side): #right side #might differ 1 or 2 points, therefore no equality
                dx = new_width-old_width
            else:
                dx = x - (x_side)
                dx *= (xfactor-1)
            
            if y == self.y_margin:
                dy = 0
            elif y > (old_height - y_side):
                dy = new_height - old_height
            else:
                dy =y - (y_side)
                dy *= (yfactor-1)
            
            self.move(item,dx,dy)
        
        #fix labels
        self.coords('xy_label', new_width/2, 10)
        self.coords('x_label', new_width-self.x_margin, new_height-self.y_margin+30)
        self.coords('pol_label', new_width - self.x_margin, self.y_margin-10)
        
        #if there is a line, scale it too.
        x_offset = x_side
        y_offset = y_side
        
        for item in self.find_withtag('line'):
            self.pixelsX = old_width
            self.pixelsY = old_height
            coords = self.coords(item)
            xcoords = coords[::2]
            ycoords = coords[1::2]
            cartX = []
            cartY = []
            width = self.itemcget(item, 'width')
            fill = self.itemcget(item, 'fill')
            dash = self.itemcget(item, 'dash')
            #get cartesian coordinates
            for i in range(len(xcoords)):
                cartX.append(self.getCartesianX(xcoords[i]))
                cartY.append(self.getCartesianY(ycoords[i]))
            #set new pixel number:
            self.pixelsX = new_width
            self.pixelsY = new_height
            #get canvas coordinates
            new_coords = []
            for i in range(len(xcoords)):
                canvxy = self.getCanvasXY([cartX[i], cartY[i]])
                new_coords.append(canvxy)
            self.delete(item)
            self.create_line(new_coords, tags = ('line'), fill = fill, width = width, dash = dash)
        
        #scale trec_marker, trec_text, trec_point
        items = self.find_withtag('trec_marker') + self.find_withtag('trec_text') + self.find_withtag('trec_point')
        for item in items:
            coords = self.coords(item)
            if len(coords) == 4:
                [x1, y1, x2, y2] = coords
                x = (x1+x2)/2.0
                y = (y1+y2)/2.0
            elif len(coords) == 2:
                [x, y] = coords
            if y == self.y_margin:
                dy = 0
            elif y > (old_height - y_side):
                dy = new_height - old_height
            else:
                dy =y - (y_side)
                dy *= (yfactor-1)
            
            self.move(item,0,dy)

        #set geometry to avoid infinite resizing...
        #topframe is self.master, gui is topframe.master and root is gui.master....
        root = self.master.master.master
        height = root.winfo_height()
        width = root.winfo_width()
        #explicit geometry:
        root.geometry('%sx%s' % (width, height))
        a = self.getCartesianY(50)
        
        #fix layout
        self.delete('layout')
        self.makeAxis()
        self.setXYTicks()
        
        return 'break'
    
    def updateLineCoordinates(self, new_xmin, new_xmax, new_ymin, new_ymax):
        """updates the position of all plot objects with tag 'line'
        """
        old_xmin = self.minX
        old_xmax = self.maxX
        old_ymin = self.minY
        old_ymax = self.maxY
        
        lines = self.find_withtag('line')
        for line in lines:
            old_coords = self.coords(line)
            old_xs = old_coords[::2]
            old_ys = old_coords[1::2]
            real_x = []
            real_y = []
            for i in range(len(old_xs)):
                real_x.append(self.getCartesianX(old_xs[i]))
                real_y.append(self.getCartesianY(old_ys[i]))
            #set new min/max
            self.minX = new_xmin
            self.maxX = new_xmax
            self.minY = new_ymin
            self.maxY = new_ymax
            new_coords = []
            for i in range(len(real_x)):
                new_coords.append(self.getCanvasXY([real_x[i], real_y[i]]))
            #set the new coords
            self.coordsMultiple(line, new_coords)
            #reset max/min
            self.minX = old_xmin
            self.maxX = old_xmax
            self.minY = old_ymin
            self.maxY = old_ymax
    
    def coordsMultiple(self, item, coords):
        """tkInters coords have trouble setting new coords for items if the number of coords>4 (for lines or polygons)
        This function does that instead...
        """
        kw = {}
        keys = ['width', 'fill', 'dash', 'tags']
        for key in keys:
            kw[key] = self.itemcget(item, key)
        type = self.type(item)
        self.delete(item)
        self._create(type, coords, kw)
        
    
    def reDrawAll(self, xmin = None, xmax = None, ymin = None, ymax = None):
        """reDrawAll redraws the entire plot. It is however not used on resizing because it is a bit slow.
        If ALL arguments xmin,xmax,ymin and ymax are set, the plot will resize to these values. Note that all of them 
        must be valid.   
        """
        if xmin!=None and xmax!=None and ymin!=None and ymax!=None:
            self.updateLineCoordinates(xmin, xmax, ymin, ymax)
            self.minX = xmin
            self.maxX = xmax
            self.minY = ymin
            self.maxY = ymax
            autoscale = False
        elif Gui.scaling_mode.get() == 2: #if manual scale...
            autoscale = False
        else:
            autoscale = True
            self.original_data += self.outside_zoom_list
            self.outside_zoom_list = []
        try:
            self.plot(self.original_data, self.xname, self.yname, autoscale)
        except (AttributeError, ValueError): #occurs when resizing without a plot
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
        self.create_text(middle, 10, text = 'Plotting %s vs. %s' %(self.yname, self.xname), tags = tags + ('xy_label',))
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
        self.polarization = text
        self.create_text(width - self.x_margin, self.y_margin - 10, text = text, anchor = E, tags = tags + ('pol_label',))
    
    def setOpacityLabelForData(self, opac_cor):
        self.delete('opacity_data')
        tags = ('labels', 'opacity_data')
        quarter = int(self.cget('width'))/4
        if opac_cor == 'both':
            opac_cor = 'Gain & TCal(K)'
        elif opac_cor == 'gain':
            opac_cor = 'Gain'
        elif opac_cor == 'tcal':
            opac_cor == 'TCal(K)'
        text = 'Opacity correction: %s' %opac_cor
        if not opac_cor == 'none':
            self.create_text(3*quarter, self.y_margin-15, text = text, anchor = SW, tags = tags)
    
    def setOpacityLabel(self):
        self.delete('opacity')
        tags = ('labels', 'opacity')
        quarter = int(self.cget('width'))/4
        self.create_text(quarter, self.y_margin-15, text = 'Opacity corrected polynomial', anchor = SW, tags = tags)
    
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
                y_label = self.numTools.num2date(text_y)
            else:
                y_label = self.roundNumber(text_y, self.maxY,self.minY)
            self.create_text(self.x_margin-5, y, text = y_label, anchor = E, tags = ('y_ticks',))
        #x-ticks
        for x in self.xticks:
            text_x = self.getCartesianX(x)
            if self.xname == 'Time':
                x_label = self.numTools.num2date(text_x)
            else:
                x_label = self.roundNumber(text_x, self.maxX,self.minY)
            self.create_text(x, height-self.y_margin+10, text = x_label, tags = ('x_ticks',))
    
    def roundNumber(self, unrounded, maxi, mini):
        """roundNumber receives a number and the percentage change of max and min in the series the number comes from. 
        Returns the number with appropriate number of digits"""
        try:
            number_of_digits = int(max(0,math.ceil(1-math.log10(abs(maxi-mini)))))
        except (ZeroDivisionError, ValueError):
            number_of_digits = 2 

        expr = '%.' + str(number_of_digits) +'f'
        if maxi > 100000:
            # TODO: fix
            expr = '%.' + str(number_of_digits) +'e'
        return expr % unrounded
    
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
        if len(bbox)==4:
            try:
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
                            
                self.outside_zoom_list = list(set(self.data_indices).union(set(self.outside_zoom_list))-set(zoom_list))
                #Note, the order is not an error!!! it is because canvas y min is top left, not bottom left like cartesian y min
                #zoom shouldn't forget about deleted stuff:
                zoom_list.extend(self.current_deleted)
                [x1,y2,x2,y1] = bbox
                self.delete('line')
                [self.minX, self.maxX, self.minY, self.maxY] = [self.getCartesianX(x1), self.getCartesianX(x2), self.getCartesianY(y1), self.getCartesianY(y2)]
                self.plot(zoom_list, self.xname, self.yname, False)
            except (ValueError,TclError ), e:
                pass
    
    def deleteSelection(self, event):
        bbox = self.coords('Selection_Rectangle')
        self.delete('Selection_Rectangle')
        try:
            item_list = self.find_enclosed(*bbox)
        except TypeError:
            item_list = []
        for item in item_list:
            if 'plotted' in self.gettags(item) and not 'label' in self.gettags(item):
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

    def deleteWithSameTime(self, item):
        """deleteWithSameTime deletes all points in the 
        plot with the same time as the clicked point....
        """
        tags = self.gettags(item)
        ref_index = int(tags[0])
        
        ref_time = self.database.get('Timestamp')[ref_index]
        indices = self.data_indices + self.outside_zoom_list
        for i in indices:
            time = self.database.get('Timestamp')[i]
            if time == ref_time:
                #delete it if not deleted, else undelete it...
                if i in self.deleted_list:
                    self.deleted_list.remove(i)
                    Gui.included_points.set(Gui.included_points.get()-1)
                else:
                    self.deleted_list.append(i)
                    Gui.included_points.set(Gui.included_points.get()+1)
        self.reDrawAll()
    
    def findSameFreqSource(self, event):
        """find points with the same frequency and source as 'item', 
        build a list of them and connect the points with lines. 
        """
        items = self.find_overlapping(event.x-1, event.y-1, event.x+1, event.y+1)
        item = None
        #algorithm to find the outmost point (most of the time, there are a lot of points on top of each other)
        while items:
            if self.type(items[-1]) == 'oval':
                item = items[-1]
                break
            else:
                items = items[:-1]
        #find the frequency and time
        if item:
            tags = self.gettags(item)
            if 'plotted' in tags and self.type(item) == 'oval':
                index = int(tags[0])
                frequencies = self.database.get('Frequency')
                sources = self.database.get('Source')
                match_frequency = frequencies[index]
                match_source = sources[index]
                match_list = []
                #match_list.append(index)
                for i in self.data_indices:
                    if frequencies[i] == match_frequency and sources[i] == match_source:
                        match_list.append(i)
                self.connectPoints(match_list)
        
    def connectPoints(self, datalist):
        """connect all points in datalist. 
        """
        tags = ('line')
        self.delete(tags)
        coords = []
        for index in datalist:
            _x = self.database.get(self.xname)[index]
            _y = self.database.get(self.yname)[index]
            coord = self.getCanvasXY([_x, _y])
            coords.append(coord)
        coords.sort()
        self.create_line(coords, tags = tags)
    
    def drawVirtualPoint(self, x, y, weight, _a = None):
        try:
            x = float(x)
            y = float(y)
            weight = int(weight)
            if not [x,y,weight] in self.virtual_points_list:
                self.virtual_points_list.append([x,y,weight])
        except ValueError:
            pass
        else:
            [canvx, canvy] = self.getCanvasXY([x,y])
            size = 3
            x1 = canvx - size
            x2 = canvx + size
            y1 = canvy - size
            y2 = canvy + size
            
            tags = ('plotted', 'virtual')
            for i in range(weight):
                self.create_rectangle(x1, y1, x2, y2, fill = 'black', tags = tags)
    
    def getVirtualList(self):
        return_list_x = []
        return_list_y = []
        for item in self.find_withtag('virtual'):
            coords = self.coords(item)
            xs = coords[::2]
            ys = coords[1::2]
            canvx = sum(xs)/len(xs)
            canvy = sum(ys)/len(ys)
            return_list_x.append(self.getCartesianX(canvx))
            return_list_y.append(self.getCartesianY(canvy))
        return [return_list_x, return_list_y]
    
    def setDisplayDeletedPoints(self, value):
        self.display_deleted_points = value
        self.reDrawAll()
    
    def sortTime(self, x1, x2):
        """cmp function used for sorting in time
        """
        xtime1 = self.database.get('Time')[x1]
        xtime2 = self.database.get('Time')[x2]
    
        if xtime1>xtime2:
            return 1
        elif xtime1 == xtime2:
            return 0
        else:
            return -1
    
    def closePlot(self):
        self.delete(ALL)
        self.makeAxis()
        self.setLabels()
        self.setXYTicks()
        


	
	
	
	
