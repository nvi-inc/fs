      subroutine worm(ip)
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
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if((ichcm_ch(parm,1,'r').eq.0.or.ichcm_ch(parm,1,'2').eq.0)
     &   .and.VLBA.ne.iand(drive,VLBA)) then
        ihd = 2
      else if(ichcm_ch(parm,1,'r').eq.0 .or.
     &        ichcm_ch(parm,1,'2').eq.0) then
        ip(3)=-501
        goto 990
      else if(ichcm_ch(parm,1,'w').eq.0 .or.
     &        ichcm_ch(parm,1,'1').eq.0) then
        ihd = 1
      else if (cjchar(parm,1).eq.','.and.VLBA.ne.iand(drive,VLBA)) then
        ihd = 2
      else if (cjchar(parm,1).eq.',') then
        ihd = 1
      else if(cjchar(parm,1).eq.'*') then
        ihd=ihdwo_fs
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
        icl=iclwo_fs
      else
        ip(3) = -272
        goto 990
      endif
C
C  3. Plant values in COMMON
C
300   continue
      ihdwo_fs=ihd
      iclwo_fs=icl
      goto 990
C
C  5.  Measure speeds, check first if new that the calibrations have been
C                      determined.
C
500   continue
      if(iclwo_fs.eq.2)then
        if(ihdwo_fs.eq.1.and..not.kswrite_fs) then
          ip(3)=-372
          goto 990
        else if(ihdwo_fs.eq.2.and..not.ksread_fs) then
          ip(3)=-372
          goto 990
        endif
      else if(ihdwo_fs.eq.0) then
        ip(3)=-371
        goto 990
      endif
C
      call fs_get_icheck(icheck(20),20)
      ichold=icheck(20)
      icheck(20) = 0
      call fs_set_icheck(icheck(20),20)
C
      call lvdonn('lock',ip)
      if(ip(3).ne.0) goto 800
      call wohd(ihdwo_fs,fowo_fs,sowo_fs,fiwo_fs,siwo_fs,ip,khecho_fs,
     &          lu,iclwo_fs)
      if(ip(3).ne.0) goto 800
C
C  set the approrpiate flag, note: KxxWO_FS=IHDWO_FS.EQ.x will not work here
C  we don't want to change old value of other parameter
C
      if(iclwo_fs.eq.2) then
        if(ihdwo_fs.eq.1) kwrwo_fs=.true.
        if(ihdwo_fs.eq.2) krdwo_fs=.true.
      else if(iclwo_fs.eq.3) then !update current values
        fastfw(ihdwo_fs)=fowo_fs(ihdwo_fs)
        fastrv(ihdwo_fs)=fiwo_fs(ihdwo_fs)
        slowfw(ihdwo_fs)=sowo_fs(ihdwo_fs)
        slowrv(ihdwo_fs)=siwo_fs(ihdwo_fs)
      endif
C
      call lvdofn('unlock',ip)
      if(ip(3).ne.0) goto 800
C
C  6.  Set up response
C
600   continue
      nch=ieq
      if(ieq.eq.0) nch=nchar+1
      nch=ichmv(ibuf,nch,2h/ ,1,1)
      if(ihdwo_fs.eq.1) then
        nch=ichmv(ibuf,nch,6hwrite ,1,5)
      else if(ihdwo_fs.eq.2) then
        nch=ichmv(ibuf,nch,4hread  ,1,4)
      endif
      nch=mcoma(ibuf,nch)
C
      if(iclwo_fs.eq.1) then
        nch=ichmv(ibuf,nch,4hold ,1,3)
      else if(iclwo_fs.eq.2) then
        nch=ichmv(ibuf,nch,4hnew ,1,3)
      else if(iclwo_fs.eq.3) then
        nch=ichmv(ibuf,nch,6hupdate,1,6)
      endif
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(fowo_fs(ihdwo_fs),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
      nch=nch+ir2as(sowo_fs(ihdwo_fs),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
      nch=nch+ir2as(fiwo_fs(ihdwo_fs),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
      nch=nch+ir2as(siwo_fs(ihdwo_fs),ibuf,nch,8,1)
C
      nch=nch-1
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      nrec=1
      goto 990
C
800   continue
      if(ip(2).ne.0) call clrcl(ip(1))
      ip(2)=0
      call logit7(0,0,0,0,ip(3),ip(4),ip(5))
      call lvdofn('unlock',ip)
C
C  That's all
C
990   continue
      call char2hol('q@',ip(4),1,2)
      ip(1)=iclass
      ip(2)=nrec
      if(ichold.ne.-99) then
        icheck(20)=ichold
        call fs_set_icheck(icheck(20),20)
      endif
      return
      end
