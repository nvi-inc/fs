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
      function iphck(i)
C  checks for phase cal in track c#870115:04:51 #
C 
C     Given a track #, IPHCK checks for phase cal < 50kHz 
C     and returns as 0 if there is no phase cal.
C     If the phase cal is OK, IPHCK returns as the track #. 
C 
      double precision pcal 
C 
      iphck = 0 
      call phcal(pcal,i,idum) 
      if (pcal.le.50000.) iphck = i 
      return
      end 
