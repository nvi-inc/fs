      subroutine newlg(ibuf,lsorin)
C
C     NEWLG fills in the buffer with the first line of the log file
C           and sends this to DDOUT for starting a new log.
C
      include '../include/fscom.i'
      include '../include/dpi.i'
      include 'bosscm.i'
C
C  INPUT:
C
      integer*2 ibuf(1)
C      - buffer to use, assumed to be at least 50 characters long
      integer*2 ib(60)
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
      integer itsp(8)
      data itsp/0,3,7,15,30,60,120,240/
C
C     The new-log information line:
C   MARK IV FIELD SYSTEM VERSION <version> <station> <year> <occup#>
C     Send this with option "NL" to LOGIT, i.e. start new log file.
C
      call ifill_ch(ibuf,3,60,' ')
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
C
C     Send configuration info from control files to log
C
      call ifill_ch(ib,1,120,' ')
      nch = 1
      nch=ichmv_ch(ib,nch,'location')
      nch=mcoma(ib,nch)
      call fs_get_lnaant(lnaant)
      nch=ichmv(ib,nch,lnaant,1,8)
      nch=mcoma(ib,nch)
      nch=ichmv(ib,nch,lidstn,1,1)
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
      nch=mcoma(ib,nch)
      nch = ichmv(ib,nch,loccup,1,8)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(iacttp,ib,nch,o'100000'+6)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(i20kch,ib,nch,o'100000'+6)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(i70kch,ib,nch,o'100000'+6)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(iyrctl_fs,ib,nch,o'100000'+6)
      nch=nch-1
      call logit3(ib,nch,lsor)
      call ifill_ch(ib,1,120,' ')
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
      call ifill_ch(ib,1,120,' ')
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
C
      nch = 1
      nch = ichmv_ch(ib,nch,'head0,')
      do i=1,4
        if (i.eq.1) then
           call fs_get_wrhd_fs(wrhd_fs)
          idum=wrhd_fs
        else if(i.eq.2) then
          idum=rdhd_fs
        else if(i.eq.3) then
          idum=rpro_fs
        else
          idum=rpdt_fs
        endif
        if(idum.eq.0) then
          nch=ichmv_ch(ib,nch,'all')
        else if(idum.eq.1) then
          nch=ichmv_ch(ib,nch,'odd')
        else if(idum.eq.2) then ! no else so illegal value is blank
          nch=ichmv_ch(ib,nch,'even')
        endif
        nch=mcoma(ib,nch)
      enddo
      if(kadapt_fs) then
        nch=ichmv_ch(ib,nch,'adaptive')
      else
        nch=ichmv_ch(ib,nch,'fixed')
      endif
      nch=mcoma(ib,nch)
      if(kiwslw_fs) then
        nch=ichmv_ch(ib,nch,'yes')
      else
        nch=ichmv_ch(ib,nch,'no')
      endif
      nch=mcoma(ib,nch)
      nch=nch+ir2as(lvbosc_fs,ib,nch,6,4)
      nch=mcoma(ib,nch)
      nch=nch+ib2as(ilvtl_fs,ib,nch,o'100000'+5)
      nch=nch-1
      call logit3(ib,nch,lsor)
C
      call fs_get_drive_type(drive_type)
      if(drive_type.eq.VLBA2) then
         ipr=5
      else
         ipr=2
      endif
