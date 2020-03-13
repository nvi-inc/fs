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
from idlelib.TreeWidget import TreeItem, TreeNode

class HelpFrame(Toplevel):
    
    def __init__(self, parent = None, _fontsize = None):
        global fontsize
        if not _fontsize:
            fontsize = 8
        else:
            fontsize = int(_fontsize)
        Toplevel.__init__(self, parent)
        self.createLeftSide()
        self.createRightSide()
    
    def createLeftSide(self):
        leftSide = Frame(self)
        leftSide.pack(side = LEFT, anchor = NW, expand = 1, fill = BOTH)        
        canvas = Canvas(leftSide)
        scrollbar = Scrollbar(leftSide, orient = VERTICAL)
        canvas.config(bg = 'white', scrollregion = canvas.bbox(ALL), yscrollcommand = scrollbar.set)
        canvas.pack(side=LEFT, expand = 1, fill = BOTH)
        scrollbar.config(command = canvas.yview)
        scrollbar.pack(side=LEFT, fill=Y)
        l1 = self.createTOC()
        item = HelpMenu('Contents', 1, l1)
        node = TreeNode(canvas, None, item)
        node.update()
        node.expand()        
    
    def createTOC(self):
        TOC = [['Introduction', 'On Field System Log Files'],
               ['Graphical User Interface', 'Main Screen', 
               ['File Menu','Open Log', 'Close Log', 'Edit I/O Settings', 'List Log', 'List Data', 'Print Plot(s)', 'Quit'],
               ['Plotting Menu','Plot descriptions', 'Plot All', 'XY Plot...', 'Clear All Plots'],
               ['Options Menu', 'Connect Data Points', 'Superimpose Next', 'Superimpose All', 'Split All', 'Grid', 'Log Scale', 'Invert Scale', 'Display Average', 'Display Absolute Time'],
               ['Settings Menu', 'Reload Default Settings', 'Edit Control File', 'Edit Control File in a Text Editor'], 
               ['Help Menu', 'Help Contents', 'About logpl']],
               ['Mouse Actions', 'Selecting Plots', 'Zooming Plots', 'Deleting Single Points', 'Deleting Selection of Points', 'Superimposing Plots'],
               ['Batch Mode', 'Commands', 'Writing Scripts for Logpl'], ['Starting Logpl']]
        return TOC
    
    def textOut(self, text):
        print text
    
    def createRightSide(self):
        rightSide = Frame(self)
        rightSide.pack(side = LEFT, anchor = NW, expand = 1, fill = BOTH)
        scrollbar = Scrollbar(rightSide, orient = VERTICAL)
        global textbox
        textbox = Text(rightSide, yscrollcommand = scrollbar.set, bg = 'white', relief = SUNKEN, wrap = WORD)
        textbox.pack(side=LEFT, expand = 1, fill = BOTH)
        scrollbar.config(command = textbox.yview)
        scrollbar.pack(side=LEFT, fill=Y)


