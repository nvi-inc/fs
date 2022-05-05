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
      subroutine errot(cmess,eltpar,ltrchi,lbuf,isbuf) 
      real ltrchi 
      dimension eltpar(5)
      integer*2 lbuf(1)
      character*(*) cmess
C 
C WRITE XXXERR LOG ENTRY
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
C INPUT:
C 
C       ELTPAR = ARRAY OF ERRORS IN THE FIT PARAMETERS
C 
C       LTRCHI = REDUCED CHI OF THE FIT 
C 
C XXXERR LOG ENTRY IDENTIFIER 
C 
      icnext=1 
      icnext=ichmv_ch(lbuf,icnext,cmess) 
      icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C SIGMA OFFSET
C 
      icnext=icnext+jr2as(eltpar(2)*180.0/RPI,lbuf,icnext,-9,5,isbuf)   
      icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C SIGMA HALF-WIDTH
C 
      icnext=icnext+jr2as(eltpar(3)*180.0/RPI,lbuf,icnext,-7,4,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C TEMPERATURE PEAK SIGMA
C 
      icnext=icnext+jr2as(eltpar(1),lbuf,icnext,-7,4,isbuf)  
      icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C SIGMA TEMPERATURE OFFSET
C 
      icnext=icnext+jr2as(eltpar(4),lbuf,icnext,-7,4,isbuf)  
      icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C SIGMA TEMPERATURE SLOPE 
C 
      icnext=icnext+jr2as(eltpar(5),lbuf,icnext,-7,4,isbuf)  
      icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C REDUCED CHI 
C 
      icnext=icnext+jr2as(ltrchi,lbuf,icnext,-8,4,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
C CLEAN UP AND SEND DATA
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 

      return
      end 
