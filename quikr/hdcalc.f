      subroutine hdcalc(ip,itask)
C
C  Calculate the calibration parameters
C
      include '../include/fscom.i'
C
      integer ip(5),ireg(2),iparm(2)
      integer*2 ibuf(50)
      integer get_buf,ichcm_ch
      logical ktemp
      real temp
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
      data ilen/100/
C
C  1.  Get the command
C
      if( itask.eq.6) then
         indxtp=1
      else
         indxtp=2
      endif
C
      ip(3)=0
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
        ksread_fs(indxtp)=.false.
        kswrite_fs(indxtp)=.false.
        ksdread_fs(indxtp)=.false.
        ksdwrite_fs(indxtp)=.false.
        kbdwrite_fs(indxtp)=.false.
        kbdread_fs(indxtp)=.false.
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
      ksread_fs(indxtp)=kv13_fs(indxtp).and.kv15for_fs(indxtp)
      if(ksread_fs(indxtp))
     $     rsread_fs(indxtp)=1397./(rv13_fs(indxtp)-rv15for_fs(indxtp))
C
      kswrite_fs(indxtp)=ksread_fs(indxtp).and.
     $     kv15scale_fs(indxtp).and.kv15for_fs(indxtp).and.
     $     kvw0_fs(indxtp).and.kvw8_fs(indxtp)
      if(kswrite_fs(indxtp)) rswrite_fs(indxtp)=
     &     rsread_fs(indxtp)*(rv15scale_fs(indxtp)-rv15for_fs(indxtp))/
     $     (rvw8_fs(indxtp)-rvw0_fs(indxtp))
C
      ksdread_fs(indxtp)=kv15rev_fs(indxtp).and.kv15for_fs(indxtp).and.
     $     ksread_fs(indxtp)
      if(ksdread_fs(indxtp)) rsdread_fs(indxtp)=
     $     (rv15rev_fs(indxtp)-rv15for_fs(indxtp))*rsread_fs(indxtp)
C
      ksdwrite_fs(indxtp)=kv15for_fs(indxtp).and.kvrevw_fs(indxtp).and.
     $     ksread_fs(indxtp)
      if(ksdwrite_fs(indxtp)) rsdwrite_fs(indxtp)=
     $     (rv15for_fs(indxtp)-rvrevw_fs(indxtp))*rsread_fs(indxtp)
C
      kbdwrite_fs(indxtp)=kv15flip_fs(indxtp).and.
     $     kv15for_fs(indxtp).and.ksread_fs(indxtp).and.
     $     kvw0_fs(indxtp).and.kswrite_fs(indxtp)
      if(kbdwrite_fs(indxtp)) then
         rbdwrite_fs(indxtp)=
     &        (rv15flip_fs(indxtp)-rv15for_fs(indxtp))*
     $        rsread_fs(indxtp)/2.+
     $        rvw0_fs(indxtp)*rswrite_fs(indxtp)+350.
         call fs_get_drive(drive)
         call fs_get_drive_type(drive_type)
         if(drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBAB) then
            call fs_get_rdhd_fs(rdhd_fs,indxtp)
            if(rdhd_fs(indxtp).eq.1)
     $           rbdwrite_fs(indxtp)=rbdwrite_fs(indxtp)+698.5
         else
            call fs_get_wrhd_fs(wrhd_fs,indxtp)
            if(wrhd_fs(indxtp).eq.2)
     $           rbdwrite_fs(indxtp)=rbdwrite_fs(indxtp)+698.5
         endif
      endif
