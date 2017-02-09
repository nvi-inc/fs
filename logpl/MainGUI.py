#LogPlotter/MainGUI.py
import os, sys
try: #check for Tkinter
    from Tkinter import *
    import tkMessageBox, tkFont, math, operator, threading, readline, tkFileDialog, string
except ImportError:
    print 'Tkinter not correctly installed. Exiting...'
    sys.exit()

try: #check for logpl 
    from PlotCanvas import PlotCanvas
    from PlotManager import PlotManager
    from Settings import Settings
    from SettingsWindow import SettingsWindow
    from CanvasConstructor import CanvasConstructor
    from IOSettings import IOSettings
    from HelpFrame import HelpFrame
    from ColorSelector import ColorSelector
except ImportError:
    print 'Logpl not correctly installed. Exiting...'
    sys.exit()
    
    
class MainGUI:
    """
    ##########################################
    Main class of LogPlotter starts up the GUI and connects all classes. 
    ##########################################
    """
###############Declaration of class variables. In init, plot_height and plot_width are set relative to screen size 
    plot_height = 0
    label_height = 50
    plot_width = 0
    xaxis_height = 25
    active_plot = 0
    temp_selected_plot = None
    batch_mode = 0
    verbose = 0
    output_mode = None
    output_name = None
    output_text = ''

################Init - initiates GUI

    def __init__(self, **args):
        #name = 'logpl'
        self.root = Tk()
        #self.root.resizable(width =1, height = 5)
        self.root.minsize(800,550)
        
        screenheight= self.root.winfo_screenheight()
        screenwidth = self.root.winfo_screenwidth()
        #normal font:
        global font
        font = tkFont.Font(font = ("Helvetica 8 normal"))
        #bold font:
        global fontb
        fontb = tkFont.Font(font = ("Helvetica 8 bold"))
        self.root.option_add("*Font", fontb)
            
        #set display proportion after paper size. 
        paper  =  8.5/11.0
        
        #let plot height be fixed...
        MainGUI.plot_height = int(screenheight/1.41)
        
        x = screenwidth / (paper*MainGUI.plot_height)
        #self.setToDim(8.5, 11)
        MainGUI.plot_width = screenwidth/x + 150
        
        self.status_text = StringVar()
        
        MainGUI.output_name = args.get('output_name')
        if args.get('output_mode') == 'printer':
            MainGUI.output_mode = 0
        elif args.get('output_mode') == 'file':
            MainGUI.output_mode = 1
        
        if args.get('cmd') or args.get('cfile'):
            MainGUI.batch_mode=1
            if args.get('verbose'):
                MainGUI.verbose = 1
            else:
                MainGUI.verbose = 0
            self.status_text.set('Running in batch mode')
            #direct self.status_text.set() to sys.stdout (or print)
            self.status_text.set = self.printError
        
        
        if args.get('geometry'):
            try:
                self.root.geometry(args.get('geometry'))
            except TclError:
                self.status_text.set('Bad geometry setting. Using default value(+1+1)')
        else:
            #default geometry setting
            self.root.geometry('+1+1')
        #####read IOSettings:
        self.ios = IOSettings()
        self.filename = None
        #default directory is now IOSettings.default_directory
        #default control file is now IOSettings.default_control_file
        #################################statusBar:

        
        
        #create settingshandler:
        self.settings = Settings()
        #create a PlotManager:

        self.plotman = PlotManager()

        self.canvas_man=[]
        
        
        self.root.title('LogPlotter 2')

        #checkbutton variables:
        self.check_data = {}
        self.check_superimpose=IntVar()
        self.check_connect = IntVar()
        self.check_absTime = IntVar()
        
        #plotsettings for XY-plot
        self.plotsetting = IntVar()
        self.plotsetting.set(0)

        
#################################menubar:

        menubar = Menu(self.root)
        filemenu = Menu(menubar, tearoff = 0)
        filemenu.add_command(label='Open Log', command = lambda:self.openFile(), underline = 0)
        filemenu.add_command(label='Close Log', command = lambda:self.closeFile(), underline = 0)
        filemenu.add_separator()
        filemenu.add_command(label='Edit I/O Settings', command = lambda: self.IOSettings(), underline = 0)
        filemenu.add_separator()
        filemenu.add_command(label = 'Print Plot(s)', command = lambda: self.printCanvas(), underline = 0)
        filemenu.add_separator()
        filemenu.add_command(label = 'List Log', command = lambda: self.getComments(), underline = 0)
        filemenu.add_command(label = 'List Data', command = lambda: self.listData(), underline = 5)
        filemenu.add_separator()
        filemenu.add_command(label='Quit', command = lambda:self.root.destroy(), underline = 0)
        menubar.add_cascade(label='File', menu = filemenu, underline = 0)

##########################Build plot menu dynamically from settings:

        self.plotmenu = Menu(menubar, tearoff = 0)
        
        if args.get('ctrlfile'): #set new control file
            IOSettings.default_control_file=args.get('ctrlfile')
        
        menubar.add_cascade(label='Plotting', menu = self.plotmenu, underline = 0)

        optionsmenu = Menu(menubar, tearoff = 0)
        optionsmenu.add_checkbutton(label='Connect data points', variable = self.check_connect, command = lambda: self.connectPoints(), underline = 0)
        optionsmenu.add_separator()
        optionsmenu.add_checkbutton(label = 'Superimpose Next', variable = self.check_superimpose, underline = 0)
        optionsmenu.add_command(label = 'Superimpose All', command = lambda: self.superImposeAll(), underline = 12)
        optionsmenu.add_command(label = 'Split All', command = lambda: self.splitAll(), underline = 1)
        optionsmenu.add_separator()
        optionsmenu.add_command(label = 'Grid On/Off', command = lambda: self.grid(), underline = 0)
        optionsmenu.add_command(label = 'Log Scale On/Off', command = lambda: self.logScale(), underline = 0)
        optionsmenu.add_command(label = 'Invert Y Scale On/Off', command = lambda: self.invertScale(), underline = 0)
        optionsmenu.add_separator()
        optionsmenu.add_command(label = 'Display Average', command = lambda: self.average(), underline = 0)
        optionsmenu.add_separator()
        optionsmenu.add_checkbutton(label = 'Display Absolute Time', variable = self.check_absTime, command = lambda: self.absoluteTime(), underline = 17)
        menubar.add_cascade(label = 'Options', menu = optionsmenu, underline = 0)
    
        settingsmenu = Menu(menubar, tearoff = 0)
        settingsmenu.add_command(label='Reload Default Control File', command = lambda: self.readSettings(), underline = 0)
        settingsmenu.add_command(label='Edit Control File', command = lambda: self.editSettings(), underline = 0)
        settingsmenu.add_separator()
        settingsmenu.add_command(label = 'Edit Shapes and Colors', command = lambda : self.changeShapeColor(), underline = 5)
        settingsmenu.add_separator()
        settingsmenu.add_command(label = 'Increase Font Size', command = lambda: self.fontSize('increase'), underline = 0)
        settingsmenu.add_command(label = 'Decrease Font Size', command = lambda: self.fontSize('decrease'), underline = 0)
        menubar.add_cascade(label='Settings', menu = settingsmenu, underline = 0)
        
        helpmenu = Menu(menubar, tearoff = 0)
        helpmenu.add_command(label = 'Help Contents', command = lambda: HelpFrame(None, font.cget('size')), underline = 0)
        helpmenu.add_command(label = 'About LogPlotter', command = lambda: tkMessageBox.showinfo('About LogPlotter', self.about()), underline = 0)
        menubar.add_cascade(label = 'Help', menu = helpmenu, underline = 0)
        self.root.config(menu=menubar)
        
##############################geometry:
        bottomframe = Frame(self.root)
        bottomframe.pack(expand = 0, fill = X, anchor = SW, side = BOTTOM)
        
        topframe = Frame(self.root)
        topframe.pack(side = BOTTOM, anchor = NW, fill = BOTH, expand = 1)
        
        rightside = Frame(topframe)
        rightside.pack(side = RIGHT, fill = BOTH, anchor = NE, expand = 0)
        
        #global leftside
        leftside = Canvas(topframe, height = MainGUI.plot_height + MainGUI.label_height)
        leftside.pack(side = RIGHT, expand = 1, anchor = NW, fill = BOTH)

        self.status_text.set('Initializing...')
        self.progressBar = Label(bottomframe, relief = RAISED, textvariable = self.status_text, anchor = W)
        self.progressBar.pack(fill = X, expand = 1, side = LEFT)
        self.xypos = StringVar()
        self.xypos.set('Y:    | X:     ')
        Label(bottomframe, relief = RAISED, textvariable = self.xypos).pack(fill = X, expand = 0, side = RIGHT)
        
#################################plottingFrame:
        
        self.labelsCanvas = Canvas(leftside, width = MainGUI.plot_width, height = MainGUI.label_height, relief = GROOVE, bd = 1, highlightthickness = 0)
        self.labelsCanvas.pack(side = TOP, fill = X, anchor = NW)
    
        self.plottingFrame = Canvas(leftside, width = MainGUI.plot_width, height = MainGUI.plot_height+MainGUI.xaxis_height)
        self.plottingFrame.pack(expand = 1, fill = BOTH, anchor = NW)
        
        self.plottingFrame.bind('<Configure>', (lambda event: self.changeHeightWidth(event)))
        self.plottingFrame.bind_all('<Shift-B1-Motion>', (lambda event: self.startDrag(event)))
        self.plottingFrame.bind_all('<ButtonRelease-1>', lambda event: self.releaseDrag(event))
        
        

#################################labelFrame (height = 50):

        self.labelsCanvas.create_text(MainGUI.plot_width/3, 5, text = 'Station: ', tags = ('station', 'file_info'), anchor = W, font = font)
        self.labelsCanvas.create_text(MainGUI.plot_width/3, 20, text = 'Filename: ', tags = ('filename','file_info'), anchor = W, font = font)
        self.labelsCanvas.create_text(MainGUI.plot_width/3, 35, text = '', tags = ('system','file_info'), anchor = W, font = font)           

##############################################Plot Details Frame
        
        plot_detail_Frame = LabelFrame(rightside, text = 'Plot Details', relief = GROOVE, bd =3, pady = 10, padx=5)
        #leftside.create_window(10,10, window = plot_detail_Frame)
        plot_detail_Frame.grid(row = 1, column = 1, columnspan=3,padx=15, pady = 15, sticky = E)
        
        Label(plot_detail_Frame, text = 'Plot :').grid(row = 0, column = 0, rowspan = 2)
        
        self.selected_Plot = StringVar()
        self.selected_Plot.set('None selected')
        self.plotNames = OptionMenu(plot_detail_Frame,self.selected_Plot, None)
        self.plotNames.grid(row = 1, column = 1, columnspan = 2, sticky = W)
        
        self.entry_Pts = StringVar()
        Label(plot_detail_Frame, text = '#Pts in plot').grid(row = 2, column = 0)
        Label(plot_detail_Frame, textvariable = self.entry_Pts).grid(row = 2, column = 1)
        self.entry_delPts = StringVar()
        Label(plot_detail_Frame, text = '#Pts outside of plot').grid(row = 3, column = 0)
        Label(plot_detail_Frame, textvariable = self.entry_delPts).grid(row = 3, column = 1)
        
#####################################Y-axis frame

        y_detail_Frame = LabelFrame(plot_detail_Frame, text = 'Y axis',padx=15, pady=5)
        y_detail_Frame.grid(row=4, column = 0, columnspan = 3, pady=10)

        Label(y_detail_Frame, text = 'Y max').grid(row=0, column =0)
        self.entry_Ymax = Entry(y_detail_Frame)
        self.entry_Ymax.grid(row =0, column =1, columnspan =3)
        Label(y_detail_Frame, text = 'Y min').grid(row=1, column =0)
        self.entry_Ymin = Entry(y_detail_Frame)
        self.entry_Ymin.grid(row =1, column =1, columnspan =3)
        
        Button(y_detail_Frame, text = 'Set Y axis', command = lambda: self.setY()).grid(row=2, column = 0, columnspan =3, sticky = E+W, pady=5)
        
