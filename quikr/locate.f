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
      subroutine locate(ip,itask)
C
C  Locate track position roughly
C
      include '../include/fscom.i'
C
      integer ip(5),ireg(2),iparm(2)
      integer*2 ibuf(50)
      integer get_buf,ichcm_ch
      real*4 mper
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
      data ilen/100/
C
      if( itask.eq.8) then
         indxtp=1
      else
         indxtp=2
      endif
C
      ichold=-99
      iclass=0
      nrec=0
C
C  1.  Get the command
C
      iclcm=ip(1)
      if(iclcm.eq.0) then
        ip(3)=-1
        goto 990
      endif
C
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar=min0(ilen,ireg(2))
      ieq=iscn_ch(ibuf,1,nchar,'=')
      if(ieq.eq.0) then
        goto 500
      else if(cjchar(ibuf,ieq+1).eq.'?') then
        ip(4)=o'77'
        goto 600
      endif
      ich=ieq+1
C
C  2. Get parameters.
C
C  2.1  Range of motion
C
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        rng=200
      else if(cjchar(parm,1).eq.'*') then
        rng=rnglc_fs(indxtp)
      else if(ierr.eq.0) then
        rng=parm
      else
        ip(3)=-231
        goto 990
      endif
C
C  2.2  Number of Samples
C
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        nsamp=1
      else if(cjchar(parm,1).eq.'*') then
        nsamp=nsamplc_fs(indxtp)
      else if(ierr.eq.0) then
        nsamp=iparm(1)
      else
        ip(3)=-232
        goto 990
      endif
C
C  2.3 step size
C
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        step=40
      else if(cjchar(parm,1).eq.'*') then
        step=steplc_fs(indxtp)
      else if(ierr.eq.0) then
        step=parm
      else
        ip(3)=-233
        goto 990
      endif
C
C  which head
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if((ichcm_ch(parm,1,'r').eq.0.or.ichcm_ch(parm,1,'2').eq.0)
     &     .and.(
     $     (VLBA.eq.drive(indxtp).and.VLBAB.eq.drive_type(indxtp))
     $     .or.VLBA4.eq.drive(indxtp).or.MK3.eq.drive(indxtp).or.
     &     (drive(indxtp).eq.MK4.and.MK4B.ne.drive_type(indxtp))
     $     )
     &     ) then
        ihd = 2
      else if(ichcm_ch(parm,1,'r').eq.0.or.
     &        ichcm_ch(parm,1,'2').eq.0) then
        ip(3)=-501
        goto 990
      else if(ichcm_ch(parm,1,'w').eq.0.or.
     &        ichcm_ch(parm,1,'1').eq.0) then
        ihd = 1
      else if(cjchar(parm,1).eq.'*') then
        ihd=ihdlc_fs(indxtp)
      else if (cjchar(parm,1).eq.','.and.(
     $       VLBA4.eq.drive(indxtp).or.MK3.eq.drive(indxtp).or.
     &       (VLBA.eq.drive(indxtp).and.VLBAB.eq.drive_type(indxtp))
     $       .or.
     &       (drive(indxtp).eq.MK4.and.MK4B.ne.drive_type(indxtp))
     $       )
     &       ) then
        ihd = 2
      else if (cjchar(parm,1).eq.',') then
        ihd=1
      else
        ip(3) = -234
        goto 990
      endif
C
C  3. Plant values in COMMON
C
300   continue
      ihdlc_fs(indxtp)=ihd
      steplc_fs(indxtp)=step
      nsamplc_fs(indxtp)=nsamp
      rnglc_fs(indxtp)=rng
      goto 990
C
C  5.  Find peak
C
500   continue
      call fs_get_ispeed(ispeed,indxtp)
      call fs_get_cips(cips,indxtp)
      call fs_get_idirtp(idirtp,indxtp)
      call fs_get_ienatp(ienatp,indxtp)
      if(ispeed(indxtp).eq.0.or. ! if tape isn't moving, don't go any further
     &   (ispeed(indxtp).eq.-3.and.cips(indxtp).eq.0)) then
        ip(3)=-331
        goto 990
      else if (idirtp(indxtp).ne.1.and.ienatp(indxtp).ne.0) then
c ! not rec in rev
        ip(3)= -332
        goto 990
      else if(ihdlc_fs(indxtp).eq.0) then ! command must be set up
        ip(3)=-333
        goto 990
      endif
C
C   do a coarse search for a track
C
      call fs_get_icheck(icheck(20+indxtp-1),20+indxtp-1)
      ichold=icheck(20+indxtp-1)
      icheck(20+indxtp-1) = 0
      call fs_set_icheck(icheck(20+indxtp-1),20+indxtp-1)
C
      call lvdonn('lock',ip,indxtp)
      if(ip(3).ne.0) goto 800
C
      call lchd(ihdlc_fs(indxtp),steplc_fs(indxtp),nsamplc_fs(indxtp),
     $     rnglc_fs(indxtp),rpdt_fs(indxtp),vltlc,peakv,mper,ip,
     $     khecho_fs,lu,indxtp)
      if(ip(3).ne.0) goto 800
C
      call lvdofn('unlock',ip,indxtp)
      if(ip(3).ne.0) goto 800
C
C  6.  Set up response
C
600   continue
      nch=ieq
      if(ieq.eq.0) nch=nchar+1
      nch=ichmv_ch(ibuf,nch,'/')
C
      nch=nch+ir2as(rnglc_fs(indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ib2as(nsamplc_fs(indxtp),ibuf,nch,o'100000'+2)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(steplc_fs(indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(ihdlc_fs(indxtp).eq.1) then
        nch=ichmv_ch(ibuf,nch,'1')
      else if(ihdlc_fs(indxtp).eq.2) then
        nch=ichmv_ch(ibuf,nch,'2')
      endif
      nch=mcoma(ibuf,nch)
C
      if(ieq.eq.0) nch=nch+ir2as(peakv,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(ieq.eq.0) nch=nch+ir2as(mper,ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if ((drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2).or.
     &     (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)
     &     ) then
         if(ieq.eq.0) nch=nch+ir2as(vltlc,ibuf,nch,8,1)
      else
         if(ieq.eq.0) nch=nch+ir2as(vltlc,ibuf,nch,8,3)
      endif
C
      nch=nch-1
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      nrec=1
      goto 990
C
C  error shut-off of LDVT
C
800   continue
      if(ip(2).ne.0) call clrcl(ip(1))
      ip(2)=0
      call logit7(0,0,0,0,ip(3),ip(4),ip(5))
      call lvdofn('unlock',ip,indxtp)
      goto 999
C
C  That's all
C
990   continue
      ip(1)=iclass
      ip(2)=nrec
      call char2hol('q@',ip(4),1,2)
999   continue
      if(ichold.ne.-99) then
        icheck(20+indxtp-1)=ichold
        call fs_set_icheck(icheck(20+indxtp-1),20+indxtp-1)
      endif
      return
      end
