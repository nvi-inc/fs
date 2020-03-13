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
      subroutine detr(jbuf,ifc,ilc,iayr,iadoy,iahr,iam,ias,iats,
     +                anlon,anlat,erlon,erlat,iferr)
C
      integer*2 jbuf(1) 
C 
      ifield=0
      iferr=1 
C 
C POINTING COMPUTER TIME
C 
      ifield=ifield+1 
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      iayr=ias2b(jbuf,ic1,2)
      iadoy=ias2b(jbuf,ic1+3,3) 
      iahr=ias2b(jbuf,ic1+7,2)
      iam=ias2b(jbuf,ic1+10,2)
      ias=ias2b(jbuf,ic1+13,2)
      iats=ias2b(jbuf,ic1+16,1) 
      if ((ic1.le.0 .or. 
     +   iayr .eq.-32768 .or. 
     +   iadoy.eq.-32768 .or. 
     +   iahr .eq.-32768 .or. 
     +   iam  .eq.-32768 .or. 
     +   ias  .eq.-32768 .or. 
     +   iats .eq.-32768) .and.iferr.ge.0) iferr=-ifield
C 
C  ANTENNA'S CALCULATED LONGITUDE LIKE COORDINATE 
C 
      anlon=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C                       LATITUDE LIKE COORDINATEU 
C 
      anlat=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  TRACKING ERROR FOR LONGITUDE LIKE COORDIANTER
C 
      erlon=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C                     LATITUDE LIKE COORDINATE
C 
      erlat=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
      return
      end 
