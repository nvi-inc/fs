      subroutine hdcalc(ip)
C
C  Calculate the calibration parameters
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
C  1.  Get the command
C
      iclass=0
      nrec=0
      iclcm=ip(1)
      if(iclcm.eq.0) then
        ip(3)=-1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar=min0(ilen,ireg(2))
      ieq=iscn_ch(ibuf,1,nchar,'=')
      if(ieq.eq.0) then
        goto 300
      else if(ichcm_ch(ibuf,ieq+1,'clear').eq.0) then
        ksread_fs=.false.
        kswrite_fs=.false.
        ksdread_fs=.false.
        ksdwrite_fs=.false.
        kbdwrite_fs=.false.
        kbdread_fs=.false.
        goto 990
      else if(cjchar(ibuf,ieq+1).eq.'?') then
        ip(4)=o'77'
        goto 500
      endif
      ich=ieq+1
C
C  no parameters
C
      ip(3) = -261
      goto 990
C
C  Calculate calibration parameters
C
300   continue
C
      ksread_fs=kv13_fs.and.kv15for_fs
      if(ksread_fs) rsread_fs=1397./(rv13_fs-rv15for_fs)
C
      kswrite_fs=ksread_fs.and.kv15scale_fs.and.kv15for_fs
     &           .and.kvw0_fs.and.kvw8_fs
      if(kswrite_fs) rswrite_fs=
     &   rsread_fs*(rv15scale_fs-rv15for_fs)/(rvw8_fs-rvw0_fs)
C
      ksdread_fs=kv15rev_fs.and.kv15for_fs.and.ksread_fs
      if(ksdread_fs) rsdread_fs=(rv15rev_fs-rv15for_fs)*rsread_fs
C
      ksdwrite_fs=kv15for_fs.and.kvrevw_fs.and.ksread_fs
      if(ksdwrite_fs) rsdwrite_fs=(rv15for_fs-rvrevw_fs)*rsread_fs
C
      kbdwrite_fs=kv15flip_fs.and.kv15for_fs.and.ksread_fs
     &            .and.kvw0_fs.and.kswrite_fs
      if(kbdwrite_fs) then
        rbdwrite_fs=
     &  (rv15flip_fs-rv15for_fs)*rsread_fs/2.+rvw0_fs*rswrite_fs+350.
        call fs_get_wrhd_fs(wrhd_fs)
        if(wrhd_fs.eq.2) rbdwrite_fs=rbdwrite_fs+698.5
      endif
C
      kbdread_fs=kv15flip_fs.and.kv15for_fs.and.ksread_fs
      if(kbdread_fs) then
        rbdread_fs=
     &  (rv15flip_fs+rv15for_fs)*rsread_fs/2.+350.
        call fs_get_drive(drive)
        call fs_get_drive_type(drive_type)
        if(drive.eq.VLBA.or.drive_type.eq.MK3B) then
           call fs_get_wrhd_fs(wrhd_fs)
           if(wrhd_fs.eq.1) rbdread_fs=rbdread_fs+698.5
        else
           if(rdhd_fs.eq.2) rbdread_fs=rbdread_fs+698.5
        endif
      endif
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if(VLBA.eq.drive.or.MK3B.eq.drive_type) then
        kswrite_fs=ksread_fs
        ksdwrite_fs=ksdread_fs
        kbdwrite_fs=kbdread_fs
        rswrite_fs=rsread_fs
        rsdwrite_fs=rsdread_fs
        rbdwrite_fs=rbdread_fs
        ksread_fs=.false.
        ksdread_fs=.false.
        kbdread_fs=.false.
      endif
C
C  5.  Prepare output
C
500   continue
      nch=ieq
      if(nch.eq.0) nch=nchar+1
      nch=ichmv_ch(ibuf,nch,'/')
C
      if(kbdwrite_fs) nch=nch+ir2as(rbdwrite_fs,ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(kbdread_fs) nch=nch+ir2as(rbdread_fs,ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(ksdwrite_fs) nch=nch+ir2as(rsdwrite_fs,ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(ksdread_fs) nch=nch+ir2as(rsdread_fs,ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      call fs_get_drive_type(drive_type)
      if(kswrite_fs.and.drive_type.NE.VLBA2) then
        nch=nch+ir2as(rswrite_fs,ibuf,nch,8,2)
      else if(kswrite_fs) then
        nch=nch+ir2as(rswrite_fs,ibuf,nch,8,5)
      endif
      nch=mcoma(ibuf,nch)
C
      if(ksread_fs) nch=nch+ir2as(rsread_fs,ibuf,nch,8,2)
C
      nch=nch-1
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      nrec=1
C
C  That's all
C
990   continue
      call char2hol('q@',ip(4),1,2)
      ip(1)=iclass
      ip(2)=nrec
      return
      end
