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
      subroutine fitot(cmess,ltpar,ierr,lbuf,isbuf)
      real ltpar
      dimension ltpar(5)
      integer*2 lbuf(1)
      character*(*) cmess
C 
C WRITE XXXFIT LOG ENTRY
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
C INPUT:
C 
C       LTPAR = ARRAY OF FIT PARAMETERS 
C 
C       IERR  = FIT CODE FROM FITTING ROUTINE 
C 
C XXXFIT LOG ENTRY IDENTIFIER 
C 
       icnext=1 
       icnext=ichmv_ch(lbuf,icnext,cmess) 
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C  OFFSET 
C 
       icnext=icnext+jr2as(ltpar(2)*180.0/RPI,lbuf,icnext,-9,5,isbuf)    
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C HALF-WIDTH
C 
       icnext=icnext+jr2as(ltpar(3)*180.0/RPI,lbuf,icnext,-7,4,isbuf)  
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C  TEMPERATURE PEAK   
C 
       icnext=icnext+jr2as(ltpar(1),lbuf,icnext,-7,4,isbuf) 
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C TEMPERATURE OFFSET
C 
       icnext=icnext+jr2as(ltpar(4),lbuf,icnext,-7,4,isbuf)   
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C TEMPERATURE SLOPE 
C 
       icnext=icnext+jr2as(ltpar(5),lbuf,icnext,-7,4,isbuf)     
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C FIT CODE
C 
       icnext=icnext+ib2as(ierr,lbuf,icnext,3)
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C CLEAN UP AND SEND DATA
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 

      return
      end 
