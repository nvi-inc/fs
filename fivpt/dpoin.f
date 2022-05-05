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
      subroutine dpoin(lmess,i,tim,off,temp,sig,np,lbuf,isbuf) 
      integer*2 lbuf(1)
      character*(*) lmess
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,lmess)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+ib2as(i,lbuf,icnext,3)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(tim,lbuf,icnext,-7,0,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      icnext=icnext+jr2as(off*180./RPI,lbuf,icnext,-8,4,isbuf)   
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(temp,lbuf,icnext,-8,3,isbuf)  
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      if (np.le.1) goto 100 
      icnext=icnext+jr2as(sig,lbuf,icnext,-6,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
100   continue
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ')
      call logit2(lbuf,nchars)

      return
      end