##########################################X-axis frame
        
        x_detail_Frame = LabelFrame(plot_detail_Frame, text = 'X axis', padx=15, pady=5)
        x_detail_Frame.grid(row = 5, column = 0, columnspan = 3, pady = 10)
       
        Label(x_detail_Frame, text='date format: YYYY.DDD.HH:MM:SSSS').grid(row = 0, column = 0, columnspan = 2)
        
        Label(x_detail_Frame, text = 'X min').grid(row = 1, column = 0)
        self.entry_Tmin = Entry(x_detail_Frame, width = 20)
        self.entry_Tmin.grid(row = 1, column = 1)
        
        Label(x_detail_Frame, text = 'X max').grid(row = 2, column = 0)
        self.entry_Tmax = Entry(x_detail_Frame, width = 20)
        self.entry_Tmax.grid(row = 2, column = 1)

        Button(x_detail_Frame, text = 'Set X axis', command = lambda: self.setX()).grid(row=3, column = 0, columnspan =3, sticky = E+W, pady=5)

##############################################Plot detail frame (again)

        
        Button(plot_detail_Frame, text = 'Zoom out', command = lambda: self.zoomOut(), padx=0).grid(row = 6, column = 0, pady = 5, padx=0, sticky = E+W)
        Button(plot_detail_Frame, text = 'Autoscale', command = lambda: self.reScale(), padx=0).grid(row = 6, column = 1, pady = 5, padx=0, sticky = E+W)
        Button(plot_detail_Frame, text = 'Clear changes', command = lambda: self.resetPlot(), padx=0).grid(row = 6, column = 2, pady = 5, padx=0, sticky = E+W)
        Label(plot_detail_Frame, text = 'Left click plot to select it').grid(row = 7, column = 0, columnspan = 3)
        Label(plot_detail_Frame, text = 'Hold Control, left button and drag over plot \nto zoom').grid(row = 8, column = 0, columnspan = 3)
        Label(plot_detail_Frame, text = 'Double click right mouse button to add/delete\n points').grid(row = 9, column = 0, columnspan = 3)
        Label(plot_detail_Frame, text = 'Hold right button and drag to add/delete \nselection').grid(row = 10, column = 0, columnspan = 3)
        Label(plot_detail_Frame, text = 'Superimpose plots by dragging them onto each other\n while holding shift').grid(row = 11, column = 0, columnspan = 3)
        
##############################
        self.readSettings()
        self.status_text.set('Idle, open log file in file menu')

