#!/usr/bin/env python3
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

import numpy as np
import os
from lmfit import minimize, Parameters, Model, Minimizer, fit_report
import copy
import pandas as pd
import sys
from scipy import stats
import getopt
import warnings
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from matplotlib.backend_bases import *
from matplotlib.backends.qt_compat import QtCore, QtWidgets, is_pyqt5
from matplotlib.figure import Figure
from matplotlib.backends.backend_qt5agg import (
        FigureCanvas, NavigationToolbar2QT as NavigationToolbar)
from pdplotanalysis import *
from expwindow import *
from iowindow import *
from parwindow import *
import matplotlib.pyplot as plt
plt.style.use('classic')



class PDPlotWindow(QMainWindow):
    """Create a window, menus and plot
    """
    def __init__(self):

        """Initialize with super,
        Then Create the mainwidget which will occupy entire window,
        Show the window
        """

        super().__init__()
        self.hassaved=1 #Whether or it has been saved since last edits were made to data

        #IO
        self.logdir = "/usr2/log/" #Where the program looks for the log files
        self.mdlctr = "/usr2/control/mdlpo.ctl" #Default location/name of control file
        self.errname="None" #Default error and xtr names for saving (while change once a file has been opened)
        self.xtrname="None"

        #data config
        self.df=pd.DataFrame(columns=['indicator', 'az', 'el', 'az_off', 'el_off', 'az_sigma', 'el_sigma','ii', 'jj', 'det', 'source', 'xel_off', 'xel_sigma', 'off_vector', 'e_e']) #Initialize with effectively empty df
        self.datatype = 'residual' #Type of data which will be plotted, defaults to residuals
        self.errortype = "input" #Type of errors (input, prior, post). Defaults to input
        self.flagstring='0000' #Default flagstring, will change once something is read in
        self.statsdict = {} #Dictionary used for displaying statistics
        self.coloredsources = [] #Which of the sources will be colored in the graph
        self.intermediatesources =[] #A temporary space to store sources while changing
        self.xelazflag = 0 #set to 1 for xel coordinates
        self.graphcounter = 0 #Counts where in the cycle of graphs you are
        self.model_flags= np.zeros(30).tolist() #placeholder list for flags to be applied to the model, aren't active until a file has been read in
        self.pickedpoint= np.zeros(20).tolist() #placeholder list for data about any picked point for display in the sidebar
        self.overwriteflag = 0 #If the user wants to overwrite an existing file
        self.antenna="" #Placeholder for antenna name
        self.fname=('','') #placeholder for fileinfo when file is opened
        self.yname="" #placholder for yaxis name
        self.xname="" #Placeholder for xaxis name
        self.sourcelist=[] #List of all sources which can be graphed
        self.setWindowTitle("PDPlot-Py")



        self.mainwidge() #setup the gui
        self.show()

    def mainwidge(self):
        """Create main widget, and set layout then create all menus
        then initialize the canvas/figure to prepare for plotting,
        and lastly create widgets for main screen
        """

        self._main = QWidget()
        self.setCentralWidget(self._main)
        self.gridLayout = QGridLayout()
        self._main.setLayout(self.gridLayout)

        #MatPlotLib configuration
        self.figure=Figure()
        self.canvas=FigureCanvas(self.figure)
        self.addToolBar(NavigationToolbar(self.canvas, self))
        self.gridLayout.addWidget(self.canvas, 1,1,10,10)

        #Sidebar data for a selected point
        self.pickedlabel = QLabel("")
        self.pickedlabel.setFont(QFont("Monospace"))
        self.gridLayout.addWidget(self.pickedlabel,4,12)
        self.pickedlabel.setMaximumWidth(190)
        self.pickedlabel.setMinimumWidth(190)
        self.pickedlabelcr()

        #Create the menus
        self.menubarcreator()

    def menubarcreator(self):
        """Add all the menus in the right order, then actually set them up
        """
        self.StatusBarLabel = QLabel()
        self.statusBar().addPermanentWidget(self.StatusBarLabel, 1)
        self.StatusBarLabel.setText("Ready for Processing")

        self.menubar = self.menuBar()
        self.fileMenu = self.menubar.addMenu('File')
        self.editMenu = self.menubar.addMenu('Edit')
        self.graphMenu = self.menubar.addMenu('Graph')
        self.dataMenu = self.menubar.addMenu('Data')
        self.sigmaMenu = self.menubar.addMenu('Sigma')
        self.sourceMenu = self.menubar.addMenu('Sources')
        self.UtiMenu = self.menubar.addMenu('Utilities')
        self.statMenu = self.menubar.addMenu('Statistics')
        self.statMenu.setFont(QFont("Monospace"))


        #Files to set up the menus
        self.filemenucr()
        self.editmenucr()
        self.datamenucr()
        self.sigmamenucr()
        self.statmenucr()
        self.sourcemenucr()
        self.utilmenucr()
        self.graphmenucr()

    def filemenucr(self):
        """Create file menu.
        """
        NewAct = QAction('New', self)
        OpenAct = QAction('Open', self)
        SaveAct = QAction('Save', self)
        IOAct = QAction('I/O Setup',self)
        PrintAct = QAction("Print", self)
        ExitAct = QAction('Exit', self)

        self.fileMenu.addAction(NewAct)
        self.fileMenu.addAction(OpenAct)
        self.fileMenu.addAction(SaveAct)
        self.fileMenu.addAction(IOAct)
        self.fileMenu.addSeparator()
        self.fileMenu.addAction(PrintAct)
        self.fileMenu.addSeparator()
        self.fileMenu.addAction(ExitAct)

        NewAct.triggered.connect(lambda: self.getfile("Log Files (*log*)"))
        SaveAct.triggered.connect(self.saveclick)
        IOAct.triggered.connect(self.iowindow)
        OpenAct.triggered.connect(lambda: self.getfile("xtrac (xtr*)"))
        PrintAct.triggered.connect(self.printfigure)
        ExitAct.triggered.connect(lambda: QCoreApplication.quit())

    def editmenucr(self):
        """Create edit menu
        """

        AddAct = QAction('Add all points', self)
        ReAct = QAction('Reprocess', self)
        XSigAct = QAction('X-Sigma', self)
        ParamAct = QAction('Modify Parameter',self)

        AddAct.triggered.connect(self.addall)
        ReAct.triggered.connect(self.total_updater)
        ParamAct.triggered.connect(self.paramwindow)
        XSigAct.triggered.connect(self.xsig)

        self.editMenu.addAction(AddAct)
        self.editMenu.addAction(ReAct)
        self.editMenu.addAction(XSigAct)
        self.editMenu.addSeparator()
        self.editMenu.addAction(ParamAct)

    def graphmenucr(self):
        """Create graph menu
        """

        self.AzElAct = QAction('El vs. Az', self, checkable=True)
        self.XElOffsetTimeAct = QAction('X-El Offset vs. Time', self, checkable=True)
        self.XElAzAct = QAction('X-El vs. Az', self, checkable=True)
        self.AzOffsetTimeAct = QAction('Az-Offset vs. Time', self, checkable=True)
        self.AzOffsetAzAct = QAction('Az-Offset vs. Az', self, checkable=True)
        self.ElOffAzAct = QAction('El-Offset vs. Az', self, checkable=True)
        self.XElElAct = QAction('X-El vs. El',self, checkable=True)
        self.AzOffsetElAct = QAction('Az-Offset vs. El',self, checkable=True)
        self.ElOffElAct = QAction('El-Offset vs. El', self, checkable=True)

        self.axselection= QActionGroup(self)
        self.axselection.addAction(self.AzElAct)
        self.axselection.addAction(self.XElAzAct)
        self.axselection.addAction(self.XElOffsetTimeAct)
        self.axselection.addAction(self.AzOffsetAzAct)
        self.axselection.addAction(self.AzOffsetTimeAct)
        self.axselection.addAction(self.ElOffAzAct)
        self.axselection.addAction(self.XElElAct)
        self.axselection.addAction(self.AzOffsetElAct)
        self.axselection.addAction(self.ElOffElAct)
        self.axselection.isExclusive()


        self.AzElAct.triggered.connect(lambda: self.plotter("az", "el"))
        self.XElOffsetTimeAct.triggered.connect(lambda: self.plotter("time", "xel_off"))
        self.XElAzAct.triggered.connect(lambda: self.plotter("az", "xel_off"))
        self.AzOffsetTimeAct.triggered.connect(lambda: self.plotter("time", "az_off"))
        self.AzOffsetAzAct.triggered.connect(lambda: self.plotter("az", "az_off"))
        self.ElOffAzAct.triggered.connect(lambda: self.plotter("az", "el_off"))
        self.XElElAct.triggered.connect(lambda: self.plotter("el", "xel_off"))
        self.AzOffsetElAct.triggered.connect(lambda: self.plotter("el", "az_off"))
        self.ElOffElAct.triggered.connect(lambda: self.plotter("el", "el_off"))

        self.graphMenu.addAction(self.AzElAct)
        self.graphMenu.addAction(self.XElOffsetTimeAct)
        self.graphMenu.addAction(self.XElAzAct)
        self.graphMenu.addAction(self.AzOffsetTimeAct)
        self.graphMenu.addAction(self.AzOffsetAzAct)
        self.graphMenu.addAction(self.ElOffAzAct)
        self.graphMenu.addAction(self.XElElAct)
        self.graphMenu.addAction(self.AzOffsetElAct)
        self.graphMenu.addAction(self.ElOffElAct)

        self.xelaz()

    def datamenucr(self):
        """Create data menu
        """

        self.RawAct = QAction('Raw Data', self, checkable=True)
        self.ResAct = QAction('Residuals', self, checkable=True)
        self.UncAct = QAction('Uncorrected', self, checkable=True)

        self.dataselection= QActionGroup(self)
        self.dataselection.addAction(self.RawAct)
        self.dataselection.addAction(self.ResAct)
        self.dataselection.addAction(self.UncAct)
        self.dataselection.isExclusive()

        self.ResAct.triggered.connect(self.switchdfres)
        self.RawAct.triggered.connect(self.switchdfraw)
        self.UncAct.triggered.connect(self.switchdfunc)

        self.dataMenu.addAction(self.RawAct)
        self.dataMenu.addAction(self.UncAct)
        self.dataMenu.addAction(self.ResAct)

    def sigmamenucr(self):
        """Create sigma menu
        """

        self.InputAct = QAction('Input', self, checkable=True)
        self.PriorAct = QAction('A Priori', self, checkable=True)
        self.PostAct = QAction('A Posteriori', self, checkable=True)
        self.NosigAct = QAction('No Sigma', self, checkable=True)

        self.sigmagroup =  QActionGroup(self)
        self.sigmagroup.setExclusive(True)
        self.sigmagroup.addAction(self.InputAct)
        self.sigmagroup.addAction(self.PriorAct)
        self.sigmagroup.addAction(self.PostAct)
        self.sigmagroup.addAction(self.NosigAct)

        self.InputAct.triggered.connect(lambda: self.errortypechanger("input"))
        self.PostAct.triggered.connect(lambda: self.errortypechanger("post"))
        self.PriorAct.triggered.connect(lambda: self.errortypechanger("prior"))
        self.NosigAct.triggered.connect(lambda: self.errortypechanger("none"))


        self.sigmaMenu.addAction(self.InputAct)
        self.sigmaMenu.addAction(self.PriorAct)
        self.sigmaMenu.addAction(self.PostAct)
        self.sigmaMenu.addAction(self.NosigAct)

    def statmenucr(self):
        """Create stat menu
        """

        for key, value in self.statsdict.items():
            self.statsdict[key] = "{:8.5f}".format(float(value))


        self.statMenu.clear()
        for key, value in self.statsdict.items():
            if key == 'EL-FEC' or key=='RChi' or key == "xEL-mean" or key == "EL-mean":
                self.statMenu.addSeparator()
            if key == "DFree":
                    self.statMenu.addAction(QAction('{0: <10}'.format(str(key))+": "+str(int(float(value))), self))
            elif float(self.flagstring[-1])==0:
                if key != "xEL-FEC":
                    self.statMenu.addAction(QAction('{0: <10}'.format(str(key))+": "+'{:.5f}'.format(float(value)), self))
            elif float(self.flagstring[-1])==1:
                if key != "AZ-FEC":
                    self.statMenu.addAction(QAction('{0: <10}'.format(str(key))+": "+'{:.5f}'.format(float(value)), self))

    def sourcemenucr(self):
        """Creates menu of all sources from dataframe
        """

        self.sourceMenu.clear()
        allaction = QAction('All', self, checkable=True)
        allaction.triggered.connect(lambda state: self.allsources(state))
        self.sourceMenu.addAction(allaction)
        self.sourceMenu.addSeparator()
        for i in self.sourcelist:
            item = QAction(i, self,checkable=True )
            self.sourceMenu.addAction(item)
            item.triggered.connect(lambda state, i=i: self.addsources(i, state))

    def utilmenucr(self):
        """Create Utlitiy Menu.
        """

        self.xelcordAct = QAction('xEL Coordinates', self, checkable=True)
        self.azcordAct = QAction('Az Coordinates', self, checkable=True)
        self.azcordAct.triggered.connect(self.xelaz)
        self.xelcordAct.triggered.connect(self.xelaz)
        self.coordinatebuttons = QActionGroup(self)
        self.coordinatebuttons.addAction(self.xelcordAct)
        self.coordinatebuttons.addAction(self.azcordAct)
        self.coordinatebuttons.setExclusive(True)

        self.xelfecAct = QAction('xEL FEC in calculations', self, checkable=True)
        self.azfecAct = QAction('Az FEC in calculations', self, checkable=True)
        self.nofecAct = QAction('No FEC in Calculations', self, checkable=True)
        self.azfecAct.triggered.connect(lambda: self.fecswap(0))
        self.xelfecAct.triggered.connect(lambda: self.fecswap(1))
        self.nofecAct.triggered.connect(lambda: self.fecswap(2))
        self.fecbuttons = QActionGroup(self)
        self.fecbuttons.addAction(self.xelfecAct)
        self.fecbuttons.addAction(self.azfecAct)
        self.fecbuttons.addAction(self.nofecAct)
        self.fecbuttons.setExclusive(True)

        self.seeallAct = QAction("See All Points", self, checkable=True)
        self.seeallAct.toggled.connect(lambda state: self.seeall(state))

        self.UtiMenu.addAction(self.xelcordAct)
        self.UtiMenu.addAction(self.azcordAct)
        self.UtiMenu.addSeparator()
        self.UtiMenu.addAction(self.xelfecAct)
        self.UtiMenu.addAction(self.azfecAct)
        self.UtiMenu.addAction(self.nofecAct)
        self.UtiMenu.addSeparator()
        self.UtiMenu.addAction(self.seeallAct)

    def seeall(self, state):
        """Function which when a button is pressed (state=True), will temporarily show all data points.
        Then when unchecked will return to previous selection of data.
        """

        if state==True:
            self.df_old=copy.deepcopy(self.df)
            for index, row in self.df.iterrows():
                self.df.at[index, "indicator"]=1
        else:
            self.df=self.df_old

        self.plotter(self.xname, self.yname)

    def addsources(self, i, state):
        """Add i to the list of sources which are to be colored. Necessary to have intermediatesources in order to have 'all' option work correctly.
        """

        self.hassaved=0
        if state==False:
            if i in self.intermediatesources:
                self.intermediatesources.remove(i)
        if state==True:
            if i not in self.intermediatesources:
                self.intermediatesources.append(i)
        if ['all'] not in self.coloredsources:
            self.coloredsources=self.intermediatesources
        self.plotter(self.xname, self.yname)

    def allsources(self, state, flag=1):
        """When 'all' is selected returns all sources colored
        """

        self.hassaved=0
        if state==True and flag==0:
            self.prevsources=[]
            self.intermediatesources=[]
            self.coloredsources=['all']
        elif state==True and flag==1:
            self.coloredsources=['all']
        elif state==False:
            self.coloredsources=self.intermediatesources
        else:
            pass
        self.plotter(self.xname, self.yname)

    def addall(self):
        """Adds all points to the group which will be processed
        (a more permanent measure compared to seeall).
        """

        self.hassaved=0
        for index, row in self.df_rad.iterrows():
            if row["indicator"]!='*bad':
                self.df_rad.at[index, "indicator"]=1
        self.df_rad, self.df_stats, self.df_unc_rad, self.df_unc_stats=reprocessdf(self.df_rad, self.oldmodel_all)
        for index, row in self.df.iterrows():
            self.df.at[index, "indicator"]=1
        self.plotter(self.xname, self.yname)

    def writeall(self):
        """Save xtract and error files as new files (depending on IO settings)
        """

        self.hassaved=1
        allwriter(self.xtrname, self.errname, self.all_info, self.df_deg, self.df_stats, self.df_unc_deg, self.df_unc_stats, self.df_cor_deg, self.df_cor_stats, self.oldmodel_all, self.fit_data, self.fit_stats, self.newmodel, self.cor_matrix, self.conditionstring, self.flagstring, self.filename)

    def saveclick(self):
        """Test case for save button in file menu
        """

        if os.path.isfile(self.logdir+self.xtrname) or os.path.isfile(self.logdir+self.errname):
            if self.overwriteflag==0:
                self.StatusBarLabel.setText("ERROR: Didn't select overwrite so cannot write files")
            else:
                self.writeall()
        else:
            self.writeall()

    def total_updater(self):
        """Reprocesses all the selected data, and gives new statistics.
        """

        self.model_flags = [str(i) for i in self.model_flags]
        self.StatusBarLabel.setText("Please wait for processing to be completed")

        self.df_cor_deg, self.df_unc_deg, self.model_flags, self.df_cor_stats, self.az_fec, self.el_fec, self.redchi, self.dfree, self.conditionstring, self.fit_data, self.fit_stats, self.newmodel, self.cor_matrix = general2(self.df_unc_rad, self.df_rad, self.model_phi, self.model_flags, self.oldmodel_params, self.all_info, self.df_stats, self.df_unc_stats, self.oldmodel_all, self.flagstring, self.version, self.filename)
        self.df = copy.deepcopy(self.df_cor_deg)

        self.statsdict={"AZ-mean":self.df_cor_stats[0], "AZ-rms":self.df_cor_stats[1], "EL-mean":self.df_cor_stats[2], "EL-rms":self.df_cor_stats[3], "xEL-mean":self.df_cor_stats[7], "xEL-rms":self.df_cor_stats[8], "EL-FEC": self.el_fec, "AZ-FEC":self.az_fec, "xEL-FEC": self.az_fec, "RChi": self.redchi, "DFree": self.dfree}
        if float(self.flagstring[-3])==1:
            self.nofecAct.setChecked(True)
        elif float(self.flagstring[-1])==1:
            self.xelfecAct.setChecked(True)
        else:
            self.azfecAct.setChecked(True)

        self.ResAct.trigger()
        self.xelazflag=float(self.flagstring[-2])
        self.xelaz()
        self.antenna = self.all_info.split()[0]
        self.sourcelist=self.df['source'].unique().tolist()
        self.sourcemenucr()
        self.statmenucr()
        self.plotter(self.xname, self.yname)

    def grapherrorbars(self):
        """Depending on the errortype selected it determines which sigmas should be used for error-bars in the figure
        """

        if self.errortype == "prior":
            if 'az' in self.yname:
                self.errorbar = self.df_tograph['az_prior_sigma']
            elif 'xel' in self.yname:
                self.errorbar = self.df_tograph['xel_prior_sigma']
            else:
                self.errorbar = self.df_tograph['el_prior_sigma']
        elif self.errortype == "post":
            if 'az' in self.yname:
                self.errorbar = self.df_tograph['az_post_sigma']
            elif 'xel' in self.yname:
                self.errorbar = self.df_tograph['xel_post_sigma']
            else:
                self.errorbar = self.df_tograph['el_post_sigma']
        elif self.errortype == "input":
            if 'az' in self.yname:
                self.errorbar = self.df_tograph['az_input_sigma']
            elif 'xel' in self.yname:
                self.errorbar = self.df_tograph['xel_input_sigma']
            else:
                self.errorbar = self.df_tograph['el_input_sigma']
        elif self.errortype == "none":
            self.errorbar = np.zeros(len(self.df_tograph.index))

    def plotter(self, xname, yname):
        """Adds a subplot and finds data in df based off input.
        Then is plots the data, and formats the graph.
        Lastly, it connects to events, draws the graph, and then outputs necessary
        data to other places.
        """

        if 'all' in self.coloredsources:
            self.coloredsources=self.sourcelist


        if not self.df.empty:
            self.figure.clf()
            self.xname=xname
            self.yname=yname
            self.df_tograph = self.df[self.df.indicator==1]
            if not self.df_tograph.empty:
                self.grapherrorbars()

                self.ax = self.figure.add_subplot(111)
                for name, group in self.df_tograph.groupby('source'):
                    if name in self.coloredsources:
                        group.plot(x=self.xname, y=self.yname, ax=self.ax, label=name, legend=False, marker='o', linestyle='', picker=5,markersize=5)
                    else:
                        group.plot(x=self.xname, y=self.yname, ax=self.ax, label=name, legend=False, marker='o', linestyle='', picker=5,markersize=5, color='grey')

                self.x = self.df_tograph[self.xname]
                self.y = self.df_tograph[self.yname]
                if self.yname!= 'el' and self.xname!='time':
                    self.ax.plot([0, 360], [0, 0], '-', lw=1, color='black')
                if self.yname !="el" and self.errortype!="none":
                    self.ax.errorbar(self.x, self.y, yerr=self.errorbar, linestyle="None",capsize=5, mew=1, color='black')

                self.ax.set_ylabel(self.unitter(self.yname))
                self.ax.set_xlabel(self.unitter(self.xname))
                self.ax.set_title(self.antenna+" "+self.datatype+" "+" "+self.filename)
                self.figure.canvas.mpl_connect('pick_event', self.onpick)
                self.figure.tight_layout()
                self.canvas.draw()
                self.StatusBarLabel.setText('Plot up to date')
            else:
                self.StatusBarLabel.setText('No Data Selected')
        else:
            self.StatusBarLabel.setText('Open log or xtr file')

    def keyPressEvent(self, event):
        """If user clicks tab button then cycles through different graphs.
        Dependent on whether 'time' section of dataframe is actually populated or not (If not data then given zeros).
        """

        xelgraphcycle=[self.AzElAct, self.XElAzAct,  self.ElOffAzAct, self.XElElAct, self.ElOffElAct]
        azgraphcycle=[self.AzElAct, self.AzOffsetAzAct, self.ElOffAzAct, self.AzOffsetElAct, self.ElOffElAct]
        if self.df.loc[0, "time"]!=0:
            xelgraphcycle=[self.AzElAct, self.XElOffsetTimeAct, self.XElAzAct,  self.ElOffAzAct, self.XElElAct, self.ElOffElAct]
            azgraphcycle=[self.AzElAct, self.AzOffsetTimeAct, self.AzOffsetTimeAct, self.AzOffsetAzAct, self.ElOffAzAct, self.AzOffsetElAct, self.ElOffElAct]
        if self.xelazflag==1:
            graphcycle= azgraphcycle
        else:
            graphcycle= xelgraphcycle

        if event.key() == QtCore.Qt.Key_N:
            self.graphcounter+=1
            graphcycle[self.graphcounter%len(xelgraphcycle)].trigger()
        elif event.key() == QtCore.Qt.Key_P:
            self.graphcounter-=1
            graphcycle[self.graphcounter%len(xelgraphcycle)].trigger()
        elif event.key() == QtCore.Qt.Key_R:
            self.total_updater()

    def onpick(self, event):
        """When a point is dblclicked on inside the figure,
        that point is removed from the dataframe, and then regraphed.
        If anyother type of click is done, then we create a list of data from that point for the sidebar (picklabelcr)
        """

        thisline = event.artist
        xdata = thisline.get_xdata()
        ydata = thisline.get_ydata()
        ind = event.ind
        azremoved=0
        elremoved=0

        if event.mouseevent.dblclick:
            self.hassaved=0
            self.figure.clf()
            for index, row in self.df.iterrows():
                if self.xname!='time':
                    if round(row[self.yname],2) == round(ydata[ind][0],2) and round(row[self.xname],2) == round(xdata[ind][0],2):
                        self.df.at[index, 'indicator']=0
                        self.df_unc_deg.at[index, 'indicator']=0
                        self.df_unc_rad.at[index, 'indicator']=0
                        self.df_cor_deg[index, 'indicator']=0
                        azremoved = self.df.at[index, 'az']
                        elremoved = self.df.at[index, 'el']
                else:
                    if round(row[self.yname],4) == round(ydata[ind][0],4):
                        self.df.at[index, 'indicator']=0
                        self.df_unc_deg.at[index, 'indicator']=0
                        self.df_unc_rad.at[index, 'indicator']=0
                        self.df_cor_deg[index, 'indicator']=0
                        azremoved = self.df.at[index, 'az']
                        elremoved = self.df.at[index, 'el']


            for index, row in self.df_deg.iterrows():
                if round(azremoved,2) == round(row["az"],2) and round(elremoved,2) == round(row["el"],2):
                    self.df_deg.at[index, 'indicator']=0
                    self.df_rad.at[index, 'indicator']=0

            self.plotter(self.xname,self.yname)


            self.df_rad, self.df_stats, self.df_unc_rad, self.df_unc_stats=reprocessdf(self.df_rad, self.mdlctr)
        else:
            for index, row in self.df.iterrows():
                if self.xname != 'time':
                    if round(row[self.yname],2) == round(ydata[ind][0],2)and round(row[self.xname],2) == round(xdata[ind][0],2):
                        self.pickedpoint=[row['az'], row['el'], row['az_off'], row['az_input_sigma'], row['az_prior_sigma'], row['az_post_sigma'], row['el_off'], row['el_input_sigma'], row['el_prior_sigma'], row['el_post_sigma'], row['xel_off'], row['xel_input_sigma'], row['xel_prior_sigma'], row['xel_post_sigma'], row['source']]
                else:
                    if round(row[self.yname],4) == round(ydata[ind][0],4):
                        self.pickedpoint=[row['az'], row['el'], row['az_off'], row['az_input_sigma'], row['az_prior_sigma'], row['az_post_sigma'], row['el_off'], row['el_input_sigma'], row['el_prior_sigma'], row['el_post_sigma'], row['xel_off'], row['xel_input_sigma'], row['xel_prior_sigma'], row['xel_post_sigma'], row['source']]
            self.pickedlabelcr()

    def unitter(self, axis):
        """Function to print out nice axis-labels from dataframe column names
        """

        if axis == "az":
            return "Azimuth (Degrees)"
        elif axis == "el":
            return "Elevation (Degrees)"
        elif axis == "az_off":
            return "Azimuth Offset"
        elif axis == "xel_off":
            return "X-Elevation Offset"
        elif axis == "el_off":
            return "Elevation Offset"
        elif axis == "az_sigma":
            return "Azimuth Sigma"
        elif axis == "xel_sigma":
            return "X-Elevation Sigma"
        elif axis == "el_sigma":
            return "Elevation Sigma"
        elif axis == 'time':
            return "Time"
        else:
            return axis

    def xelaz(self):
        """This handles reprocessing when the coordinate system switches.
        This includes regraphing, changing what is visible on the menus,
        changing the flagstring, and checking the right boxes.
        """

        if self.yname=='az':
            self.yname='xel'
        elif self.yname=='az_off':
            self.yname='xel_off'
        elif self.yname=='xel':
            self.yname='az'
        elif self.yname=='xel_off':
            self.yname='az_off'

        self.plotter(self.xname, self.yname)

        if self.xelazflag ==1:
            self.xelazflag=0
            self.flagstring = self.flagstring[:-2]+'1'+self.flagstring[-1]
            self.pickedlabelcr()
            self.statmenucr()
            self.AzOffsetTimeAct.setVisible(False)
            self.AzOffsetElAct.setVisible(False)
            self.AzOffsetAzAct.setVisible(False)
            try:
                if self.df.loc[0, "time"]!=0:
                    self.XElOffsetTimeAct.setVisible(True)
            except:
                pass
            self.XElElAct.setVisible(True)
            self.XElAzAct.setVisible(True)
            self.xelcordAct.setChecked(True)

        else:
            self.xelazflag=1
            self.flagstring = self.flagstring[:-2]+'0'+self.flagstring[-1]
            self.pickedlabelcr()
            self.statmenucr()
            try:
                if self.df.loc[0, "time"]!=0:
                    self.AzOffsetTimeAct.setVisible(True)
            except:
                pass
            self.AzOffsetElAct.setVisible(True)
            self.AzOffsetAzAct.setVisible(True)
            self.XElOffsetTimeAct.setVisible(False)
            self.XElElAct.setVisible(False)
            self.XElAzAct.setVisible(False)
            self.azcordAct.setChecked(True)

    def fecswap(self, n):
        """Changes the fec in the flagstring to be used for future calculations.
        """

        self.hassaved=0
        if n==1:
            self.flagstring = self.flagstring[0]+'0'+self.flagstring[2]+'1'
        elif n==0:
            self.flagstring = self.flagstring[0]+'0'+self.flagstring[2]+'0'
        elif n==2:
            self.flagstring = self.flagstring[0]+'1'+self.flagstring[2:]

    def switchdfraw(self):
        """Switch the plotted data to the raw data (bring over the sigmas thought)
        """

        self.df_deg_edit = self.df_deg[self.df_deg["indicator"]!="*bad"]
        self.df_deg_edit['indicator']=pd.to_numeric(self.df_deg_edit['indicator'])
        self.df_deg_edit = self.df_deg_edit.reset_index(drop=True)

        self.df_deg_edit["az_input_sigma"] = self.df_cor_deg["az_input_sigma"]
        self.df_deg_edit["el_input_sigma"] = self.df_cor_deg["el_input_sigma"]
        self.df_deg_edit["xel_input_sigma"] = self.df_cor_deg["xel_input_sigma"]
        self.df_deg_edit["az_prior_sigma"] = self.df_cor_deg["az_prior_sigma"]
        self.df_deg_edit["el_prior_sigma"] = self.df_cor_deg["el_prior_sigma"]
        self.df_deg_edit["xel_prior_sigma"] = self.df_cor_deg["xel_prior_sigma"]
        self.df_deg_edit["az_post_sigma"] = self.df_cor_deg["az_post_sigma"]
        self.df_deg_edit["el_post_sigma"] = self.df_cor_deg["el_post_sigma"]
        self.df_deg_edit["xel_post_sigma"] = self.df_cor_deg["xel_post_sigma"]
        self.df = copy.deepcopy(self.df_deg_edit)
        self.datatype = 'raw'

    def switchdfunc(self):
        """Switch the plotted data to the uncorrected data (bring over the sigmas thought)
        """

        self.df_unc_deg_edit=self.copy.deepcopy(self.df_unc_deg)
        self.df_unc_deg_edit["az_input_sigma"] = self.df_cor_deg["az_input_sigma"]
        self.df_unc_deg_edit["el_input_sigma"] = self.df_cor_deg["el_input_sigma"]
        self.df_unc_deg_edit["xel_input_sigma"] = self.df_cor_deg["xel_input_sigma"]
        self.df_unc_deg_edit["az_prior_sigma"] = self.df_cor_deg["az_prior_sigma"]
        self.df_unc_deg_edit["el_prior_sigma"] = self.df_cor_deg["el_prior_sigma"]
        self.df_unc_deg_edit["xel_prior_sigma"] = self.df_cor_deg["xel_prior_sigma"]
        self.df_unc_deg_edit["az_post_sigma"] = self.df_cor_deg["az_post_sigma"]
        self.df_unc_deg_edit["el_post_sigma"] = self.df_cor_deg["el_post_sigma"]
        self.df_unc_deg_edit["xel_post_sigma"] = self.df_cor_deg["xel_post_sigma"]
        self.df = copy.deepcopy(self.df_unc_deg_edit)
        self.datatype = 'uncorrected'
    def switchdfres(self):
        """Switch the plotted data to the corrected data.
        """

        self.df = copy.deepcopy(self.df_cor_deg)
        self.datatype = 'residual'

    def printfigure(self):
        """Save the figure as a file.
        """

        text, result = QInputDialog.getText(self, 'Figure PDF Name', "Name of file",QLineEdit.Normal, self.antenna+'_'+self.xname+"_"+self.yname+'.pdf')
        self.figure.savefig(text)

    def paramwindow(self):
        """Open a window for the parameters.
        """

        self.pwind = ParamWindow(self.model_flags, self.xelazflag)
        self.pwind.show()
        self.pwind.paramsavebutton.clicked.connect(self.getparams)

    def getparams(self):
        """If save is clicked in the parameter window
        then save those as the new model_flags and close that window.
        """

        self.hassaved=0
        self.model_flags = self.pwind.get_params()
        print(self.model_flags)
        self.pwind.accept()

    def iowindow(self):
        """Create window for IO information.
        """

        self.overwritextrcheckflag=0
        self.overwriteerrcheckflag=0
        self.iowind = IOWindow(self.xtrname, self.errname, self.logdir, self.mdlctr)
        self.iowind.show()
        self.iowind.filesavebutton.clicked.connect(self.getiostuff)

    def getiostuff(self):
        """When save is clicked save the data in the io window, and then close
        """

        self.hassaved=0
        self.fileouts = self.iowind.get_fileouts()
        self.logdir = self.fileouts[0]
        self.mdlctr = self.fileouts[1]
        self.xtrname = self.fileouts[2]
        self.errname = self.fileouts[3]
        self.overwriteflag = self.fileouts[4]
        self.overwritecheck()
        self.iowind.accept()

    def overwritecheck(self):
        """Check if a message needs to be shown about overwriting the file.
        Then asks for confirmation if they want overwriting to occur.
        """

        if self.overwriteflag ==1:
            if os.path.isfile(self.logdir+self.xtrname) and self.overwritextrcheckflag==0:
                item, ok = QInputDialog.getItem(self, "Overwrite xtrac", "That xtrac file already exists.\nAre you sure you want to overwrite it?", ("No", "Yes"), 0, False)
                if item=="Yes" and ok:
                    self.overwritextrcheckflag=1
            if os.path.isfile(self.logdir+self.errname) and self.overwriteerrcheckflag==0:
                erritem, ok = QInputDialog.getItem(self, "Overwrite error", "That error file already exists.\nAre you sure you want to overwrite it?", ("No", "Yes"), 0, False)
                if erritem=="Yes" and ok:
                    self.overwriteerrcheckflag=1

    def xsig(self):
        """Open up menu asking for x-sigma filtering value, then applies it with sigmatest.
        """

        text, result = QInputDialog.getText(self, 'X-Sigma Testing', "Value for X-Sigma:", QLineEdit.Normal, '3')
        try:
            val = float(text)
            self.sigmatest(val)
        except:
            self.StatusBarLabel.setText("Value must be a number")

    def sigmatest(self, val):
        """Take out all data more than val*sigma away from zero, after determining what the right sigmas are
        """

        self.hassaved=0
        if "xel" in self.yname:
            signame = "xel_"
        elif "az" in self.yname:
            signame = "az_"
        elif "el" in self.yname:
            signame = "el_"

        signame = signame+self.errortype+"_sigma"
        print(signame)



        for index, row in self.df.iterrows():
            if row[self.yname]>(val*row[signame]):
                self.df.at[index, 'indicator']=0
                self.df_unc_deg.at[index, 'indicator']=0
                self.df_unc_rad.at[index, 'indicator']=0
                self.df_deg.at[index, 'indicator']=0
                self.df_rad.at[index, 'indicator']=0
                self.df_cor_deg[index, 'indicator']=0
        self.plotter(self.xname, self.yname)

    def pickedlabelcr(self):
        """Format list, and then create sidebar text
        from list of data categories given when a point is selected.
        """


        self.pickedpoint = ['{:.5f}'.format(float(i)) if isinstance(i, float) else i for i in self.pickedpoint]
        if self.xelazflag==1:
            text="Azimuth:         {0}\n\nElevation:       {1}\n\nAz-Offset:       {2}\n\nAz-Input-Sigma:  {3}\n\nAz-Prior-Sigma:  {4}\n\nAz-Post-Sigma:   {5}\n\nEl-Offset:       {6}\n\nEl-Input-Sigma:  {7}\n\nEl-Prior-Sigma:  {8}\n\nEl-Prior-Sigma:  {9}\n\nSource:          {10}".format(self.pickedpoint[0], self.pickedpoint[1], self.pickedpoint[2], self.pickedpoint[3], self.pickedpoint[4], self.pickedpoint[5], self.pickedpoint[6], self.pickedpoint[7], self.pickedpoint[8], self.pickedpoint[9], self.pickedpoint[14])
        else:
            text="Azimuth:         {0}\n\nElevation:       {1}\n\nxEL-Offset:      {2}\n\nxEL-Input-Sigma: {3}\n\nxEL-Prior-Sigma: {4}\n\nxEL-Post-Sigma:  {5}\n\nEl-Offset:       {6} \n\nEl-Input-Sigma:  {7}\n\nEl-Prior-Sigma:  {8}\n\nEl-Prior-Sigma:  {9}\n\nSource:          {10}".format(self.pickedpoint[0], self.pickedpoint[1], self.pickedpoint[10], self.pickedpoint[11], self.pickedpoint[12], self.pickedpoint[13], self.pickedpoint[6], self.pickedpoint[7], self.pickedpoint[8], self.pickedpoint[9], self.pickedpoint[14])

        self.pickedlabel.setText(text)

    def errortypechanger(self, errorstr):
        """Change the errortype to whatever is fed in
        """

        self.errortype=errorstr
        self.plotter(self.xname, self.yname)

    def getfile(self, filetype):
        """Open and process a file, otherwise spit out errors on the statusbar.
        Also applies settings from the read in file, and then plots.
        """


        self.StatusBarLabel.setText("Please wait for processing to be completed")
        self.fname = QFileDialog.getOpenFileName(self, 'Open file', self.logdir, filetype)
        if self.fname[0] != '':
            if 'xtr' in self.fname[0] or 'log' in self.fname[0]:
                self.StatusBarLabel.setText("Please wait for processing")
                self.df_unc_rad, self.df_rad, self.df_deg, self.model_phi, self.model_flags, self.oldmodel_params,self.all_info, self.df_stats, self.df_unc_stats, self.oldmodel_all, self.flagstring, self.xtrname, self.version, self.filename = general(self.fname[0], self.mdlctr)
                self.xtrname = re.findall(r'[^/]+$', self.xtrname)[0]
                if self.xtrname == '':
                    self.errname = ''
                    self.StatusBarLabel.setText('Error: Need to specify xtr and err filenames in IO Setup')
                else:
                    self.errname = 'err'+self.xtrname[3:]

                self.df_cor_deg, self.df_unc_deg, self.model_flags, self.df_cor_stats, self.az_fec, self.el_fec, self.redchi, self.dfree, self.conditionstring, self.fit_data, self.fit_stats, self.newmodel, self.cor_matrix = general2(self.df_unc_rad, self.df_rad, self.model_phi, self.model_flags, self.oldmodel_params, self.all_info, self.df_stats, self.df_unc_stats, self.oldmodel_all, self.flagstring, self.version, self.filename)

                self.statsdict={"AZ-mean":self.df_cor_stats[0], "AZ-rms":self.df_cor_stats[1], "EL-mean":self.df_cor_stats[2], "EL-rms":self.df_cor_stats[3], "xEL-mean":self.df_cor_stats[7], "xEL-rms":self.df_cor_stats[8], "EL-FEC": self.el_fec, "AZ-FEC":self.az_fec, "xEL-FEC": self.az_fec, "RChi": self.redchi, "DFree": self.dfree}

                if float(self.flagstring[-3])==1:
                    self.nofecAct.setChecked(True)
                elif float(self.flagstring[-1])==1:
                    self.xelfecAct.setChecked(True)
                else:
                    self.azfecAct.setChecked(True)

                self.ResAct.trigger()
                self.xelazflag=float(self.flagstring[-2])
                self.antenna = self.all_info.split()[0]
                self.sourcelist=self.df['source'].unique().tolist()
                self.sourcemenucr()
                self.statmenucr()
                self.AzElAct.trigger()
                self.xelaz()
                self.PriorAct.trigger()

            else:
                self.StatusBarLabel.setText('ALERT: Please choose an xtr or log file')
        else:
            self.StatusBarLabel.setText('ALERT: No such file')

    def closeEvent(self, event):
        """Event which is closed whenever the window is closed,
        and if things haven't been saved, asked."""
        if self.hassaved==0:
            quit_msg = "Are you sure you have saved changes?"
            reply = QMessageBox.question(self, 'Confirmation',
                     quit_msg, QMessageBox.Yes, QMessageBox.No)

            if reply == QMessageBox.Yes:
                event.accept()
            else:
                event.ignore()
        else:
            event.accept()



if __name__ == '__main__':
    #df = pd.read_pickle("df2.pkl")
    app = QApplication(sys.argv)
    ex = PDPlotWindow()
    ex.show()
    sys.exit(app.exec_())
