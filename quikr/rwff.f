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
      if (VLBA .eq.drive.or.VLBA4.eq.drive) goto 500
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
      call fs_get_icheck(icheck(18),18)
      ichold = icheck(18)
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      ibuf(1) = -3
      call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      call run_matcn(iclass,1)
      call rmpar(ip)
      if(ip(3).lt.0) go to 415
      ireg(2) = get_buf(ip(1),ibuf,-ilen,idum,idum)
      call ma2tp(ibuf,ilow,lfeet_fs,ifastp,icaptp,istptp,itactp,irdytp)
      call fs_set_icaptp(icaptp)
      call fs_set_istptp(istptp)
      call fs_set_irdytp(irdytp)
      call fs_set_itactp(itactp)
      call fs_set_lfeet_fs(lfeet_fs)
      if (irdytp.eq.0) goto 410
        ierr = -301
C          if vacuum not ready, forget it
        goto 990
C
410   continue
      ienatp = 0
      call fs_set_ienatp(ienatp)
      ispeed = 7
      call fs_set_ispeed(ispeed)
      idirtp = mod(isub-3,2)
      call fs_set_idirtp(idirtp)
      ilowtp = 1
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
      call char2hol('tp',ibuf(2),1,2)
      if(drive.eq.MK4) then
        call fs_get_kenastk(kenastk)
        call en2ma4(ibuf(3),ienatp,kenastk)
      else if(drive.eq.MK3) then
         call en2ma(ibuf(3),ienatp,-1,ltrken)
      endif
      call put_buf(iclass,ibuf,-13,'fs','  ')
C
      call tp2ma(ibuf(3),ilowtp,0)
      call put_buf(iclass,ibuf,-13,'fs','  ')
C
      if(isub.lt.5) then
         call fs_get_iskdtpsd(iskdtpsd)
         if (iskdtpsd.eq.-2) then
            call ichmv_ch(lgen,1,'960')
         else if (iskdtpsd.eq.-1) then
            call ichmv_ch(lgen,1,'880')
         else
            call ichmv_ch(lgen,1,'720')
         endif
      else
         call fs_get_imaxtpsd(imaxtpsd)
         if (imaxtpsd.eq.-2) then
            call ichmv_ch(lgen,1,'960')
         else if (imaxtpsd.eq.-1) then
            call ichmv_ch(lgen,1,'880')
         else
            call ichmv_ch(lgen,1,'720')
         endif
      endif
      call mv2ma(ibuf(3),idirtp,ispeed,lgen)
      call fs_set_lgen(lgen)
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec=nrec+3
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call mvdis(ip,iclcm)
C
415   continue
      icheck(18) =ichold
      call fs_set_icheck(icheck(18),18)
      if(ichold.ge.0) then
        icheck(18)=mod(ichold,1000)+1
        call fs_set_icheck(icheck(18),18)
        kmvtp_fs=.true.
      endif
      return
C        vlba recorder movement commands
500   continue
      ierr = 0
      call fc_rwff_v(ip,isub,ierr)
      if (ierr.ne.0) goto 990
      call mvdis(ip,iclcm)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('q<',ip(4),1,2)
      return
      end
