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
      subroutine site(vfivpt,lbuf,isbuf)
      integer*2 lbuf(1)
C
      include '../include/dpi.i'
      include '../include/fscom.i'
C
C  WRITE SITE RECORD TO LOG
C
      icnext=1
      icnext=ichmv_ch(lbuf,1,'site ')
C
C  ANTENNA NAME
C
      call fs_get_lnaant(lnaant)
      icnext=ichmv(lbuf,icnext,lnaant,1,8)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C  LONGITUDE
C
      call fs_get_wlong(wlong)
      icnext=icnext+jr2as(sngl(wlong*rad2deg),lbuf,icnext,-8,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C  LATITIUDE
C
      call fs_get_alat(alat)
      icnext=icnext+jr2as(sngl(alat*rad2deg),lbuf,icnext,-8,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C  DIAMETER
C
      icnext=icnext+jr2as(diaman,lbuf,icnext,-6,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C  AXIS TYPE
C 
      icnext=ichmv_ch(lbuf,icnext,'xxxx')
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C  POINTING MODEL NUMBER
C 
      icnext=icnext+ib2as(0,lbuf,icnext,3)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C  FIVPT VERSION NUMBER 
C 
      icnext=icnext+jr2as(vfivpt,lbuf,icnext,-5,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C  FS VERSION 
C 
      icnext=icnext+jr2as(fsver,lbuf,icnext,-5,2,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C CLEAN UP AND SEND 
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 
C 
      return
      end 
