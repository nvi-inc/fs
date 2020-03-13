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
      subroutine cadis(ip,iclcm, itask,ilong)
C  display cable cal c#870115:04:36#
C 
C 1.  CADIS PROGRAM SPECIFICATION 
C 
C 1.1.   CADIS displays data from the cable cal 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from IBCON 
C        IP(2)  - number of records in class
C        IP(3)  - error return from IBCON 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf(30),ibuf2(30)
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
C 
      character*1 cjchar
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/60/ 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:   800220 
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from IBCON.  If not 0, get out
C     immediately.
C 
C 
      iclass = ip(1)
      ierr = ip(3)
      nrec = 0
C 
      if (ierr.lt.0) goto 990 
      if (iclass.eq.0.or.iclcm.eq.0) goto 990 
C 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from IBCON. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv_ch(ibuf2,nch,'/') 
C                   Put / to indicate a response
C 
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      if(jchar(ibuf,nchar).eq.10) nchar=nchar-1 !remove LF if present
      if(jchar(ibuf,nchar).eq.13) nchar=nchar-1 !remove CR if present
      if (itask.ne.0) then
         ich = itask            ! nominally 4
         if(ich.gt.nchar-2) ich=nchar-2
      else
         ich=1
         do while(ich.le.nchar-2)
            if(0.ne.index("0123456789+-.Ee",cjchar(ibuf(2),ich))) then
               goto 200
            endif
            ich=ich+1
         enddo
 200     continue
      endif
      call gtfld(ibuf(2),ich,nchar-2,ic1,ic2)
      if(ic1.gt.0.and.ic2-ic1+1.ge.1) then
        nch = ichmv(ibuf2,nch,ibuf(2),ic1,ic2-ic1+1)
C                   Skip the " S " before the number
C                   Move buffer contents into output list 
      cablevt = das2b(ibuf(2),ic1,ic2-ic1+1,ierr)
C                   Don't check error return
      else
        cablevt = 0.0
      endif
      if(ilong.eq.1) then
         cablevl=cablevt
         call fs_set_cablevl(cablevl)
      else
         cablev=cablevt
         call fs_set_cablev(cablev)
      endif
C                   Store current cable value in COMMON 
C 
C 
C     5. Now send to buffer back to BOSS
C 
      iclass = 0
      if (ierr.lt.0) goto 900 
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
900   ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qy',ip(4),1,2)

990   return
      end 
