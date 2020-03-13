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
      subroutine offco(off,azof,elof,azpos,elpos,ierr)
C 
C  OFFSET CALCULATION FOR SYSTEM TEMPERATURE
C 
C  INPUT: 
C 
C        OFF = DISTANCE TO GO OFF SOURCE
C 
C  OUTPUT:
C 
C        AZOF   = AZIMUTH OFFSET
C 
C        ELOF   = ELEVATION OFFSET
C 
C        AZPOS  = AZIMUTH OF THE RESULTING POSIOTN
C 
C        ELPOS  = ELEVATION OF THE RESULTING POSITION 
C 
C        IERR = 0 IF NO ERROR 
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
C  INITAILLY ASSUME THAT: 
C 
      call local(azpos,elpos,'azel',ierr) 
      if (ierr.ne.0) return
      azof=off/cos(elpos) 
      elof=0.0
C 
C  NOW FIX IT, IF ITS WRONG 
C 
      if (azpos.gt.RPI) azof=-azof
      if (elpos.lt.75.0*(RPI/180.)) goto 1000
      azof=0.0
      elof=-off 
C 
1000  continue
      azpos=azpos+azof
      if (azpos.ge.2.0*RPI) azpos=azpos+2.0*RPI
      if (azpos.lt.0.0) azpos=azpos-2.0*RPI 
      elpos=elpos+elof

      return
      end 