#######################Argument section:
        if args.get('log') and self.settings_dict:
            try:
                self.openFile(args.get('log'))
            except IOError:
                self.status_text.set('Log file ' + args.get('log') + ' does not exist. Ignoring command...')

        if MainGUI.batch_mode==1:
            self.root.update()
            self.root.wm_withdraw()
            if args.get('cfile'):
                self.cfileRead(args.get('cfile'))
            else:
                self.batchMode()
        else:
            self.root.mainloop()
            
    def batchMode(self, cfile_cmd = None):
        """
        Function for running the batch mode:
        """
        
        cmds = ['abstime=', 'average', 'cfile=', 'channel=', 'control=', 'defdir=', 'fontdec', 'fontinc',
                'grid', 'invert=', 'line=', 'list=', 'log=', 
                'lscale=', 'output=', 'plot=', 'plotall', 'plots', 'plotxy=', 'removeall', 'reset', 'scale=', 
                'showdisp=', 'splitall', 'super=', 'superall', 'timescale=', 'xscale=']
        helptext = """
Command    Parameter     Description
-------    ---------     -----------
abstime=   0/1           Display absolute (1) or relative (0)
                         time on the time axis.
average    void          Displays average of data on selected plot
cfile=     filename      Transfer control to command file.
channel=   int           Select active channel. First plot is 1, last is n. 
control=   filename      Read settings from control file.
                         This requires the log file to be reloaded. 
defdir=    path          Set the default directory for logfiles
fontdec    void          Decrease font size
fontinc    void          Increase font size
grid       void          Turn grid on/off on selected plot
invert=    0/1           Invert Y-axis on plot, on/off.
exit       void          Terminate logpl and exit.
help       void          Display help text (this text).
line=      0/1           Connecting line between data points on/off.
list=      command,file  Fetch data for command. To save the output, specify 
                         the filename, else leave it blank. 
log=       filename      Open specified log file.
lscale=    0/1           Logarithmic Y-axis scale on/off.
output=    dest,name     Select output destination. For "dest" use "file" or
                         "print". "name" is filename or printername. 
                         Leave arguments blank to print output to 
                         default printer/file. 
                         Output files could be EPS/PS, PDF, BMP, JPEG/JPG, 
                         TIFF, GIF or PNG. Specify by file suffix. 
                         Unrecognized suffixes will be printed as PS. 
plot=      plotname      Plot specified plotname
plotall    void          Plots all available plots
plots      void          Prints available plots
plotxy=    plot1,plot2   Plots plot1 versus plot2
removeall  void          Removes all plots
reset      void          Resets both the x and y scale of the selected plot
                         Also removes other changes made to the plot(logscale etc.)
scale=     int,int       Set the Y-axis scale for the current channel.
                         Plots are always automatically autoscaled. 
settings   void          Pops up window to edit control file
showdisp=  0/1           Shows/hides logpl GUI. Default is 0
splitall   void          Splits all superimposed plots
superall   void          Superimposes all plots
super=     0/1           Print superimposed plots, on/off.
timescale= date,date     Zoom to specified dates. Date is of format
                         YYYY.DDD.HH:MM:SSSS. Minutes and seconds may
                         be omitted. 
xscale=    int,int       Sets the X-axis scale for the selected channel

You can always query the current settings by typing the command without setting
a new value.
        """
        while True:
            if cfile_cmd:
                entry = cfile_cmd
                print 'command:', entry
            else:
                #readline.parse_and_bind("tab: complete")
                try:
                    entry = raw_input('logpl>')
                except (EOFError, KeyboardInterrupt):
                    print 'exiting\n'
                    break
            if entry == 'exit':
                sys.exit()
            elif entry == 'help':
                print 'Available commands: '
                print helptext
            elif entry == 'settings':
                self.editSettings()
            else:
                match = 0
                for cmd in cmds:
                    try:
                        if entry[:len(cmd)]==cmd:
                            match = 1
                            value = entry[len(cmd):].lstrip()
                            ###
                            if cmd=='abstime=':
                                if value:
                                    self.check_absTime.set(value)
                                    self.absoluteTime()
                                else:
                                    print 'Current setting for absolute time is', self.check_absTime.get()
                            ###
                            elif cmd == 'average':
                                self.average()
                            ###
                            elif cmd == 'cfile=':
                                if value:
                                    try:
                                        self.cfileRead(value)
                                    except IOError:
                                        print 'Error: File %s could not be found.' % value
                                else:
                                    print 'No filename specified'
                            ###
                            elif cmd == 'channel=':
                                if value and value.isdigit:
                                    value = int(value)
                                    value -= 1
                                    if (len(self.canvas_man)+1)>value and value>=0:
                                        self.selectLastest(int(value))
                                    else:
                                        print 'No such channel.'
                                else:
                                    print 'Selected plot is ', str(MainGUI.active_plot +1)
                                    print 'There are ', len(self.canvas_man), ' channels.'
                                    if len(self.canvas_man)>0:
                                        for i in range(len(self.canvas_man)):
                                            try:
                                                print '%02d: %s' %(i+1, self.canvas_man[i][0].superImposeList.keys())
                                            except (AttributeError, IndexError):
                                                pass
                            ###
                            elif cmd=='control=':
                                if not value == '':
                                    IOSettings.default_control_file=value
                                    self.readSettings()
                                else:
                                    print 'Current control file: ' + IOSettings.default_control_file
                            ###
                            elif cmd == 'defdir=':
                                if value:
                                    IOSettings.default_directory = value
                                else:
                                    print 'Current default directory is ', IOSettings.default_directory
                            ###
                            elif cmd == 'fontdec':
                                self.fontSize('decrease')
                            ###
                            elif cmd == 'fontinc':
                                self.fontSize('increase')
                            ###
                            elif cmd == 'grid':
                                self.grid()
                            ###
                            elif cmd == 'invert=':
                                try:
                                    if value:
                                        try:
                                            value = int(value)
                                        except ValueError:
                                            print 'Invalid argument!'
                                            value = 0
                                        if not self.canvas_man[MainGUI.active_plot][0].invert == value:
                                            self.invertScale()
                                    else:
                                        print 'Invert scale is set to', self.canvas_man[MainGUI.active_plot][0].invert
                                except (IndexError, TypeError), e:
                                    print 'Selected plot,', MainGUI.active_plot, ',does not exist'
                            ###        
                            elif cmd == 'line=':
                                if value == '0' or value == '1':
                                    self.check_connect.set(int(value))
                                else:
                                    print 'Current status: ' + str(self.check_connect.get())
                            ###
                            elif cmd == 'list=':
                                if value:
                                    description = value.split(',')[0]
                                    try:
                                        filename = value.split(',')[1].lstrip()
                                    except IndexError: #no filename
                                        filename = None
                                    try:
                                        if self.filename:
                                            line = self._readComments(description) 
                                            print line
                                            if filename:
                                                output = open(filename, 'w')
                                                output.write(line)
                                                output.close
                                                print '%s succesfully written' %(filename)
                                        else:
                                            print "Error: Log not opened!"
                                    except (AttributeError, TypeError, KeyError, IOError), e:
                                        print 'Error reading. Log opened?'
                            ###        
                            elif cmd == 'log=':
                                if not value == '':
                                    try:
                                        self.openFile(value)
                                    except IOError:
                                        print 'Error: Could not open log!'
                                else:
                                    print 'Current log file: ' + str(self.filename)
                            ###
                            elif cmd == 'lscale=':
                                try:
                                    if value:
                                        try:
                                            value = int(value)
                                        except ValueError:
                                            print 'Invalid argument!'
                                            value = 0
                                        if not self.canvas_man[MainGUI.active_plot][0].logScale == value:
                                            self.logScale()
                                    else:
                                        print 'Logscale is set to', self.canvas_man[MainGUI.active_plot][0].logScale 
                                except (IndexError, TypeError):
                                    print 'Selected plot,', MainGUI.active_plot, ',does not exist'
                            
                            ###
                            elif cmd == 'output=':
                                if value:
                                    [destination, name] = value.split(',')
                                    destination = destination.strip()
                                    name = name.strip()
                                    if destination.lower() == 'printer':
                                        #scale to letter size:
                                        self.startPrint(destination = 0, printer = name, set_ratio = True, width = 8.5, height = 11)
                                    elif destination.lower() == 'file':
                                        self.startPrint(destination = 1, filename = name, set_ratio = True, width = 8.5, height = 11)
                                    self.removeAll()
                                else:
                                    #printing to default
                                    if (MainGUI.output_mode == 0 or MainGUI.output_mode == 1) and MainGUI.output_name:
                                        print 'printing to', MainGUI.output_name
                                        self.startPrint(destination = MainGUI.output_mode, printer = MainGUI.output_name, filename = MainGUI.output_name, set_ratio = True, width = 8.5, height = 11)
                                        self.removeAll()
                                    else:
                                        print 'Error: No default output set!'
                                        print 'Usage: "output= printer/file, printername/filename"'
                            ###
                            elif cmd == 'plot=':
                                try:
                                    if self.logreader.checkDataPresence(value):
                                        if self.check_data.get(value).get()==0: #if non existing
                                            self.check_data.get(value).set(1)
                                        else: #if already exists... remove
                                            self.check_data.get(value).set(0)
                                        self.handleCheck(value)
                                    else:
                                        print 'No such plot is available. Type plots to see available plots'
                                except AttributeError:
                                    print 'Log is not read! Use log= to specify log'
                            ###
                            elif cmd == 'plotall':
                                self.plotAll()
                            ###
                            elif cmd == 'plots':
                                print 'Available plots :'
                                try:
                                    for key in self.settings_dict.keys():
                                        if self.logreader.checkDataPresence(key):
                                            print key
                                except AttributeError:
                                    print 'No plots. Log opened?'
                            ###
                            elif cmd == 'plotxy=':
                                try:
                                    [key1, key2] = value.split(',')
                                except (ValueError):
                                    print 'incorrect input'
                                else:
                                    key1 = key1.strip()
                                    key2 = key2.strip()
                                    try:
                                        if self.logreader.checkDataPresence(key1) and self.logreader.checkDataPresence(key2):
                                            self.handleCheck(key1, key2)
                                        else:
                                            print 'No such plot is available. Type plots to see available plots' 
                                    except AttributeError:
                                        print 'No plots. Log opened?'
                            ###
                            elif cmd == 'removeall':
                                self.removeAll()
                            ###
                            elif cmd == 'reset':
                                try:
                                    self.resetPlot()
                                except (ValueError, IndexError):
                                    print 'Selected plot does not exist! Selected plot is: ', MainGUI.active_plot
                            ###
                            elif cmd == 'scale=':
                                try:
                                    [minY, maxY] = value.split(',')
                                except ValueError:
                                    print 'Incorrect input'
                                else:
                                    self.setY(minY,maxY)
                            ###
                            elif cmd == 'showdisp=':
                                if value == '0':
                                    self.root.wm_withdraw()
                                elif value == '1':
                                    self.root.wm_deiconify()
                            ###
                            elif cmd == 'splitall':
                                self.splitAll()
                            ###
                            elif cmd == 'superall':
                                self.superImposeAll()
                            ###   
                            elif cmd == 'super=':
                                if value == '0' or value == '1':
                                    self.check_superimpose.set(int(value))
                                else:
                                    print 'Current status: ' + str(self.check_connect.get())
                            ###
                            elif cmd == 'timescale=':
                                if not self.plotman.getYYplot():
                                    try:
                                        _l1 = value.split(',')
                                    except ValueError:
                                        print 'Incorrect input'
                                    else:
                                        for k in range(2):
                                            _l1[k] = _l1[k].strip()
                                            if len(_l1[k])==20:
                                                pass
                                            elif len(_l1[k])==17:
                                                _l1[k] += '.00'
                                            elif len(_l1[k])==14:
                                                _l1[k] += ':00.00'
                                            elif len(_l1[k])==11:
                                                _l1[k] += ':00:00.00'
                                            else:
                                                raise ValueError
                                        [minX, maxX]=_l1
                                        self.setX(minX, maxX)
                                else:
                                    print 'The plot is not a timeplot. Use xscale=. '
                            ###
                            elif cmd == 'xscale=':
                                if self.plotman.getYYplot():
                                    [minX, maxX] = value.split(',')
                                    self.setX(minX, maxX)
                                else:
                                    print 'The plot is not an XY plot. Use timescale='
                    except (ValueError, ), e: #catches all invalid inputs not specifically handled...
                        print 'Error: Invalid input! Type help for instructions'
                                
                if match == 0:
                    print 'Command not recognized. Type help for list of commands.'
                
            if cfile_cmd:
                break        

    def cfileRead(self, _filename):
        """cfileRead: help function for batchmode. Feeds batchMode commands from file"""
        cfile = open(_filename, 'r')
        for line in cfile.readlines():
            if line[0]!='#': #comments starts with #
                self.batchMode(line.rstrip())
        self.batchMode()
    
    def buildPlotMenu(self):
        """buildPlotMenu builds plotMenu from control file. """
        self.subplotmenus = {}
        old_text = self.status_text.get()
        self.status_text.set('Building plot menus...')
        description_list = self.settings_dict.keys()[:]
        #check if several keys has the same command. In that case, make cascade menu:
        cascade_list = []
        while description_list:
            key1 = description_list[0]
            label1 = self.settings_dict.get(key1)[4]
            description_list = description_list[1:]
            temp_list = []
            for key2 in description_list[:]:
                if key2[0] == '$':
                    continue
                label2 = self.settings_dict.get(key2)[4]
                if label1 == label2 and label2 != '': #cascade!
                    temp_list.append(key2)
                    description_list.remove(key2)
                    #break
                
            
            if len(temp_list) > 0:
                temp_list.append(key1)
                cascade_list.append(temp_list)
            #description_list.append(key1)
            #cascade_list contains those commands that should be cascaded!
            
        #print cascade_list
        description_list = self.settings_dict.keys()[:]
        #clear old cascade menus
        max_index = len(self.settings_dict.keys())
        try:
            self.subplotmenus.clear()
            extra_menus = 3
            self.plotmenu.delete(0,max_index+extra_menus)
        except AttributeError: #not yet created
            pass      
        #print cascade_list
        #building cascade-list
        for i in range(len(cascade_list)):
        #cascade[0]
            for key in cascade_list[i]: #build cascade_menu
            #if not built:
                group = self.settings_dict.get(key)[4]
                if not self.subplotmenus.has_key(group):
                    self.subplotmenus[group] = Menu(self.plotmenu, tearoff=0)
                
                self.check_data[key] = IntVar()
                if key[-1] == '$':
                    keylabel = key[:-1]
                else:
                    keylabel = key
                self.subplotmenus[group].add_checkbutton(label=keylabel, variable=self.check_data[key], command=lambda key=key: self.handleCheck(key), state=DISABLED)
                #pop key from description_list:
                description_list.remove(key)
            self.plotmenu.add_cascade(label=group, menu=self.subplotmenus[group])
        for key in description_list:
            if not key[0] == '$':
                #check_button variable:
                self.check_data[key] = IntVar()
                #description is keys in settings_dict
                if key[-1] == '$':
                    keylabel = key[:-1]
                else:
                    keylabel = key
                self.plotmenu.add_checkbutton(label=keylabel, variable=self.check_data[key], command=lambda key=key: self.handleCheck(key), state=DISABLED)
        self.plotmenu.add_separator()
        self.plotmenu.add_command(label = 'Plot All', command = lambda: self.plotAll(), underline = 0)
        self.plotmenu.add_separator()
        self.plotmenu.add_command(label = 'XY Plot...', command = lambda:self.xyPlot(), underline = 0)
        self.plotmenu.add_separator()
        self.plotmenu.add_command(label = 'Clear All Plots', command = lambda:self.removeAll(), underline = 0)

        self.status_text.set('Plot menus rebuilt. Please reload log file')
        
        if not self.settings_dict:
            self.status_text.set('Warning: LogPlotter is using an empty or nonexistent control file!')
        
    
    def handleCheck(self,key, key2 = None):
        """handleCheck handles calls from the plotmenu. If a plot is called once, it is plotted. If twice, it is removed. 
           handleCheck can also handle XY-plot. It also sets the plot labels on every update """
        if key2:
            if self.check_absTime.get():
                self.check_absTime.set(0)
                self.absoluteTime()
            self.plot(key,key2)
        elif (self.check_data.get(key).get() == 1): #if checked, plot, otherwise remove existing plot
            self.plot(key)
        else:
            self.removePlot(key)
        #update labels:
        self.setPlotLabels()

        
    def plot(self, key1, key2 = None):
        """plot is called only by handlecheck. Plot calls logreader to get the data, and sends it to plotCanvas. All objects 
#of plotCanvas are saved in a list self.canvas_man[i][0]. The description is saved in self.canvas_man[i][1]"""

        _canvas = Canvas(self.plottingFrame, closeenough = 0)
        _canvas.option_add("*font", fontb)
        if not key2:
            l1 = self.logreader.getList(key1)[:]
            #if there is a YY-plot, remove it
            if self.plotman.getYYplot():
                self.removeAll(1)
            #update all existing plots, if not superimposing
            if not self.check_superimpose.get():
                _plots = self.plotman.addPlot()
            else:
                _plots = PlotManager.active_plots
                if _plots == 0:
                    _plots = self.plotman.addPlot()
        else: #XY-plot!
            if self.plotsetting.get() == 0 or not self.plotman.getYYplot(): #option = create new
                #remove all normal plots:
                self.removeAll()
            if (not self.plotsetting.get() == 2) or PlotManager.active_plots==0: #option = superimpose
                _plots = self.plotman.addPlot()
            else:
                _plots = PlotManager.active_plots
                    
            max_time = None
            timePair=0
            try:
                if self.check_timePair.get()==1:
                    timePair=1
                    try:
                        time =int(self.entry_PairingTime.get())
                    except:
                        time = 1
                    if self.timePairingFormat.get()=='hours':
                        max_time = time
                    elif self.timePairingFormat.get()=='minutes':
                        max_time = time/60.0
                    elif self.timePairingFormat.get()=='seconds':
                        max_time = time/3600.0
            except (AttributeError, ), e: #created from batchmode. no self.timePairing etc..
                pass
            l1 = self.logreader.getListYY(key1,key2, timePair, max_time)
            self.plotman.setYYplot(True)
        
        if _plots>0:
                for i in range(len(self.canvas_man)):
                    self.canvas_man[i][0].redraw()
        _canvas.configure(width = MainGUI.plot_width, height = MainGUI.plot_height/_plots, highlightthickness = 0)
    
        #check superimpose option, later: 
        if (self.check_superimpose.get() and len(self.canvas_man)>0):
            if MainGUI.active_plot>(len(self.canvas_man)-1):
                self.selectLastest()
            self.canvas_man[MainGUI.active_plot][0].plotData(l1, superimpose = 1)
        else:
            _canvas.pack(fill = X, expand = YES)
            _canvas.bind('<Button-1>', (lambda event, type = '<Button-1>': self.onEvent(event, type)))
            _canvas.bind('<Motion>', (lambda event, type = '<Motion>': self.onEvent(event, type)))
            #zooming:
            _canvas.bind('<Control-Button-1>', (lambda event, type = 'zoom': self.setZoomRect(event, type)))
            _canvas.bind('<Control-B1-Motion>', self.onDrag)
            _canvas.bind('<Control-ButtonRelease-1>', self.onZoom)
            #deleting points:
            _canvas.bind('<Button-3>', (lambda event, type = 'delete': self.setZoomRect(event, type)))
            _canvas.bind('<B3-Motion>', self.onDrag)
            _canvas.bind('<ButtonRelease-3>', self.onDelete)
            
            
            self.canvas_man.append([PlotCanvas(_canvas), key1])
            self.canvas_man[-1][0].connectPoints = self.check_connect.get()
            self.canvas_man[-1][0].absTime = self.check_absTime.get()
            self.canvas_man[-1][0].plotData(l1)
            
            
            #make x-axis:
            if PlotManager.active_plots == 1:
                _xaxis = Canvas(self.plottingFrame, width = MainGUI.plot_width, height = MainGUI.xaxis_height, highlightthickness = 0)
                _xaxis.pack(side=BOTTOM)
                self.canvas_man[0][0].createXaxis(_xaxis, self.plotman.getYYplot())
        #autoscale the plot if more than one
        if len(self.canvas_man)>0:# and not self.check_superimpose.get():
            self.canvas_man[-1][0].zoomToAxis()
        
        if key1[-1] == '$':
            keylabel1 = key1[:-1]
        else:
            keylabel1 = key1
        if key2:
            if key2[-1] == '$':
                keylabel2 = key2[:-1]
            else:
                keylabel2 = key2
            self.status_text.set('Plotting ' + ' ' + keylabel1 + ' vs. ' + keylabel2)
        else:
            self.status_text.set('Plotting ' + keylabel1)
        
        if self.check_superimpose.get():
            self.selectLastest(MainGUI.active_plot)
        else:
            self.selectLastest()


    def selectLastest(self, index = None): 
        """selectLatest selects the Latest plots. Works as if the plots was clicked"""
        if index or index == 0:
            MainGUI.active_plot = index
        else:
            #select latest plot:
            MainGUI.active_plot = len(self.canvas_man)-1
        
        for cman in self.canvas_man:
            cman[0].setBorder()
            
        if MainGUI.active_plot>=0:
            self.canvas_man[MainGUI.active_plot][0].setBorder('red')
            
            #update plot details
            _pn = self.plotNames.children['menu']
            _pn.delete(0, END)
            for name in self.canvas_man[MainGUI.active_plot][0].superImposeList.keys():
                _pn.add_command(label = name, command = lambda name = name: self.setMaxMinXY(name))
            if self.selected_Plot.get() in self.canvas_man[MainGUI.active_plot][0].superImposeList.keys():
                self.setMaxMinXY(self.selected_Plot.get())
            else:
                self.setMaxMinXY(name)
        else:
            MainGUI.active_plot = None
    
    def setZoomRect(self, event, type):
        """setZoomRect is accessed on right mouse button click. It accesses the same function in PlotCanvas"""
        if type == 'zoom':
            fill_color = 'yellow'
        elif type == 'delete':
            fill_color = 'red'
        else:
            fill_color = 'black'
            
        self.canvas_man[MainGUI.temp_selected_plot][0].setZoomRect(event, fill_color)
    
    def onDrag(self, event):
        """onDrag is accessed on right mouse button drag. It accesses the same function in PlotCanvas"""
        self.canvas_man[MainGUI.temp_selected_plot][0].onDrag(event)

    def onZoom(self, event):
        """onZoom is accessed on right mouse button release. It accesses the same function in PlotCanvas"""
        #if more than one plot, zoom only y. 
        if PlotManager.active_plots>1:
            self.status_text.set('More than 1 plot. Not zooming X-axis.')
        else:
            self.status_text.set('Zooming plot')
        self.canvas_man[MainGUI.temp_selected_plot][0].onZoom(event)
        #update labels
        self.setPlotLabels()
        #select plot
        self.selectLastest(MainGUI.temp_selected_plot)
    
    def onDelete(self, event):
        """onDelete is help function for onDelete in PlotCanvas. Accessed when deleting multiple points. 
        It simply passes on the event to the PlotCanvas object"""
        self.canvas_man[MainGUI.temp_selected_plot][0].onDelete(event)
        #select plot
        self.selectLastest(MainGUI.temp_selected_plot)
    
    def setY(self, minY=None, maxY=None):
        """setY sets the Y-axis to user specified max and min"""
        if not (minY and maxY):
            minY = self.entry_Ymin.get()
            maxY = self.entry_Ymax.get()
        key = self.selected_Plot.get()
        try:
            minY = float(minY)
            maxY = float(maxY)
        except ValueError:
            self.status_text.set('Error: Invalid input for Y-axis')
        else:
            try:
                #draw this one first.. the others will be plotted nicely anyhow
                self.canvas_man[MainGUI.active_plot][0].datalist = self.canvas_man[MainGUI.active_plot][0].superImposeList.get(key) 
                self.canvas_man[MainGUI.active_plot][0].datalist[0][3] = minY
                self.canvas_man[MainGUI.active_plot][0].datalist[0][4] = maxY
                self.canvas_man[MainGUI.active_plot][0].redraw()
            except (TypeError, IndexError, KeyError):
                self.status_text.set('Error: No plot selected')
            else:
                self.selectLastest(MainGUI.active_plot)
    
    def setX(self, minX = None, maxX = None):
        """setX sets the X-axis to user specified max and min"""
        if not (minX and maxX):
            minX = self.entry_Tmin.get()
            maxX = self.entry_Tmax.get()
        key = self.selected_Plot.get()
        try:
            if not self.plotman.getYYplot():
                minX = self.logreader.lr.makeTimeStamp(minX, 1)
                maxX = self.logreader.lr.makeTimeStamp(maxX, 1)
            else:
                minX = float(minX)
                maxX = float(maxX)
            for key in self.canvas_man[MainGUI.active_plot][0].superImposeList.keys():
                self.canvas_man[MainGUI.active_plot][0].datalist = self.canvas_man[MainGUI.active_plot][0].superImposeList.get(key)
                self.canvas_man[MainGUI.active_plot][0].datalist[0][1] = minX
                self.canvas_man[MainGUI.active_plot][0].datalist[0][2] = maxX
            self.canvas_man[MainGUI.active_plot][0].redraw()
            #refresh x-axis
            self.canvas_man[0][0].xaxis.delete(ALL)
            self.canvas_man[0][0].createXaxis(self.canvas_man[0][0].xaxis, self.canvas_man[0][0].xyPlot)
            #set other plots to new axis:
            if PlotManager.active_plots>1:
                for i in range(len(self.canvas_man)):
                    self.canvas_man[i][0].zoomToAxis()
        except ValueError:
            self.status_text.set('Error: Invalid input for X-axis')
        except (TypeError, IndexError, KeyError):
            self.status_text.set('Error: No plot selected')
        else:
            self.selectLastest(MainGUI.active_plot)
        
    def setPlotLabels(self):
        """setPlotLabels set the plotlabels in the top label. 
        It checks if the plot is superimposed and what color 
        and shape it is drawn with"""
        #reset height:
        self.labelsCanvas.configure(height = MainGUI.label_height)
        #determine step size.. Depends on font size
        step = font.cget('size')+2
        #first, center fileinfo:
        for (i,item) in enumerate(self.labelsCanvas.find_withtag('file_info')):
            x = MainGUI.plot_width/3
            y = step * (i+1) #self.labelsCanvas.coords(item)[1]
            self.labelsCanvas.coords(item, x,y)
        xlim = self.labelsCanvas.bbox('file_info')[2]
        
        if 4*step>MainGUI.label_height:
            cur_height = int(self.labelsCanvas.master.cget('height'))
            self.labelsCanvas.master.configure(height = cur_height+step)
            cur_height = int(self.labelsCanvas.cget('height'))
            self.labelsCanvas.configure(height = cur_height+step)
            

        #delete all old labels:
        self.labelsCanvas.delete('plot_label')
        num = self.labelsCanvas.winfo_width()
        
        #self.labelsCanvas.configure(width = MainGUI.plot_width)
        y=0
        _side = 1 #variable to change side
        for i in range(len(self.canvas_man)):
            _side*=-1
            #change side every other time
            if _side == -1:
                x = step*5+4
                y+=step
            else:
                #if not MainGUI.screenadaptation:
                x = xlim + step*6+50
                if x>MainGUI.plot_width-step*6:
                    x = step*5+4
                    y+=step
            
            self.labelsCanvas.create_text(x-4,y, text = 'Plot ' + str(i+1) + ': ', anchor = E, tags = 'plot_label', font = font)
            descriptions = self.canvas_man[i][0].superImposeList.keys()
            for key in descriptions:
                color = self.canvas_man[i][0].canvas.itemcget(key, 'outline')
                width = self.canvas_man[i][0].canvas.itemcget(key, 'width')
                coords = self.canvas_man[i][0].canvas.coords(key)
                xs = coords[::2]
                ys = coords[1::2]
                label_coord = [None]*len(coords)
                try:
                    middlex = sum(xs)/len(xs)
                    middley = sum(ys)/len(ys)                   
                    for j in range(len(xs)):
                        label_coord[2*j]=xs[j]-middlex+x
                    for j in range(len(ys)):
                        label_coord[1+2*j]=ys[j]-middley+y
                    type = self.canvas_man[i][0].canvas.type(key)
                    if type == 'oval':
                        self.labelsCanvas.create_oval(label_coord, outline = color, width = width, fill = color, tags = 'plot_label')
                    if type == 'rectangle':
                        self.labelsCanvas.create_rectangle(label_coord, outline = color, width = width, fill = color, tags = 'plot_label')
                    if type == 'polygon':
                        self.labelsCanvas.create_polygon(label_coord, outline = color, width = width, fill = color, tags = 'plot_label')
                except (ZeroDivisionError, ), e:
                    pass #don't draw, plot not in view... (i.e after zooming). Not considered an error
                if self.plotman.getYYplot():
                    [key1, key2] = key.split(' vs. ')
                    if key1[-1]=='$':
                        key1 = key1[:-1]
                    if key2[-1]=='$':
                        key2 = key2[:-1]
                    key = key1 + ' vs. ' + key2
                elif key[-1]=='$':
                    key=key[:-1]
                self.labelsCanvas.create_text(x+6,y, text = key, anchor = W, tags = 'plot_label', font = font)
                #move down:
                #check length
                if y>(MainGUI.label_height-step):
                    cur_height = int(self.labelsCanvas.master.cget('height'))
                    self.labelsCanvas.master.configure(height = cur_height+step)
                    cur_height = int(self.labelsCanvas.cget('height'))
                    self.labelsCanvas.configure(height = cur_height+step)
                y += step
            y -= step
        
    
    def absoluteTime(self):
        """absoluteTime is called from the menu and sets the x-scale 
        to show absolute time instead of relative time"""
        #if not xy-plot
        if not self.plotman.getYYplot():
            #if checked...
            _option =  self.check_absTime.get()
            try:
                self.canvas_man[0][0].absTime = self.check_absTime.get()
                xaxis = self.canvas_man[0][0].xaxis
                #clear x-axis
                self.canvas_man[0][0].xaxis.delete(ALL)
                self.canvas_man[0][0].createXaxis(xaxis, False, _option)
            except IndexError: #no plot created
                pass
    
    def connectPoints(self):
        """connectPoints is called from the menus and connects 
        the datapoints on all plots with a line"""
        _option = self.check_connect.get()==1
        for i in range(len(self.canvas_man)):
            self.canvas_man[i][0].connectPoints = _option
            self.canvas_man[i][0].redraw()
            self.selectLastest(MainGUI.active_plot)
        if _option:
            status = 'on'
        else:
            status = 'off'
        self.status_text.set('Connect points is ' + status)


    def grid(self):
        """grid displays a grid net on the plot"""
        try:
            self.canvas_man[MainGUI.active_plot][0].grid = not self.canvas_man[MainGUI.active_plot][0].grid
            self.canvas_man[MainGUI.active_plot][0].redraw()
            if self.canvas_man[MainGUI.active_plot][0].grid:
                status = 'on'
            else:
                status = 'off'
            self.status_text.set('Grid net is ' + status)
            self.selectLastest(MainGUI.active_plot)
        except (IndexError, TypeError):
            self.status_text.set('Error: No plot is selected') 
    
    def logScale(self):
        """logScale displays the selected plot 
        with a log10 base y scale"""
        try:
            self.canvas_man[MainGUI.active_plot][0].logScale = not self.canvas_man[MainGUI.active_plot][0].logScale
            _a = self.canvas_man[MainGUI.active_plot][0].logScale
            self.canvas_man[MainGUI.active_plot][0].redraw()
            self.selectLastest(MainGUI.active_plot)
            #check if logscale was successful: 
            if not _a == self.canvas_man[MainGUI.active_plot][0].logScale:
                self.status_text.set('Error: Log Scale command was not successful. Plot contains zero or negative values')
            else:
                if self.canvas_man[MainGUI.active_plot][0].logScale:
                    status = 'on'
                else:
                    status = 'off'
                self.status_text.set('Log scale is ' + status)
        except (IndexError, TypeError):
            self.status_text.set('Error: No plot is selected')

    def invertScale(self):
        """invertScale inverts the y scale of the selected plot"""
        try:
            self.canvas_man[MainGUI.active_plot][0].invert = not self.canvas_man[MainGUI.active_plot][0].invert
            self.canvas_man[MainGUI.active_plot][0].redraw()
            if self.canvas_man[MainGUI.active_plot][0].invert:
                status = 'on'
            else:
                status = 'off'
            self.status_text.set('Invert scale is ' + status)
            self.selectLastest(MainGUI.active_plot)
        except (IndexError, TypeError):
            self.status_text.set('Error: No plot is selected')
    
    def average(self):
        """average draws a dotted line in the plot to display the average value. 
        The average value is then displayed in the status bar"""
        try:
            self.canvas_man[MainGUI.active_plot][0].average = not self.canvas_man[MainGUI.active_plot][0].average
            self.canvas_man[MainGUI.active_plot][0].redraw()
            if self.canvas_man[MainGUI.active_plot][0].average:
                self.status_text.set('Average value = %s' % (self.canvas_man[MainGUI.active_plot][0].getAverage()))
            #select current
            self.selectLastest(MainGUI.active_plot)
        except (IndexError, TypeError):
            self.status_text.set('Error: No plot is selected')
    
    def superImposeAll(self):
        """superImpose all superimposes all active plots"""
        if PlotManager.active_plots>1:
            #remove all existing plots, set superimposeNext and replot
            _plot_list = []
            for key in self.check_data.keys():
                if self.check_data.get(key).get():
                    _plot_list.append(key)
            self.removeAll()
            self.check_superimpose.set(1)
            for key in _plot_list:
                self.check_data[key].set(1)
                self.handleCheck(key)
            self.check_superimpose.set(0)

    def splitAll(self):
        """splitAll splits all superimposed plots to nonsuperimposed plots"""
        plots = []
        for i in range(len(self.canvas_man)):
            plots.extend(self.canvas_man[i][0].superImposeList.keys())
        #before remove, check if XY-plot
        _xyplot = self.plotman.getYYplot()
        #clear all plots
        self.removeAll()
        #make sure not superimposing
        self.check_superimpose.set(0)
        #plot all again
        for plot in plots:
            if not _xyplot: #if data vs time plot
                self.check_data[plot].set(1)
                self.handleCheck(plot)
            else:
                [key1, key2] = plot.split(' vs. ')
                self.plotsetting.set(1)
                self.handleCheck(key1, key2)

    def resetPlot(self):
        """resetPlot resets all changes made to the active plot"""
        if len(self.canvas_man)>0:
            #delete plot, draw it again
            try:
                keys = self.canvas_man[MainGUI.active_plot][0].superImposeList.keys()
                self.canvas_man[MainGUI.active_plot][0].superImposeList.clear()
                self.check_superimpose.set(0)
                for key in keys:
                    #self.removePlot(key) #remove
                    if not self.plotman.getYYplot():
                        #self.check_data.get(key).set(1)
                        _l = self.logreader.getList(key)
                    else:
                        [key1, key2] = key.split(' vs. ')
                        max_time = None
                        timePair=0
                        try:
                            if self.check_timePair.get()==1:
                                timePair=1
                                try:
                                    time =int(self.entry_PairingTime.get())
                                except:
                                    time = 1
                                if self.timePairingFormat.get()=='hours':
                                    max_time = time
                                elif self.timePairingFormat.get()=='minutes':
                                    max_time = time/60.0
                                elif self.timePairingFormat.get()=='seconds':
                                    max_time = time/3600.0
                        except (AttributeError, ), e: #created from batchmode. no self.timePairing etc..
                            pass
                        _l = self.logreader.getListYY(key1,key2, timePair, max_time)
                    self.canvas_man[MainGUI.active_plot][0].superImposeList[key] = _l
                self.canvas_man[MainGUI.active_plot][0].redraw()
            except (TypeError, IndexError):
                self.status_text.set('Error: Selected plot does not exist')
            
    
    def onEvent(self,event, type):
        """onEvent is called whenever the mouse moves over a plot. That plot is made active and it is displayed by setting
its border red"""
        #print event.state
        if event.x>150:
            _click = '' #A canvas is always clicked, so no problem with assignment. 
            #find canvas_man
            for i in range(len(self.canvas_man)):
                if self.canvas_man[i][0].identifyCanvas(event.widget):
                    _click = i
                    if type == '<Button-1>':
                        status = 'Plot %s selected' %(_click+1)
                        self.status_text.set(status)
                        MainGUI.active_plot = _click
                        #set border red
                        self.canvas_man[i][0].setBorder('red')
                elif type == '<Button-1>':
                    #set border orig. color
                    self.canvas_man[i][0].setBorder()
        
            
            
            if type == '<Motion>':
                MainGUI.temp_selected_plot = _click
                #display x and y of mouse in status bar:
                [xpos, ypos] = self.canvas_man[_click][0].coord.getCartesianXY([event.x,event.y])
                if self.canvas_man[_click][0].logScale:
                    ypos = 10**ypos
                deltaY = self.canvas_man[_click][0].datalist[0][4]-self.canvas_man[_click][0].datalist[0][3]
                ypos = self.engNumber(ypos, deltaY)
                if self.plotman.getYYplot():
                    deltaX = self.canvas_man[_click][0].datalist[0][2]-self.canvas_man[_click][0].datalist[0][1]
                    xpos = self.engNumber(xpos, deltaX)
                else:
                    if self.check_absTime.get():
                        firstday = int(self.logreader.lr.firstday)
                        xpos = self.canvas_man[_click][0].reverseTimeStamp(xpos, firstday)
                    else:
                        xpos = self.canvas_man[_click][0].convertTime(xpos,1)
                self.xypos.set('Y: ' + ypos + ' | X: ' + xpos)
            else:
                #trick to change options in OptionMenu widget
                _pn = self.plotNames.children['menu']
                _pn.delete(0, END)
                for name in self.canvas_man[_click][0].superImposeList.keys():
                    _pn.add_command(label = name, command = lambda name = name: self.setMaxMinXY(name))
                if self.selected_Plot.get() in self.canvas_man[_click][0].superImposeList.keys():
                    self.setMaxMinXY(self.selected_Plot.get())
                else:
                    self.setMaxMinXY(name)
    
    
    def engNumber(self, number, delta): #lite version of engNumber. Only receives one number.
        """engNumber receives a number and the percentage change of max and min in the series the number comes from. 
        Returns the number with appropriate number of digits"""
