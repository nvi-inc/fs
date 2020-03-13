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
      subroutine worm(ip,itask)
C
C  Estimate velocities
C
      include '../include/fscom.i'
C
      integer ip(5),ireg(2),iparm(2)
      integer*2 ibuf(50)
      integer get_buf,ichcm_ch
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
      data ilen/100/
C
      if( itask.eq.9) then
         indxtp=1
      else
         indxtp=2
      endif
C
      ichold=-99
C
C  1.  Get the command
C
      iclass=0
      nrec=0
      iclcm=ip(1)
      if(iclcm.eq.0) then
        ip(3)=-1
        goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar=min0(ilen,ireg(2))
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if((drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2).or.
     & (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)) then
        ip(3)=-273
        goto 990
      endif
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
C   Head to move
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if((ichcm_ch(parm,1,'r').eq.0.or.ichcm_ch(parm,1,'2').eq.0)
     &   .and.(
     $     (VLBA.eq.drive(indxtp).and.VLBAB.eq.drive_type(indxtp))
     $     .or.VLBA4.eq.drive(indxtp).or.MK3.eq.drive(indxtp).or.
     &     (MK4.eq.drive(indxtp).and.MK4B.ne.drive_type(indxtp))
     $     )
     &     ) then
        ihd = 2
      else if(ichcm_ch(parm,1,'r').eq.0 .or.
     &        ichcm_ch(parm,1,'2').eq.0) then
        ip(3)=-501
        goto 990
      else if(ichcm_ch(parm,1,'w').eq.0 .or.
     &        ichcm_ch(parm,1,'1').eq.0) then
        ihd = 1
      else if (cjchar(parm,1).eq.','.and.(
     &       (VLBA.eq.drive(indxtp).and.VLBAB.eq.drive_type(indxtp)).or.
     $       VLBA4.eq.drive(indxtp).or.MK3.eq.drive(indxtp).or.
     &       (MK4.eq.drive(indxtp).and.MK4B.ne.drive_type(indxtp))
     $       )
     $       ) then
        ihd = 2
      else if (cjchar(parm,1).eq.',') then
        ihd = 1
      else if(cjchar(parm,1).eq.'*') then
        ihd=ihdwo_fs(indxtp)
      else
        ip(3) = -271
        goto 990
      endif
C
C use old or new or update old calibrations?
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if(ichcm_ch(parm,1,'o').eq.0) then
        icl = 1
      else if(ichcm_ch(parm,1,'n').eq.0) then
        icl = 2
      else if(ichcm_ch(parm,1,'u').eq.0) then
        icl = 3
      else if (cjchar(parm,1).eq.',') then
        icl = 1
      else if(cjchar(parm,1).eq.'*') then
        icl=iclwo_fs(indxtp)
      else
        ip(3) = -272
        goto 990
      endif
C
C  3. Plant values in COMMON
C
300   continue
      ihdwo_fs(indxtp)=ihd
      iclwo_fs(indxtp)=icl
      goto 990
C
C  5.  Measure speeds, check first if new that the calibrations have been
C                      determined.
C
500   continue
      if(iclwo_fs(indxtp).eq.2)then
        if(ihdwo_fs(indxtp).eq.1.and..not.kswrite_fs(indxtp)) then
          ip(3)=-372
          goto 990
        else if(ihdwo_fs(indxtp).eq.2.and..not.ksread_fs(indxtp)) then
          ip(3)=-372
          goto 990
        endif
      else if(ihdwo_fs(indxtp).eq.0) then
        ip(3)=-371
        goto 990
      endif
C
      call fs_get_icheck(icheck(20+indxtp-1),20+indxtp-1)
      ichold=icheck(20+indxtp-1)
      icheck(20+indxtp-1) = 0
      call fs_set_icheck(icheck(20+indxtp-1),20+indxtp-1)
C
      call lvdonn('lock',ip,indxtp)
      if(ip(3).ne.0) goto 800
      call wohd(ihdwo_fs(indxtp),fowo_fs(1,indxtp),sowo_fs(1,indxtp),
     $     fiwo_fs(1,indxtp),siwo_fs(1,indxtp),ip,
     $     khecho_fs, lu,iclwo_fs(indxtp),indxtp)
      if(ip(3).ne.0) goto 800
C
C  set the approrpiate flag, note: KxxWO_FS=IHDWO_FS.EQ.x will not work here
C  we don't want to change old value of other parameter
C
      if(iclwo_fs(indxtp).eq.2) then
        if(ihdwo_fs(indxtp).eq.1) kwrwo_fs(indxtp)=.true.
        if(ihdwo_fs(indxtp).eq.2) krdwo_fs(indxtp)=.true.
      else if(iclwo_fs(indxtp).eq.3) then !update current values
        fastfw(ihdwo_fs(indxtp),indxtp)=fowo_fs(ihdwo_fs(indxtp),indxtp)
        fastrv(ihdwo_fs(indxtp),indxtp)=fiwo_fs(ihdwo_fs(indxtp),indxtp)
        slowfw(ihdwo_fs(indxtp),indxtp)=sowo_fs(ihdwo_fs(indxtp),indxtp)
        slowrv(ihdwo_fs(indxtp),indxtp)=siwo_fs(ihdwo_fs(indxtp),indxtp)
      endif
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
      if(ihdwo_fs(indxtp).eq.1) then
        nch=ichmv_ch(ibuf,nch,'1')
      else if(ihdwo_fs(indxtp).eq.2) then
        nch=ichmv_ch(ibuf,nch,'2')
      endif
      nch=mcoma(ibuf,nch)
C
      if(iclwo_fs(indxtp).eq.1) then
        nch=ichmv_ch(ibuf,nch,'old')
      else if(iclwo_fs(indxtp).eq.2) then
        nch=ichmv_ch(ibuf,nch,'new')
      else if(iclwo_fs(indxtp).eq.3) then
        nch=ichmv_ch(ibuf,nch,'update')
      endif
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(fowo_fs(ihdwo_fs(indxtp),indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
      nch=nch+ir2as(sowo_fs(ihdwo_fs(indxtp),indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
      nch=nch+ir2as(fiwo_fs(ihdwo_fs(indxtp),indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
      nch=nch+ir2as(siwo_fs(ihdwo_fs(indxtp),indxtp),ibuf,nch,8,1)
C
      nch=nch-1
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      nrec=1
      goto 990
C
800   continue
      if(ip(2).ne.0) call clrcl(ip(1))
      ip(2)=0
      call logit7(0,0,0,0,ip(3),ip(4),ip(5))
      call lvdofn('unlock',ip,indxtp)
C
C  That's all
C
990   continue
      call char2hol('q@',ip(4),1,2)
      ip(1)=iclass
      ip(2)=nrec
      if(ichold.ne.-99) then
        icheck(20+indxtp-1)=ichold
        call fs_set_icheck(icheck(20+indxtp-1),20+indxtp-1)
      endif
      return
      end
