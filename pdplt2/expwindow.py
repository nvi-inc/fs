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

class ExplanationWindow(QDialog):
    def __init__(self, parent=None):
        super(ExplanationWindow, self).__init__(parent)
        self.gridLayout = QGridLayout()
        self.setLayout(self.gridLayout)
        text="Parameter 1: AZ-angle Encoder Offset \
            \nParameter 2: AZ-Angle Sag \nParameter 3: Axis Skew \
            \nParameter 4: Box Offset \
            \nParameter 5: Tilt Out (tilt of El=+90 toward (AZ,EL)=(0,0)) \
            \nParameter 6: Tilt Over (tilt of El=+90 toward (AZ,EL)=(+90,0))\nTile Amplitude = sqrt(P5^2+P6^2)\nTile of EL=+90 is toward (AZ,EL)=(atan2(P6,P5),0)) \
            \nParameter 7: EL-angle Encoder Offset \
            \nParameter 8: EL-angle sag \
            \nParameter 9: ad hoc EL-angle Slope (degrees/radians) \
            \nParameter 10: ad hoc deltaElcosEl Coefficient \
            \nParameter 11: ad hoc deltaElsinEl Coefficient \
            \nParameter 12: ad hoc AZ-angle Slope (degrees/radians) \
            \nParameter 13: ad hoc deltaAZcosAZ Coefficient \
            \nParameter 14: ad hoc deltaAZsinAZ Coefficient \
            \nParameter 15: ad hoc deltaELcos2AZ Coefficient \
            \nParameter 16: ad hoc deltaELsinEl Coefficient \
            \nParameter 17: ad hoc deltaAZcos2AZ Coefficient \
            \nParameter 18: ad hoc deltaAZsin2AZ Coefficient \
            \nParameter 19: ad hoc deltaELcos8El Coefficient \
            \nParameter 20: ad hoc deltaELsin8El Coefficient \
            \nParameter 21: ad hoc deltaELcosAZ Coefficient \
            \nParameter 22: ad hoc deltaELsinAZ Coefficient \
            \nParameter 23: ad hoc deltaELcotEl Coefficient "

        self.label = QLabel(text)
        self.gridLayout.addWidget(self.label)
