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
      subroutine newtp(ip,itask)
C  new tape command c#870115:04:41# 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - class
C        IP(2) - number of records
C        IP(3) - error
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES:  QUIKR
C     CALLED SUBROUTINES: character subroutines
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*2 ibuf(40)         !  class buffer
      integer*2 lmsg(16)         !  message response
      dimension ireg(2) 
      integer get_buf
      character*1 cjchar
      equivalence (ireg(1),reg) 
      data lmsg   /2h"t,2ho ,2hco,2hnt,2hin,2hue,2h, ,2hus,2he ,2hla, 
     /             2hbe,2hl ,2h c,2hom,2hma,2hnd/ 
cxx lmsg="to continue, use label command"
      data nmsg/32/ 
      data ilen/80/             !  length of ibuf
C 
C     1. First check out the input variables.  Then get the command 
C     into a buffer and find the "=". 
C 
      if( itask.eq.2) then
         indxtp=1
      else
         indxtp=2
      endif
c
      iclcm = ip(1) 
      do i=1,3
        ip(i) = 0
      enddo
      call char2hol('qn',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
C
c if we have drives a new tape was mounted don't halt
c 
      call fs_get_drive(drive)
      if(drive(1).ne.0.and.drive(2).ne.0) then
         call fs_get_knewtape(knewtape,indxtp)
         if(knewtape(indxtp)) then
            knewtape(indxtp)=.false.
            call fs_set_knewtape(knewtape,indxtp)
            return
         endif
      endif
c
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.ne.0) then
C                   Ignore any parameters for this command.
        nchar=ieq-1
        do while (nchar.gt.1)
           if(cjchar(ibuf,nchar).eq.' ') then
              nchar=nchar-1
           else
              goto 100
           endif
        enddo
      endif
 100  continue
C 
C     2. Now form the response message buffer.
C     ***NOTE WE ARE SETTING BOSS'S HALT VARIABLE OURSELVES!!***
C 
      nch = ichmv_ch(ibuf,nchar+1,'/')
      call fs_get_select(select)

      if(drive(1).ne.0.and.drive(2).ne.0) then
         if(select.eq.0) then
            idum=ichmv_ch(lmsg,24,'1')
         else if(select.eq.1) then
            idum=ichmv_ch(lmsg,24,'2')
         endif
      else
            idum=ichmv_ch(lmsg,24,' ')
      endif
      nch = ichmv(ibuf,nch,lmsg,1,nmsg) - 1 
C 
      khalt = .true.
      call fs_set_khalt(khalt)
      call ifill_ch(ltpnum(1,indxtp),1,8,'00') 
      call ifill_ch(ltpchk(1,indxtp),1,4,'00') 
C                   Zero out the tape number and check label
C 
C     3. Now send the message back to BOSS. 
C 
      iclass = 0
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      return
      end 

