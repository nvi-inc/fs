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
      subroutine radec(ra,dec,ha,irah,iram,ras,ldsign,idecd,idecm,decs, 
     .lhsign,ihah,iham,has)
C 
C     RADEC returns the hms, dms, hms for ra, dec, and ha.
C
      include '../include/dpi.i'
C 
      double precision ra,dec                     !  lar  <910607.0551>
      integer*2 ldsign,lhsign
C 
C  INPUT: 
C 
C     RA, DEC, HA - in radians
C 
C 
C  OUTPUT:
C 
C     IRAH,IRAM,RAS - hms for ra
C     LDSIGN,IDECD,IDECM,DECS - sign, dms for dec 
C     LHSIGN,IHAH,IHAM,HAS - sign, hms for hour angle
C
      double precision h,d
C
C  CONSTANTS:
C
C
C
C     1. First convert the RA.
C
      h = ra*12.d0/dpi
      irah = h
      iram = (h-irah)*60.0
      ras = (h-irah-iram/60.0)*3600.0
C
C
C     2. Next the declination.
C
      d = abs(dec)*180.0/dpi
      idecd = d
      idecm = (d-idecd)*60.0
      decs = (d-idecd-idecm/60.0)*3600.0
      call char2hol('  ',ldsign,1,2)
      if (dec.lt.0) call char2hol('- ',ldsign,1,2)
C 
C 
C     3. Finally the hour angle.
C 
      h = abs(ha)*12.0/dpi
      ihah = h
      iham = (h-ihah)*60.0
      has = (h-ihah-iham/60.0)*3600.0 
      call char2hol('  ',lhsign,1,2)
      if (ha.lt.0) call char2hol('- ',lhsign,1,2)
      return
      end 
