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
      subroutine twrap(itime) 
C 
C     FIX UP TIMES WHICH MAY HAVE OVERFLOWED (WRAPPED AROUND) 
C 
C  INPUT: 
C 
      dimension itime(3)
C     - time array
C     ITIME(1) - (year-1970)*1024 + days
C     ITIME(2) - hours*60 + min 
C     ITIME(3) - seconds*100 + msec/10
C 
C 
C  PROGRAMMER: NRV
C  LAST MODIFIED:  CREATED 791010 
C# LAST COMPC'ED  870115:04:23    # 
C 
C 
      if (itime(3).lt.6000) goto 1
      itime(3) = itime(3) - 6000
      itime(2) = itime(2) + 1 
1     if (itime(2).lt.1440) goto 2
      itime(2) = itime(2) - 1440
      itime(1) = itime(1) + 1 
2     return
      end 