# greatly simplied to give and gives better precision
        return '%.6g' % number
            
    def setMaxMinXY(self, plotname):
        """setMaxMinXY sets the max/min X's and Y's of the active plot in the right plot detail frame"""
        self.selected_Plot.set(plotname)
        #plot is MainGUI.active_plot
        try:
            header = self.canvas_man[MainGUI.active_plot][0].superImposeList.get(plotname)[0]
            oldTmin = self.entry_Tmin.get()
            oldTmax = self.entry_Tmax.get()
            #delete old entries:
            self.entry_Ymax.delete(0,END)
            self.entry_Ymin.delete(0,END)
            self.entry_Tmax.delete(0,END)
            self.entry_Tmin.delete(0,END)
            
            if self.plotman.getYYplot():
                self.entry_Tmin.insert(0, header[1])
                self.entry_Tmax.insert(0, header[2])
            else:
                try:
                    self.entry_Tmin.insert(0, self.canvas_man[MainGUI.active_plot][0].superImposeList.get(plotname)[1][1])
                except TypeError:
                    self.entry_Tmin.insert(0, oldTmin)
                try:
                    self.entry_Tmax.insert(0, self.canvas_man[MainGUI.active_plot][0].superImposeList.get(plotname)[-1][1])
                except TypeError:
                    self.entry_Tmax.insert(0, oldTmax)
                    
            self.entry_Ymin.insert(0, header[3])
            self.entry_Ymax.insert(0, header[4])
            pts = len(self.canvas_man[MainGUI.active_plot][0].superImposeList.get(plotname))-1-self.canvas_man[MainGUI.active_plot][0].superImposeList.get(plotname).count(None)
            delpts = self.canvas_man[MainGUI.active_plot][0].superImposeList.get(plotname).count(None)
            try:
                delpts += len(self.canvas_man[MainGUI.active_plot][0].backup_data.get(plotname))-1-pts
            except (AttributeError, ), e: #no backup_data = no zoom
                pass
            self.entry_Pts.set(str(pts))
            self.entry_delPts.set(str(delpts))
        except IndexError: #error when all plots are removed and user chooses one. Simply do nothing...
            self.status_text.set('Plot does not exist!') 
    
    def reScale(self):
        """reScale redraws the active plot."""
        #active plot is self.canvas_man[MainGUI.active_plot][0]
        
        if (type(MainGUI.active_plot)==type(1)) and (len(self.canvas_man)>0):
            self.canvas_man[MainGUI.active_plot][0].redraw()
                

    def zoomOut(self):
        """zoomOut redraws the plot in its original size, i.e it is fully zoomed out"""
        #active plot: self.canvas_man[MainGUI.active_plot][0]
        if (type(MainGUI.active_plot)==type(1)) and len(self.canvas_man)>0:
            #information is lost on Zoom, so it has to ge refetched.
            if (self.canvas_man[MainGUI.active_plot][0].zoomCount>0):
                _data = self.canvas_man[MainGUI.active_plot][0].backup_data
                self.canvas_man[MainGUI.active_plot][0].canvas.delete(ALL)
                if len(_data.keys())>1:
                    si=1
                    self.canvas_man[MainGUI.active_plot][0].color = -1
                else:
                    si = 0
                for key in _data.keys():
                    self.canvas_man[MainGUI.active_plot][0].plotData(_data.get(key), superimpose = si)
            #rebuild x-scale
            self.canvas_man[0][0].xaxis.delete(ALL)
            xaxis = self.canvas_man[0][0].xaxis
            self.canvas_man[0][0].createXaxis(xaxis, self.plotman.getYYplot())
        self.setPlotLabels()
        
    def removePlot(self,check):
        """removePlot is called from handleCheck if plot is already plotted. It is then removed by removePlot
        check is the plot description"""
        for i in range(len(self.canvas_man)):
            if self.canvas_man[i][1] == check:
                #if this plotmanager has superimposed plot, remove only the superimposed:
                if len(self.canvas_man[i][0].superImposeList.keys())>1:
                    #remove this datalist, replot with others
                    self.canvas_man[i][0].superImposeList.pop(check)
                    #delete ALL points, 
                    self.canvas_man[i][0].canvas.delete(ALL)
                    #reset colors
                    self.canvas_man[i][0].color=-1
                    for key in self.canvas_man[i][0].superImposeList.keys():
                        _list = self.canvas_man[i][0].superImposeList.get(key)
                        self.canvas_man[i][0].plotData(_list, superimpose = 1)
                    #change name:
                    self.canvas_man[i][1]=key    
                else:      
                    self.canvas_man[i][0].remove(self.plotman.removePlot())
                    #if i=0, move xaxis to 1 (new zero, if present)
                    if (len(self.canvas_man)>1 and i==0):
                        self.canvas_man[1][0].xaxis = self.canvas_man[0][0].xaxis
                    self.canvas_man.pop(i)
                    if PlotManager.active_plots>0:
                        for i in range(len(self.canvas_man)):
                            self.canvas_man[i][0].redraw()
                    break
            else: #check if perhaps the canvas_man has this plot superimposed
                if self.canvas_man[i][0].superImposeList.has_key(check):
                    #pop this list, redraw the plot...
                    self.canvas_man[i][0].superImposeList.pop(check)
                    self.canvas_man[i][0].canvas.delete(ALL)
                    self.canvas_man[i][0].color=-1
                    for key in self.canvas_man[i][0].superImposeList.keys():
                        _list = self.canvas_man[i][0].superImposeList.get(key)
                        self.canvas_man[i][0].plotData(_list, superimpose = 1)
        #update plot labels...
        self.setPlotLabels()
        #display status:
        self.status_text.set('Removing plot ' + check)
        if MainGUI.active_plot>=(len(self.canvas_man)-1):
            self.selectLastest()
        else:
            self.selectLastest(MainGUI.active_plot)

    def plotAll(self):
        """plotAll plots all available plots"""
        #clear all
        self.removeAll()
        #make sure superimpose is not on
        self.check_superimpose.set(0)
        #all available plots are in self.settings_dict.keys()
        for key in self.settings_dict.keys():
            try:
                if self.logreader.checkDataPresence(key): #plot exists
                    self.check_data.get(key).set(1)
                    self.handleCheck(key)
            except (AttributeError), e:
                #logreader is not created, do nothing
                self.status_text.set('No log exists!')

    def removeAll(self, onlyXYremove=0):
        """removeAll removes all plots"""
        #remove XY-plots
        if self.plotman.getYYplot():
            while 1:
                try:
                    self.canvas_man[0][0].remove(self.plotman.removePlot())
                    self.canvas_man.pop(0)
                except IndexError:
                    break
            self.plotman.setYYplot(False)
            self.plotman.setAxisCreated(False)
        elif not onlyXYremove: #remove normal plots
            for keys in self.check_data.keys():
                if self.check_data[keys].get():
                    self.removePlot(keys)
                    self.check_data[keys].set(0)
        #update labels:
        self.setPlotLabels()
        self.status_text.set('All plots removed')

    def closeFile(self):
        """closeFile closes the log and cleares all plots"""
        #clear all plots
        self.removeAll()
        #disable plotmenu
        i=0
        while True:
            try:
                label = self.plotmenu.entrycget(i, 'label')
                #following checks that no cascade menus are disabled
                if (self.settings_dict.has_key(label) or self.settings_dict.has_key(label + '$')):
                    self.plotmenu.entryconfig(i, state = DISABLED)
                i += 1
                #if self.plotmenu.entrycget(index, option)
            except TclError:
                break
        for key in self.subplotmenus:
                old_keyname = ''
                i=0 
                while True:
                    keyname = self.subplotmenus[key].entrycget(i, 'label')
                    self.subplotmenus[key].entryconfig(i, state = DISABLED)
                    if keyname == old_keyname:
                        break
                    else:
                        i+=1
                        old_keyname=keyname
        self.status_text.set('Logfile closed')
        self.labelsCanvas.itemconfig('filename', text= 'Filename: ')
        self.labelsCanvas.itemconfig('station', text= 'Station: ')
        self.labelsCanvas.itemconfig('system', text= '') 
        self.filename = None

    def openFile(self, _filename=None):
        """openFile opens a log. It either opens a file dialog or is called automatically with a filename. 
        After a log is opened, logreader is called, and thereafter, the available plots are made available in the plot menu."""
        #close existing log
        self.closeFile()
        self.status_text.set('Opening file')
        if not _filename:
            _filename = tkFileDialog.askopenfilename(initialdir = IOSettings.default_directory, filetypes=[
                    ('Log files','*.log'),
                    ("Any file", "*"),
                    ])
        if _filename and not os.path.isfile(_filename):
            self.status_text.set('Error: file ' + _filename + ' does not exist')
            _filename = None
        #access Logreader, LogReader.__init__ reads file, builds dictionary
        if _filename:
            self.filename = _filename
            #running logreader in thread!
            self.logreader = LogReader()
            self.logreader.setInit(_filename, self.settings_dict)
            self.logreader.setDaemon(1)
        
            self.logreader.start()
        
        
            y2 = MainGUI.plot_height+MainGUI.xaxis_height-2 
         
            y1=y2-5
            
            color = '#2F9EFF'
            c1 = self.plottingFrame.create_rectangle(1,y1-1,MainGUI.plot_width, y2+1)
            c = self.plottingFrame.create_rectangle(2,y1,2,y2, outline = color, fill = color)
            while self.logreader.isAlive():
                progress = self.logreader.progress
                if not MainGUI.batch_mode:
                    self.plottingFrame.coords(c, 2, y1, (MainGUI.plot_width)/100*progress, y2)
                    self.plottingFrame.itemconfig(c, outline = color, fill = color)
                    self.plottingFrame.update()
                    self.status_text.set('Logfile reading progress: ' + str(progress) + '%')
                    self.progressBar.update()
                else:
                    char = progress/5
                    rem = 100/5-char
                    bar = '[%s%s]' % ('#'*(char), ' '*(rem))
                    middle = 10
                    print '%s%s%%%s' % (bar[:middle],progress,bar[middle:]), '\r',
            self.plottingFrame.delete(c)
            self.plottingFrame.delete(c1)
            
            #self.progressBar.config(bg = old_bg)
            self.status_text.set('Logfile ' + _filename.strip() + ' read succesfully')
            #set plotlist status enabled if data exist.
            length = len(self.settings_dict.keys())
            i=0
            while True: #enable plots only if data is available
                try:
                    keyname = self.plotmenu.entrycget(i, 'label')
                    if self.logreader.checkDataPresence(keyname) or self.logreader.checkDataPresence(keyname+'$'):
                        self.plotmenu.entryconfig(i, state = NORMAL)
                    i +=1
                except TclError:
                    break
            #enable submenus
            for key in self.subplotmenus:
                old_keyname = ''
                i=0
                while True:
                    keyname = self.subplotmenus[key].entrycget(i, 'label')
                    if self.logreader.checkDataPresence(keyname) or self.logreader.checkDataPresence(keyname+'$'):
                        self.subplotmenus[key].entryconfig(i, state = NORMAL)
                    if keyname == old_keyname:
                        break
                    else:
                        i+=1
                        old_keyname=keyname
            #set labels:
            #set filename
            self.labelsCanvas.itemconfig('filename', text = 'Filename: ' + _filename.strip())
            #set station name
            station=self.logreader.getStation()
            if station:
                self.labelsCanvas.itemconfig('station', text = 'Station: ' + station.strip())
            #set system info
            system=self.logreader.getSystem()
            if system:
                self.labelsCanvas.itemconfig('system', text = system.strip())
        


    def readSettings(self):
        """readSettings reads control file specified in IOSettings. Thereafter the plotmenu is rebuilt."""
        try:
            self.settings_dict = self.settings.readSF(IOSettings.default_control_file)
        except (IOError, IndexError):
            if not MainGUI.batch_mode:
                answer = tkMessageBox.askyesno('Error','Control file not found or file corrupt! Quit?\nPress Yes to Quit, No to open edit settings window')
                if answer:
                    sys.exit()
                else:
                    #create 'empty' settings
                    self.settings_dict = {}
                    self.editSettings()
            else:
                self.settings_dict = {}
                print 'Error: Control file ', IOSettings.default_control_file, ' not found or file corrupt. Please specify a proper control file!'
        else:
            #reload menus
            self.buildPlotMenu()
            if self.filename:
                if not MainGUI.batch_mode:
                    answer = tkMessageBox.askyesno('LogPlotter 2', 'Plot menus rebuilt. Log needs to be reloaded. \nReload %s?' %(self.filename))
                    if answer:
                        self.openFile(self.filename)
                    else:
                        self.filename = None
                else:
                    self.filename = None   

    def editSettings(self):
        """editSettings calls the SettingsWindow in which settings can be edited"""
        sw = SettingsWindow()
        sw.option_add('*font', fontb)
        
        sw.focus_set()
        #sw.grab_set()
        sw.wait_window()
        if sw.reload:
            self.settings_dict = sw.settings.settings_dict
            self.buildPlotMenu()
            if self.filename:
                if not MainGUI.batch_mode:
                    answer = tkMessageBox.askyesno('LogPlotter 2', 'Plot menus rebuilt. Log needs to be reloaded. \nReload %s?' %(self.filename))
                    if answer:
                        self.openFile(self.filename)
                    else:
                        self.filename = None
                else:
                    self.filename = None
                   

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
        if MainGUI.output_mode == 0 or MainGUI.output_mode == 1:
            destination.set(MainGUI.output_mode)
        else: 
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
        
        if MainGUI.output_mode == 1:
            filename.insert(0, MainGUI.output_name)
            for format in formats:
                if MainGUI.output_name.upper().count(format):
                    output_format.set(format)
        else:
            filename.insert(0, 'output.PS')
        Label(settingsframe, text = 'Output printer:').grid(row = 3, column = 0, pady =5, sticky = W)
        printer = Entry(settingsframe)
        if MainGUI.output_mode == 0:
            printer.insert(0, MainGUI.output_name)
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

        plots = len(self.canvas_man)
        label_height = self.labelsCanvas.winfo_height()
        plot_height = MainGUI.plot_height
        axis_height = MainGUI.xaxis_height
        tot_height = label_height+plot_height+axis_height
        cConstruct = CanvasConstructor(width = MainGUI.plot_width, height = tot_height, plots = plots)
        #add label
        margin = 50
        cConstruct.addCanvas(self.labelsCanvas, margin-15)
        for i in range(plots):
            cv = self.canvas_man[i][0].canvas
            #canvas_out.scale(ALL, -info_box,0,0.5,0.5)
            #cv.move(ALL,-75,0)
            cConstruct.addCanvas(cv, -margin)
            #cv.move(ALL,200,0)
        #add x-scale if there is one
        if len(self.canvas_man)>0:
            cConstruct.addCanvas((self.canvas_man[0][0].xaxis), -margin)
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
                status = cConstruct.printCanvas(filename, format)
            except IOError: #PIL might cause IO-error
                self.status_text.set('Error: File error while printing to file. Check write permissions')
            else:
                if status == 1: #PIL Error
                    self.status_text.set('Error: Python Imaging Library (PIL) not correctly installed. Can only send output to postscript!')
                else:
                    self.status_text.set('Output sent to %s' % filename)
            cConstruct.destroy()
        elif kw.get('destination')==0: #printer
            if not kw.get('printcommand')==1:
                printcmd = 'lpr'
            else:
                printcmd = 'psprint'
            cConstruct.printCanvas(None, None, printcmd, kw.get('printer'))
            cConstruct.destroy()
    
    def _setOutputFilename(self, suffix, old_name, *novar):
        if suffix == 'EPS':
            suffix = 'PS'
        last_dot = old_name.rfind('.')
        new_name = old_name[:last_dot+1]+suffix
        return new_name
    
    def setToAxis(self):
        """setToAxis simply makes sure the current plot is scaled to the current x-axis. The purpose of this is so that 
        a plot can be scaled to a zoomed x-axis"""
        if (type(MainGUI.active_plot)==type(1)):
            self.canvas_man[MainGUI.active_plot][0].zoomToAxis() 

    def xyPlot(self):
        """xyPlot sets the settings for plotting an XY-plot. It calls xyPlot_OK on OK."""
        ######################XYPLOTTING!
        self.xyPlotTop = Toplevel()
        self.xyPlotTop.focus_set()
        topframe = Frame(self.xyPlotTop)
        topframe.pack(side = TOP)
        xlabelframe = LabelFrame(topframe, text = 'Y values', padx=5, pady=5)
        xlabelframe.grid(row=0, column = 0, rowspan = 3)
        ylabelframe = LabelFrame(topframe, text = 'X values', padx=5, pady=5)
        ylabelframe.grid(row=0, column = 1, rowspan = 3)
        plotsettingsframe = LabelFrame(topframe, text = 'Plot Settings', padx=5, pady=5)
        plotsettingsframe.grid(row = 1, column = 2, padx=5, pady=5)
        timePairingFrame = LabelFrame(topframe, text = 'Time Pairing', padx= 5, pady=5)
        timePairingFrame.grid(row=2, column = 2, padx =5, pady=5)
        buttonframe = Frame(self.xyPlotTop)
        buttonframe.pack(side = TOP)
        Button(buttonframe, text = 'Clear Plots', command = lambda:self.removeAll()).pack(side = RIGHT)
        Button(buttonframe, text = 'Cancel', command = lambda:self.xyPlotTop.destroy()).pack(side = RIGHT)
        Button(buttonframe, text = 'Apply', command = lambda:self.xyPlot_OK()).pack(side = RIGHT)
        Button(buttonframe, text = 'OK', command = lambda:self.xyPlot_OK(1)).pack(side = RIGHT)
        
        ###########################XY's
        xscrollbar = Scrollbar(xlabelframe, orient = VERTICAL)
        self.xlistbox = Listbox(xlabelframe, exportselection = 0, yscrollcommand=xscrollbar.set)
        self.xlistbox.pack(side = LEFT)
        xscrollbar.config(command = self.xlistbox.yview)
        xscrollbar.pack(side=RIGHT, fill=Y)

        yscrollbar = Scrollbar(ylabelframe, orient = VERTICAL)
        self.ylistbox = Listbox(ylabelframe, exportselection=0, yscrollcommand = yscrollbar.set)
        self.ylistbox.pack(side = LEFT)
        yscrollbar.config(command = self.ylistbox.yview)
        yscrollbar.pack(side=RIGHT, fill=Y)
        
        ######add options to plotsettings
        Radiobutton(plotsettingsframe, text = 'New Plot (erases old)', variable = self.plotsetting, value = 0).pack(anchor = W)
        Radiobutton(plotsettingsframe, text = 'Plot after existing (using its X axis)', variable = self.plotsetting, value = 1).pack(anchor = W)
        Radiobutton(plotsettingsframe, text = 'Superimpose on existing plot', variable = self.plotsetting, value = 2).pack(anchor = W)   
        
        ############timePairingFrame
        self.timePairingFormat = StringVar()
        self.timePairingFormat.set('seconds')
        self.check_timePair = IntVar()
        Checkbutton(timePairingFrame, text ='On/Off', variable = self.check_timePair).grid(row=0, column=0)
        optmenu=OptionMenu(timePairingFrame, self.timePairingFormat, 'seconds', 'minutes', 'hours')
        optmenu.grid(row=0, column=1)
        Label(timePairingFrame, text='Max time: ').grid(row=1, column=0)
        self.entry_PairingTime = Entry(timePairingFrame)
        self.entry_PairingTime.grid(row=1, column=1)
        self.entry_PairingTime.insert(0, 60)
        ######add plotnames
        for key in self.check_data.keys():
            try:
                if self.logreader.checkDataPresence(key):
                    self.xlistbox.insert(END, key)
                    self.ylistbox.insert(END, key)
            except AttributeError: #nofile is opened
                self.status_text.set('No log file is opened! Closing XY plot window. ')
                self.xyPlotTop.destroy()
                break 
        
    def xyPlot_OK(self, close = 0):
        """xyPlot_OK is called by xyPlot. It thereafter calls handleCheck with two parameters. 
        It then plots an XY-plot"""
        #get selection from self.(x/y)listbox
        #for new plot, do nothing
        xkey = self.xlistbox.get(ACTIVE)
        ykey = self.ylistbox.get(ACTIVE)
        if self.plotsetting.get() == 2:
            self.check_superimpose.set(1)
        else:
            self.check_superimpose.set(0)
        if xkey and ykey:
            self.handleCheck(xkey,ykey)
        if close == 1:
            self.xyPlotTop.destroy() 
  
    def IOSettings(self):
        """IOSettings calls ios.gui, which is the gui for IOSettings. 
        Pops up window with setup for I/O Settings"""
        self.ios.gui()

    def about(self):
        """about displays a message with information about logpl"""
        message = """LogPlotter 2 \nVersion 2.2.0 (10/06/2008)\n\nLogplotter reads and plots logfiles with Field System Data\nIt is developed for Python 2.4 (and higher 2.x versions). \nVersion on this system is """ + sys.version
        return message
        
    
    def getComments(self):
        """getComments pops up new toplevel window. It has tools to extract information from the logfile. 
        The actual extracting is done by the internal function _readComments.  
        """
        if self.filename:
            #open getcomments window
            top = Toplevel()
            topFrame = Frame(top)
            topFrame.pack()
            Label(topFrame, text = 'Logfile: ' + self.filename).grid(row = 0, column = 0, columnspan = 2, sticky = W)
            
            Label(topFrame, text = 'Command to list: ').grid(row = 1, column = 0, sticky = W)
            cmd = Entry(topFrame, width = 32)
            cmd.grid(row = 1, column = 1, sticky = W)
            cmd.insert(END, '"')
            
            txtFrame = Frame(top, pady = 10, padx = 5)
            txtFrame.pack(fill = BOTH, expand = 1, anchor = NW)
            txtFrame.grid_rowconfigure(0, weight= 1)
            
            yscrollbar = Scrollbar(txtFrame, orient = VERTICAL)
            xscrollbar = Scrollbar(txtFrame, orient = HORIZONTAL)
            #global textbox
            textbox = Text(txtFrame, yscrollcommand = yscrollbar.set, xscrollcommand = xscrollbar.set, bg = 'white', relief = SUNKEN, wrap = NONE, font = ('Courier', 11, 'normal'))
            textbox.grid(row = 0, column = 0, sticky = N+W+S+E)
            txtFrame.grid_columnconfigure(0, weight = 1)
            yscrollbar.config(command = textbox.yview)
            yscrollbar.grid(row = 0, column = 1, sticky = N+S)
            xscrollbar.config(command = textbox.xview)
            xscrollbar.grid(row=2, column = 0, columnspan = 2, sticky = E+W)
            
            bottomFrame = Frame(top)
            bottomFrame.pack()
            Button(bottomFrame, text = 'List', command = (lambda: textbox.insert(END,self._readComments(cmd.get())))).pack(side = LEFT)
            Button(bottomFrame, text = 'Clear', command = (lambda: textbox.delete(1.0, END))).pack(side = LEFT)
            top.minsize(width = 200, height = 550)
            
            menubar = Menu(top)
            filemenu = Menu(menubar, tearoff = 0)
            filemenu.add_command(label = 'Save to file', command = (lambda: tkFileDialog.asksaveasfile().writelines(textbox.get(1.0, END))), underline = 0)
            filemenu.add_separator()
            filemenu.add_command(label = 'Print', command = lambda: self.printText(textbox.get(1.0, END)), underline = 0)
            filemenu.add_separator()
            filemenu.add_command(label = 'Close', command = lambda: top.destroy(), underline = 0)
            menubar.add_cascade(label = 'File', menu = filemenu, underline = 0)
            top.config(menu = menubar)
        else:
            self.status_text.set('Error: No logfile opened')
            
    def _readComments(self, cmd):
        """_readComments is an internal function. Extracts data from logfile and returns the data. 
        """
        #textbox.delete(1.0, END)
        text = ''
        try:
            logfile = open(self.filename)
        except IOError:
            text = 'IOError'
        else:
            for line in logfile.readlines():
                if line[21:21+len(cmd)]==cmd:
                    #textbox.insert(END, line)
                    text += line
            logfile.close()
        return text
    
    
    def listData(self):
        """listData pops up window with functions to list data from the logfile """
        if self.filename:
            top = Toplevel()
            txtFrame = Frame(top)
            txtFrame.pack(side = TOP, expand = 1, fill = BOTH, anchor = NW)
            
            scrollbar = Scrollbar(txtFrame, orient = VERTICAL)
            txt = Text(txtFrame, yscrollcommand = scrollbar.set, bg = 'white')
            txt.pack(side = LEFT, expand=1, fill = BOTH)
            scrollbar.config(command = txt.yview)
            scrollbar.pack(side=LEFT, fill=Y)
            
            menubar = Menu(top)
            filemenu = Menu(menubar, tearoff = 0)
            filemenu.add_command(label = 'Save to file', command = (lambda : tkFileDialog.asksaveasfile().writelines(txt.get(1.0, END))), underline = 0)
            filemenu.add_separator()
            filemenu.add_command(label = 'Print', command = lambda: self.printText(txt.get(1.0, END)), underline = 0)
            filemenu.add_separator()
            filemenu.add_command(label = 'Close', command = lambda: top.destroy(), underline = 0)
            menubar.add_cascade(label = 'File', menu = filemenu, underline = 0)
            
            plotmenu = Menu(menubar, tearoff = 0)
            
            top.config(menu = menubar)
            top.minsize(width = 510, height = 100)
            
            for a in self.settings_dict.keys():
                if a[0] != '$' and self.logreader.checkDataPresence(a):
                    plotmenu.add_command(label = a, command = (lambda text = self._getList(a): txt.insert(END, text)))
            plotmenu.add_separator()
            plotmenu.add_command(label = 'Clear List', command = lambda : txt.delete(1.0, END))
            menubar.add_cascade(label = 'Data', menu = plotmenu, underline = 0)
        else:
            self.status_text.set('Error: No logfile opened')  
        
    def _getList(self, key):
        """_getList is an internal function used by listData"""
        #clear old text:
        #txt.delete(1.0, END)
        header = 'Logfile: %s\nData: %s\n\n\tdate \t \t data\n' %(self.filename, key)
        header += '-'*55+'\n'
        _dlist = self.logreader.getList(key)
        data = header
        for line in _dlist[1:]:
            data += '%s \t %s\n' %(line[1], line[0])
    
        data += '-'*55+'\n\n'
        return data
    
    def printText(self, text):
        """printText sends string variable to the printer spooler. 
        Used by functions getList and getComments. """
        self.printTextTop = Toplevel()
        self.printTextTop.resizable(width = 0, height = 0)
        mainFrame = LabelFrame(self.printTextTop, padx = 5, pady = 5)
        mainFrame.pack(pady = 10, padx = 10)
        topframe = Frame(mainFrame)
        topframe.pack(pady = 5, padx = 5)
        Label(topframe, text = 'Printer name:').pack(side = LEFT)
        printername = StringVar()
        Entry(topframe, textvariable = printername).pack(side = LEFT)
        Label(mainFrame, text = 'Leave blank for default printer', anchor = W).pack(pady = 5, padx = 5)
        bframe = Frame(mainFrame)
        bframe.pack(pady = 5, padx = 5)
        Button(bframe, text = 'Print', command = lambda : self._printText_ok(text, printername.get())).pack(side = LEFT)
        Button(bframe, text = 'Cancel', command = lambda: self.printTextTop.destroy()).pack(side = LEFT)
    
    def _printText_ok(self, text, printername):
        self.printTextTop.destroy()
        if printername:
            printerspool = os.popen('lpr -P %s' % (printername), 'w')
        else:
            printerspool = os.popen('lpr', 'w')
        printerspool.write(text)
        printerspool.close()
    
    def changeShapeColor(self):
        """changeShapeColor calls ColorSelector which is a
        Toplevel window with options to change the shape and
        color of the datapoints. 
        """
        try:
            shapes_and_colors = self.canvas_man[MainGUI.active_plot][0].colorlist
        except (IndexError, TypeError):
            self.status_text.set('Error: No plot is selected')
        else:
            csc = ColorSelector(shapes_and_colors)
            csc.wait_window()
            if csc.applyToAll:
                for i in range(len(self.canvas_man)):
                    self.canvas_man[i][0].colorlist = shapes_and_colors
                    self.canvas_man[i][0].redraw()
            elif csc.applyToSelected:
                self.canvas_man[MainGUI.active_plot][0].colorlist = shapes_and_colors
                self.canvas_man[MainGUI.active_plot][0].redraw()
            self.setPlotLabels()
    
    def changeHeightWidth(self, event = None):
        """changeHeightWidth is automatically called whenever the logpl 
        window is resized. The plots are then redrawn to fit the new geometry. 
        Plotlabels is also redrawn. 
        """
        height = self.plottingFrame.winfo_height()
        width = self.plottingFrame.winfo_width()
        
        MainGUI.plot_height = height - MainGUI.xaxis_height
        if not event:
            width = MainGUI.plot_width #already set   
        
        MainGUI.plot_width = width
        
        
        #get leftside reference using an entry-box. Using Ymin, but could have used anyone
        leftside_width = self.entry_Ymin.master.master.master.winfo_reqwidth()
        #By setting the geometry, I prevent to get caught in loops. 
        self.root.geometry('%sx%s' % (width + leftside_width, self.root.winfo_height()))
        
        try:
            #update plots:
            for i in range(len(self.canvas_man)):
                self.canvas_man[i][0].redraw(width)
            #xaxis
            _option =  self.check_absTime.get()
            xaxis = self.canvas_man[0][0].xaxis
            #clear x-axis
            
            self.canvas_man[0][0].xaxis.delete(ALL)
            self.canvas_man[0][0].createXaxis(xaxis, self.plotman.getYYplot(), _option)
            self.selectLastest(MainGUI.active_plot)
            
            
        except (IndexError, AttributeError):
            pass
        self.setPlotLabels()
        return 'break'
        
    def setToDim(self, width=8.5, height= 11.0):
        """setToDim is a help function for the printing tools. 
        It sets the plots to fit a certain geometry. Default is
        letter size (8.5in x 11in)
        """
        x = float(width)/float(height)*1.03
        #let plot height be fixed...
        side_width = self.root.winfo_width() - MainGUI.plot_width
        
        tot_height = MainGUI.plot_height + self.labelsCanvas.winfo_height()
        MainGUI.plot_width = int(x*tot_height)#1.6
        width = int(MainGUI.plot_width+side_width)
        height = int(self.root.winfo_height())
        self.root.geometry('%sx%s' % (width, height))
        self.changeHeightWidth(None)
    
    def fontSize(self, delta):
        """fontSize takes input argument delta as either 'increase' or 'decrease' on which it 
        either adds +/- 2 to the font size. This applies to all text in lopgl
        """ 
        
        size = font.cget('size')
        if delta == 'increase':
            size +=2
        else:
            size -= 2
        
        size = max(size, 8)
        size = min(size, 14)
        
        font.configure(size = size)
        fontb.configure(size = size)
        
        if len(self.canvas_man)>0:
            PlotCanvas.font.configure(size = size)
        
        
    def startDrag(self, event):
        """startDrag is initated when a plot is dragged 
        while holding the shift key. A copy of the plot is made
        that follows the mouse coordinates. 
        """
        #selected plot is MainGUI.active_plot
        #create_window is drawn on top of all canvases!
        #first, copy canvas:
        
        if event.x>150 and len(self.canvas_man)>1:
            try:
                cp  = self.canvas_man[MainGUI.active_plot][0].canvas
                height = int(cp.cget('height'))
                event.y += height*MainGUI.active_plot
                if not self.plottingFrame.find_withtag('copy_window'):
                    canvas_copy = Canvas(self.plottingFrame, highlightthickness = 2)
                    canvas_copy = self.copyCanvas(cp, canvas_copy)
                    self.plottingFrame.create_window(event.x, event.y, window = canvas_copy, anchor = 'center', tags = ('copy_window', MainGUI.active_plot), state = DISABLED)
                else:
                    self.plottingFrame.coords('copy_window', event.x, event.y)
            except TypeError:
                pass
    
    def releaseDrag(self,event):
        """releaseDrag superimposes the plot from which the drag started on 
        the plot at the mouse's current position. 
        """
        try:
            if self.plottingFrame.find_withtag('copy_window'):
                if event.x>150:
                    try:
                        item = self.plottingFrame.find_withtag('copy_window')
                        from_canvas = int(self.plottingFrame.gettags(item)[1])
                        height = float(self.canvas_man[MainGUI.active_plot][0].canvas.cget('height'))
                        event.y += height*MainGUI.active_plot
                        to_canvas = int(event.y/height)
                        if to_canvas != from_canvas:
                            #superimpose all plots in from_canvas on to_canvas
                            #plots on from_canvas:
                            plots = self.canvas_man[from_canvas][0].superImposeList.keys()
                            #delete from_canvas
                            if not self.plotman.getYYplot():
                                for key in plots:
                                    self.check_data.get(key).set(0)
                                    self.handleCheck(key)
                            else:
                                self.plotsetting.set(2)
                                self.canvas_man[from_canvas][0].remove(self.plotman.removePlot())
                                self.canvas_man.pop(from_canvas)
                            old_option = self.check_superimpose.get()
                            #check superimpose option
                            self.check_superimpose.set(1)
                            if from_canvas<to_canvas:
                                to_canvas -=1
                            MainGUI.active_plot = to_canvas
                            for key in plots:
                                if not self.plotman.getYYplot():
                                    self.check_data.get(key).set(1)
                                    self.handleCheck(key)
                                else:
                                    [key, key2] = key.split(' vs. ')
                                    self.handleCheck(key, key2) 
                            self.check_superimpose.set(old_option)
                    except (IndexError):
                        pass
                self.plottingFrame.delete('copy_window')
        except TclError:
            pass
        
    def copyCanvas(self, canvas_in, canvas_out):
        """copyCanvas receives to canvases, and copies one
        to the other and returns it. 
        """
        kw = {}
        list = canvas_in.find_withtag('datadot')
        #list = list + canvas_in.find_withtag('border')
        for item in list:
            type = canvas_in.type(item)
            coords = canvas_in.coords(item)
            kw['outline'] = canvas_in.itemcget(item, 'outline')
            kw['fill'] = canvas_in.itemcget(item, 'fill')
            kw['width'] = canvas_in.itemcget(item, 'width')
            canvas_out._create(type, coords, kw)
        info_box = 150
        canvas_out.scale(ALL, -info_box,0,0.5,0.5)
        bbox = canvas_out.bbox(ALL)
        width = bbox[2]-bbox[0]
        height = bbox[3]-bbox[1]
        canvas_out.config(height = height, width = width)
        return canvas_out
    
    def printError(self, error_text):
        """printError prints whatever is sent to the status bar
        when in batch mode.
        """
        if MainGUI.verbose:
            print error_text
        elif error_text.lower().count('error'):
            print error_text

