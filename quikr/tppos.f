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
      subroutine tppos(ip,itask)
C  tape position control c#870115:04:34#
C
C     TAPPOS sends commands to BOSS that control the position of the tape
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910114  Changed LFEET to LFEET_FS and changed comparisons with
C               9600 to 20000.
C
C
C     INPUT VARIABLES:
      dimension ip(1)
C        IP(1)  - class number of input parameter buffer.
C
C     OUTPUT VARIABLES:
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are
C
C 2.2.   COMMON BLOCKS USED
      include '../include/fscom.i'
C
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES: QUIKR
C     CALLED SUBROUTINES: GTPRM
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        ICH    - character counter 
      integer*4 idt4
      integer*2 ibuf(20)                 !  class buffer
      dimension it(6)                    !  holds current time from system
      dimension iparm(2)                 !  parameters returned from gtprm
      dimension ireg(2)                  !  registers from exec calls
      integer get_buf
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/                        !  length of ibuf, characters
C 
C 
C     PROGRAM STRUCTURE 
C 
C     1. If there was "=" in the buffer, then we have parameters. 
C     If none, then error.  If parameter is "?" then give last command. 
C 
      if( itask.eq.2) then
         indxtp=1
      else
         indxtp=2
      endif
c
      ierr=0
      iclcm = ip(1) 
      iclass = 0
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) then
        ierr = -101
        goto 990
      endif
      if (cjchar(ibuf,ieq+1).eq.'?') then
        nch = ichmv_ch(ibuf,ieq,'/')
        nch = nch + ib2as(iftgo,ibuf,nch,o'40000'+o'400'*5+5)
        iclass = 0
        nch = nch - 1
        call put_buf(iclass,ibuf,-nch,'fs','  ')
        nrec = 1
        goto 990
      endif
C 
C     2. Get the parameter (foot count) and decode it.
C               TAPEPOS=<position>
C
      ich = 1+ieq
      call gtprm2(ibuf,ich,nchar,1,parm,ierr)
C                   Get the position in feet
      if (ierr.eq.1.or.ierr.eq.2) then
        ierr = -101
        goto 990
      endif
      ift = iparm(1)
      if (ift.lt.0 .or. ift.gt.20000) then
        ierr = -201
        goto 990
      endif
C
C     3. Get the tape motion and foot count status.
C     Then, make sure that the tape is stopped!  If not, we can't move it.
C     Check if the amount to move is within 100 feet.  If so, don't bother.
C
      ibuf(1) = -3
       if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      call run_matcn(iclass,1)
      call rmpar(ip)
      if (ip(3).lt.0) return
      ireg(2) = get_buf(ip(1),ibuf,-ilen,idum,idum)
      call ma2tp(ibuf,ilow,lfeet_fs(1,indxtp),ifastp,icaptp(indxtp),
     $     istptp(indxtp),itactp(indxtp),irdytp(indxtp))
      call fs_set_icaptp(icaptp,indxtp)
      call fs_set_istptp(istptp,indxtp)
      call fs_set_itactp(itactp,indxtp)
      call fs_set_irdytp(irdytp,indxtp)
      call fs_set_lfeet_fs(lfeet_fs,indxtp)
C
      iclass = 0
      nrec = 0
      call fs_get_icaptp(icaptp,indxtp)
      if (icaptp(indxtp).ne.0) then
        ierr = -301
        goto 990
      endif
      call fs_get_lfeet_fs(lfeet_fs,indxtp)
      iftnow = ias2b(lfeet_fs(1,indxtp),1,5)
      if (iftnow.gt.20000.or.iftnow.lt.0) iftnow=0
C                   Consider out-of-range as 0
      iftdif = iabs(iftnow-ift)
      if (iftdif.le.100) then
        ierr = -302
        goto 990
      endif
C
C     4. Send the commands to BOSS.  Commands are:
C              RW@! or FF@! 
C          and ET@<now+feet/31fps>
C     Also, set commanded feet into common. 
C 
      iftgo = ift
      call fc_rte_time(it,it(6))
      idt4 = 0.5d0 + iacttp(indxtp) + iftdif/.225d0
      idt = mod(idt4,100)
      call iadt(it,idt,1)
      idt = idt4/100
      call iadt(it,idt,2) 
C                     Add on the time difference to the present
      if(drive(1).eq.0.or.drive(2).eq.0) then
         inext1=ichmv_ch(ibuf,1,'ff')
         if (iftnow.gt.iftgo) inext1=ichmv_ch(ibuf,1,'rw')
         inext1=ichmv_ch(ibuf,inext1,'@!')
         inext2=ichmv_ch(ibuf(4),1,'et@')
      else if(indxtp.eq.1) then
         inext1=ichmv_ch(ibuf,1,'ff1')
         if (iftnow.gt.iftgo) inext1=ichmv_ch(ibuf,1,'rw1')
         inext1=ichmv_ch(ibuf,inext1,'@!')
         inext2=ichmv_ch(ibuf(4),1,'et1@')
      else
         inext1=ichmv_ch(ibuf,1,'ff2')
         if (iftnow.gt.iftgo) inext1=ichmv_ch(ibuf,1,'rw2')
         inext1=ichmv_ch(ibuf,inext1,'@!')
         inext2=ichmv_ch(ibuf(4),1,'et2@')
      endif
      inext2 = inext2 + ib2as(it(6),ibuf(4),inext2,o'40000'+o'400'*4+4)
      inext2 = ichmv_ch(ibuf(4),inext2,'.')
      inext2 = inext2 + ib2as(it(5),ibuf(4),inext2,o'40000'+o'400'*3+3) 
      inext2 = ichmv_ch(ibuf(4),inext2,'.')
      inext2 = inext2 + ib2as(it(4),ibuf(4),inext2,o'40000'+o'400'*2+2)
      inext2 = ichmv_ch(ibuf(4),inext2,':')
      inext2 = inext2 + ib2as(it(3),ibuf(4),inext2,o'40000'+o'400'*2+2) 
      inext2 = ichmv_ch(ibuf(4),inext2,':')
      inext2 = inext2 + ib2as(it(2),ibuf(4),inext2,o'40000'+o'400'*2+2) 
      inext2 = ichmv_ch(ibuf(4),inext2,'.')
      inext2 = inext2 + ib2as(it(1),ibuf(4),inext2,o'40000'+o'400'*2+2)
      call copin(ibuf,inext1-1)
      call copin(ibuf(4),inext2-1)
C                     Send the commands to BOSS 
C 
990   ip(1) = iclass
      ip(2) = nrec
      ip(3) = ierr
      call char2hol('qu',ip(4),1,2)
      return
      end 
