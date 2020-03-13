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
      subroutine pcdis(ip,iclcm)
C  pcalr parms display c#870115:04:52#
C 
C 1.1.   PCDIS gets data from common variables and displays them
C 
C 2.  PCDIS INTERFACE 
C
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES: PCALC
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf2(60)
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/120/
C 
C 6.  PROGRAMMER: NRV & MAH 
C     CREATED: 19820318 
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.
C 
C 
      if (iclcm.eq.0) return
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      if (nch.eq.0) nch = nchar+1 
C                  If no "=" found position after last character
      nch = ichmv_ch(ibuf2,nch,'/') 
C              Put / to indicate a response 
C 
C 
C     2.  Fill the buffer with the required common variables
C 
      ierr = 0
C 
      nch = nch+ib2as(ncycpc,ibuf2,nch,o'100000'+8) 
      nch = mcoma(ibuf2,nch)
C 
      nch = nch+ib2as(ipaupc,ibuf2,nch,o'100000'+8) 
      nch = mcoma(ibuf2,nch)
C 
      call char2hol('fs',lrep,1,2)
      if (ireppc.eq.1) call char2hol('by',lrep,1,2)
      if (ireppc.eq.2) call char2hol('rw',lrep,1,2)
      if (ireppc.eq.3) call char2hol('ab',lrep,1,2)
      nch = ichmv(ibuf2,nch,lrep,1,2)
      nch = mcoma(ibuf2,nch)
C
      nch = nch+ib2as(nblkpc,ibuf2,nch,o'100000'+8)
      nch = mcoma(ibuf2,nch)
C
      nch = nch+ib2as(ibugpc,ibuf2,nch,o'100000'+8)
C
      do i=1,28
        if (itrkpc(i).gt.0) then
          nch = mcoma(ibuf2,nch)
          nch = nch+ib2as(i,ibuf2,nch,o'100000'+8)
        endif
      enddo
C
C     5. Now send the buffer to SAM and schedule PPT.
C
      iclass = 0
      nch = nch - 1
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C                   Send buffer starting with info to display
      if (.not.kcheck) ierr = 0
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qp',ip(4),1,2)
      return
      end 
