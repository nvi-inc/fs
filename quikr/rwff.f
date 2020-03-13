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
      subroutine rwff(ip,isub)
C  rewind or fast-forward tape  <910324.0015>
C
C     SEND APPROPRIATE COMMANDS TO TAPE DRIVE FOR
C     REWIND OR FAST FORWARD MOTIONS.
C     FOR REWIND: ISUB=3 720 RATE   ISUB=5 880 RATE
C     FOR FASTF:  ISUB=4 720 RATE   ISUB=6 880 RATE
C
C     MODIFICATIONS:
C  WHO  WHEN    DESCRIPTION
C  NRV  811023  ALL COMMANDS USE 720 RATE GENERATOR
C  MWH  890522  CHANGE RATE GENERATOR TO 880 FOR HIGH SPEED (330 IPS)
C  GAG  910111  Changed LFEET to LFEET_FS in call to MA2TP.
C
      include '../include/fscom.i'

      dimension ip(1)
      dimension ireg(2)
      integer get_buf
      integer*2 ibuf(10)
      equivalence (ireg(1),reg)
      data ilen/20/
C
      if( isub.lt.10) then
         indxtp=1
      else
         indxtp=2
      endif
      iclcm = ip(1)
      if (iclcm.ne.0) goto 110
100   ierr = -1
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.ne.0) goto 100
C                   If parameters, error
      call fs_get_drive(drive)
      if (VLBA .eq.drive(indxtp).or.VLBA4.eq.drive(indxtp)) goto 500
C
C
C     1. Set up buffer for rewinding or fast forwarding tape:
C                   mmTP)=78800000
C            or     mmTP)=F8800000
C*******************       720
C     where 7 = direction (reverse=0) and speed (top speed)
C           F = direction (forward=0) and speed (top speed)
C           880 = 3 digit rate (fastest)
C     BUT FIRST-
C     Send buffer to disable all recording:
C                   mmTP%=0xxxxxxx
C     Send buffer to turn on low tape sensor:
C                   mmTP(=80000000
C     and set up bypass mode.
C
C     Also, reset all of the appropriate common variables
C
      call fs_get_icheck(icheck(18+indxtp-1),18+indxtp-1)
      ichold = icheck(18+indxtp-1) 
      icheck(18+indxtp-1) = 0
      call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
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
     &     istptp(indxtp),itactp(indxtp),irdytp(indxtp))
      call fs_set_icaptp(icaptp,indxtp)
      call fs_set_istptp(istptp,indxtp)
      call fs_set_irdytp(irdytp,indxtp)
      call fs_set_itactp(itactp,indxtp)
      call fs_set_lfeet_fs(lfeet_fs,indxtp)
      if (irdytp(indxtp).eq.0) goto 410
        ierr = -301
C          if vacuum not ready, forget it
        goto 990
C
410   continue
      ienatp(indxtp) = 0
      call fs_set_ienatp(ienatp,indxtp)
      ispeed(indxtp) = 7
      call fs_set_ispeed(ispeed,indxtp)
      idirtp(indxtp) = mod(mod(isub,10)-3,2)
      call fs_set_idirtp(idirtp,indxtp)
      ilowtp(indxtp) = 1
C
      nrec=0
      iclass = 0
      call fs_get_rack(rack)
      if(rack.eq.MK4) then
         ibuf(1)=9
         call char2hol('fm/rec 0',ibuf(2),1,8)
         call put_buf(iclass,ibuf,-10,'fs','  ')
         nrec = nrec+1
      endif
c
      ibuf(1) = 0
      if(indxtp.eq.1) then
         call char2hol('t1',ibuf(2),1,2)
      else
         call char2hol('t2',ibuf(2),1,2)
      endif
      if(drive(indxtp).eq.MK4) then
        call fs_get_kenastk(kenastk,indxtp)
        call en2ma4(ibuf(3),ienatp(indxtp),kenastk(1,indxtp))
      else if(drive(indxtp).eq.MK3) then
         call en2ma(ibuf(3),ienatp(indxtp),-1,ltrken)
      endif
      call put_buf(iclass,ibuf,-13,'fs','  ')
C
      call tp2ma(ibuf(3),ilowtp(indxtp),0)
      call put_buf(iclass,ibuf,-13,'fs','  ')
C
      if(mod(isub,10).lt.5) then
         call fs_get_iskdtpsd(iskdtpsd,indxtp)
         if (iskdtpsd(indxtp).eq.-2) then
            call ichmv_ch(lgen(1,indxtp),1,'960')
         else if (iskdtpsd(indxtp).eq.-1) then
            call ichmv_ch(lgen(1,indxtp),1,'880')
         else
            call ichmv_ch(lgen(1,indxtp),1,'720')
         endif
      else
         call fs_get_imaxtpsd(imaxtpsd,indxtp)
         if (imaxtpsd(indxtp).eq.-2) then
            call ichmv_ch(lgen(1,indxtp),1,'960')
         else if (imaxtpsd(indxtp).eq.-1) then
            call ichmv_ch(lgen(1,indxtp),1,'880')
         else
            call ichmv_ch(lgen(1,indxtp),1,'720')
         endif
      endif
      call mv2ma(ibuf(3),idirtp(indxtp),ispeed(indxtp),lgen(1,indxtp))
      call fs_set_lgen(lgen,indxtp)
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec=nrec+3
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call mvdis(ip,iclcm,indxtp)
C
415   continue
      icheck(18+indxtp-1) =ichold
      call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
      if(ichold.ge.0) then
        icheck(18+indxtp-1)=mod(ichold,1000)+1
        call fs_set_icheck(icheck(18+indxtp-1),18+indxtp-1)
        kmvtp_fs(indxtp)=.true.
      endif
      return
C        vlba recorder movement commands
500   continue
      ierr = 0
      call fc_rwff_v(ip,isub,ierr)
      if (ierr.ne.0) goto 990
      call mvdis(ip,iclcm,indxtp)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('q<',ip(4),1,2)
      return
      end