class LogReader(threading.Thread):
    """
    ###############################################################
    #Receives filename from MainGUI, opens file, and 
    #send line by line to linereader. Receives data from linereader,
    #puts it in a dictionary, sends list back to MainGUI
    #Reads in the entire dictionary when new file is opened
    ###############################################################
    """
    
    def setInit(self, filename, settings_dict):
        """setInit sets initial variables. __init__ not used since it 
        inherits threading.Thread's __init__. 
        """
        self.filename = filename
        self.settings_dict = settings_dict
        self.progress = 0
        self.prev_progress = -1
        
    def run(self):
        """run is accessed by LogReader.start() (inherited from threading.Thread). 
        Reads file specified in setInit, and sends line by line to LineReader. Builds
        dictionary of information. Records reading progress in self.progress. 
        """
        filename = self.filename
        settings_dict = self.settings_dict
        self.settings = settings_dict
        self.initialize = 1
        fileobject = open(filename, 'r')
    
        self.database = {}
        self.lr = LineReader(settings_dict)
        file_lines = fileobject.readlines()
        tot_lines = len(file_lines)
        percentage = max(int(tot_lines/100),1)
        ten_percent = percentage
        self.progress = 0
        for (line_no, line) in enumerate(file_lines):
            datalist = self.lr.getData(line)
            if datalist:
                #for loop to support several matches:
                for i in range(len(datalist[0])):
                    templist = []
                    templist.append(datalist[1][i])
                    templist.extend(datalist[2:])
                    try:
                        self.database[datalist[0][i]].append(templist)
                    except KeyError:
                        self.database[datalist[0][i]]=[templist]
            #progress:
            if line_no == percentage:
                percentage += ten_percent
                self.progress = int(float(line_no+1)/tot_lines*100+1)
        #read stationname:
        fileobject.seek(0)
        self.firstLine = fileobject.readline()
        self.secondLine = fileobject.readline()
        #self.getFilename(fileobjekt.readline())
        fileobject.close()
    
    def getSystem(self):
        """getSystem returns system information from logfile if there is any. 
        Otherwise, 'No information' is returned. 
        """
        try:
            return self.firstLine[21:-1]
        except:
            return 'No information'
    
    def getStation(self):
        """getStation returns station name if there is one. Otherwise, 
        'not specified' is returned. 
        """
        _lineoffset = self.secondLine.find('location')
        if _lineoffset != -1:
            try:
                _line = self.secondLine[_lineoffset + len('location'):].split(',')
                return _line[1] + ' starting ' + self.firstLine[:20]
            except IndexError:
                return 'Not specified'
    
    def getList(self, key,index=0):
        """getList returns data for specified key. List is in order:
        [data, date, timeStamp], where timeStamp is the date, calculated in 
        relative hours from starting time. 
        """
        _list = self.prepareList(key)
        return _list

    def getListYY(self, key1, key2, timePair, max_time):
        _list1 = self.database.get(key1)[:]
        _list2 = self.database.get(key2)[:]
        #fix xlist, ylist
        if timePair:
            [_list1, _list2] = self.fixXYlist(_list1,_list2, max_time)
        #extract y-coordinates
        ylist1 = map(operator.itemgetter(0), _list1)
        #extract y-coordinates
        ylist2 = map(operator.itemgetter(0), _list2)
        #max, min:
        maxY1 = max(ylist1)
        minY1 = min(ylist1)
        maxY2 = max(ylist2)
        minY2 = min(ylist2)
        #build datalist compatible with original version:
        datalist = []
        #header:
        keylabel1=key1
        keylabel2=key2
        #if keylabel1[-1]=='$':
        #    keylabel1 = keylabel1[:-1]
        #if keylabel2[-1]=='$':
        #    keylabel2 = keylabel2[:-1]
        description = keylabel1 + ' vs. ' + keylabel2
        datalist.append([description, minY2, maxY2, minY1, maxY1])
        #data
        length = 0

        if len(ylist1)>len(ylist2):
            length = len(ylist2)
        else:
            length = len(ylist1)

        for i in range(length):
            datalist.append([ylist1[i],0,ylist2[i],0])

        return datalist
   