class HelpMenu(TreeItem):
    def __init__(self, node, expandable, sublist=None):
        self.node = node
        self.expandable = expandable
        self.sublist = sublist
            
    def GetText(self):
        node = self.node
        return node
    
    def IsExpandable(self):
        return self.expandable

    def GetSubList(self):
        if self.sublist:
            prelist = self.sublist
            l1 = []
            for node in prelist:
                if type(node)==type([]):
                    l1.append(HelpMenu(node[0],1,node[1:]))
                else:
                    l1.append(HelpMenu(node,0))
            return l1
    
    def OnDoubleClick(self):
        node = self.node
        if type(node) == list:
            text = node[0]
        else:
            text = node
        textbox.delete(1.0, END)
        textbox.insert(END, text + '\n', 'header')
        headerfont = ('Helvetica', fontsize, 'bold')
        textfont = ('Helvetica', fontsize, 'normal')
        textbox.tag_config('header', font = headerfont, underline = 1)
        ######################insert text
        helptext = ''
        if text.lower().strip() == 'introduction':
            helptext = """logpl2 is a new version of logpl, but written in Python. The purpose of the program is to examine Field System log files. By specifying what data that is to be extracted from the log files, that data can be plotted by logpl2. The plots can be manipulated in a number of ways, described later. Plots can either be plotted data vs time or data vs some other data, i.e an xy-plot. Plots can be printed to a postscript file or a printer with postscript support. 

Logpl2 can run with either a graphical user interface or from the command line. In the command line mode, logpl2 can do all that can be done in the graphical mode. Also, it can receive a file of commands, so that a list of commands are executed automatically. However, please note that even though the command line mode can run without display any GUI at all, it still needs an X-server. 
            """
        elif text.lower().strip() == 'on field system log files':
            helptext = """The Field System makes log entries in the format TimeTypeCommandData, where: 

Time A 13-digit ASCII string in the format yydddhhmmssss. For example, 9720517224415 means year 97, day 205, time 17:22:44.15. 

Type A single character indicating the type of entry. 

Command A string that defines what type of data will follow in the Data section. For example, wx/ means that weather data will follow. 

Data A set of comma-separated data. 

Logpl2 extracts data from log files by letting the user specify a selection. A selection is defined by a command, a parameter and an optional matching string. The command is the Field System log file command that should be extracted and the parameter is the index in the comma-separated data list following the command. The optional search string allows the user to specify another criteria for selecting data, since the log file entry must also contain the search string to be selected. 
            """
        elif text.lower().strip() == 'graphical user interface':
            helptext = """To start logpl2, type logpl in the command prompt. For available arguments, use logpl -help, which will display a help menu. With no arguments, the main GUI will open up. If it is the first run, logpl2 will not be able to find a control file which it needs to set up the plot menus. Therefore, logpl2 will automatically open the edit settings window. There, the user can specify what data to extract from the log file. 
            """
        elif text.lower().strip() == 'main screen':
            helptext = """When plotting, plots are selected by moving the mouse over them. Plots may also be selected in command mode (see batch mode section). The details of the selected plot is displayed in the Plot Details box. First of all, it contains an options menu which displays the name of the current plot. If the plot contains several superimposed plots, all the names will appear in this list. By selecting the plot there, its details will appear below. 

Below the options menu is the Y-axis box. It contains the maximum and minimum Y value of the selected plot. It also shows how many data points that appear in the plot. The user may set the y axis manually by specifying the minimum and maximum value and then pressing the Set to Y axis button. 

Under the Y-axis box is the X-axis box. It has a label showing the date format. When plotting a time plot, the minimum and maximum date of the data series will appear of this format below. If an XY-plot is drawn, the maximum and minimum X value will appear. The user may also set the x axis manually by specifying the minimum and maximum value. If there is a time plot, use the date format, and if there is an xy plot, simply set the x value. The axis is set to the values if Set to X axis is pressed. 

In the bottom of the Plot Details box is a row of buttons. They are Zoom Out, AutoScale and Clear Changes. Plots are zoomed by clicking and dragging the right mouse button over the area the user wants to zoom in to. The plot is fully zoomed out when clicking the Zoom Out button. The user may delete data points from a plot by clicking on them with the left mouse button. The data point is then filled in white. When clicking the AutoScale button, this data point is then moved to the upper border of the plot, and the entire plot is scaled without this point. To move it back in to the plot, simply click it again and press AutoScale. To clear all changes made to the plot (e.g zooming or deleting points) click Clear changes and the plot will plotted in its original version. 
"""
        elif text.lower().strip() == 'file menu':
            helptext = """The file menu contains different options to open and close logs, print different kinds of data, setting I/O settings and to quit logpl. 
            """
        elif text.lower().strip() == 'open log':
            helptext = """To open a new log, select Open Log in the File menu. A file dialog will pop up, and upon selecting a log, it will be read according to the control file. All commands found in the log file will then be made available in the Plot menu (they are disabled at first). 

If no log is chosen (i.e the user pressed cancel), if there is an opened log, it will be closed. 

Note that if a log is already opened, logpl2 will close the existing log (and all the plots) before opening another. 
            """
        elif text.lower().strip() == 'close log':
            helptext = """The Close Log menu item closes the opened log if there is one. When closing the log, all existing plots are removed. 
"""
        elif text.lower().strip() == 'edit i/o settings':
            helptext = """To change control file and/or default directory for log files use this option. A window pops up with entries for these options. These entries are saved in a binary file. If there is no binary file upon starting logpl2, one is generated. The default values for the control file is /usr2/control/logpl.ctl and the default value for the log file directory is /usr2/log/. If any of these entries are non existing or in any way invalid, the program will handle the error. The default value for the control file is automatically changed when saving or opening a control file in the edit settings window. 
"""
        elif text.lower().strip() == 'print plot(s)':
            helptext = """When selecting the Print Plot(s) menu item pops up a print dialog where the user can select printer preferences. The user can select destination, print command, filename and printer name. The options for destination is file, printer and display. When selecting file, the current plots are saved in a file with the filename in the filename entry. The file format is determined by the option made to the right of the filename. Not all information is preserved when printing as a non postscript file (e.g fonts). 

If printer is selected as destination, the current plots are printed with the selected printer command to the specified printer. If display is selected, a window pops up that shows the output. In this case, nothing is printed or saved. In order for the plot to fit a print out, most often, the plots needs to be rescaled. This can be done by using the rescale function. The values are preset to fit US letter size (8.5x11). Note that only the scale is important, not the actual values.  
"""
        elif text.lower().strip() == 'list log':       
            helptext = """To view the log file, this function can be used. The user can specify a command to list, and press List. All lines that includes the specified command will be listed. The default command is a quote ("), which would then list all comments. To list the entire log file, leave the command entry blank. To print the data, use print in the file menu. The data can also be saved to a file. The user should then use Save to file in the file menu. To close the list log window, use close in the file menu. The data listed can be cleared by using the Clear button.
"""
        elif text.lower().strip() == 'list data':
            helptext = """To list specific data in the log file, the List Data function can be used. It allows the user to list all data that is specified in the control file (i.e all that can be plotted). All items are found in the Data menu. It is also possible to clear the data from this menu. When selecting a data item, all data that corresponds to it is listed, with the time of its recording. In the file menu, the user can choose to save the data to a file, print it or close the window. 
            """
        elif text.lower().strip() == 'quit':
            helptext = """To exit logpl2, select quit. This terminates the program. Logpl2 does not need to terminate any subprocesses or delete temporary files, so the user may terminate logpl2 as the user chooses. 
"""
        elif text.lower().strip() == 'options menu':
            helptext = """All options that manipulates the current or next plot are in this menu. All options may be used in combination with each other. For instance, if both the Superimpose Next and the Log Scale option is checked, the next plot will appear with a logged y axis, superimposed on the previous plot without changing its y axis.  

Also note that all options under this menu except the superimpose all and split all options apply to the selected plot. They will be applied to all data in that plot, even if it contains many superimposed data sets. That means that several data can not have different options within the same plot. For instance, it is not possible to have a superimposed plot with one set of data inversed, but not the other. 
"""
        elif text.lower().strip() == 'connect data points':
            helptext = """The Connect data points option connects all active data points with a line on all current plots and the next plots when checked. When it is toggled off, the lines disappear. 
"""
        elif text.lower().strip() == 'superimpose next':
            helptext = """When the Superimpose Next option is checked, the next plot will appear superimposed on the selected plot. If no plot is selected, it will appear on the plot last drawn. If there is no plot to superimpose on, the plot will appear as normal. 
"""
        elif text.lower().strip() == 'superimpose all':
            helptext = """When selecting the Superimpose All command, all plots are superimposed on each other. 
"""
        elif text.lower().strip() == 'split all':
            helptext = """To split up one or several superimposed plots, the user can use the Split All command, which will redraw all plots (superimposed or not) as normal, single plots. 
"""
        elif text.lower().strip() == 'grid':
            helptext = """To add a grid on the selected plot, use this option. It will draw a grid net over the plot. To remove the grid net, press this option again. 
"""
        elif text.lower().strip() == 'log scale':
            helptext = """To use a logarithmic scale on the selected plot, use this command. The plot is then redrawn with a logarithm 10 scale. If the plot contains zero or negative values, the logarithmic command won't work. An error message will be displayed in the lower status bar. If the log scale command is successful, the y-scale will adapt to a log scale as well. To remove the log scale, press this option again. 
"""
        elif text.lower().strip() == 'invert scale':
            helptext = """To invert the y-scale on the selected plot, press invert scale. The plot is then redrawn with an inverted scale. To invert the plot back to normal, press this option again. 
"""
        elif text.lower().strip() == 'display average':
            helptext = """To display the mean value of the data use this option. It will draw a dotted line over the entire graph at the y position of the mean value. It will also display the mean value in the status bar (or in the command prompt if in batch mode). If several data sets are superimposed in the same plot, all of those averages will be displayed. 
"""
        elif text.lower().strip() == 'display absolute time':
            helptext = """On default, when plotting a data vs. time plot, the x axis displays a relative time with 0 as the first value. The time is automatically presented in hours, minutes, seconds or a combination of these depending on the timespan. When checking the Display Absolute Time option, the absolute time will instead appear on the x-axis. That is, the time will be on the format (YYYY.DDD.HH:MM:SSSS). This is useful when the user zooms a plot, and might loose track of the relative time. 
"""
        elif text.lower().strip() == 'settings menu':
            helptext = """In logpl2, the control files are set up via an internal editor, or a text editor. It can be accessed from the Settings menu. The first item in the Settings menu is the Reload Default Control File, which simply reads the default control file specified as default and rebuilds menus after it. This is in most cases done automatically, so this menu item won't be used very often. However, if the user would update the working control file (and not save it) the user could revert to the original one using this option. 

The second item is the Edit Control File command. It starts up the internal editor for the control file. The control file is essential for logpl2. Without it, it cannot extract any data from the log files. 

Under the Settings menu, the user also finds the item Edit Shapes and Colors. With that tool, the user can customize the appearance of a selected or all plots. The user may select any of the 5 predefined shape, and any color fitting the RGB-system. Note that if logpl2 would need to superimpose so many plots that it ran out of predefined colors and shapes, it would create a random set. 

The last two items in the menu are increase and decrease font size. This applies to all fonts in logpl2 and will also appear on the print out. 
"""
        elif text.lower().strip() == 'reload default settings':
            helptext = """The reload default settings option reloads the control file. So if the user is working on an updated working control file, the user can revert back to the original one using this function. """
        elif text.lower().strip() == 'edit control file':
            helptext = """When starting the internal editor, the current control file (if there is one) is opened automatically. The user can also choose to create a new file, open another file, and save them. The control files are fully backwards compatible with the logpl1 control files. Also, they may be edited with a text editor. 

In the bottom of the window there are three buttons: Add Single Command, Add Command Pair and Remove Command. When pressing the  Add Single Command button, a new line is created.  When pressing the  Add Command Pair button, two lines are created, and they are connected to each other. To remove a line, select it with the radiobutton on the side and press  Remove Command. 

The file menu in the edit control file window consists of the following items: New, Open, Save, Save As, Cancel and Close and use new settings. The are explained below. 

New
To create a new control file, use this item. It will clear the tables of the opened control file (if any). 

Open
To open another control file, use this item. It will pop up a file dialog in which the user may pick another control file. 

Save/Save As
To save the opened control file, use any of these options. Note that the control file does not need to be saved to be used by logpl2. However, if the user would not save it, the new information would be lost when closing logpl2. 

Cancel
To close this window and not update the settings, use this option. If the control file was altered, logpl2 will ask if the user wants to save the updates. Note that even if the updates are saved, the working control file will still not be updated. 

Close and use new settings
To close this window and use the new settings, use this options. If the control file was altered, logpl2 will ask if the user wants to save the updates. Note that saving is not required for logpl2 to work with the new settings. If a log file was opened, logpl2 will ask if the user wants to reload the log file to work with the new settings. Note that this is required. Otherwise, logpl2 will not allow the user to access the log file data. 

There are 6 columns of editable fields in the main window. They are Command, Dividing Character, Description, Parameter, String and Group Name. 

Command
The Command field should contain the command that logpl2 will look in the log file after. 

Dividing Character
The dividing character is the character dividing the parameters. In the field system, most of the time the dividing character will be a blank sign or a comma. That is why this field is an options box with this options. It is however possible to use a custom character. This is done by selecting other. Note that the dividing character can only be one character. 

Description
The Description field should contain the description of the data matching the parameters set up. The description name will appear in the plotting menu in GUI mode, and is the name being accessed in batch mode. The description name MUST be unique and it cannot contain exclamation marks (!). This is because the exclamation mark is a reserved character in Tkinter. The first description in a command pair must start with a $ sign, and the second one must end with a $ sign. 

Parameter
The parameter field should contain which number the parameter of the data has, counting from the command. If the parameter number is negative, the counting starts from the string. 

String
If logpl2 should look for a command AND a string, enter a string here. If there is none, enter nothing. 

Group Name
If logpl2 should put the data in a cascaded list in the plotting menu, enter a group name. If several data share a group name, they will appear in the same cascaded list. The name of the cascaded list is the group name. 

            """
        elif text.lower().strip() == 'edit control file in a text editor':
            helptext = """1. Command, the pattern logpl will grep the log file for. 
 
 2. Parameter, the number of separated data field for the command,
               a negative value means to take the value just after the
              field with "String"
 
 3. Description, the menu label logpl will use for the command. The description 
                 must be unique for every data. For pair commands, the first 
                 description must begin with a $-sign, and the second must end 
                 with a $-sign. 
 
 4. String, a level-2 grep. This parameter is optional and may be left out,
            for negative "Parameter" values, it is the string before the
            data field
 
 5. Dividing Character, the character that separates the parameters. 
                        If left out, it defaults to a comma. 
 
 6. Group Name, Specify a group name to put the data in a cascaded menu
                in the plot menu. If several data share a group name, 
                they appear in the same cascade menu. 

 
 This file is space-separated, and fields may only contain spaces
 if they are inside double quotes. To have a double quote in a field, type 4 double quotes.
 
 Note that single quotes are parsed as normal ASCII.  
 
 Only field 1,2 and 3 are required by logpl. An empty field may simply be left out
 but if there are fields to the right of it, specify it empty by using two double quotes (""). 
 
 Also note, the interpretation of the control file is CASE SENSITIVE! """
        elif text.lower().strip() == 'help menu':
            helptext = """The internal help system is found under this menu. It contains two items: Help Contents and About LogPlotter. The latter display a message box with the logpl2 version and the required Python version. The former opens a window with an extensive help that covers all of logpl2. It is basically this document. To navigate the help file, a tree system is used. The help text is displayed by double clicking headers in the tree. 
"""
        elif text.lower().strip() == 'help contents':
            helptext = """Displays this help"""
        elif text.lower().strip() == 'about logpl':
            helptext = """Displays version number of logpl and required Python version. """
        elif text.lower().strip() == 'mouse actions':
            helptext = """In logpl2, the user can use the mouse to manipulate the plots in a number of ways. 
            """
        elif text.lower().strip() == 'selecting plots':
            helptext = """A number of tools in logpl2 require that a plot is selected for them in order to work. To select a plot, simply click on the plot with the left mouse button. The user can tell the plot is selecting by a red border surrounding the plot. Also, the latest plotted plot is automatically selected. If that plot is removed, the plot before it is selected. 
            """
        elif text.lower().strip() == 'zooming plots':
            helptext = """To zoom in on a plot, hold the control key while pressing the left mouse button and dragging over the area the user wants to zoom in on. When the mouse button is released, the plot will be zoomed in on the covered area. The covered area is displayed with a shaded yellow rectangle. Note that the zoomed in data is automatically scaled. 
            """
        elif text.lower().strip() == 'deleting single points':
            helptext = """To delete a single point from a data set, double click on it with the right mouse button. The data point will then be filled with white as to indicate it is removed. To rescale the plot without this point, press Autoscale, on the right side. If the point doesn't fit the plot anymore, it will appear on the closest border. 
            """
        elif text.lower().strip() == 'deleting selection of points':
            helptext = """To delete multiple points, click with the right mouse button and drag over the selection the user wants removed. The area to be removed is displayed with a shaded red rectangle. To redraw the plot, press Autoscale. 
            """
        elif text.lower().strip() == 'superimposing plots':
            helptext = """There are a number of ways to superimpose plots on each other in logpl2. One of them is to hold the shift key and then left click on a plot the user wants superimposed and drag it to the plot the user wants to superimpose it on. When the left mouse button is released, the plots will be drawn on top of each other. 
            """
        elif text.lower().strip() == 'batch mode':
            helptext = """Logpl2 can be ran from the command prompt with the full capability of the GUI. 


To start logpl2 in batch mode, start by typing logpl -cmd. Logpl2 will then be started in batch mode, with the default option of not showing the GUI. It can be brought up any time with the command showdisp=1. If the user wants to automatically run a series of commands, type logpl -cfile <filename>, where filename is the name of a command file, containing commands as one would type them in batch mode. After all commands are ran, the user comes back to the batch mode prompt. 

To display a help text in batch mode simply type help. It will display a complete list of all commands. 

If a control file isn't found on startup, logpl will tell the user so, but unlike in GUI-mode, the edit settings window will not automatically appear. The user must then either specify a control file with the control= command, or open the edit settings window with the settings command. 

The user may also decide the level of feedback from logpl2. By starting logpl2 with the argument -verbose, the feedback from logpl2 will be extensive. All messages that are normally displayed in the status bar are now instead displayed in the command window. This option is by default set to be off. In that case, only error messages are displayed. 

If a command is not recognized, logpl2 will tell the user. Note that unlike logpl1, commands must fully match (including the equal sign if there is one). All commands that normally require an input ends with a "=". The input data should follow the equal sign, but blank spaces or tabs do not matter. Multiple input data are separated by a comma sign (","). Again, blank spaces do not matter. Commands that doesn't end with an equal sign do not take in any arguments. 

If all input data is omitted, the current status of the command will be displayed. That is, to display the current status of showdisp=, type showdisp=.

Examples:
If no control file is found, logpl2 will tell the user so. The user should then (but is not required to) start off by specifying a control file. Thereafter, a log can be opened. After it is read the user may plot the data and after they are plotted, they can be printed. The GUI can once again, be brought up at any time, but does not need to be. To print temperature data from the log station.log to printer $PRINTER is done by typing: (assuming the correct settings are found in temp_settings.pkl)
control=temp_settings.pkl
log=station.log
plot=Temperature
output=printer, $PRINTER
"""
        elif text.lower().strip() == 'commands':
            textfont = ('Courier',) + textfont[1:]
            helptext = """Command    Parameter     Description
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
                         Output files could be EPS/PS, BMP, JPEG/JPG, 
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
a new value."""
        elif text.lower().strip() == 'writing scripts for logpl':
            helptext = """It is possible to run logpl2 with a command script. The script file can contain all commands that were listed in section 3.2. The command file can either be specified when starting logpl2 by typing logpl -cfile filename, or by starting logpl2 in batch mode and then specifying the command file with the command cfile= filename. If the user wants logpl2 to quit after the command file is read, simply add exit to the end of the file. If the first character of a line is a #-sign, the line is interpreted as a comment. 

Example command file
The following command file will print temperature data and humidity data on one page, cable-length versus Pressure on one page, and a superimposed plot with all existing data on one page. It will send the output to the default output. After the script is finished, logpl2 should exit

The command file should then have the following appearance:

#Example command file for logpl2
plot= Temperature
plot= Humidity
output=
plotxy= Pressure, Cable-length
output= 
plotall
superall
output=
exit
#done

In order to execute this script, the user must start logpl with a set of arguments (see starting logpl section). First of all, a log file must be specfied, then the command file must be specified and finally a default output must be specified. 

Assume the log file is station.log, the command file is command_file, and the default printer is default_printer. 

Start logpl2 with the following line: 
logpl -log station.log -cfile command_file -output printer default_printer

Note that a control file containing the specification for all this data is required. 

            """
        elif text.lower().strip() == 'starting logpl':
            textfont = ('Courier',) + textfont[1:]
            helptext = """Logpl2 may be started using a variety of arguments. If no arguments is used, it will start up in normal GUI mode. 
            
Argument   Parameter    Description
--------   ---------    -----------
-cfile     commandfile  Logpl starts in batchmode and 
                        automatically reads commands 
                        from commandfile
-cmd       void         Starts logpl in batchmode
-control   controlfile  Logpl uses specified controlfile
-f         void         Skips version check of Python/Tkinter and runs
                        logpl regardless of version. 
-geometry  geometry     Set geometry for logpl. Format is of
                        standard X11 format (WIDTHxHEIGHT+XPOS+YPOS). 
                        Default is +1+1. 
                        The user may also change height/width. 
-help      void         Displays this help
-log       logfile      Logpl automatically opens logfile
-output    mode name    Specify default output. Mode should be
                        printer for print or file to print to a file. 
                        The name is printer name in print mode, or file name
                        in file mode. Note that output requires 2 arguments.  
-verbose   void         Displays status messages in batch mode.
                        Default is off. Error messages are
                        still displayed

If no argument is used, logpl starts up in normal GUI mode."""
        elif text.lower().strip() == 'plotting menu':
            helptext = """The plotting menu contains two parts. The first part is automatically built from the control file, and contains all specified data that can be extracted from the log file. The plotting menu is rebuilt after each reload of the control file. So if the control file is updated, so is the plotting menu. After any data is plotted, that plot will be selected. If a plot is removed, the plot before it will be selected. 
"""
        elif text.lower().strip() == 'plot descriptions':
            helptext = """The first section of the plotting menu contains all plot commands. If several commands have a common group name (see control file section) they will appear in a cascaded list. All plot commands are disabled when no log file is read. They are made available if they exist after a log file is read and the data is extracted. 
"""
        elif text.lower().strip() == 'plot all':
            helptext = """When the Plot All command is selected, all plots that are available in the plotting list (i.e they exist) is plotted. If no log is read, no plots are available and thus nothing will happen. 
"""
        elif text.lower().strip() == 'xy plot...':
            helptext = """When XY Plot is selected a window pops up. It contains two lists, X values and Y values. When a log is opened that contains data, these data will appear in both lists. The user can then select the data for the X-axis and the data for the Y-axis in the two lists. If the user clicks Cancel, the window just closes and nothing happens. If the user clicks Apply, an XY-plot will appear containing the specified data. If OK is clicked, the XY plot appears and the XY Plot window closes. All data versus time plots will always be removed before plotting an XY plot. 

In the XY Plot window, there are several options the user can choose. First of all, there are 3 options in the Plot Setting frame. They are New Plot, Plot after existing and Superimpose on existing plot. If New Plot is chosen, all old XY plots will be removed before plotting the new one. If Plot after existing is chosen, the new XY plot will appear under the previous XY plot using its x scale. If the user chooses the superimpose options, the next plot will be superimposed on the existing one but still use the old x axis. 

There is also a Time Pairing frame. If checked on, x values and y values that differ in time more than what is specified in the entry box (setting hours, minutes or seconds in the option box) will be omitted. This might lead to empty data series. In that case, the time pairing option is ignored. 

If there is no data to plot, a message will appear informing the user of this and the window will close. 
"""
        elif text.lower().strip() == 'clear all plots':
            helptext = """When selecting Clear All Plots all current plots are closed. This affects both data versus time plots and XY-plots. 
"""
        textbox.config(font = textfont)
        textbox.insert(END, helptext)
        #textfont.config(family = 'Helvetica')

if __name__ == '__main__':
    a = HelpFrame()
    a.mainloop()