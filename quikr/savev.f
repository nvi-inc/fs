      subroutine savev(ip)
C
C  Peak up on tape drive read response
C
      include '../include/fscom.i'
C
      integer vrevw,v15rev,v15for,v15scale,v13,v15flip,vw0,vw8
      parameter(
     &          vrevw    = 1,
     &          v15rev   = 2,
     &          v15for   = 3,
     &          v15scale = 4,
     &          v13      = 5,
     &          v15flip  = 6,
     &          vw0      = 7,
     &          vw8      = 8)
  
      integer ip(5),ireg(2),iparm(2)
      integer*2 ibuf(50)
      integer get_buf,ichcm_ch
      real*4 volts(2)
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
      data ilen/100/
C
C  1.  Get the command
C
      iclass=0
      nrec=0
      iclcm=ip(1)
      if(iclcm.eq.0) then
        ip(3) =-1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar=min0(ilen,ireg(2))
      ieq=iscn_ch(ibuf,1,nchar,'=')
      if(ieq.eq.0) then
        goto 500
      else if(cjchar(ibuf,ieq+1).eq.'?') then
        ip(4)=o'77'
        goto 500
      endif
C
C  2. Get parameters.
C
C   Voltage name to remember
C
      call fs_get_drive(drive)
      ich=ieq+1
      icm=iscn_ch(ibuf,ich,nchar,',')
      if(icm.eq.0) icm=nchar
      if(ichcm_ch(ibuf,ich,'vrevw').eq.0) then
        indx=vrevw
      else if(ichcm_ch(ibuf,ich,'v15rev').eq.0) then
        indx=v15rev
      else if(ichcm_ch(ibuf,ich,'v15for').eq.0) then
        indx=v15for
      else if(ichcm_ch(ibuf,ich,'v15scale').eq.0) then
        indx=v15scale
      else if(ichcm_ch(ibuf,ich,'v13').eq.0) then
        indx=v13
      else if(ichcm_ch(ibuf,ich,'v15flip').eq.0) then
        indx=v15flip
      else if(ichcm_ch(ibuf,ich,'vw0').eq.0) then
        indx=vw0
        if(VLBA.eq.and(drive,VLBA)) then
          ip(3)=-502
          goto 990
        endif
      else if(ichcm_ch(ibuf,ich,'vw8').eq.0) then
        indx=vw8
        if(VLBA.eq.and(drive,VLBA)) then
          ip(3)=-502
          goto 990
        endif
      else if(ichcm_ch(ibuf,ich,'clear').eq.0) then
        kvrevw_fs=.false.
        kv15rev_fs=.false.
        kv15for_fs=.false.
        kv15scale_fs=.false.
        kv13_fs=.false.
        kv15flip_fs=.false.
        kvw0_fs=.false.
        kvw8_fs=.false.
        goto 990
      else
        ip(3) = -251
        goto 990
      endif
C
C  2.2  Voltage
C
      ich=icm+1
c     write(6,9100) indx
9100  format(10x,"the indx is ",i6,/)
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(cjchar(parm,1).eq.',') then
        if(indx.le.6) then   !use peaked position
          if(.not.kpeakv_fs)  then
            ip(3) =-351
            goto 990
          endif
          vlt=vltpk_fs
        else
          call lvdonn('lock',ip)
          if(ip(3).ne.0) go to 800
C
          ihd=1
          if(.not.kposhd_fs(1)) then
            ip(3) =-352
            goto 990
          endif
C
          call vlt_read(ihd,volts,ip)
          vlt=volts(ihd)
          if(ip(3).ne.0) go to 800
C
          call lvdofn('unlock',ip)
          if(ip(3).ne.0) go to 800
        endif
      else if(ierr.eq.0) then
        vlt=parm
      else
        ip(3) =-252
        goto 990
      endif
C
C  3. Plant values in COMMON
C
300   continue
      if(indx.eq.vrevw) then
        kvrevw_fs=.true.
        rvrevw_fs=vlt
      else if(indx.eq.v15rev) then
        kv15rev_fs=.true.
        rv15rev_fs=vlt
      else if(indx.eq.v15for) then
        kv15for_fs=.true.
        rv15for_fs=vlt
      else if(indx.eq.v15scale) then
        kv15scale_fs=.true.
        rv15scale_fs=vlt
      else if(indx.eq.v13) then
        kv13_fs=.true.
        rv13_fs=vlt
      else if(indx.eq.v15flip) then
        kv15flip_fs=.true.
        rv15flip_fs=vlt
      else if(indx.eq.vw0) then
        kvw0_fs=.true.
        rvw0_fs=vlt
      else if(indx.eq.vw8) then
        kvw8_fs=.true.
        rvw8_fs=vlt
      endif
      goto 990
C
C  5.  Prepare output
C
500   continue
      nch=nchar+1
      nch=ichmv_ch(ibuf,nch,'/')
C
      if(kvrevw_fs)      nch=nch+ir2as(rvrevw_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kv15rev_fs)     nch=nch+ir2as(rv15rev_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kv15for_fs)     nch=nch+ir2as(rv15for_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kv15scale_fs)   nch=nch+ir2as(rv15scale_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kv13_fs)        nch=nch+ir2as(rv13_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kv15flip_fs)    nch=nch+ir2as(rv15flip_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kvw0_fs)        nch=nch+ir2as(rvw0_fs,ibuf,nch,8,3)
      nch=mcoma(ibuf,nch)
C
      if(kvw8_fs)        nch=nch+ir2as(rvw8_fs,ibuf,nch,8,3)
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
      call lvdofn('unlock',ip)
C
C  That's all
C
990   continue
      call char2hol('q@',ip(4),1,2)
      ip(1)=iclass
      ip(2)=nrec
      return
      end