#################################
#Fixes lists used by XY-plots. If timedifference between to values too large, scratch it...
#Assume list is ordered
################################    
    def fixXYlist(self,xlist,ylist, max_time):        
        new_xlist = []
        new_ylist = []
        #print 'Entering...', len(xlist), len(ylist)
        for xs in xlist:
            xtime = xs[2]
            timediff = []
            for ys in ylist:
                ytime = ys[2]
                timediff.append(abs(xtime-ytime))
            #get min time
            if timediff:
                time = min(timediff)
                if time<=max_time:
                    #print time          
                    index = timediff.index(time)
                    new_xlist.append(xs)
                    new_ylist.append(ylist[index])
                    #pop from the old lists
                    ylist.pop(index)       
        #print 'Returning...', len(xlist), len(ylist), len(new_xlist), len(new_ylist)
        if not (new_xlist and new_ylist):
            return [xlist, ylist]
        else:
            return [new_xlist, new_ylist]
                    
 
    def prepareList(self,key):
        description = key
        datalist = self.database.get(key)[:]
        #find max and min
        data = map(operator.itemgetter(0), datalist)
        timestamp = map(operator.itemgetter(2), datalist)
        datalist.insert(0, [description, min(timestamp),max(timestamp), min(data), max(data)])
        return datalist

    def checkDataPresence(self, key): #returns true if data present, otherwise false
        return self.database.__contains__(key)

