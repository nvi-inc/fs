#!/usr/bin/python
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

import Tkinter
import ttk
import tkFont
import array
import socket
import os
import readline
import sys
import string
import subprocess
import datetime
import time

class msg_tk(Tkinter.Tk):
	def __init__(self,parent):
		Tkinter.Tk.__init__(self,parent)
		fontsize=14

		self.parent = parent
		self.customFont = tkFont.Font(family="Helvetica", size=fontsize)
		self.initialize()

                self._max_read_bytes = 10000000 # 10M
                self._bandA = ["ip","pps","gps"]
                self._bandB = ["ip","pps","gps"]
                self._bandC = ["ip","pps","gps"]
                self._bandD = ["ip","pps","gps"]
                self._to = [""]
                self._comment = ""
                self._station = ""
                self._schedule = ""
                self._type = ""
                self._20k = ""
                self._70k = ""
                self._maser = ""
                self._mci = ""

                # read in vgosmsg conf
                fileHandle = open ( '/usr2/control/rdbemsg.ctl' )
                self.vconf = fileHandle.readlines()
                fileHandle.close ()

		for self.vc in self.vconf:
			if (self.vc[0] == "*"):
				continue
                        self.vc.rstrip('\r\n')
                        self.val = self.vc.split(':');
                        if (self.val[0] == "to"):
                                self._to = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "type"):
                                self._type = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "station"):
                                self._station = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "R-A"):
                                self._bandA[0] = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "R-B"):
                                self._bandB[0] = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "R-C"):
                                self._bandC[0] = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "R-D"):
                                self._bandD[0] = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "mci"):
                                self._mci = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "comment"):
                                self._comment = self.val[1].rstrip('\r\n')
                        elif (self.val[0] == "schedule"):
                                self._schedule = self.val[1].rstrip('\r\n')
                        else:
                                print "unknown value";
                        #print self.val

		self._ts = time.time()
                self._mcilogtime = datetime.datetime.fromtimestamp(self._ts).strftime('%Y%m')


	def initialize(self):
		self.grid()
	
		# Welcome 2 lines

		r0 = Tkinter.Label(self,fg="white", bg="blue",text=u"---------- RDBE msg ----------",font=self.customFont,width=15)
                r0.grid(column=0,row=0,columnspan=7,sticky='EW')

		r1 = Tkinter.Label(self,fg="white", bg="blue",text=u" ", font=self.customFont,width=15)
                r1.grid(column=0,row=1,columnspan=7,sticky='EW')

		# Session Name
		r2_0 = Tkinter.Label(self,fg="white",bg="blue",text=u"Session Name:",font=self.customFont,width=15)
		r2_0.grid(column=0,row=2,sticky='EW')

		self.sessionname = Tkinter.StringVar()
		self.sessionnameVariable = Tkinter.Entry(self,textvariable=self.sessionname,font=self.customFont,width=15)
                self.sessionnameVariable.grid(column=1,row=2,sticky='EW')

		# Station Code
		r2_2 = Tkinter.Label(self,fg="white",bg="blue",text=u"Station Code:",font=self.customFont,width=15)
                r2_2.grid(column=2,row=2,sticky='EW')

		self.stationcode = Tkinter.StringVar()
                self.stationcodeVariable = Tkinter.Entry(self,textvariable=self.stationcode,font=self.customFont,width=15)
                self.stationcodeVariable.grid(column=3,row=2,sticky='EW')

		#Message Type
		r2_4 = Tkinter.Label(self,fg="white", bg="blue",text=u"Message Type",font=self.customFont,width=15)
                r2_4.grid(column=4,row=2,sticky='EW')

                msg_types = ('Ready', 'Start', 'Stop')
                self.typeVariable = Tkinter.StringVar()
                self.typeBox = ttk.Combobox(self, textvariable=self.typeVariable, values=msg_types, state='readonly',font=self.customFont,width=15)
                self.typeBox.grid(column=5,row=2,sticky='EW')

		r3 = Tkinter.Label(self,fg="white", bg="blue",text=u" ", font=self.customFont,width=15)
                r3.grid(column=0,row=3,columnspan=7,sticky='EW')


		# RDBE and SEFD

		r4_0 = Tkinter.Label(self,fg="white", bg="blue",text=u"- RDBE -",font=self.customFont,width=15)
                r4_0.grid(column=0,row=4,sticky='EW')
	
		r4_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"- SEFD -",font=self.customFont,width=15)
                r4_3.grid(column=3,row=4,sticky='EW')

		r5_0 = Tkinter.Label(self,fg="white", bg="blue",text=u" ",font=self.customFont,width=15)
                r5_0.grid(column=0,row=5,sticky='EW')

		r5_1 = Tkinter.Label(self,fg="white", bg="blue",text=u"PPS Offset",font=self.customFont,width=15)
		r5_1.grid(column=1,row=5,sticky='EW')

		r5_2 = Tkinter.Label(self,fg="white", bg="blue",text=u"GPS Offset",font=self.customFont,width=15)
                r5_2.grid(column=2,row=5,sticky='EW')

		r5_4 = Tkinter.Label(self,fg="white", bg="blue",text=u"IF0",font=self.customFont,width=15)
                r5_4.grid(column=4,row=5,sticky='EW')
                
                r5_5 = Tkinter.Label(self,fg="white", bg="blue",text=u"IF1",font=self.customFont,width=15)
                r5_5.grid(column=5,row=5,sticky='EW')

		r5_6 = Tkinter.Label(self,fg="white", bg="blue",text=u"SRC",font=self.customFont,width=15)
                r5_6.grid(column=6,row=5,sticky='EW')

		r6_0 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandA",font=self.customFont,width=15)
                r6_0.grid(column=0,row=6,sticky='EW')

		self.ppsA = Tkinter.StringVar()
		ppsAlabel = Tkinter.Label(self,textvariable=self.ppsA,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
		ppsAlabel.grid(column=1,row=6,sticky='EW')

		self.gpsA = Tkinter.StringVar()
                gpsAlabel = Tkinter.Label(self,textvariable=self.gpsA,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                gpsAlabel.grid(column=2,row=6,sticky='EW')

		r6_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandA",font=self.customFont,width=15)
                r6_3.grid(column=3,row=6,sticky='EW')

		self.sefdA0 = Tkinter.StringVar()
                self.sefdA0Variable = Tkinter.Label(self,textvariable=self.sefdA0,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdA0Variable.grid(column=4,row=6,sticky='EW')

		self.sefdA1 = Tkinter.StringVar()
                self.sefdA1Variable = Tkinter.Label(self,textvariable=self.sefdA1,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdA1Variable.grid(column=5,row=6,sticky='EW')

		self.sefdSRC = Tkinter.StringVar()
		self.sefdSRCVariable = Tkinter.Label(self,textvariable=self.sefdSRC,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdSRCVariable.grid(column=6,row=6,sticky='EW')

		r7 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandB",font=self.customFont,width=15)
                r7.grid(column=0,row=7,sticky='EW')

		self.ppsB = Tkinter.StringVar()
                ppsBlabel = Tkinter.Label(self,textvariable=self.ppsB,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                ppsBlabel.grid(column=1,row=7,sticky='EW')

                self.gpsB = Tkinter.StringVar()
                gpsBlabel = Tkinter.Label(self,textvariable=self.gpsB,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                gpsBlabel.grid(column=2,row=7,sticky='EW')

		r7_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandB",font=self.customFont,width=15)
                r7_3.grid(column=3,row=7,sticky='EW')

		self.sefdB0 = Tkinter.StringVar()
                self.sefdB0Variable = Tkinter.Label(self,textvariable=self.sefdB0,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdB0Variable.grid(column=4,row=7,sticky='EW')

		self.sefdB1 = Tkinter.StringVar()
                self.sefdB1Variable = Tkinter.Label(self,textvariable=self.sefdB1,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdB1Variable.grid(column=5,row=7,sticky='EW')

		r7_6 = Tkinter.Label(self,fg="white", bg="blue",text=u"Time",font=self.customFont,width=15)
                r7_6.grid(column=6,row=7,sticky='EW')

		r8 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandC",font=self.customFont,width=15)
                r8.grid(column=0,row=8,sticky='EW')

		self.ppsC = Tkinter.StringVar()
                ppsClabel = Tkinter.Label(self,textvariable=self.ppsC,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                ppsClabel.grid(column=1,row=8,sticky='EW')

                self.gpsC = Tkinter.StringVar()
                gpsClabel = Tkinter.Label(self,textvariable=self.gpsC,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                gpsClabel.grid(column=2,row=8,sticky='EW')

		r8_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandC",font=self.customFont,width=15)
                r8_3.grid(column=3,row=8,sticky='EW')

		self.sefdC0 = Tkinter.StringVar()
                self.sefdC0Variable = Tkinter.Label(self,textvariable=self.sefdC0,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdC0Variable.grid(column=4,row=8,sticky='EW')

		self.sefdC1 = Tkinter.StringVar()
                self.sefdC1Variable = Tkinter.Label(self,textvariable=self.sefdC1,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdC1Variable.grid(column=5,row=8,sticky='EW')
	
		self.sefdTIME = Tkinter.StringVar()
		self.sefdTIMEVariable = Tkinter.Label(self,textvariable=self.sefdTIME,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdTIMEVariable.grid(column=6,row=8,sticky='EW')

		r9 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandD",font=self.customFont,width=15)
                r9.grid(column=0,row=9,sticky='EW')

		self.ppsD = Tkinter.StringVar()
                ppsDlabel = Tkinter.Label(self,textvariable=self.ppsD,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                ppsDlabel.grid(column=1,row=9,sticky='EW')

                self.gpsD = Tkinter.StringVar()
                gpsDlabel = Tkinter.Label(self,textvariable=self.gpsD,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                gpsDlabel.grid(column=2,row=9,sticky='EW')

		r9_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"BandD",font=self.customFont,width=15)
                r9_3.grid(column=3,row=9,sticky='EW')

		self.sefdD0 = Tkinter.StringVar()
                self.sefdD0Variable = Tkinter.Label(self,textvariable=self.sefdD0,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdD0Variable.grid(column=4,row=9,sticky='EW')

		self.sefdD1 = Tkinter.StringVar()
                self.sefdD1Variable = Tkinter.Label(self,textvariable=self.sefdD1,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdD1Variable.grid(column=5,row=9,sticky='EW')

		r10_0 = Tkinter.Label(self,fg="white", bg="blue",text=u" ",font=self.customFont,width=15)
                r10_0.grid(column=0,row=10,sticky='EW')

		r10_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"Az",font=self.customFont,width=15)
                r10_3.grid(column=3,row=10,sticky='EW')

		self.sefdAz = Tkinter.StringVar()
                self.sefdAzVariable = Tkinter.Label(self,textvariable=self.sefdAz,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdAzVariable.grid(column=4,row=10,sticky='EW')

		r10_5 = Tkinter.Label(self,fg="white", bg="blue",text=u"El",font=self.customFont,width=15)
                r10_5.grid(column=5,row=10,sticky='EW')

		self.sefdEl = Tkinter.StringVar()
                self.sefdElVariable = Tkinter.Label(self,textvariable=self.sefdEl,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                self.sefdElVariable.grid(column=6,row=10,sticky='EW')

		r11 = Tkinter.Label(self,fg="white", bg="blue",text=u" ",font=self.customFont,width=15)
                r11.grid(column=0,row=11,columnspan=7,sticky='EW')	

		# Maser offset and MCI

		r12 = Tkinter.Label(self,fg="white", bg="blue",text=u"- Maser -",font=self.customFont,width=15)
                r12.grid(column=0,row=12,sticky='EW')

		r12_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"- MCI -",font=self.customFont,width=15)
               	r12_3.grid(column=3,row=12,sticky='EW')

		r13_0 = Tkinter.Label(self,fg="white", bg="blue",text=u" ",font=self.customFont,width=15)
                r13_0.grid(column=0,row=13,sticky='EW')

		r13 = Tkinter.Label(self,fg="white", bg="blue",text=u"Reading",font=self.customFont,width=15)
                r13.grid(column=1,row=13,sticky='EW')
                
                r13_4 = Tkinter.Label(self,fg="white", bg="blue",text=u"Sensor",font=self.customFont,width=15)
                r13_4.grid(column=4,row=13,sticky='EW')
                
                r13_5 = Tkinter.Label(self,fg="white", bg="blue",text=u"Reading",font=self.customFont,width=15)
                r13_5.grid(column=5,row=13,sticky='EW')

		r14_0 = Tkinter.Label(self,fg="white", bg="blue",text=u"Maser Offset",font=self.customFont,width=15)
                r14_0.grid(column=0,row=14,sticky='EW')

		self.maser = Tkinter.StringVar()	
		self.maserVariable = Tkinter.Entry(self,textvariable=self.maser,font=self.customFont,width=15)
                self.maserVariable.grid(column=1,row=14,columnspan=1,sticky='EW')

		r14_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"20K",font=self.customFont,width=15)
                r14_3.grid(column=3,row=14,sticky='EW')

                self.cryo20t = Tkinter.StringVar()
                cryo20tlabel = Tkinter.Label(self,textvariable=self.cryo20t,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                cryo20tlabel.grid(column=4,row=14,sticky='EW')

                self.cryo20v = Tkinter.StringVar()
                cryo20vlabel = Tkinter.Label(self,textvariable=self.cryo20v,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                cryo20vlabel.grid(column=5,row=14,sticky='EW')

		r15_0 = Tkinter.Label(self,fg="white", bg="blue",text=u" ",font=self.customFont,width=15)
                r15_0.grid(column=0,row=15,sticky='EW')

		r15_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"70K",font=self.customFont,width=15)
                r15_3.grid(column=3,row=15,sticky='EW')
                
                self.cryo70t = Tkinter.StringVar()
                cryo70tlabel = Tkinter.Label(self,textvariable=self.cryo70t,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                cryo70tlabel.grid(column=4,row=15,sticky='EW')
                
                self.cryo70v = Tkinter.StringVar()
                cryo70vlabel = Tkinter.Label(self,textvariable=self.cryo70v,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                cryo70vlabel.grid(column=5,row=15,sticky='EW')
	
                row = 21 
		rpnt_0 = Tkinter.Label(self,fg="white", bg="blue",text=u" ",font=self.customFont,width=15)
                rpnt_0.grid(column=0,row=row,columnspan=7,sticky='EW')	

                row = row + 1
		rpnt_1_0 = Tkinter.Label(self,fg="white", bg="blue",text=u"- Pointing - ",font=self.customFont,width=15)
                rpnt_1_0.grid(column=0,row=row,sticky='EW')

		rpnt_1_2 = Tkinter.Label(self,fg="white", bg="blue",text=u"Source",font=self.customFont,width=15)
                rpnt_1_2.grid(column=2,row=row,sticky='EW')

                self.pSRC    = Tkinter.StringVar()
                pSRClabel = Tkinter.Label(self,textvariable=self.pSRC,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                pSRClabel.grid(column=3,row=row,sticky='EW')

		rpnt_1_4 = Tkinter.Label(self,fg="white", bg="blue",text=u"Time",font=self.customFont,width=15)
                rpnt_1_4.grid(column=4,row=row,sticky='EW')

                self.pTIM    = Tkinter.StringVar()
                pTIMlabel = Tkinter.Label(self,textvariable=self.pTIM,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                pTIMlabel.grid(column=5,row=row,sticky='EW')

		row = row + 1
		rpnt_2_0 = Tkinter.Label(self,fg="white", bg="blue",text=u"Lon",font=self.customFont,width=15)
                rpnt_2_0.grid(column=0,row=row,sticky='EW')

		rpnt_2_1 = Tkinter.Label(self,fg="white", bg="blue",text=u"Lat",font=self.customFont,width=15)
                rpnt_2_1.grid(column=1,row=row,sticky='EW')

		rpnt_2_2 = Tkinter.Label(self,fg="white", bg="blue",text=u"X-Lat offset",font=self.customFont,width=15)
                rpnt_2_2.grid(column=2,row=row,sticky='EW')

		rpnt_2_3 = Tkinter.Label(self,fg="white", bg="blue",text=u"Lat offset",font=self.customFont,width=15)
                rpnt_2_3.grid(column=3,row=row,sticky='EW')

		rpnt_2_4 = Tkinter.Label(self,fg="white", bg="blue",text=u"X-Lat QC",font=self.customFont,width=15)
                rpnt_2_4.grid(column=4,row=row,sticky='EW')

		rpnt_2_5 = Tkinter.Label(self,fg="white", bg="blue",text=u"Lat QC",font=self.customFont,width=15)
                rpnt_2_5.grid(column=5,row=row,sticky='EW')

		rpnt_2_6 = Tkinter.Label(self,fg="white", bg="blue",text=u"Detector",font=self.customFont,width=15)
                rpnt_2_6.grid(column=6,row=row,sticky='EW')

		row = row + 1
                self.lon     = Tkinter.StringVar()
                lonlabel = Tkinter.Label(self,textvariable=self.lon,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                lonlabel.grid(column=0,row=row,sticky='EW')
                
                self.lat     = Tkinter.StringVar()
                latlabel = Tkinter.Label(self,textvariable=self.lat,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                latlabel.grid(column=1,row=row,sticky='EW')
                
                self.xlatoff = Tkinter.StringVar()
                xlatofflabel = Tkinter.Label(self,textvariable=self.xlatoff,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                xlatofflabel.grid(column=2,row=row,sticky='EW')
                
                self.latoff = Tkinter.StringVar()
                latofflabel = Tkinter.Label(self,textvariable=self.latoff,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                latofflabel.grid(column=3,row=row,sticky='EW')
                
                self.xlatqc = Tkinter.StringVar()
                xlatqclabel = Tkinter.Label(self,textvariable=self.xlatqc,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                xlatqclabel.grid(column=4,row=row,sticky='EW')
                
                self.latqc = Tkinter.StringVar()
                latqclabel = Tkinter.Label(self,textvariable=self.latqc,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                latqclabel.grid(column=5,row=row,sticky='EW')
                
                self.detec = Tkinter.StringVar()
                deteclabel = Tkinter.Label(self,textvariable=self.detec,anchor="w",fg="white",bg="black",font=self.customFont,width=15)
                deteclabel.grid(column=6,row=row,sticky='EW')
                
		row = row + 3
		r21 = Tkinter.Label(self,fg="white", bg="blue",text=u" ", font=self.customFont,width=15)
                r21.grid(column=0,row=row,columnspan=7,sticky='EW')

		row = row + 1
		r22 = Tkinter.Label(self,fg="white", bg="blue",text=u"To",font=self.customFont,width=15)
                r22.grid(column=0,row=row,sticky='EW')

		self.addressTo = Tkinter.StringVar()
		self.toVariable = Tkinter.Entry(self,textvariable=self.addressTo,font=self.customFont,width=15)
                self.toVariable.grid(column=1,row=row,columnspan=2,sticky='EW')
	
		row = row + 3
		r25 = Tkinter.Label(self,fg="white", bg="blue",text=u"Comments",font=self.customFont,width=15)
                r25.grid(column=0,row=row,sticky='EW')
	
		#self.comment = Tkinter.StringVar()
		self.commentBox = Tkinter.Text(self,height=3,font=self.customFont,width=15)
		self.commentBox.grid(column=1,row=row,columnspan=3,sticky='WE')
		
		commentScroll = Tkinter.Scrollbar(self, command=self.commentBox.yview)
		commentScroll.grid(column=4,row=row,sticky='WNS')
		self.commentBox['yscrollcommand'] = commentScroll.set

		row = row + 1
		update_button = Tkinter.Button(self,text=u"Update Values", command=self.OnButtonUpdate,font=self.customFont,width=15)
		update_button.grid(column=5,row=row)

		send_button = Tkinter.Button(self,text=u"Send Msg", command=self.OnButtonSend,font=self.customFont,width=15)
		send_button.grid(column=6,row=row)
	
		#Window settings
		self.columnconfigure(0,weight=1)
		self.resizable(False,False)
		self.update()
		#self.geometry('720x460+20+20')
		self.configure(background = 'blue')
		#self.entry.focus_set()
		#self.entry.selection_range(0, Tkinter.END)

	def OnButtonUpdate(self):
		print "Updating Values!"
		c = self.stationcode.get()
		if c == "":
			c = self._station
			self.stationcode.set(c)
# make sure no funny characters for shell
                if not c.isalnum():
                        c = ""
			self.stationcode.set(c)

		s = self.sessionname.get()
		if s == "":
			proclognm = subprocess.Popen(["lognm"], stdout=subprocess.PIPE)
                	s1 = proclognm.stdout.read().rstrip('\n')
			if s1[-2:] == c:
				s = s1[:-2]
                	self.sessionname.set(s)
# make sure no funny characters for shell
                if not s.isalnum():
                        s = ""
                	self.sessionname.set(s)

		try:
			self.GetRDBEVals()
		except:
			print "Could not get RDBE data!"

		if self._mci != "":
			try:
				self.GetCryoVals()
			except Exception,e: 
				print str(e)
				print "Could not get MCI data!"
		else:
			print "No MCI node defined!"

		try:
			self.GetSEFDVals()
		except:
			print "Could not get SEFD values!"

		try:
			self.GetPntVals()
		except:
			print "Could not get Pointing values!"

		self.addressTo.set(self._to)

	def OnButtonSend(self):
		print "Sending Message!"
		#print self.typeBox.get()
		self.sendMessage()

	def GetRDBEVals(self):
		host = "127.0.0.1"
                port = 5000
                print "Updating offset values: "+ self._bandA[0]
                host = self._bandA[0]
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect ((host,port))
                rv = s.send("pps_offset?;\n")
		ra = s.recv(8192).rstrip(';\r\n').split(':')
                self._junk,self._bandA[1] = ra
                rv = s.send("gps_offset?;\n")
                self._junk,self._bandA[2] = s.recv(8192).rstrip(';\r\n').split(':')
                s.close()

		self.ppsA.set(self._bandA[1])
		self.gpsA.set(self._bandA[2])

		print "Updating offset values: "+ self._bandB[0]
                host = self._bandB[0]
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect ((host,port))
                rv = s.send("pps_offset?;\n")
                self._junk,self._bandB[1] = s.recv(8192).rstrip(';\r\n').split(':')
                rv = s.send("gps_offset?;\n")
                self._junk,self._bandB[2] = s.recv(8192).rstrip(';\r\n').split(':')
                s.close()

		self.ppsB.set(self._bandB[1])
                self.gpsB.set(self._bandB[2])

                print "Updating offset values: "+ self._bandC[0]
                host = self._bandC[0]
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect ((host,port))
                rv = s.send("pps_offset?;\n")
                self._junk,self._bandC[1] = s.recv(8192).rstrip(';\r\n').split(':')
                rv = s.send("gps_offset?;\n")
                self._junk,self._bandC[2] = s.recv(8192).rstrip(';\r\n').split(':')
                s.close()

		self.ppsC.set(self._bandC[1])
                self.gpsC.set(self._bandC[2])

                print "Updating offset values: "+ self._bandD[0]
                host = self._bandD[0]
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect ((host,port))
                rv = s.send("pps_offset?;\n")
                self._junk,self._bandD[1] = s.recv(8192).rstrip(';\r\n').split(':')
                rv = s.send("gps_offset?;\n")
                self._junk,self._bandD[2] = s.recv(8192).rstrip(';\r\n').split(':')
                s.close()

		self.ppsD.set(self._bandD[1])
                self.gpsD.set(self._bandD[2])

	def GetCryoVals(self):
                print "Updating Cryo Values"
		c = self.stationcode.get()
		proc20 = subprocess.Popen(["ssh", "oper@" + self._mci, "tail", "-n", "100", "mci_" + c + "_" + self._mcilogtime + ".txt", "|", "egrep", "'AD214|AD215'"], stdout=subprocess.PIPE)
                text =proc20.stdout.read()
		for line in text.split('\n'):
			if "AD214" in line:
				self._20k=line.split(';')
			if "AD215" in line:
				self._70k=line.split(';')

		self.cryo20t.set(self._20k[0])
		self.cryo20v.set(self._20k[2])

		self.cryo70t.set(self._70k[0])
                self.cryo70v.set(self._70k[2])

                #print self._20k
                #print self._70k
	
	def GetSEFDVals(self):
                print "Updating SEFD Values"
		s = self.sessionname.get()
		c = self.stationcode.get()
		procSEFD = subprocess.Popen(["/bin/sh", "-c", "grep 'onoff#VAL' /usr2/log/" + s + c + ".log  | tail  -n 8"], stdout=subprocess.PIPE)

                self._SEFD = procSEFD.stdout.read().split('\n')

		for vals in self._SEFD[:-1]:
			v = vals.rstrip(';\r\n').split()

#			print v

			self.sefdSRC.set(v[1])

			t = v[0].split("#")
			self.sefdTIME.set(t[0])

			self.sefdAz.set(v[2])
			self.sefdEl.set(v[3])

			if (v[4] == "15a0"):
				self.sefdA0.set(v[10])
			elif (v[4] == "15a1"):
				self.sefdA1.set(v[10])
			elif (v[4] == "15b0"):
                                self.sefdB0.set(v[10])
			elif (v[4] == "15b1"):
                                self.sefdB1.set(v[10])
			elif (v[4] == "15c0"):
                                self.sefdC0.set(v[10])
			elif (v[4] == "15c1"):
                                self.sefdC1.set(v[10])
			elif (v[4] == "15d0"):
                                self.sefdD0.set(v[10])
			elif (v[4] == "15d1"):
                                self.sefdD1.set(v[10])

		#print self._SEFD[1]

	def GetPntVals(self):
                print "Updating Pointing Values"
		s = self.sessionname.get()
		c = self.stationcode.get()
		procPnt = subprocess.Popen(["/bin/sh", "-c", "grep 'fivpt#xoffset' /usr2/log/" + s + c + ".log  | tail  -n 1"], stdout=subprocess.PIPE)

                vals = procPnt.stdout.read().split('\n')[0]

		v = vals.split()

		self.pSRC.set(v[10])

		t = v[0].split("#")
		self.pTIM.set(t[0])

		self.lon.set(v[1])
		self.lat.set(v[2])
		self.xlatoff.set(v[3])
		self.latoff.set(v[4])
		self.xlatqc.set(v[7])
		self.latqc.set(v[8])
		self.detec.set(v[9])

	def sendMessage(self):
		TO = self.addressTo.get()
		SUBJECT = self.sessionname.get() + ", KPGO12M, " + self.typeVariable.get() + " message"
		TEXT = 	" Comment:\n" +\
			" " + self.commentBox.get('1.0',Tkinter.END) + "\n" +\
			" Maser Offset: " + self.maser.get() + "\n\n" + \
			"============RDBE-OFFSETS===========\n" + \
                	" PPS Offset\n" + \
                	" RDBE-BandA: " + self.ppsA.get() + "\n" + \
                	" RDBE-BandB: " + self.ppsB.get() + "\n" +\
                	" RDBE-BandC: " + self.ppsC.get() + "\n" +\
                	" RDBE-BandD: " + self.ppsD.get() + "\n" +\
                	"==================================\n" +\
                	" GPS Offset\n" +\
                	" RDBE-BandA: " + self.gpsA.get() +"\n" +\
                	" RDBE-BandB: " + self.gpsB.get() +"\n" +\
                	" RDBE-BandC: " + self.gpsC.get() +"\n" +\
                	" RDBE-BandD: " + self.gpsD.get() +"\n\n"
		if self._mci != "":
			TEXT = TEXT +\
                	"============CRYO-INFORMATION======\n" +\
			" MCI INFO\n" +\
			" 20K = " + self.cryo20t.get() + " | " + self.cryo20v.get() + "\n" +\
			" 70K = " + self.cryo70t.get() + " | " + self.cryo70v.get() + "\n\n"
		TEXT = TEXT +\
			"============SEFD-INFORMATION======\n" + \
			" SOURCE: " + self.sefdSRC.get() + " | TIME: " + self.sefdTIME.get() +"\n" + \
			" Az: " + self.sefdAz.get() + " | El: " + self.sefdEl.get() +"\n" + \
                        " RDBE-BandA: " + self.sefdA0.get() + " | " + self.sefdA1.get() +"\n" + \
                        " RDBE-BandB: " + self.sefdB0.get() + " | " + self.sefdB1.get() +"\n" + \
                        " RDBE-BandC: " + self.sefdC0.get() + " | " + self.sefdC1.get() +"\n" + \
                        " RDBE-BandD: " + self.sefdD0.get() + " | " + self.sefdD1.get() + "\n\n"
		TEXT = TEXT +\
			"========POINTING-INFORMATION======\n" + \
			" SOURCE: " + self.pSRC.get() + " | TIME: " + self.pTIM.get() + " | DETECTOR: " + self.detec.get() + "\n" + \
			" Lon: " + self.lon.get() + " | Lat: " + self.lat.get() +"\n" + \
			" OFFSETS: X-Lat: " + self.xlatoff.get() + " | Lat: " + self.latoff.get() +"\n" + \
			" QCs: X-Lat: " + self.xlatqc.get() + " | Lat: " + self.latqc.get()


		process = subprocess.Popen(["mail", "-s", SUBJECT, TO], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		process.stdin.write(TEXT)
		print process.communicate()[0]
		process.stdin.close()


if __name__ == "__main__":
	app = msg_tk(None)
	app.title("RDBE msg")
	app.mainloop()