C
      kbdread_fs(indxtp)=kv15flip_fs(indxtp).and.
     $     kv15for_fs(indxtp).and.ksread_fs(indxtp)
      if(kbdread_fs(indxtp)) then
        rbdread_fs(indxtp)=
     &  (rv15flip_fs(indxtp)+rv15for_fs(indxtp))*rsread_fs(indxtp)/2.+
     $        350.
        call fs_get_drive(drive)
        call fs_get_drive_type(drive_type)
        if(drive(indxtp).eq.VLBA.or.
     &       (drive(indxtp).eq.MK4.and.drive_type(indxtp).eq.MK4B)
     &       ) then
           call fs_get_wrhd_fs(wrhd_fs,indxtp)
           if(wrhd_fs(indxtp).eq.1)
     $          rbdread_fs(indxtp)=rbdread_fs(indxtp)+698.5
        else
           call fs_get_rdhd_fs(rdhd_fs,indxtp)
           if(rdhd_fs(indxtp).eq.2)
     $          rbdread_fs(indxtp)=rbdread_fs(indxtp)+698.5
        endif
      endif
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if((drive(indxtp).eq.VLBA.and.drive_type(indxtp).ne.VLBAB).or.
     &     (drive(indxtp).eq.MK4.and.drive_type(indxtp).eq.MK4B)
     &     ) then
        kswrite_fs(indxtp)=ksread_fs(indxtp)
        ksdwrite_fs(indxtp)=ksdread_fs(indxtp)
        kbdwrite_fs(indxtp)=kbdread_fs(indxtp)
        rswrite_fs(indxtp)=rsread_fs(indxtp)
        rsdwrite_fs(indxtp)=rsdread_fs(indxtp)
        rbdwrite_fs(indxtp)=rbdread_fs(indxtp)
        ksread_fs(indxtp)=.false.
        ksdread_fs(indxtp)=.false.
        kbdread_fs(indxtp)=.false.
      else if(drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBAB
     $       ) then
        ktemp=ksread_fs(indxtp)
        ksread_fs(indxtp)=kswrite_fs(indxtp)
        kswrite_fs(indxtp)=ktemp
c
        ktemp=ksdread_fs(indxtp)
        ksdread_fs(indxtp)=ksdwrite_fs(indxtp)
        ksdwrite_fs(indxtp)=ktemp
c
        ktemp=kbdread_fs(indxtp)
        kbdread_fs(indxtp)=kbdwrite_fs(indxtp)
        kbdwrite_fs(indxtp)=ktemp
c
        temp=rsread_fs(indxtp)
        rsread_fs(indxtp)=rswrite_fs(indxtp)
        rswrite_fs(indxtp)=temp
c
        temp=rsdread_fs(indxtp)
        rsdread_fs(indxtp)=rsdwrite_fs(indxtp)
        rsdwrite_fs(indxtp)=temp
c
        temp=rbdread_fs(indxtp)
        rbdread_fs(indxtp)=rbdwrite_fs(indxtp)
        rbdwrite_fs(indxtp)=temp
      endif
C
C  5.  Prepare output
C
500   continue
      nch=ieq
      if(nch.eq.0) nch=nchar+1
      nch=ichmv_ch(ibuf,nch,'/')
C
      if(kbdwrite_fs(indxtp))
     $     nch=nch+ir2as(rbdwrite_fs(indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(kbdread_fs(indxtp))
     $     nch=nch+ir2as(rbdread_fs(indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(ksdwrite_fs(indxtp))
     $     nch=nch+ir2as(rsdwrite_fs(indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      if(ksdread_fs(indxtp))
     $     nch=nch+ir2as(rsdread_fs(indxtp),ibuf,nch,8,1)
      nch=mcoma(ibuf,nch)
C
      call fs_get_drive_type(drive_type)
      if(kswrite_fs(indxtp).and..not.
     &     ((drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2).or.
     &     (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)
     &     )) then
        nch=nch+ir2as(rswrite_fs(indxtp),ibuf,nch,8,2)
      else if(kswrite_fs(indxtp)) then
        nch=nch+ir2as(rswrite_fs(indxtp),ibuf,nch,8,5)
      endif
      nch=mcoma(ibuf,nch)
C
      if(ksread_fs(indxtp).and..not.
     &     ((drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2).or.
     &     (drive(indxtp).eq.VLBA4.and.drive_type(indxtp).eq.VLBA42)
     &     )) then
         nch=nch+ir2as(rsread_fs(indxtp),ibuf,nch,8,2)
      else if(ksread_fs(indxtp)) then
         nch=nch+ir2as(rsread_fs(indxtp),ibuf,nch,8,5)
      endif
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
