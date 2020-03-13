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
      subroutine updat
C  update time-like common variables c#870407:11:31#
C 
C     UPDAT updates values on COMMON for the Field System 
C     IF IT WERE A PROGRAM: 
C     UPDAT reschedules itself for the number of seconds in the 
C           future in its first parameter, the default being 1 sec. 
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
C     CALLED SUBROUTINES: JULDA, SIDTM
C 
C 3.  LOCAL VARIABLES 
C 
      dimension it(5) 
C               - times from system 
C               - also for RMPAR
C     NSEC - how often we re-schedule ourselves 
C        IYR    - year from system
C        MJD    - Julian date, returned from JULDA
      double precision st0
C      - sidereal time at 0h UT 
      double precision f
C       - fraction to convert UT to ST and sec to rad, from JULDA 
C        GST    - Greenwich sidereal time 
C        ARG    - temp for calc 
C        CDEC,SDEC,CLAT,SLAT
C               - sine, cosine of dec, latitude 
C        SAZIM    - temp for az calc
C 
C 6.  PROGRAMMER: nrv 
C     LAST MODIFIED:  800216
C# LAST COMPC'ED  870407:11:31 #
C 
C     0. Statement function to define inverse COS.
C 
      acos(x) = atan2(sqrt(1.0-x*x),x)
C 
C 
C     1. Get current time, then compute Julian day. 
C        Calculate sidereal times, ha.
C        Calculate az, el.
C 
C     CALL RMPAR(IT)
C 
C1    NSEC = IT(1)
C     IF (NSEC.EQ.0) NSEC=1 
C 
      call fc_rte_time(it,iyear)
      iut1 = it(4)*60 + it(3) 
      iut2 = it(2)*100 + it(1)
      itoday = (iyear-1970)*1024+it(5)
C 
      call ymday(iyear,it(5),imon,iday) 
      mjd = julda(imon,iday,iyear-1900) 
      call sidtm(mjd,st0,f) 
      gst = st0 + f*(iut1*60.0+iut2/100.0)
      tlst = gst - wlong
      if (tlst.ge.DTWOPI) tlst = tlst - DTWOPI
      if (tlst.le.0     ) tlst = tlst + DTWOPI
C 
      ha = tlst - radat 
      if (ha.gt. DPI) ha = ha - DTWOPI 
      if (ha.lt.-DPI) ha = ha + DTWOPI 
      call fs_set_ha(ha)
C 
      cdec = cos(decdat)
      sdec = sin(decdat)
      clat = cos(alat)
      slat = sin(alat)
      arg = cdec*clat*cos(ha) + sdec*slat 
      elev = DPI/2.0 - acos(arg) 
      arg = (-slat/(clat*cos(elev)))*(sin(elev)-sdec/slat)
C 
C***HANDLE ROUNDING PROBLEM HERE (MWH - 840806) 
      if (arg.lt.-1.) arg = -1. 
      if (arg.gt.1.) arg = 1. 
C** 
      azim = acos(arg)
      sazim = -cdec*sin(ha)/cos(elev) 
      if (sazim.lt.0) azim = DTWOPI - azim
C 
      return
      end 
