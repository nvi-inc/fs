*
* Copyright (c) 2020, 2023, 2025  NVI, Inc.
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
      subroutine fpdis(ip,ibuf,ilen,nchar)
C 
C 1.1.   FPDIS gets data from common variables and displays them
C 
C     INPUT VARIABLES:
      dimension ip(1)
      integer*2 ibuf(1) 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
      include '../include/dpi.i'
      include '../include/boz.i'
C 
C     CALLING SUBROUTINES: FVPNT
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
C        NCH    - character counter 
C 
C 6.  PROGRAMMER: MWH 
C     CREATED: 840510 
C 
C     PROGRAM STRUCTURE 
C 
C     1. First set up output buffer for response. 
C 
      nch = iscn_ch(ibuf,1,nchar,'=') 
      if (nch.eq.0) nch = nchar+1 
C                  If no "=" found position after last character
      nch = ichmv_ch(ibuf,nch,'/')  
C              Put / to indicate a response 
C 
C     2.  Fill the buffer with the required common variables
C 
200   ierr = 0
      nch = ichmv(ibuf,nch,laxfp,1,4) 
      nch = mcoma(ibuf,nch) 
      nch = nch + ib2as(nrepfp,ibuf,nch,ocp100002)
      nch = mcoma(ibuf,nch) 
      nch = nch + ib2as(nptsfp,ibuf,nch,ocp100002)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(stepfp,ibuf,nch,6,2)
      nch = mcoma(ibuf,nch) 
      nch = nch + ib2as(intpfp,ibuf,nch,ocp100002)
      nch = mcoma(ibuf,nch) 
      iend=iflch(ldevfp,4)
      nch = ichmv(ibuf,nch,ldevfp,1,iend)
      nch = mcoma(ibuf,nch) 
      nch = nch + ib2as(iwtfp,ibuf,nch,ocp100004)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(bmfp_fs*180./RPI,ibuf,nch,8,4)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(calfp,ibuf,nch,6,1)
      nch = mcoma(ibuf,nch)
      nch = nch + ir2as(fxfp_fs,ibuf,nch,10,2)
      nch = mcoma(ibuf,nch) 
      nch = nch + ir2as(sngl(ssizfp*RAD2DEG),ibuf,nch,6,4)
      nch = mcoma(ibuf,nch)
      nch = nch + ib2as(ichfp_fs,ibuf,nch,ocp100002)
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,'fs','  ')
C                   Send buffer starting with info to display 
      ip(1) = iclass
      ip(2) = 1 
      call char2hol('qz',ip(4),1,2)
990   return
      end 
