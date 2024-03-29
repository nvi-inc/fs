*
* Copyright (c) 2020-2021, 2023 NVI, Inc.
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
      subroutine newlg(ibuf,lsorin)
C
C     NEWLG fills in the buffer with the first line of the log file
C           and sends this to DDOUT for starting a new log.
C
      include '../include/fscom.i'
      include '../include/dpi.i'
      include '../include/boz.i'
C
C  INPUT:
C
      integer*2 ibuf(1)
C      - buffer to use, assumed to be at least 50 characters long
      integer*2 ib(128)
      integer*2 lprocdumm(6)
      character*1 model,cjchar
      character*256 display_server_envar
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
      nch = nch + ib2as(idum,ibuf,nch,ocp100000+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerMinor_FS
      nch = nch + ib2as(idum,ibuf,nch,ocp100000+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerPatch_FS
      nch = nch + ib2as(idum,ibuf,nch,ocp100000+5)
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
C     Add release info to log
C
      nch = 1
      nch=ichmv_ch(ibuf,nch,'release')
      nch=mcoma(ibuf,nch)
      idum=sVerMajor_FS
      nch = nch + ib2as(idum,ibuf,nch,ocp100000+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerMinor_FS
      nch = nch + ib2as(idum,ibuf,nch,ocp100000+5)
      nch = ichmv_ch(ibuf,nch,'.')
      idum=sVerPatch_FS
      nch = nch + ib2as(idum,ibuf,nch,ocp100000+5)
      call fs_get_sVerrelease_fs(sVerRelease_FS)
      idum=iflch(sVerRelease_FS,32)
      if(idum.ne.0) then
         nch = ichmv_ch(ibuf,nch,'-')
         nch = ichmv(ibuf,nch,sVerRelease_FS,1,idum)
      endif
      nch = nch-1
      call logit3(ibuf,nch,lsor)
C
C   add OS info to log
C
      call log_uname
C
C   fortran info
C
      nch = 1
      nch=ichmv_ch(ibuf,nch,'fortran')
      nch=mcoma(ibuf,nch)
      call fs_get_fortran(fortran)
      idum=iflch(fortran,32)
      if(idum.ne.0) then
         nch = ichmv(ibuf,nch,fortran,1,idum)
      endif
      nch = nch-1
      call logit3(ibuf,nch,lsor)
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
      else if(rack.eq.VLBA4.and.rack_type.eq.VLBA4C) then
        nch=ichmv_ch(ib,nch,'vlbac')
      else if(rack.eq.VLBA4.and.rack_type.eq.VLBA4CDAS) then
        nch=ichmv_ch(ib,nch,'cdas')
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
      else if(rack.eq.DBBC.and.rack_type.eq.DBBC_DDC) then
        nch=ichmv_ch(ib,nch,'dbbc_ddc')
      else if(rack.eq.DBBC.and.rack_type.eq.DBBC_DDC_FILA10G) then
        nch=ichmv_ch(ib,nch,'dbbc_ddc/fila10g')
      else if(rack.eq.DBBC.and.rack_type.eq.DBBC_PFB) then
        nch=ichmv_ch(ib,nch,'dbbc_pfb')
      else if(rack.eq.DBBC.and.rack_type.eq.DBBC_PFB_FILA10G) then
        nch=ichmv_ch(ib,nch,'dbbc_pfb/fila10g')
      else if(rack.eq.DBBC3.and.rack_type.eq.DBBC3_DDCU) then
        nch=ichmv_ch(ib,nch,'dbbc3_ddc_u')
      else if(rack.eq.DBBC3.and.rack_type.eq.DBBC3_DDCV) then
        nch=ichmv_ch(ib,nch,'dbbc3_ddc_v')
      else if(rack.eq.DBBC3.and.rack_type.eq.DBBC3_DDCE) then
        nch=ichmv_ch(ib,nch,'dbbc3_ddc_e')
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
      else if(drive(1).eq.MK5.and.drive_type(1).eq.FLEXBUFF) then
        nch=ichmv_ch(ib,nch,'flexbuff')
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
      call logit3(ib,nch-1,lsor)
c
      nch = ichmv_ch(ib,1,'equip2,')
c
c
      call fs_get_freqif3(freqif3)
      nch=nch+ib2as(freqif3/100,ib,nch,zcp8000+10)
c
      nch=ichmv_ch(ib,nch,'.')
      nch=nch+ib2as(mod(freqif3,100),ib,nch,zcpC100+2)
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
      nch=nch+ib2as(ihwid,ib,nch,zcp8005)
c
      nch=mcoma(ib,nch)
      call fs_get_i70kch(i70kch)
      nch = nch + ib2as(i70kch,ib,nch,zcp8005)
c
      nch=mcoma(ib,nch)
      call fs_get_i20kch(i20kch)
      nch = nch + ib2as(i20kch,ib,nch,zcp8005)
c
      nch=mcoma(ib,nch)
      if(pcalcntrl.eq.3) then
         nch=ichmv_ch(ib,nch,"if3")
      else
         nch=ichmv_ch(ib,nch,"none")
      endif

      nch=mcoma(ib,nch)
      call fs_get_imk4fmv(imk4fmv)
      nch = nch + ib2as(imk4fmv,ib,nch,zcp8005)

      nch=mcoma(ib,nch)
      call fs_get_ndas(ndas)
      nch = nch + ib2as(ndas,ib,nch,zcp8002)

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
         nch = nch + ib2as(wx_met,ib,nch,zcp8005)
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
         nch = nch + ib2as(mk4sync_dflt,ib,nch,zcp8002)
      endif

      nch=mcoma(ib,nch)
      if(mk4dec_fs.eq.13) then
         nch=ichmv_ch(ib,nch,'return')
      else if(mk4dec_fs.eq.ichar('$')) then
         nch=ichmv_ch(ib,nch,'$')
      else if(mk4dec_fs.eq.ichar('%')) then
         nch=ichmv_ch(ib,nch,'%')
      endif
      call logit3(ib,nch-1,lsor)
c
      nch = ichmv_ch(ib,1,'equip3,')
c
      nch=ichmv_ch(ib,nch,'v')
      call fs_get_dbbcddcvs(dbbcddcvs)
      call fs_get_dbbcddcvc(dbbcddcvc)
      call char2hol(dbbcddcvs,ib,nch,nch+dbbcddcvc-1)
      nch=nch+dbbcddcvc
c
      nch=mcoma(ib,nch)
      nch=ichmv_ch(ib,nch,'v')
      call fs_get_dbbcpfbvs(dbbcpfbvs)
      call fs_get_dbbcpfbvc(dbbcpfbvc)
      call char2hol(dbbcpfbvs,ib,nch,nch+dbbcpfbvc-1)
      nch=nch+dbbcpfbvc
c
      call fs_get_dbbc_cond_mods(dbbc_cond_mods)
      call fs_get_dbbc_como_cores(dbbc_como_cores)
      call fs_get_dbbc_cores(dbbc_cores)
      do i=1,dbbc_cond_mods
         nch=mcoma(ib,nch)
         nch = nch + ib2as(dbbc_como_cores(i),ib,nch,zcp8002)
      enddo

      call fs_get_dbbc_if_factors(dbbc_if_factors)
      do i=1,dbbc_cond_mods
         nch=mcoma(ib,nch)
         nch = nch + ib2as(dbbc_if_factors(i),ib,nch,zcp8005)
      enddo
c
      nch=mcoma(ib,nch)
      call fs_get_m5b_crate(m5b_crate)
      nch = nch + ib2as(m5b_crate,ib,nch,zcp8003)
c
      nch=mcoma(ib,nch)
      call fs_get_fila10gvsi_in(fila10gvsi_in)
      ilast=index(fila10gvsi_in,' ')
      if(ilast.eq.0) ilast=len(fila10gvsi_in)
      call char2hol(fila10gvsi_in,ib,nch,nch+ilast-1)
      nch=nch+ilast-1
c
      call logit3(ib,nch-1,lsor)
c
      if(rack.eq.DBBC3) then
          nch = ichmv_ch(ib,1,'dbbc3,')
c
          call fs_get_dbbc3_ddc_bbcs_per_if(dbbc3_ddc_bbcs_per_if)
          nch = nch + ib2as(dbbc3_ddc_bbcs_per_if,ib,nch,zcp8002)
c
          nch=mcoma(ib,nch)
          call fs_get_dbbc3_ddc_ifs(dbbc3_ddc_ifs)
          nch = nch + ib2as(dbbc3_ddc_ifs,ib,nch,zcp8002)
c
          nch=mcoma(ib,nch)
          nch=ichmv_ch(ib,nch,'v')
          call fs_get_dbbc3_ddce_vs(dbbc3_ddce_vs)
          call fs_get_dbbc3_ddce_vc(dbbc3_ddce_vc)
          call char2hol(dbbc3_ddce_vs,ib,nch,nch+dbbc3_ddce_vc-1)
          nch=nch+dbbc3_ddce_vc
c
          nch=mcoma(ib,nch)
          nch=ichmv_ch(ib,nch,'v')
          call fs_get_dbbc3_ddcu_vs(dbbc3_ddcu_vs)
          call fs_get_dbbc3_ddcu_vc(dbbc3_ddcu_vc)
          call char2hol(dbbc3_ddcu_vs,ib,nch,nch+dbbc3_ddcu_vc-1)
          nch=nch+dbbc3_ddcu_vc
c
          nch=mcoma(ib,nch)
          nch=ichmv_ch(ib,nch,'v')
          call fs_get_dbbc3_ddcv_vs(dbbc3_ddcv_vs)
          call fs_get_dbbc3_ddcv_vc(dbbc3_ddcv_vc)
          call char2hol(dbbc3_ddcv_vs,ib,nch,nch+dbbc3_ddcv_vc-1)
          nch=nch+dbbc3_ddcv_vc
c
          nch=mcoma(ib,nch)
          call fs_get_dbbc3_mcdelay(dbbc3_mcdelay)
          nch = nch + ib2as(dbbc3_mcdelay,ib,nch,zcp8002)
c
          nch=mcoma(ib,nch)
          call fs_get_dbbc3_iscboard(dbbc3_iscboard)
          nch = nch + ib2as(dbbc3_iscboard,ib,nch,zcp8002)
c
          nch=mcoma(ib,nch)
          call fs_get_dbbc3_clockr(dbbc3_clockr)
          nch = nch + ib2as(dbbc3_clockr,ib,nch,zcp8004)

          call logit3(ib,nch-1,lsor)
      endif
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
C
      if(rack.eq.RDBE) then
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
      nch = nch + ib2as(iapdflg,ib,nch,zcp8005)
      call logit3(ib,nch-1,lsor)
c
      nch = 1
      nch = ichmv_ch(ib,nch,'fsserver,')
      call getenv('FS_DISPLAY_SERVER', display_server_envar)
      if (display_server_envar .eq. "off") then
          nch = ichmv_ch(ib,nch,'disabled')
      else
          nch = ichmv_ch(ib,nch,'enabled')
      endif
      call logit3(ib,nch-1,lsor)

      call log_env_dbbc3

      return
      end


