      subroutine peak(ip)
C
C  Peak up on tape drive read resposne
C
      include '../include/fscom.i'
C
      integer ip(5),ireg(2),iparm(2)
      integer*2 ibuf(50)
      integer get_buf,ichcm_ch
      real*4 mper
      equivalence (reg,ireg(1)),(parm,iparm(1))
      character cjchar
      data ilen/100/
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
C   Number of samples
C
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        nsamp=3
      else if(cjchar(parm,1).eq.'*') then
        nsamp=nsamppk_fs
      else if(ierr.eq.0) then
        nsamp=iparm(1)
      else
        ip(3)=-241
        goto 990
      endif
C
C   Number of iterations
C
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        iter=1
      else if(cjchar(parm,1).eq.'*') then
        iter=iterpk_fs
      else if(ierr.eq.0) then
        iter=iparm(1)
      else
        ip(3)=-242
        goto 990
      endif
C
C   Head to move
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      call fs_get_drive(drive)
      if(ichcm_ch(parm,1,'r').eq.0.and.MK3.eq.iand(drive,MK3)) then
        ihd = 2
      else if(ichcm_ch(parm,1,'r').eq.0) then
        ip(3)=-501
        goto 990
      else if(ichcm_ch(parm,1,'w').eq.0) then
        ihd = 1
      else if(cjchar(parm,1).eq.'*') then
        ihd=ihdpk_fs
      else if (cjchar(parm,1).eq.','.and.VLBA.ne.iand(drive,VLBA)) then
        ihd = 2
      else if (cjchar(parm,1).eq.',') then
        ihd = 1
      else
        ip(3) = -243
        goto 990
      endif
C
C   Minimum peak voltage
C
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        vmin=.2
      else if(cjchar(parm,1).eq.'*') then
        vmin=vminpk_fs
      else if(ierr.eq.0) then
        vmin=parm
      else
        ip(3)=-244
        goto 990
      endif
C
C  3. Plant values in COMMON
C
300   continue
      ihdpk_fs=ihd
      iterpk_fs=iter
      nsamppk_fs=nsamp
      vminpk_fs=vmin
      goto 990
C
C  5.  Find peak
C
500   continue
      kpeakv_fs=.false.
      call fs_get_ispeed(ispeed)
      call fs_get_idirtp(idirtp)
      call fs_get_ienatp(ienatp)
      if(ispeed.eq.0) then ! tape must be moving
        ip(3)=-341
        goto 990
      else if(idirtp.ne.1..and.ienatp.ne.0) then ! not rec in rev
        ip(3)= -342
        goto 990
      else if(ihdpk_fs.eq.0) then ! command must be set-up
        ip(3)=-343
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
C
      call pkhd(ihdpk_fs,iterpk_fs,nsamppk_fs,rpdt_fs,vltpk_fs,peakv,
     &          mper,ip,khecho_fs,lu,kpeakv_fs,vminpk_fs)
      if(ip(3).ne.0) goto 800
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
C
      nch=nch+ib2as(nsamppk_fs,ibuf,nch,o'100003')
      nch=mcoma(ibuf,nch)
C
      nch=nch+ib2as(iterpk_fs,ibuf,nch,o'100003')
      nch=mcoma(ibuf,nch)
C
      if(ihdpk_fs.eq.1) then
        nch=ichmv(ibuf,nch,6hwrite ,1,5)
      else if(ihdpk_fs.eq.2) then
        nch=ichmv(ibuf,nch,4hread  ,1,4)
      endif
      nch=mcoma(ibuf,nch)
C
      if(ieq.eq.0) nch=nch+ir2as(vminpk_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(ieq.eq.0) nch=nch+ir2as(peakv,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(ieq.eq.0) nch=nch+ir2as(mper,ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(kpeakv_fs) then
        nch=ichmv(ibuf,nch,2ht ,1,1)
      else
        nch=ichmv(ibuf,nch,2hf ,1,1)
      endif
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(vltpk_fs,ibuf,nch,8,3)
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
