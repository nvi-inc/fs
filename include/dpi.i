*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
C DPI.I SOME USEFUL CONSTANTS RELATED TO PI
C
      DOUBLE PRECISION DPI,DEG2RAD,RAD2DEG,DTWOPI,SEC2RAD,RAD2SEC
      REAL RPI
      PARAMETER (DPI=3.141 592 653 589 793 238 46D0,
     &           DEG2RAD=DPI/180.0D0,
     &           RAD2DEG=180.0D0/DPI,
     &           DTWOPI=2.0D0*DPI,
     &           SEC2RAD=DPI/43200.0D0,
     &           RAD2SEC=43200.0D0/DPI,
     &           RPI=3.141592)
