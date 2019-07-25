      subroutine et(ip)
C  stop tape

      include '../include/fscom.i'
C
C     This routine sends out the appropriate commands
C     to stop the tape.
C
C  WHO  WHEN    DESCRIPTION
C  WEH  850512  CHECK RMPAR AFTER CHECKING FOR VACUUM
C  GAG  910111  Changed LFEET to LFEET_FS in call to MA2TP.
C  gag  920714  Added MK4 control code and use of the tape rate generator
C               common variable lgen.
C
      dimension ip(1)
      dimension ireg(2)
      integer get_buf
      integer*2 ibuf(10)
      equivalence (ireg(1),reg)
      data ilen/20/
C
      ichold = -99
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
      if (VLBA .eq. and(drive,VLBA)) goto 200
C 
C     1. Set up buffer for ending tape, i.e. send zero speed: 
C                   mmTP)=07200000
C     Then turn off enable bit: 
C                   mmTP%=0xxxxxxx
C     and set up bypass mode. 
C 
      call fs_get_icheck(icheck(18),18)
      ichold = icheck(18) 
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      ispeed = 0
      call fs_set_ispeed(ispeed)
C                   Put stopped indicator in common
      ibuf(1) = -3
      call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      call run_matcn(iclass,1)
      call rmpar(ip)
      if(ip(3).lt.0) go to 155
      ireg(2) = get_buf(ip(1),ibuf,-ilen,idum,idum)
      call ma2tp(ibuf,ilow,lfeet_fs,ifastp,icaptp,istptp,itactp,irdytp)
      call fs_set_icaptp(icaptp)
      call fs_set_istptp(istptp)
      call fs_set_itactp(itactp)
      call fs_set_irdytp(irdytp)
      call fs_set_lfeet_fs(lfeet_fs)
C
      ibuf(1) = 0
      call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      nrec = 0
C
C  DISABLE RECORD ENABLE ON MARK III DRIVE
C
      ienatp = 0
      call fs_set_ienatp(ienatp)
      call fs_get_kena(kenastk)
C                   Indicate disabled in common
      if (MK3.eq.and(drive,MK3)) then
        call en2ma(ibuf(3),ienatp,-1,ltrken)
      else if (MK4.eq.and(drive,MK4)) then
        call en2ma4(ibuf(3),ienatp,kenastk)
      endif
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec = nrec + 1
C
C  VACUUM MUST BE UP
C
      call fs_get_irdytp(irdytp)
      if (irdytp.ne.0) then
        goto 150
      endif
      call fs_get_idirtp(idirtp)
      call fs_get_lgen(lgen) ! get the rate generator
      call mv2ma(ibuf(3),idirtp,ispeed,lgen)
C                     Send the stop message
C
      call put_buf(iclass,ibuf,-13,'fs','  ')
      nrec = nrec + 1
C
150   call run_matcn(iclass,nrec)
      call rmpar(ip)
      call mvdis(ip,iclcm)
C
155   continue
      if (ichold.ne.-99) then
        icheck(18) = ichold
        call fs_set_icheck(icheck(18),18)
      endif
      if (ichold.ge.0) then
        icheck(18) = mod(ichold,1000)+1
        call fs_set_icheck(icheck(18),18)
        kmvtp_fs=.true.
      endif
      return
C
C             if VLBA recorder, then this section
200   continue
c
      call fc_et_v(ip)
      call mvdis(ip,iclcm)
      return

990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('q<',ip(4),1,2)
      return
      end
