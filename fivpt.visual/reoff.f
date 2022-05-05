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
      subroutine reoff(lonosv,latosv,ierr)
      real lonosv,latosv
C 
C  PICK THE APPROPROATE OFFSETS FOR THE GIVEN AXIS SYSTEM 
C 
C  OUTPUT:
C 
C     LONOSV CONTAINS THE LONGITUDE AXIS OFFSET 
C 
C     LATOSV CONTAINS THE LATITUDE  AXIS OFFSET 
C 
C     IERR IS NONZERO IF AN ERROR OCCUURRED 
C 
      include '../include/fscom.i'
C 
      integer ichcm_ch
C
C  THE FOLLOWING VARIABLES ARE READ FROM FSCOM: 
C 
C        XOFF, YOFF, AZOFF, ELOFF, RAOFF, DECOFF, LAXFP 
C 
C  HA/DEC, NOT RA/DEC 
C 
      if (ichcm_ch(laxfp,1,'hadc').ne.0) goto 200
      call fs_get_raoff(raoff)
      lonosv=-raoff 
      call fs_get_decoff(decoff)
      latosv=decoff 
      return
C 
C  AZ/EL
C 
200   continue
      if (ichcm_ch(laxfp,1,'azel').ne.0) goto 400
      call fs_get_azoff(azoff)
      lonosv=azoff
      call fs_get_eloff(eloff)
      latosv=eloff
      return
C 
C  X/Y NS 
C 
400   continue
      if (ichcm_ch(laxfp,1,'xyns').ne.0) goto 600
      call fs_get_xoff(xoff)
      lonosv=xoff 
      call fs_get_yoff(yoff)
      latosv=yoff 
      return
C 
C  X/Y EW 
C 
600   continue
      if (ichcm_ch(laxfp,1,'xyew').ne.0) goto 800
      call fs_get_xoff(xoff)
      lonosv=xoff 
      call fs_get_yoff(yoff)
      latosv=yoff 
      return
C 
C UNKNOWN AXIS SYSTEM 
C 
800   continue
      ierr=-10

      return
      end 
