      subroutine newlg(ibuf,lsorin)
C
C     NEWLG fills in the buffer with the first line of the log file
C           and sends this to DDOUT for starting a new log.
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
C  INPUT:
C
      integer*2 ibuf(1)
C      - buffer to use, assumed to be at least 50 characters long
      integer*2 ib(128)
      integer*2 lprocdumm(6)
      character*1 model,cjchar
C     LSOR - source of this message
C
C  OUTPUT: NONE
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  NRV  830914  Added occupation serial # as second buffer
C  LAR  880205  Added FSUPDATE call.
C  LAR  880331  Added 2nd line with minor version #
C  WEH  880708  REMOVE FSUPDATE CALL
C  gag  920902  Changed code to use pi from the include file dpi.i
C
C  LOCAL
C
C     The new-log information line:
C   MARK IV FIELD SYSTEM VERSION <version> <station> <year> <occup#>
C     Send this with option "NL" to LOGIT, i.e. start new log file.
C
      nch = ichmv_ch(ibuf,1,'Log Opened: ')
      nch = ichmv_ch(ibuf,nch,'Mark IV Field System ')
      nch = ichmv_ch(ibuf,nch,'Version ')
      idum=sVerMajor_FS
      nch = nch + ib2as(idum,ibuf,nch,o'100000'+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerMinor_FS
      nch = nch + ib2as(idum,ibuf,nch,o'100000'+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerPatch_FS
      nch = nch + ib2as(idum,ibuf,nch,o'100000'+5)
      nch = nch-1
      call char2hol('nl',nl,1,2)
      call ifill_ch(lprocdumm,1,12,' ')
      idum=ichmv(lsor,1,lsorin,1,2)
      if(index('$&',cjchar(lsor,1)).ne.0) then
          idum=ichmv(lsor,1,lsorin,2,1)
      endif
      call logit5(ibuf(1),nch,lsor,lprocdumm,nl)
      call fs_get_logchg(logchg)
      logchg=mod(logchg+1,2147483647)
      call fs_set_logchg(logchg)
C
C     Send configuration info from control files to log
C
      nch = 1
      nch=ichmv_ch(ib,nch,'location')
      nch=mcoma(ib,nch)
      call fs_get_lnaant(lnaant)
      nch=ichmv(ib,nch,lnaant,1,8)
      nch=mcoma(ib,nch)
      call fs_get_wlong(wlong)
      call fs_get_alat(alat)
      wl = wlong * 180.0D0/dpi
      al = alat * 180.0D0/dpi
      nch = nch + ir2as(wl,ib,nch,7,2)
      nch=mcoma(ib,nch)
      nch = nch + ir2as(al,ib,nch,6,2)
      nch=mcoma(ib,nch)
      call fs_get_height(height)
      nch = nch + ir2as(height,ib,nch,6,1)
      nch=nch-1
      call logit3(ib,nch,lsor)
c
      nch = 1
      nch = ichmv_ch(ib,nch,'horizon1')
      nch = mcoma(ib,nch)
      call fs_get_horaz(horaz)
      call fs_get_horel(horel)
      do i=1,8
        if(horaz(i).lt.0) goto 400
        nch = nch + ir2as(horaz(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
        if(horel(i).lt.0) goto 400
        nch = nch + ir2as(horel(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
      enddo
400   nch = nch-2
      call logit3(ib,nch,lsor)
      nch = 1
      nch = ichmv_ch(ib,nch,'horizon2')
      nch = mcoma(ib,nch)
      do i=9,15
        if(horaz(i).lt.0) goto 500
        nch = nch + ir2as(horaz(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
        if(horel(i).lt.0) goto 500
        nch = nch + ir2as(horel(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
      enddo
500   nch = nch-2
      if(nch.gt.8) call logit3(ib,nch,lsor)
c
      nch = 1
      nch = ichmv_ch(ib,nch,'antenna,')
      call fs_get_diaman(diaman)
      nch = nch + ir2as(diaman,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_slew1(slew1)
      nch = nch + ir2as(slew1,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_slew2(slew2)
      nch = nch + ir2as(slew2,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_lolim1(lolim1)
      nch = nch + ir2as(lolim1,ib,nch,6,1)
      nch=mcoma(ib,nch)
      call fs_get_uplim1(uplim1)
      nch = nch + ir2as(uplim1,ib,nch,6,1)
      nch=mcoma(ib,nch)
      call fs_get_lolim2(lolim2)
      nch = nch + ir2as(lolim2,ib,nch,6,1)
      nch=mcoma(ib,nch)
      call fs_get_uplim2(uplim2)
      nch = nch + ir2as(uplim2,ib,nch,6,1)
      nch=mcoma(ib,nch)
      nch = ichmv(ib,nch,iaxis,1,4) - 1
      call logit3(ib,nch,lsor)

      nch = ichmv_ch(ib,1,'equip,')
c
      call fs_get_rack(rack)
      call fs_get_rack_type(rack_type)
      if(rack.eq.MK3) then
        nch=ichmv_ch(ib,nch,'mk3')
      else if(rack.eq.VLBA.and.rack_type.eq.VLBAG) then
        nch=ichmv_ch(ib,nch,'vlbag')
      else if(rack.eq.VLBA.and.rack_type.eq.VLBA) then
        nch=ichmv_ch(ib,nch,'vlba')
      else if(rack.eq.MK4.and.rack_type.eq.MK4) then
        nch=ichmv_ch(ib,nch,'mk4')
      else if(rack.eq.MK4.and.rack_type.eq.MK45) then
        nch=ichmv_ch(ib,nch,'mk5')
      else if(rack.eq.VLBA4.and.rack_type.eq.VLBA4) then
        nch=ichmv_ch(ib,nch,'vlba4')
      else if(rack.eq.VLBA4.and.rack_type.eq.VLBA45) then
        nch=ichmv_ch(ib,nch,'vlba5')
      else if(rack.eq.K4.and.rack_type.eq.K41) then
        nch=ichmv_ch(ib,nch,'k41')
      else if(rack.eq.K4.and.rack_type.eq.K41U) then
        nch=ichmv_ch(ib,nch,'k41u')
      else if(rack.eq.K4.and.rack_type.eq.K42) then
        nch=ichmv_ch(ib,nch,'k42')
      else if(rack.eq.K4.and.rack_type.eq.K42A) then
        nch=ichmv_ch(ib,nch,'k42a')
      else if(rack.eq.K4.and.rack_type.eq.K42B) then
        nch=ichmv_ch(ib,nch,'k42b')
      else if(rack.eq.K4.and.rack_type.eq.K42BU) then
        nch=ichmv_ch(ib,nch,'k42bu')
      else if(rack.eq.K4.and.rack_type.eq.K42C) then
        nch=ichmv_ch(ib,nch,'k42c')
      else if(rack.eq.K4K3.and.rack_type.eq.K41) then
        nch=ichmv_ch(ib,nch,'k41/k3')
      else if(rack.eq.K4K3.and.rack_type.eq.K41U) then
        nch=ichmv_ch(ib,nch,'k41u/k3')
      else if(rack.eq.K4K3.and.rack_type.eq.K42) then
        nch=ichmv_ch(ib,nch,'k42/k3')
      else if(rack.eq.K4K3.and.rack_type.eq.K42A) then
        nch=ichmv_ch(ib,nch,'k42a/k3')
      else if(rack.eq.K4K3.and.rack_type.eq.K42BU) then
        nch=ichmv_ch(ib,nch,'k42bu/k3')
      else if(rack.eq.K4MK4.and.rack_type.eq.K41) then
        nch=ichmv_ch(ib,nch,'k41/mk4')
      else if(rack.eq.K4MK4.and.rack_type.eq.K41U) then
        nch=ichmv_ch(ib,nch,'k41u/mk4')
      else if(rack.eq.K4MK4.and.rack_type.eq.K42) then
        nch=ichmv_ch(ib,nch,'k42/mk4')
      else if(rack.eq.K4MK4.and.rack_type.eq.K42A) then
        nch=ichmv_ch(ib,nch,'k42a/mk4')
      else if(rack.eq.K4MK4.and.rack_type.eq.K42B) then
        nch=ichmv_ch(ib,nch,'k42b/mk4')
      else if(rack.eq.K4MK4.and.rack_type.eq.K42BU) then
        nch=ichmv_ch(ib,nch,'k42bu/mk4')
      else if(rack.eq.K4MK4.and.rack_type.eq.K42C) then
        nch=ichmv_ch(ib,nch,'k42c/mk4')
      else if(rack.eq.LBA) then
        nch=ichmv_ch(ib,nch,'lba')
      else if(rack.eq.LBA4) then
        nch=ichmv_ch(ib,nch,'lba4')
      else if(rack.eq.S2) then
        nch=ichmv_ch(ib,nch,'s2')
      else if(rack.eq.DBBC) then
        nch=ichmv_ch(ib,nch,'dbbc')
      else if(rack.eq.RDBE) then
        nch=ichmv_ch(ib,nch,'rdbe')
      else if(rack.eq.0) then
        nch=ichmv_ch(ib,nch,'none')
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if(drive(1).eq.MK4.and.drive_type(1).eq.MK4B) then
        nch=ichmv_ch(ib,nch,'mk4b')
      else if(drive(1).eq.MK3) then
        nch=ichmv_ch(ib,nch,'mk3')
      else if(drive(1).eq.VLBA.and.drive_type(1).eq.VLBA) then
        nch=ichmv_ch(ib,nch,'vlba')
      else if(drive(1).eq.VLBA.and.drive_type(1).eq.VLBA2) then
        nch=ichmv_ch(ib,nch,'vlba2')
      else if(drive(1).eq.VLBA.and.drive_type(1).eq.VLBAB) then
        nch=ichmv_ch(ib,nch,'vlbab')
      else if(drive(1).eq.MK4) then
        nch=ichmv_ch(ib,nch,'mk4')
      else if(drive(1).eq.S2) then
        nch=ichmv_ch(ib,nch,'s2')
      else if(drive(1).eq.VLBA4.and.drive_type(1).eq.VLBA4) then
        nch=ichmv_ch(ib,nch,'vlba4')
      else if(drive(1).eq.VLBA4.and.drive_type(1).eq.VLBA42) then
        nch=ichmv_ch(ib,nch,'vlba42')
      else if(drive(1).eq.K4.and.drive_type(1).eq.K41) then
        nch=ichmv_ch(ib,nch,'k41')
      else if(drive(1).eq.K4.and.drive_type(1).eq.K42) then
        nch=ichmv_ch(ib,nch,'k42')
      else if(drive(1).eq.K4.and.drive_type(1).eq.K41DMS) then
        nch=ichmv_ch(ib,nch,'k41/dms')
      else if(drive(1).eq.K4.and.drive_type(1).eq.K42DMS) then
        nch=ichmv_ch(ib,nch,'k42/dms')
      else if(drive(1).eq.MK5.and.drive_type(1).eq.MK5A) then
        nch=ichmv_ch(ib,nch,'mk5a')
      else if(drive(1).eq.MK5.and.drive_type(1).eq.MK5A_BS) then
        nch=ichmv_ch(ib,nch,'mk5a_bs')
      else if(drive(1).eq.MK5.and.drive_type(1).eq.MK5B) then
        nch=ichmv_ch(ib,nch,'mk5b')
      else if(drive(1).eq.MK5.and.drive_type(1).eq.MK5B_BS) then
        nch=ichmv_ch(ib,nch,'mk5b_bs')
      else if(drive(1).eq.MK5.and.drive_type(1).eq.MK5C) then
        nch=ichmv_ch(ib,nch,'mk5c')
      else if(drive(1).eq.MK5.and.drive_type(1).eq.MK5C_BS) then
        nch=ichmv_ch(ib,nch,'mk5c_bs')
      else if(drive(1).eq.MK6.and.drive_type(1).eq.MK6) then
        nch=ichmv_ch(ib,nch,'mk6')
      else if(drive(1).eq.0) then
        nch=ichmv_ch(ib,nch,'none')
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if(drive(2).eq.MK4.and.drive_type(2).eq.MK4B) then
        nch=ichmv_ch(ib,nch,'mk4b')
      else if(drive(2).eq.MK3) then
        nch=ichmv_ch(ib,nch,'mk3')
      else if(drive(2).eq.VLBA.and.drive_type(2).eq.VLBA) then
        nch=ichmv_ch(ib,nch,'vlba')
      else if(drive(2).eq.VLBA.and.drive_type(2).eq.VLBA2) then
        nch=ichmv_ch(ib,nch,'vlba2')
      else if(drive(2).eq.VLBA.and.drive_type(2).eq.VLBAB) then
        nch=ichmv_ch(ib,nch,'vlbab')
      else if(drive(2).eq.MK4) then
        nch=ichmv_ch(ib,nch,'mk4')
      else if(drive(2).eq.S2) then
        nch=ichmv_ch(ib,nch,'s2')
      else if(drive(2).eq.VLBA4.and.drive_type(2).eq.VLBA4) then
        nch=ichmv_ch(ib,nch,'vlba4')
      else if(drive(1).eq.VLBA4.and.drive_type(1).eq.VLBA42) then
        nch=ichmv_ch(ib,nch,'vlba42')
      else if(drive(2).eq.K4.and.drive_type(2).eq.K41) then
        nch=ichmv_ch(ib,nch,'k41')
      else if(drive(2).eq.K4.and.drive_type(2).eq.K42) then
        nch=ichmv_ch(ib,nch,'k42')
      else if(drive(2).eq.K4.and.drive_type(2).eq.K41DMS) then
        nch=ichmv_ch(ib,nch,'k41/dms')
      else if(drive(2).eq.K4.and.drive_type(2).eq.K42DMS) then
        nch=ichmv_ch(ib,nch,'k42/dms')
      else if(drive(2).eq.0) then
        nch=ichmv_ch(ib,nch,'none')
      endif
c
      nch=mcoma(ib,nch)
      if(decoder4.eq.3) then
         nch=ichmv_ch(ib,nch,"mk3")
      else if(decoder4.eq.4) then
         nch=ichmv_ch(ib,nch,"mk4")
      else if(decoder4.eq.1) then
         nch=ichmv_ch(ib,nch,"dqa")
      else
         nch=ichmv_ch(ib,nch,"none")
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_freqif3(freqif3)
      nch=nch+ib2as(freqif3/100,ib,nch,z'8000'+10)
c
      nch=ichmv_ch(ib,nch,'.')
      nch=nch+ib2as(mod(freqif3,100),ib,nch,z'C100'+2)
c
      nch=mcoma(ib,nch)
      nch=ichmv(ib,nch,ihx2a(iswavif3_fs),2,1)
c
      nch=mcoma(ib,nch)
      call fs_get_vfm_xpnt(vfm_xpnt)
      if (vfm_xpnt.eq.0) then
         nch=ichmv_ch(ib,nch,'a/d')
      else if (vfm_xpnt.eq.1) then
         nch=ichmv_ch(ib,nch,'dsm')
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_hwid(hwid)
      ihwid=hwid
      nch=nch+ib2as(ihwid,ib,nch,z'8005')
c
      nch=mcoma(ib,nch)
      call fs_get_i70kch(i70kch)
      nch = nch + ib2as(i70kch,ib,nch,z'8005')
c
      nch=mcoma(ib,nch)
      call fs_get_i20kch(i20kch)
      nch = nch + ib2as(i20kch,ib,nch,z'8005')
c
      nch=mcoma(ib,nch)
      if(pcalcntrl.eq.3) then
         nch=ichmv_ch(ib,nch,"if3")
      else
         nch=ichmv_ch(ib,nch,"none")
      endif

      nch=mcoma(ib,nch)
      call fs_get_imk4fmv(imk4fmv)
      nch = nch + ib2as(imk4fmv,ib,nch,z'8005')

      nch=mcoma(ib,nch)
      call fs_get_ndas(ndas)
      nch = nch + ib2as(ndas,ib,nch,z'8002')

      nch=mcoma(ib,nch)
      call fs_get_idasfilt(idasfilt)
      if (idasfilt.eq.0) then
         nch=ichmv_ch(ib,nch,'out')
      else if (idasfilt.eq.1) then
         nch=ichmv_ch(ib,nch,'in')
      endif

      nch=mcoma(ib,nch)
      call fs_get_idasbits(idasbits)
      if (idasbits.eq.0) then
         nch=ichmv_ch(ib,nch,'8bit')
      else if (idasbits.eq.1) then
         nch=ichmv_ch(ib,nch,'4bit')
      endif

      nch=mcoma(ib,nch)
      call fs_get_wx_met(wx_met)
      if (wx_met.eq.0) then
         nch=ichmv_ch(ib,nch,'cdp')
      else
         call fs_get_wx_host(wx_host)
         nch = nch + ib2as(wx_met,ib,nch,z'8005')
         nch=ichmv_ch(ib,nch,':')
         do i=1,65
            if(jchar(wx_host,i).eq.0) then
               nch=ichmv(ib,nch,wx_host,1,i-1)
               goto 1000
            endif
         enddo
 1000    continue
      endif

      nch=mcoma(ib,nch)
      call fs_get_mk4sync_dflt(mk4sync_dflt)
      if(mk4sync_dflt.eq.-1) then
         nch=ichmv_ch(ib,nch,'off')
      else
         nch = nch + ib2as(mk4sync_dflt,ib,nch,z'8002')
      endif

      nch=mcoma(ib,nch)
      if(mk4dec_fs.eq.13) then
         nch=ichmv_ch(ib,nch,'return')
      else if(mk4dec_fs.eq.ichar('$')) then
         nch=ichmv_ch(ib,nch,'$')
      else if(mk4dec_fs.eq.ichar('%')) then
         nch=ichmv_ch(ib,nch,'%')
      endif
c
      nch=mcoma(ib,nch)
      nch=ichmv_ch(ib,nch,'v')
      call fs_get_dbbcddcvs(dbbcddcvs)
      call fs_get_dbbcddcvc(dbbcddcvc)
      call char2hol(dbbcddcvs,ib,nch,nch+dbbcddcvc-1)
      nch=nch+dbbcddcvc
c
      nch=mcoma(ib,nch)
      call fs_get_dbbcpfbv(dbbcpfbv)
      nch=ichmv_ch(ib,nch,'v')
      nch = nch + ib2as(dbbcpfbv,ib,nch,z'800F')
c
      nch=mcoma(ib,nch)
      call fs_get_dbbc_cond_mods(dbbc_cond_mods)
      nch = nch + ib2as(dbbc_cond_mods,ib,nch,z'8002')

      call fs_get_dbbc_if_factors(dbbc_if_factors)
      do i=1,dbbc_cond_mods
         nch=mcoma(ib,nch)
         nch = nch + ib2as(dbbc_if_factors(i),ib,nch,z'8005')
      enddo
c
      nch=mcoma(ib,nch)
      call fs_get_m5b_crate(m5b_crate)
      nch = nch + ib2as(m5b_crate,ib,nch,z'8002')
c
      call logit3(ib,nch-1,lsor)
c
      if(drive(1).eq.VLBA.or.drive(1).eq.VLBA4) then
         call ldrivev('drivev1',lsor,1)
      else if(drive(1).eq.MK3.or.drive(1).eq.MK4) then
         call ldrivem('drivem1',lsor,1)
      endif
c
      if(drive(2).eq.VLBA.or.drive(2).eq.VLBA4) then
         call ldrivev('drivev2',lsor,2)
      else if(drive(2).eq.MK3.or.drive(2).eq.MK4) then
         call ldrivem('drivem2',lsor,2)
      endif
c
      if(drive(1).eq.VLBA.or.drive(1).eq.VLBA4.or.
     $     drive(1).eq.MK3.or.drive(1).eq.MK4) then
         call lhead('head1',lsor,1)
      endif
c
      if(drive(2).eq.VLBA.or.drive(2).eq.VLBA4.or.
     $     drive(2).eq.MK3.or.drive(2).eq.MK4) then
         call lhead('head2',lsor,2)
      endif
c
      nch = 1
      nch = ichmv_ch(ib,nch,'time,')
      nch = nch + ir2as(rate0ti_fs*86400.,ib,nch,12,3)
      nch=mcoma(ib,nch)
      nch = nch + ir2as(span0ti_fs/3600.0e2,ib,nch,12,3)
      nch=mcoma(ib,nch)
      call hol2char(model0ti_fs,1,1,model)
      if (model.eq.'n') then
         nch=ichmv_ch(ib,nch,'none')
      else if (model.eq.'o') then
         nch=ichmv_ch(ib,nch,'offset')
      else if (model.eq.'r') then
         nch=ichmv_ch(ib,nch,'rate')
      else if (model.eq.'c') then
         nch=ichmv_ch(ib,nch,'computer')
      endif
      call logit3(ib,nch-1,lsor)
C
c
      nch = 1
      nch = ichmv_ch(ib,nch,'flagr,')
      call fs_get_iapdflg(iapdflg)
      nch = nch + ib2as(iapdflg,ib,nch,z'8005')
      call logit3(ib,nch-1,lsor)
C
      nch = 1
      nch = ichmv_ch(ib,nch,'rdbe,')
      call fs_get_rdbe_rms_t(rdbe_rms_t)
      nch = nch + ir2as(rdbe_rms_t,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_rdbe_rms_min(rdbe_rms_min)
      nch = nch + ir2as(rdbe_rms_min,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_rdbe_rms_max(rdbe_rms_max)
      nch = nch + ir2as(rdbe_rms_max,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_rdbe_pcal_amp(rdbe_pcal_amp)
      if(rdbe_pcal_amp.eq.'r') then
         nch = ichmv_ch(ib,nch,'raw')
      else if(rdbe_pcal_amp.eq.'n') then
         nch = ichmv_ch(ib,nch,'normalized')
      else if(rdbe_pcal_amp.eq.'c') then
         nch = ichmv_ch(ib,nch,'correlator')
      endif
      call logit3(ib,nch-1,lsor)
c
      return
      end