c
      do i=1,2
        call ifill_ch(ib,1,120,' ')
        nch = 1
        nch = ichmv_ch(ib,nch,'head')
        nch = nch + ib2as(i,ib,nch,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(fastfw(i),ib,nch,7,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(slowfw(i),ib,nch,5,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(foroff(i),ib,nch,6,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(fastrv(i),ib,nch,7,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(slowrv(i),ib,nch,5,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(revoff(i),ib,nch,6,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(pslope(i),ib,nch,8,ipr)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(rslope(i),ib,nch,8,ipr)
        call logit3(ib,nch,lsor)
      enddo
      call ifill_ch(ib,1,120,' ')
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

      call ifill_ch(ib,1,120,' ')
      nch = ichmv_ch(ib,1,'equip1,')
      call fs_get_iacttp(iacttp)
      nch = nch + ib2as(iacttp,ib,nch,3)
      nch=mcoma(ib,nch)
      call fs_get_imaxtpsd(imaxtpsd)
      if (imaxtpsd.eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (imaxtpsd.eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else
        nch = nch + ib2as(itsp(imaxtpsd+1),ib,nch,3)
      endif
      nch=mcoma(ib,nch)
      call fs_get_iskdtpsd(iskdtpsd)
      if (iskdtpsd.eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (iskdtpsd.eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else
        nch = nch + ib2as(itsp(iskdtpsd+1),ib,nch,3)
      endif
      nch=mcoma(ib,nch)
      call fs_get_refreq(refreq)
      nch = nch + ir2as(refreq,ib,nch,7,1)
      nch=mcoma(ib,nch)
      call fs_get_i70kch(i70kch)
      nch = nch + ib2as(i70kch,ib,nch,z'8005')
      nch=mcoma(ib,nch)
      call fs_get_i20kch(i20kch)
      nch = nch + ib2as(i20kch,ib,nch,z'8005')
c
      nch=mcoma(ib,nch)
      call fs_get_rack(rack)
      call fs_get_rack_type(rack_type)
      if(rack.eq.MK3) then
        nch=ichmv_ch(ib,nch,'mk3')
      else if(rack.eq.VLBA.and.rack_type.eq.VLBAG) then
        nch=ichmv_ch(ib,nch,'vlbag')
      else if(rack.eq.VLBA.and.rack_type.eq.VLBA) then
        nch=ichmv_ch(ib,nch,'vlba')
      else if(rack.eq.MK4) then
        nch=ichmv_ch(ib,nch,'mk4')
      else if(rack.eq.0) then
        nch=ichmv_ch(ib,nch,'none')
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      if(drive.eq.MK3.and.drive_type.eq.MK3B) then
        nch=ichmv_ch(ib,nch,'mk3b')
      else if(drive.eq.MK3) then
        nch=ichmv_ch(ib,nch,'mk3')
      else if(drive.eq.VLBA.and.drive_type.eq.VLBA) then
        nch=ichmv_ch(ib,nch,'vlba')
      else if(drive.eq.VLBA.and.drive_type.eq.VLBA2) then
        nch=ichmv_ch(ib,nch,'vlba2')
      else if(drive.eq.MK4) then
        nch=ichmv_ch(ib,nch,'mk4')
      else if(drive.eq.S2) then
        nch=ichmv_ch(ib,nch,'s2')
      else if(drive.eq.0) then
        nch=ichmv_ch(ib,nch,'none')
      endif
c
      nch=mcoma(ib,nch)
      call fs_get_hwid(hwid)
      nch=nch+ib2as(hwid,ib,nch,z'8005')
c
      call logit3(ib,nch-1,lsor)
      nch = ichmv_ch(ib,1,'equip2,')
c
      call fs_get_motorv(motorv)
      nch=nch+ir2as(motorv,ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_inscint(inscint)
      nch=nch+ir2as(inscint,ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_inscsl(inscsl)
      nch=nch+ir2as(inscsl,ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_outscint(outscint)
      nch=nch+ir2as(outscint,ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_outscsl(outscsl)
      nch=nch+ir2as(outscsl,ib,nch,12,3)
c
      nch=mcoma(ib,nch)
      call fs_get_itpthick(itpthick)
      nch=nch+ib2as(itpthick,ib,nch,z'8000'+10)
c
      nch=mcoma(ib,nch)
      call fs_get_capstan(capstan)
      nch=nch+ib2as(capstan,ib,nch,z'8000'+10)
c
      nch=mcoma(ib,nch)
      nch=nch+ib2as(freqif3_fs/100,ib,nch,z'8000'+10)
c
      nch=mcoma(ib,nch)
      nch=nch+ib2as(mod(freqif3_fs,100),ib,nch,z'C100'+2)
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
      call logit3(ib,nch-1,lsor)
c
      call ifill_ch(ib,1,120,' ')
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
      endif
      call logit3(ib,nch-1,lsor)
      return
      end
