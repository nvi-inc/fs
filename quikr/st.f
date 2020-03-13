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
      subroutine st(ip,itask)
C  start tape c#870115:04:41#
C 
C     This routine handles the "ST" or start tape command.
C 
      dimension ip(1) 
      dimension ireg(2) 
      integer get_buf
C
      include '../include/fscom.i'
C
      integer*2 ibuf(20), lgenx(2)
      character cjchar
      equivalence (ireg(1),reg)
      data ilen/40/
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910111  Changed LFEET to LFEET_FS in call to MA2TP.
C  gag  920715  Added code to handle Mark IV tape drive, including
C               new common variable lgen for rate generator.
C
C     1. First pick up the class buffer with the command in it.
C     Find out whether this is a monitor or setting command by
C     checking for the "=" sign.
C
      if( itask.eq.1) then
         indxtp=1
      else
         indxtp=2
      endif
      ichold = -99
      iclcm = ip(1)
      if (iclcm.ne.0) goto 110
      ierr = -1
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
      call fs_get_ispeed(ispeed,indxtp)
      call fs_get_lgen(lgen,indxtp)
      call fs_get_idirtp(idirtp,indxtp)
      call fs_get_ienatp(ienatp,indxtp)
      if (ieq.eq.nchar.or.cjchar(ibuf,ieq+1).ne.'?') goto 210
      ip(4) = o'77' 
      call stdis(ip,iclcm,indxtp)
      return
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C 
C                   ST=<for/rev>,<speed>/<on/off>
C 
C     Choices are <speed>: 3,7,15,30,60,120,240 IPS.  Default 120.
C                <for/rev>: FORward or REVerse.  No default.
C 
C 
C     2.1 DIRECTION, PARAMETER 1
C 
210   ic1 = ieq+1 
      ich = ic1 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
C                   Get the direction, ASCII
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 211 
      if (cjchar(parm,1).eq.'*') then
         call fs_get_idirtp(idirtp,indxtp)
         idir = idirtp(indxtp)
         if(idirtp(indxtp).eq.-1) idirtp(indxtp)=1
      endif
      if (cjchar(parm,1).ne.',') goto 220
      ierr = -101 
C                   No default for the direction
      goto 990
211   call itped(2,idir,lgenx,ibuf,ic1,ich-2) 
      if (idir.ge.0) goto 220 
      ierr = -201 
      goto 990
C 
C 
C     2.2 SPEED, PARAMETER 2
C 
220   ic1 = ich 
      call gtprm(ibuf,ich,nchar,1,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 221 
      if (cjchar(parm,1).eq.'*') then
         call fs_get_ispeed(ispeed,indxtp)
         isp = ispeed(indxtp)
         call fs_get_lgen(lgen,indxtp)
         idum=ichmv(lgenx,1,lgen(1,indxtp),1,3)
      endif
      if (cjchar(parm,1).eq.',') then
         isp = 6
         idum=ichmv_ch(lgenx,1,'720')
C                   Default is 120 ips
      endif
      goto 230
221   call itped(1,isp,lgenx,ibuf,ic1,ich-2)
      if (isp.ge.0) goto 230
      ierr = -202 
      goto 990
C 
C     2.3 RECORD ON/OFF, PARAMETER 3
C 
230   ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 231 
      if (cjchar(parm,1).eq.'*') then
         call fs_get_ienatp(inenatp,indxtp)
         iena = ienatp(indxtp) 
      endif
      if (cjchar(parm,1).eq.',') iena = 1
C             - default is record ON
      goto 300
231   continue
      call itped(5,iena,lgenx,ibuf,ic1,ich-2) 
      if (iena.ge.0) goto 300 
        ierr = -203 
        goto 990
C 
C 
C     3. Now plant these values into COMMON.
C 
300   continue
      call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
      ichold = icheck(18+indxtp-1) 
      icheck(18+indxtp-1) = 0
      call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
      ispeed(indxtp) = isp
      call fs_set_ispeed(ispeed,indxtp)
      idirtp(indxtp) = idir 
      call fs_set_idirtp(idirtp,indxtp)
      ienatp(indxtp) = iena 
      call fs_set_ienatp(ienatp,indxtp)
      idum=ichmv(lgen(1,indxtp),1,lgenx,1,3)
      call fs_set_lgen(lgen,indxtp)
C 
C 
C     4. Set up buffer for tape drive.  Send to MATCN.
C                   mmTP)=srrr0000
C     First turn on the enable bit: 
C                   mmTP%=8xxxxxxx
C     where xx... is currently enabled tracks 
C     and set up RAW or BYP depending on direction.
C
      if (ispeed(indxtp).eq.0) goto 410
C  Skip checking the drive if tape speed is 0.
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
      if(ip(3).lt.0) go to 415
      ireg(2) = get_buf(ip(1),ibuf,-ilen,idum,idum)
      call ma2tp(ibuf,ilow,lfeet_fs(1,indxtp),ifastp,icaptp(indxtp),
     $     istptp(indxtp),itactp(indxtp),irdytp(indxtp))
      call fs_set_icaptp(icaptp,indxtp)
      call fs_set_istptp(istptp,indxtp)
      call fs_set_irdytp(irdytp,indxtp)
      call fs_set_itactp(itactp,indxtp)
      call fs_set_lfeet_fs(lfeet_fs,indxtp)
      if (irdytp(indxtp).eq.0) goto 410
        ierr = -301
C          if vacuum not ready, forget it
        goto 990
410   continue
      nrec = 0
      iclass = 0
c
      call fs_get_rack(rack)
      if(rack.eq.MK4) then
         ibuf(1)=9
         if(ienatp(indxtp).eq.0) then
            call char2hol('fm/rec 0',ibuf(2),1,8)
         else
            call char2hol('fm/rec 1',ibuf(2),1,8)
         endif
         call put_buf(iclass,ibuf,-10,'fs','  ')
         nrec = nrec+1
      endif

      ibuf(1) = 0
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      call fs_get_drive(drive)
      if (MK3.eq.drive(indxtp)) then
        call en2ma(ibuf(3),ienatp(indxtp),-1,ltrken)
      else if (MK4.eq.drive(indxtp)) then
        call fs_get_kenastk(kenastk,indxtp)
        call en2ma4(ibuf(3),ienatp(indxtp),kenastk(1,indxtp))
      endif
      call put_buf(iclass,ibuf,-13,'fs','  ')
C
      call fs_get_lgen(lgen,indxtp)
      call mv2ma(ibuf(3),idirtp(indxtp),ispeed(indxtp),lgen(1,indxtp))
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec = nrec +2
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call stdis(ip,iclcm,indxtp)
C
415   continue
      icheck(18+indxtp-1) = ichold
      call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
      if (ichold.ge.0) then
        icheck(18+indxtp-1) = mod(ichold,1000)+1
        call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
        kmvtp_fs(indxtp)=.true.
      endif
      return
C
C
C     5.  This is the read device section.
C     Fill up a class buffer, requesting ) data (mode -4).
C                                        % data (mode -2)
C
500   continue
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      iclass = 0
      ibuf(1) = -4
      call put_buf(iclass,ibuf,-4,'fs','  ')
      ibuf(1) = -2
      call put_buf(iclass,ibuf,-4,'fs','  ')
C 
      call run_matcn(iclass,2) 
      call rmpar(ip)
      call stdis(ip,iclcm,indxtp)
      return
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('q<',ip(4),1,2)
      return
      end 
