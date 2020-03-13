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
      subroutine xoffot(lonpos,latpos,lonoff,latoff,ilon,ilat,
     +     elnsig,eltsig, lbuf,isbuf)
      real lonpos,latpos,lonoff,latoff,elnsig,eltsig
      integer*2 lbuf(1)
C
       include '../include/fscom.i'
       include '../include/dpi.i'
C
      icnext=1
      icnext=ichmv_ch(lbuf,1,'xoffset ')
C
      icnext=icnext+jr2as(lonpos*180.0/RPI,lbuf,icnext,-9,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      icnext=icnext+jr2as(latpos*180.0/RPI,lbuf,icnext,-9,4,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      icnext=icnext+jr2as(cos(latpos)*lonoff*180.0/RPI,lbuf,icnext,
     &     -9,5,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C
      icnext=icnext+jr2as(latoff*180.0/RPI,lbuf,icnext,-9,5,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(cos(latpos)*elnsig*180.0/RPI,lbuf,icnext,
     &     -8,5,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C
      icnext=icnext+jr2as(eltsig*180.0/RPI,lbuf,icnext,-8,5,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+ib2as(ilon,lbuf,icnext,1)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+ib2as(ilat,lbuf,icnext,1)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=ichmv(lbuf,icnext,ldevfp,1,4) 
      icnext=ichmv_ch(lbuf,icnext,' ')
c
      call fs_get_lsorna(lsorna)
      icnext=ichmv(lbuf,icnext,lsorna,1,10) 
      icnext=ichmv_ch(lbuf,icnext,' ')
c
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ')
      call logit2(lbuf,nchars)

      return
      end