#Class that receives a line (probably read from an output stream), and what is to identified, identifies data and returns it
class LineReader:
    def __init__(self, settings_dict):
        self.initiate = 1
        self.firstday = 0
        #copy settings:
        self.settings_dict = settings_dict
        self.identification_table = self.settings_dict.keys()
        temp_table1 = []
        temp_table2 = []
        self.channel_identifier={}

    def getData(self, line):
        channel_locator = 0
        match_number = 0 #keeps track of number of matches per line
        for key in self.identification_table:
            match = self.settings_dict.get(key)[0]            
            #if channel_locator:
            if key[0]=='$':
                channel_locator = 1
            else:
                channel_locator = 0
            match_length = len(match)
            #print match, line[20:20+match_length]
            #if (line[20:20+match_length]==match):
            position1 = line[20:].find(match)
            if position1 != -1:
                #break
                position1 += 20
                #find string
                #read settings
                splitsign = self.settings_dict[key][1]
                match_string = self.settings_dict.get(key)[3]
                if splitsign.strip() == '':
                    splitsign = None
                offset = int(self.settings_dict[key][2])-1
                if channel_locator==1:
                    position = -1
                    _pos =position1+match_length
                    search_string = line[_pos:-1].split(splitsign)
                    try:
                        if search_string[offset]==match_string:
                                self.channel_identifier[key]=1
                    except IndexError:
                        pass
                else:
                    if match_string=='':    #if no match_string, don't try to find it
                        position = 0
                    else:
                        position = line[position1+match_length:-1].find(match_string)
                if (position != -1):
                    if match_number == 0:
                        data = []
                        keylist = []
                    match_number += 1
                    if offset<0: #negative offset
                        offset = offset * (-1)-1
                        position += match_length + position1
                    else:
                        position = position1 + match_length 
                    _sdata = line[position:-1].split(splitsign)
                    _sdata[-1] = _sdata[-1].strip(';')
                    no_match = 0
                    #if pair command:
                    if key[-1]=='$':
                        try:
                            #print self.channel_identifier
                            if self.channel_identifier['$' + key[:-1]]==1:
                                self.channel_identifier['$' + key[:-1]]=0
                            else:
                                no_match = 1
                                match_number -=1
                        except KeyError:
                            #no match = no data
                            no_match = 1
                            match_number -=1
                    if no_match == 0:
                        try:
                            _d = _sdata[offset].strip(string.ascii_letters+string.whitespace)
                            data.append(float(_d))
                        except (IndexError, ValueError): #if no data or not number
                            match_number -= 1
                            break
                        else:
                            keylist.append(key) #remove end line characters
                            date = line[0:20]
                            timeStamp = self.makeTimeStamp(date)

        if match_number>0:
            return [keylist,data,date,timeStamp]

    def makeTimeStamp(self, date, nodayfix = None):
        #skip year when making timestamp
        timestamp = date.split(':')
        timeydh = timestamp[0].split('.')
        #if first time accessed....
        if (self.initiate == 1):
            self.firstday = int(timeydh[1])
            self.initiate = 0
            if int(timeydh[0]) % 4 == 0: #leap year
                self.days_per_year = 366
            else:
                self.days_per_year = 365
        day_fix = int(timeydh[1])-self.firstday
        if day_fix<0 and not nodayfix:
            day_fix += self.days_per_year 
        days = day_fix*24
        #timestamp in hours (float)
        hours = int(timeydh[2])
        minutes = float(timestamp[1])/60
        seconds = float(timestamp[2])/3600.0
        timestamp = hours + minutes + seconds+days
        return timestamp   


