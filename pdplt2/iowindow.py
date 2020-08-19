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


class IOWindow(QDialog):
    def __init__(self, xtrname, errname, logdir, mdlctr, parent=None):
        super(IOWindow, self).__init__(parent)
        self.gridLayout = QGridLayout()
        self.setLayout(self.gridLayout)

        self.gengroup = QGroupBox()
        self.xtrerrgroup = QGroupBox()
        self.overwritegrp = QButtonGroup()

        self.gridLayout.addWidget(self.gengroup, 0,0,1,2)
        self.gridLayout.addWidget(self.xtrerrgroup, 1,0,1,2)

        self.genLayout = QGridLayout()
        self.xtrerrLayout = QGridLayout()
        self.gengroup.setLayout(self.genLayout)
        self.xtrerrgroup.setLayout(self.xtrerrLayout)

        self.logdescrip = QLabel('Default directory for FS log files:')
        self.mdlctrdescrip = QLabel('Control file for the model:')
        self.xtrnamedescrip = QLabel('Output file name for xtrac:')
        self.errnamedescrip = QLabel('Output file name for error:')
        self.overwritedescrip = QLabel('Overwrite Output Files:')
        self.overwritey = QRadioButton('Yes')
        self.overwriten = QRadioButton('No')
        self.overwritegrp.addButton(self.overwritey)
        self.overwritegrp.addButton(self.overwriten)
        self.overwritegrp.setExclusive(True)
        self.overwriten.setChecked(True)

        self.logpathtext = QLineEdit(self)
        self.mdlctrtext = QLineEdit(self)
        self.xtrnametext = QLineEdit(self)
        self.errnametext = QLineEdit(self)

        self.logpathtext.setText(logdir)
        self.mdlctrtext.setText(mdlctr)
        self.xtrnametext.setText(xtrname)
        self.errnametext.setText(errname)


        self.genLayout.addWidget(self.logdescrip, 0, 0)
        self.genLayout.addWidget(self.logpathtext, 0, 1)
        self.genLayout.addWidget(self.mdlctrdescrip, 1, 0)
        self.genLayout.addWidget(self.mdlctrtext, 1, 1)

        self.xtrerrLayout.addWidget(self.xtrnamedescrip, 0, 0)
        self.xtrerrLayout.addWidget(self.xtrnametext, 0, 1,1,2)
        self.xtrerrLayout.addWidget(self.errnamedescrip, 1, 0)
        self.xtrerrLayout.addWidget(self.errnametext, 1, 1, 1,2)
        self.xtrerrLayout.addWidget(self.overwritedescrip, 2, 0)
        self.xtrerrLayout.addWidget(self.overwritey, 2, 1)
        self.xtrerrLayout.addWidget(self.overwriten, 2, 2)

        self.filesavebutton = QPushButton('Save and Close')
        self.gridLayout.addWidget(self.filesavebutton, 3, 0)
        self.exitbutton = QPushButton('Cancel')
        self.exitbutton.clicked.connect(lambda: self.accept())
        self.gridLayout.addWidget(self.exitbutton, 3, 1)

    def get_fileouts(self):
        if self.overwritey.isChecked():
            self.overwriteflag=1
        else:
            self.overwriteflag=0
        self.fileouts = [self.logpathtext.text(), self.mdlctrtext.text(), self.xtrnametext.text(), self.errnametext.text(), self.overwriteflag]
        return(self.fileouts)
