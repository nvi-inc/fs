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
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *


class ParamWindow(QDialog):
    def __init__(self, paramflags, xelazflag, parent=None):
        self.xelazflag = xelazflag
        super(ParamWindow, self).__init__(parent)
        paramflags=[int(i) for i in paramflags]
        self.paramflags=paramflags
        self.gridLayout = QGridLayout()
        self.setLayout(self.gridLayout)
        text="Please choose one flag (0-4) for each parameter (1-30) \nFlag 0: This parameter is not in use. \nFlag 1: This parameter is in use. \nFlag 2: This parameter is in use but its value is hardwired. \nFlag 3: Update 3's only, hardwire 1's and 2's. \nFlag 4: This parameter is used in current model, but don't use in new model"
        self.topexplanation = QLabel(text)
        self.descriptions = QPushButton('Param Descriptions')
        self.descriptions.pressed.connect(self.explanation)
        self.gridLayout.addWidget(self.topexplanation, 0, 0, 1, 7)
        self.gridLayout.addWidget(self.descriptions, 0,7, 1, 3)
        self.buttonconstructor()

        self.paramsavebutton = QPushButton('Save and Close')
        self.gridLayout.addWidget(self.paramsavebutton,5,0,1,2)
        self.exitbutton = QPushButton('Cancel')
        self.exitbutton.clicked.connect(lambda: self.accept())
        self.gridLayout.addWidget(self.exitbutton,5,2,1,2)

    def get_params(self):
        self.paramflags = [0 if i==4 else i for i in self.paramflags]
        return self.paramflags

    def buttonconstructor(self):
        buttons = {}
        group = {}
        buttongroup={}
        self.grouplist = list(self.chunks(self.paramflags,10))
        for i in range(len(self.grouplist)):
            for j in range(len(self.grouplist[i])):
                place = i*(len(self.grouplist[i]))+j
                buttons[place,0] = QRadioButton('0')
                buttons[place,1] = QRadioButton('1')
                buttons[place,2] = QRadioButton('2')
                buttons[place,3] = QRadioButton('3')
                buttons[place,4] = QRadioButton('4')
                buttons[place,0].pressed.connect(lambda place=place: self.paramchanger(place, 0))
                buttons[place,1].pressed.connect(lambda place=place: self.paramchanger(place, 1))
                buttons[place,2].pressed.connect(lambda place=place: self.paramchanger(place, 2))
                buttons[place,3].pressed.connect(lambda place=place: self.paramchanger(place, 3))
                buttons[place,4].pressed.connect(lambda place=place: self.paramchanger(place, 4))
                buttongroup[(i,j)] = QButtonGroup()
                buttongroup[(i,j)].addButton(buttons[place,0])
                buttongroup[(i,j)].addButton(buttons[place,1])
                buttongroup[(i,j)].addButton(buttons[place,2])
                buttongroup[(i,j)].addButton(buttons[place,3])
                buttongroup[(i,j)].addButton(buttons[place,4])


                group[(i,j)] = QGroupBox('Param '+str(place+1)+':')
                vbox = QVBoxLayout()
                group[(i,j)].setLayout(vbox)
                group[(i,j)].setMaximumWidth(60)
                vbox.addWidget(buttons[place,0])
                vbox.addWidget(buttons[place,1])
                vbox.addWidget(buttons[place,2])
                vbox.addWidget(buttons[place,3])
                vbox.addWidget(buttons[place,4])
                self.gridLayout.addWidget(group[(i,j)], i+2, j)

        for key, value in buttons.items():
            if self.paramflags[key[0]]==key[1]:
                value.setChecked(True)


    def paramchanger(self, parnum, val):
        self.paramflags[parnum]=val

    def chunks(self, l, n):
        """Yield successive n-sized chunks from l."""
        for i in range(0, len(l), n):
            yield l[i:i + n]

    def explanation(self):
        self.expwindow = ExplanationWindow()
        self.expwindow.show()
