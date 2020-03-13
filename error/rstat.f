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
      subroutine rstat(lonsum,lonrms,wlnsum,latsum,latrms,wltsum,
     +                 dirms,wdisum,crssum,crsrms,wcrsum,igp,lu)
C
      double precision lonsum,lonrms,latsum,latrms,dirms,wlnsum,wltsum
      double precision wdisum,crssum,crsrms,wcrsum
      logical kif
C
      integer*2 lfat(13)
C
      data lfat/24,2hno,2h p,2hoi,2hnt,2hs ,2hfo,2hr ,2hst,2hat,
     /             2his,2hti,2hcs/
C          no points for statistics
C
      if (kif(lfat(2),lfat(1),idum,0,0,igp.le.0,lu)) stop
      didim1=0
      if (igp.gt.1) didim1=dble(float(igp))/dble(float(igp-1))
C
      lonsum=lonsum/wlnsum
      latsum=latsum/wltsum
      crssum=crssum/wcrsum
C
      lonrms=lonrms/wlnsum
      latrms=latrms/wltsum
      dirms= dirms/wdisum
      crsrms=crsrms/wcrsum
C
      lonrms=dsqrt(dabs(lonrms-lonsum*lonsum)*didim1)
      latrms=dsqrt(dabs(latrms-latsum*latsum)*didim1)
      dirms =dsqrt(dirms*didim1)
      crsrms=dsqrt(dabs(crsrms-crssum*crssum)*didim1)
C
      return
      end
