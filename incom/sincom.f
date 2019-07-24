      subroutine sincom
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
C     INITIALIZE FIELD SYSTEM COMMON
C
      integer itsp(8)
      integer idcb(2)
      integer*4 ip(5)
      integer*2 lnamef(3),lnamer(3),lnamet(3),ibuf(50)
      integer ist(9),nchar(9),ibaud(7)
C  Local variables used in the 600 section.
      integer tierr,pierr
      logical kasct,kascp,kdesp,kdest
      double precision das2b
C  Functions
      integer ichcm_ch
C  End 600 variables
      character*80 ibc, model
      equivalence (ibc,ibuf)
      data lnamef,lnamer/2h(e,2hxp,2her,2h(r,2hxd,2hef/
      data lnamet/2h(t,2hed,2hef/
      data ibaud/110,300,600,1200,2400,4800,9600/
      data kasct,kascp,kdesp,kdest/4*.false./
      data itsp/0,3,7,15,30,60,120,240/
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920720  Added kpass4 and itapof4 initialization for Mark IV
C               tape passes
C  gag  920902  Changed code to use the include file dpi.i to access the
C               pi parameters declared there.
C  nrv  921020  Reading rxdef: check hex address before storing into
C               common arrays. Use hex address in vfac array, not n.
C               Add reading an offset value following the scale factor.
C  weh 930430   removed kpass4, itapof4, koff4, etc.
C
      ierrx = 0
      inext(1)=0
      inext(2)=0
      inext(3)=0
      call fs_set_inext(inext)
      lprc = 'none'
      call char2hol(lprc,ilprc,1,8)
      call fs_set_lprc(ilprc)
      lskd = 'none'
      call char2hol(lskd,ilskd,1,8)
      call fs_set_lskd(ilskd)
      lnewpr = ' '
      call char2hol(lnewpr,ilnewpr,1,8)
      call fs_set_lnewpr(ilnewpr)
      lnewsk = ' '
      call char2hol(lnewsk,ilnewsk,1,8)
      call fs_set_lnewsk(ilnewsk)
      do i=1,31
        tpzero(i)=0
        tpsor(i)=0
        tpspc(i)=0
      enddo
      do i=1,32
        systmp(i)= 0.0
      enddo
      call fs_set_systmp(systmp)
      ipcflg=0
      itrkpa(1)=0
      itrkpa(2)=0
      ierr = 0
      pethr =600.0
      isethr = 12
      xoff=0.0
      call fs_set_xoff(xoff)
      yoff=0.0
      call fs_set_yoff(yoff)
      azoff=0.0
      call fs_set_azoff(azoff)
      eloff=0.0
      call fs_set_eloff(eloff)
      raoff=0.0
      call fs_set_raoff(raoff)
      decoff=0.0
      call fs_set_decoff(decoff)
      do i=1,21
        icheck(i)=0
        call fs_set_icheck(icheck(i),i)
      enddo
      do i=1,18
        ichvlba(i)=0
        call fs_set_ichvlba(ichvlba(i),i)
      enddo
      iadcrx =  0
      lswcal = 0
      ldv1nf = 0
      ldevfp = 0
      do i=1,2
        fastfw(i)=0.
        slowfw(i)=0.
        fastrv(i)=0.
        slowrv(i)=0.
        foroff(i)=0.
        revoff(i)=0.
        pslope(i)=0.
        rslope(i)=0.
        posnhd(i)=0.
        ipashd(i)=0
      enddo
      call fs_set_ipashd(ipashd)
      i70kch=0
      i20kch=0
      nrx_fs=0
      do i=1,maxnrx_fs
        tmpk_fs(i) = 0.0
        pvolt_fs(i) = 0.0
      end do
      tierr = 0
      pierr = 0
c
c station check arrays
c
      call char2hol(' ',stcnm(1,1),1,2)
      call fs_set_stcnm(stcnm(1,1),1)
      call char2hol(' ',stcnm(1,2),1,2)
      call fs_set_stcnm(stcnm(1,2),2)
      call char2hol(' ',stcnm(1,3),1,2)
      call fs_set_stcnm(stcnm(1,3),3)
      call char2hol(' ',stcnm(1,4),1,2)
      call fs_set_stcnm(stcnm(1,4),4)
c
      stchk(1)=0
      call fs_set_stchk(stchk(1),1)
      stchk(2)=0
      call fs_set_stchk(stchk(2),1)
      stchk(3)=0
      call fs_set_stchk(stchk(3),1)
      stchk(4)=0
      call fs_set_stchk(stchk(4),1)
C
C     2. Now initialize everything which is non-zero.
C
      do i=1,MAX_HOR
        horaz(i) = -1.0
        horel(i) = -1.0
      enddo
      fsver = 8.18
C                   Initialize the time-like variables
C                   Initialize previous segment name for LINKP
      do i=1,15
        idummy = ichmv(lfreqv(1,i),1,6h000.00,1,6)
      enddo
      call fs_set_lfreqv(lfreqv)
      iratfm = 0
      call fs_set_iratfm(iratfm)
      imodfm = 1
      call fs_set_imodfm(imodfm)
      imoddc = 4
      ispeed = 0
      call fs_set_ispeed(ispeed)
      idirtp = -1
      call fs_set_idirtp(idirtp)
      idummy = ichmv(lgen,1,3H000,1,3)
      call fs_set_lgen(lgen)
      ilowtp = 1
      ibyp=1
      lexper = ' '
      call char2hol(lexper,ilexper,1,8)
      call fs_set_lexper(ilexper)
      call char2hol('00000000',ltrken(1),1,8)
      call char2hol('00000000',ltpnum(1),1,8)
      call char2hol(' ',lsorna(1),1,10)
      call fs_set_lsorna(lsorna)
      call char2hol('0000',ltpchk(1),1,4)
      call char2hol('test/reset',ltsrs,1,10)
      ilents = 10
      call char2hol('alarm',lalrm,1,6)
      ilenal = 5
      kecho = .false.
      call fs_set_kecho(kecho)
      kcheck = .false.
      khalt = .false.
      call fs_set_khalt(khalt)
      ichvkrepro=.false.
      call fs_set_ichvkrepro(ichvkrepro)
      ichvkenable=.false.
      call fs_set_ichvkenable(ichvkenable)
      ichvkmove=.false.
      call fs_set_ichvkmove(ichvkmove)
      ichvklowtape=.false.
      call fs_set_ichvklowtape(ichvklowtape)
      imonds = -1
      ichper = 0
      tperer = 0.5
      insper = 2
      azhmwv(1) = 0.0
      azhmwv(2) = 360.0
      elhmwv(1) = 15.0
      nhorwv = 1
      iacftp = 80
      iacttp = 10
C     First mode A
      do i=1,14
        itr2vc(i,1) = i
        itr2vc(i+14,1) = -i
      enddo
C     Mode B
      do i=1,14,2
        itr2vc(i,2) = i
        itr2vc(i+14,2) = -i
        itr2vc(i+1,2) = i
        itr2vc(i+15,2) = -i
      enddo
C     Mode C
      do i=1,14,2
        itr2vc(i+1,3) = i+1
        itr2vc(i+15,3) = i
        itr2vc(i,3) = i+1
        itr2vc(i+14,3) = i
      enddo
C     Finally, mode D
      do i=1,28
        itr2vc(i,4) = 1
      enddo
      ncycpc = 0
      ipaupc = 60
      ireppc = 0
      ibyppc = 1
      nblkpc = 25
      ibugpc = 0
      do i=1,28
        itrkpc(i) = 101 
      enddo
      ndevlog = 1
      call fs_set_ndevlog(ndevlog)
      call char2hol('/dev/tty',idevlog(1,1),1,64)
      call fs_set_idevlog(idevlog)
      idummy = ichmv(loccup,1,8hoccup##!,1,8)
      idchrx = 1
      ibxhrx = 1
      ifamrx(1) = 1
      ifamrx(2) = 1
      ifamrx(3) = 1
      do i=1,100
        itapof(i)= -13000
      enddo
C
      lauxfm(1)=0
      lauxfm(2)=0
      lauxfm(3)=0
      lauxfm(4)=0
      lauxfm(5)=0
      lauxfm(6)=0
      lauxfm4(1)=0
      lauxfm4(2)=0
      lauxfm4(3)=0
      lauxfm4(4)=0
C
      klvdt_fs=.false.
      ihdpk_fs=0
      iterpk_fs=0
      nsamppk_fs=0
      vltpk_fs=0.0
      kvrevw_fs=.false.
      kv15rev_fs=.false.
      kv15for_fs=.false.
      kv15scale_fs=.false.
      kv13_fs=.false.
      kv15flip_fs=.false.
      rvrevw_fs=0.0
      rv15rev_fs=0.0
      rv15for_fs=0.0
      rv15scale_fs=0.0
      rv13_fs=0.0
      rv15flip_fs=0.0
      ksread_fs=.false.
      kswrite_fs=.false.
      ksdread_fs=.false.
      ksdwrite_fs=.false.
      kbdwrite_fs=.false.
      kbdread_fs=.false.
      rsread_fs=0.0
      rswrite_fs=0.0
      rsdread_fs=0.0
      rsdwrite_fs=0.0
      rbdwrite_fs=0.0
      rbdread_fs=0.0
      khecho_fs=.false.
      ihdlc_fs=0
      steplc_fs=0
      nsamplc_fs=0
      rnglc_fs=0.0
      ihdwo_fs=0
      fowo_fs(1)=-1.
      fowo_fs(2)=-1.
      sowo_fs(1)=-1.
      sowo_fs(2)=-1.
      fiwo_fs(1)=-1.
      fiwo_fs(2)=-1.
      siwo_fs(1)=-1.
      siwo_fs(2)=-1.
      kvw0_fs=.false.
      kvw8_fs=.false.
      rvw0_fs=0.0
      rvw8_fs=0.0
      kpeakv_fs=.false.
      wrhd_fs=-1
      rdhd_fs=-1
      rpro_fs=-1
      rpdt_fs=-1
      kadapt_fs=.false.
      kenastk(1)=.false.
      kenastk(2)=.false.
      call fs_set_kena(kenastk)
      kiwslw_fs=.false.
      lvbosc_fs=5.0
      ilvtl_fs=0
      vminpk_fs=.2
      lmtn_fs(1)=+11.0
      lmtn_fs(2)=+11.0
      lmtp_fs(1)=-11.0
      lmtp_fs(2)=-11.0
      iclwo_fs=0
      iwrcl_fs=-1
      irdcl_fs=-1
      krdwo_fs=.false.
      kwrwo_fs=.false.
      kposhd_fs(1)=.false.
      kposhd_fs(2)=.false.
      koffhd_fs=.true.
      idecpa_fs=0
      kdoaux_fs=.true.
      ierrdc_fs=1
      krptp_fs=.false.
      kmvtp_fs=.false.
      kentp_fs=.false.
C
      iadcst = 0
      idcalst = 1
      ilohst = 1
      ibxhst = 1
      ifamst(1) = 1
      ifamst(2) = 1
      ifamst(3) = 1
C
      call fs_set_freqlo(0.0,0)
      call fs_set_freqlo(0.0,1)
      call fs_set_freqlo(0.0,2)
      call fs_set_freqlo(0.0,3)
      call fs_set_frequp(0.0,0)
      call fs_set_frequp(0.0,1)
      call fs_set_frequp(0.0,2)
      call fs_set_frequp(0.0,3)
C
      llog='station '
      call char2hol(llog,illog,1,8)
      call fs_set_llog(illog) 
  
      call char2hol('      ',lfeet_fs(1),1,6)
      call fs_set_lfeet_fs(lfeet_fs)
c
      do i=1,4
        iswif3_fs(i)=1
      enddo
C
C  3. Open the file which contains the station-dependent
C     information: LOCATION.CTL
C
      call fmpopen
     &  (idcb,FS_ROOT//'/control/location.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-117,2hbo,ierr)
        goto 990
      endif
C
C  3.1 Read and decode the first line.  Station information.
C
C LINE #1  STATION NAME
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      n = ic2-ic1+1
      if (n.gt.8) then
        call logit7(0,0,0,1,-119,2hbo,1)
        ierrx = -1
      endif
      call ifill_ch(lnaant,1,8,' ')
      idummy = ichmv(lnaant,1,ibuf,ic1,min0(8,n))
      call fs_set_lnaant(lnaant)
C LINE #2  WEST LONGITUDE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      wlong = das2b(ibuf,ic1,ic2-ic1+1,ierr)*DPI/180.0D0
      call fs_set_wlong(wlong)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-119,2hbo,2)
        ierrx = ierr
      endif
C LINE #3  LATITUDE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      alat = das2b(ibuf,ic1,ic2-ic1+1,ierr)*DPI/180.0D0
      call fs_set_alat(alat)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-119,2hbo,3)
        ierrx = ierr
      endif
C LINE #4  STATION ELEVATION
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 312
      height = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      call fs_set_height(height)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-119,2hbo,4)
        ierrx = ierr
      endif
C LINE #5  OCCUPATION CODE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 312
      n = ic2-ic1+1
      idummy = ichmv(loccup,1,ibuf,ic1,min0(8,n))
      if (n.gt.8) then
        call logit7(0,0,0,1,-119,2hbo,5)
        ierrx = -1
      endif
C LINE #6  STATION ID
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 312
      call char2hol('  ',lidstn,1,2)
      idummy = ichmv(lidstn,1,ibuf,ic1,1)
C LINE #7  NEAREST PAST DECADE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      if (ilen.lt.0) goto 312
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      nch = ic2-ic1+1
      if (nch.ne.4) then
        call logit7(0,0,0,1,-172,2hbo,nch)
        ierrx = -1
        goto 990
      end if
      if (ic1.ne.0) iyrctl_fs = ias2b(ibuf,ic1,ic2-ic1+1)
      if (mod(iyrctl_fs,10).ne.0) then
        call logit7(0,0,0,1,-173,2hbo,iyrctl_fs)
        ierrx = -1
        goto 990
      endif
C LINE #8  HORIZON MASK
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      if (ilen.lt.0) goto 312
      ich = 1
      do i=1,MAX_HOR
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 315
        iaz = ias2b(ibuf,ic1,ic2-ic1+1)
        horaz(i) = iaz
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 315
        horel(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      enddo
315   if (iaz.lt.360) goto 900
      call fs_set_horaz(horaz)
      call fs_set_horel(horel)
C
312   continue
      call fmpclose(idcb,ierr)
C
C 3.12 Open the file with the equipment information.
C
      call fmpopen
     &  (idcb,FS_ROOT//'/control/equip.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-139,2hbo,ierr)
        goto 990
      endif
C LINE #1 TAPE STARTUP PARAMETER (TACC) - iacttp
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      iacttp = ias2b(ibuf,ic1,ic2-ic1+1)
      if (iacttp.lt.0) then
        call logit7(0,0,0,1,-140,2hbo,1)
        ierrx = -1
      endif
      call fs_set_iacttp(iacttp)
C LINE #2 MAX TAPE SPEED - imaxtpsd
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      imaxtpsd = ias2b(ibuf,ic1,ic2-ic1+1)
      if (imaxtpsd.eq.360) then
        index = -2
        goto 3002
      endif
      if (imaxtpsd.eq.330) then
        index = -1
        goto 3002
      endif
      if (imaxtpsd.eq.270) then
        index = 7
        goto 3002
      endif
      do i=1,8
        if (imaxtpsd.eq.itsp(i)) then
          index=i-1
          goto 3002
        endif
      enddo
        call logit7(0,0,0,1,-140,2hbo,2) ! invalid speed given
        ierrx = -1
3002  continue
      imaxtpsd = index ! invalid speed given
      call fs_set_imaxtpsd(imaxtpsd)
C LINE #3 SCHEDULE TAPE SPEED - iskdtpsd
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      iskdtpsd = ias2b(ibuf,ic1,ic2-ic1+1)
      if (iskdtpsd.eq.360) then
        index = -2
        goto 3003
      endif
      if (iskdtpsd.eq.330) then
        index = -1
        goto 3003
      endif
      if (iskdtpsd.eq.270) then
        index = 7
        goto 3003
      endif
      do i=1,8
        if (iskdtpsd.eq.itsp(i)) then
          index=i-1
          goto 3003
        endif
      enddo
        call logit7(0,0,0,1,-140,2hbo,3) ! invalid speed given
        ierrx = -1
3003  continue
      iskdtpsd = index 
      call fs_set_iskdtpsd(iskdtpsd)
C LINE #4 RF FREQUENCY - refreq
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      refreq = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,4)
        ierrx = ierr
      endif
      call fs_set_refreq(refreq)
C LINE #5 RECEIVER 70K STAGE CHECK TEMPERATURE - i70kch
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      if (ilen.lt.0) goto 320
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.ne.0) i70kch = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0.or.ic1.eq.0) then
        call logit7(0,0,0,1,-140,2hbo,5)
        ierrx = -1
        go to 990
      endif
      call fs_set_i70kch(i70kch)
C LINE #6 RECEIVER 20K STAGE CHECK TEMPERATURE - i20kch
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      if (ilen.lt.0) goto 320
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.ne.0) i20kch = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0.or.ic1.eq.0) then
        call logit7(0,0,0,1,-140,2hbo,6)
        ierrx = -1
        go to 990
      endif
      call fs_set_i20kch(i20kch)
C LINE #7  TYPE OF RACK - rack
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      if (ichcm_ch(ibuf,ic1,'mk3').eq.0) then
        rack = MK3
      else if (ichcm_ch(ibuf,ic1,'vlba').eq.0) then
        rack = VLBA
      else if (ichcm_ch(ibuf,ic1,'mk4').eq.0) then
        rack = MK4
      else
        call logit7(0,0,0,1,-140,2Hbo,7)
        ierrx = -1
        goto 990
      endif
      call fs_set_rack(rack)
C LINE #8  TYPE OF RECORDER - drive
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      if (ichcm_ch(ibuf,ic1,'mk3').eq.0) then
        drive = MK3
      else if (ichcm_ch(ibuf,ic1,'vlba').eq.0) then
        drive = VLBA
      else if (ichcm_ch(ibuf,ic1,'mk4').eq.0) then
        drive = MK4
      else
        call logit7(0,0,0,1,-140,2Hbo,8)
        ierrx = -1
        goto 990
      endif
      call fs_set_drive(drive)
C LINE #9 HARDWARE ID - hwid
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      hwid = ias2b(ibuf,ic1,ic2-ic1+1)
      if (hwid.le.100 .or. hwid.ge.255) then
        call logit7(0,0,0,1,-140,2hbo,9)
        ierrx = -1
      endif
      call fs_set_hwid(hwid)
C LINE #10 VACUUM MOTOR VOLTAGE - motorv
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      motorv = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,10)
        ierrx = ierr
      endif
      call fs_set_motorv(motorv)
C LINE #11 VACUUM SCALE INTERCEPT - inscint
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      inscint = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,11)
        ierrx = ierr
      endif
      call fs_set_inscint(inscint)
C LINE #12 VACUUM SCALE SLOPE - inscsl
      call readg(idcb,ierr,ibuf,ilen) 
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      inscsl = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,12)
        ierrx = ierr
      endif
      call fs_set_inscsl(inscsl)
C LINE #13 VACUUM SCALE INTERCEPT - outscint
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      outscint = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,13)
        ierrx = ierr
      endif
      call fs_set_outscint(outscint)
C LINE #14 VACUUM SCALE SLOPE - outscsl 
      call readg(idcb,ierr,ibuf,ilen) 
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      outscsl = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,14)
        ierrx = ierr
      endif
      call fs_set_outscsl(outscsl)
C LINE #15  TAPE THICKNESS - itpthick
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      itpthick = ias2b(ibuf,ic1,ic2-ic1+1)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,15)
        ierrx = ierr
      endif
      call fs_set_itpthick(itpthick)
C LINE #16 HEAD WRITE VOLTAGE - wrvolt
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      wrvolt = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,16)
        ierrx = ierr
      endif
      call fs_set_wrvolt(wrvolt)
C LINE #17  CAPSTAN SIZE - capstan
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      capstan = ias2b(ibuf,ic1,ic2-ic1+1)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-140,2hbo,17)
        ierrx = ierr
      endif
      call fs_set_capstan(capstan)
C LINE #18  if3 lo freq.
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      idec=iscn_ch(ibuf,ic1,ic2-ic1+1,'.')
      ifrqu=-1
      ifrqd=-1
      if(idec.gt.ic1) then
        ifrqu=ias2b(ibuf,ic1,idec-ic1)
        if(ic2-idec.eq.0) then
          ifrqd=0
        else if(ic2-idec.lt.3) then
          ifrqd=ias2b(ibuf,idec+1,ic2-idec)
        endif
      endif
      freqif3_fs=ifrqu
      freqif3_fs=100*freqif3_fs+ifrqd
      if (ifrqu.lt.0.or.ifrqd.lt.0.or.
     &    freqif3_fs.lt.50000.or.freqif3_fs.gt.100000) then
        call logit7(0,0,0,1,-140,2hbo,18)
        ierrx = ierr
      endif
C LINE #19  if3 switches
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 320
      iswavif3_fs=ia2hx(ibuf,ic1)
      if (ic2-ic1.ne.0.or.iswavif3_fs.lt.0) then
        call logit7(0,0,0,1,-140,2hbo,19)
        ierrx = ierr
      endif
C
320   continue
      call fmpclose(idcb,ierr)
C
C 3.2 Open the file with device LU information.
C
      call fmpopen(idcb,FS_ROOT//'/control/dev.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-120,2hbo,ierr)
        goto 990
      endif
C  GPIB CONFIGURATION FILE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      call char2hol(' ',idevgpib,1,64)
      idummy = ichmv(idevgpib,1,ibuf,ic1,ic2-ic1+1) ! GPIB device name
      call fs_set_idevgpib(idevgpib)
C  MAT DEVICE NAME
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      call char2hol(' ',idevmat,1,64)
      idummy = ichmv(idevmat,1,ibuf,ic1,ic2-ic1+1) ! MAT device name
C  MAT BAUD RATE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      ibmat = ias2b(ibuf,ic1,ic2-ic1+1)           ! baud rate for MAT
      call fs_set_ibmat(ibmat)
      if (ibmat.eq.-32768) then
        call logit7(0,0,0,1,-122,2hbo,3)
        ierrx = -1
      endif
      ibx = -1
      do i=1,7
        if (ibmat.eq.ibaud(i)) ibx = i
      enddo
C                   Check that a legal value was specified
      if (ibx.le.0) then
        call logit7(0,0,0,1,-122,2hbo,3)
        ierrx = -1
      endif
C  DATA BUFFER DEVICE NAME
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      call char2hol(' ',idevdb,1,64)
      idummy = ichmv(idevdb,1,ibuf,ic1,ic2-ic1+1) ! DB device name
C  DATA BUFFER BAUD RATE 
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      ibdb = ias2b(ibuf,ic1,ic2-ic1+1)        ! data buffer baud rate
      if (ibdb.eq.-32768) then
        call logit7(0,0,0,1,-122,2hbo,5)
        ierrx = -1
      endif
      ibx = -1
      do i=1,7
        if (ibdb .eq.ibaud(i)) ibx = i
      enddo
C                   Check that a legal value was specified
      if (ibx.le.0) then
        call logit7(0,0,0,1,-122,2hbo,7)
        ierrx = -1
      endif
C  ANTENNA DEVICE NAME
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      call char2hol(' ',idevant,1,64)
      idummy = ichmv(idevant,1,ibuf,ic1,ic2-ic1+1) ! antenna device name
      call fs_set_idevant(idevant)
C  BARCODE READER DEVICE NAME
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      call char2hol(' ',idevwand,1,64)
      idummy = ichmv(idevwand,1,ibuf,ic1,ic2-ic1+1) ! barcode reader device name
C  MCB DEVICE NAME
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      call char2hol(' ',idevmcb,1,64)
      idummy = ichmv(idevmcb,1,ibuf,ic1,ic2-ic1+1) ! mcb device name
      call fs_set_idevmcb(idevmcb)
C  MCB BAUD RATE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 910
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      ibmcb = ias2b(ibuf,ic1,ic2-ic1+1)      ! baud rate for MCB
      call fs_set_ibmcb(ibmcb)
      if (ibmcb.eq.-32768) then
        call logit7(0,0,0,1,-122,2hbo,9)
        ierrx = -1
      endif
      ibx = -1
      do i=1,7
        if (ibmcb.eq.ibaud(i)) ibx = i
      enddo
C                   Check that a legal value was specified
      if (ibx.le.0) then
        call logit7(0,0,0,1,-122,2hbo,9)
        ierrx = -1
      endif

C
      call fmpclose(idcb,ierr)
C
C 3.3 Open the file with tape head positioner information
C
330   continue
      call fmpopen(idcb,FS_ROOT//'/control/head.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-151,2hbo,ierr)
        goto 990
      endif
      call readg(idcb,ierr,ibuf,ilen)
      if(ierr.lt.0) goto 920
      ich=1
      do i=1,4
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if(ic1.eq.0) goto 340
        idum=-1
        if(ichcm(ibuf,ic1,4hall   ,1,3).eq.0) idum=0
        if(ichcm(ibuf,ic1,4hodd   ,1,3).eq.0) idum=1
        if(ichcm(ibuf,ic1,6heven  ,1,4).eq.0) idum=2
        if(idum.lt.0.or.(idum.eq.0.and.i.eq.4)) then
          call logit7(0,0,0,1,-153,2hbo,1)
          ierrx=-1
        endif
        if(i.eq.1) wrhd_fs=idum
        if(i.eq.2) rdhd_fs=idum
        if(i.eq.3) rpro_fs=idum
        if(i.eq.4) rpdt_fs=idum
      enddo
C
C INCHWORM PARAMETERS
C
      call readg(idcb,ierr,ibuf,ilen)
      if(ierr.lt.0) goto 920
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if(ic1.eq.0) goto 340
      if(ichcm(ibuf,ic1,8hadaptive,1,8).eq.0) then
        kadapt_fs=.true.
      else if(ichcm(ibuf,ic1,6hfixed ,1,5).eq.0) then
        kadapt_fs=.false.
      else
        call logit7(0,0,0,1,-153,2hbo,2)
        ierrx=-1
      endif
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if(ic1.eq.0) goto 340
      if(ichcm(ibuf,ic1,4hyes     ,1,3).eq.0) then
        kiwslw_fs=.true.
      else if(ichcm(ibuf,ic1,2hno ,1,2).eq.0) then
        kiwslw_fs=.false.
      else
        call logit7(0,0,0,1,-153,2hbo,2)
        ierrx=-1
      endif
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 340
      lvbosc_fs = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 340
      ilvtl_fs = ias2b(ibuf,ic1,ic2-ic1+1)
      if(ilvtl_fs.lt.0.or.ilvtl_fs.gt.4097) then
        call logit7(0,0,0,1,-153,2hbo,2)
        ierrx=-1
      endif
C
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        fastfw(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,3)
          ierrx = -1
        endif
      enddo
C
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        slowfw(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,4)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        foroff(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,5)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        fastrv(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,6)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        slowrv(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,7)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        revoff(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,8)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        pslope(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,9)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 920
      ich=1
      do i=1,2
        call gtfld(ibuf,ich,ilen,ic1,ic2)
        if (ic1.eq.0) goto 340
        rslope(i) = das2b(ibuf,ic1,ic2-ic1+1,ierr)
        if (ierr.ne.0) then
          call logit7(0,0,0,1,-153,2hbo,9)
          ierrx = ierr
        endif
      enddo
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-152,2hbo,ierr)
        goto 990
      endif
C
340   continue
      call fmpclose(idcb,ierr)
C
C
C  3.4 Open the file with antenna information
C
      call fmpopen(idcb,FS_ROOT//'/control/antenna.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-154,2hbo,ierr)
        goto 990
      endif
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      diaman = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,1)
        ierrx = ierr
      endif
      call fs_set_diaman(diaman)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      slew1 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,2)
        ierrx = ierr
      endif
      call fs_set_slew1(slew1)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      slew2 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,3)
        ierrx = ierr
      endif
      call fs_set_slew2(slew2)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      lolim1 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,4)
        ierrx = ierr
      endif
      call fs_set_lolim1(lolim1)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      uplim1 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,5)
        ierrx = ierr
      endif
      call fs_set_uplim1(uplim1)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      lolim2 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,6)
        ierrx = ierr
      endif
      call fs_set_lolim2(lolim2)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      uplim2 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7(0,0,0,1,-156,2hbo,7)
        ierrx = ierr
      endif
      call fs_set_uplim2(uplim2)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 400
      idummy = ichmv(iaxis,1,ibuf,ic1,ic2-ic1+1)
      call fmpclose(idcb,ierr)
C
C  4. Read file of RX monitor points and scale factors: RXDEF.CTL
C
400   continue
      call fmpopen(idcb,FS_ROOT//'/control/rxdef.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-143,2hbo,ierr)
        goto 990
      endif
C
C     4.1 Read and decode each line.
C
      rxncodes=0
      do n=1,MAX_RXCODES
        call readg(idcb,ierr,ibuf,ilen)
        if (ierr.lt.0) then
          call logit7(0,0,0,1,-144,2hbo,n)
          goto 990
        endif
        if (ilen.gt.0) then
          ifc = 1
          call gtfld(ibuf,ifc,ilen,ic1,ic2)
          iad = ia2hx(ibuf,ic1)
          iad = iad*16 + ia2hx(ibuf,ic1+1)+1
          if (iad.le.MAX_RXCODES) then
            call gtfld(ibuf,ifc,ilen,ic1,ic2)
            idummy = ichmv(rxlcode(1,iad),1,ibuf,ic1,6)
            call gtfld(ibuf,ifc,ilen,ic1,ic2)
            call gtprm(ibuf,ic1,ic2,2,rxvfac(iad),ierr)
            if (ierr.lt.0) then
              call logit7(0,0,0,1,-145,2hbo,n)
              goto 990
            endif
          else
            call logit7(0,0,0,1,-145,2hbo,n)
            goto 990
          endif
          rxncodes=rxncodes+1
        endif
      enddo
      call fmpclose(idcb,ierr)
C
C  5. Read file of parameters for spectrum analyzer test procedures: TEDEF.CTL
C
500   continue
      call fmpopen(idcb,FS_ROOT//'/control/tedef.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-146,2hbo,ierr)
        goto 990
      endif
C
C     5.1 Read and decode the first line.
C
      call readg(idcb,ierr,ibuf,ilen)
      ilen = iflch(ibuf,80)/2
      if (ierr.lt.0) then
        call logit7(0,0,0,0,-147,2hbo,1)
        goto 990
      endif
      ifc = 1
      do i=1,5
        call gtfld(ibuf,ifc,ilen*2,ist(i),ic2)
        nchar(i) = ic2 + 1 - ist(i)
        if (nchar(i).le.0 .or. ist(i).le.0) then
          call logit7(0,0,0,0,-148,2hbo,1)
          goto 990
        endif
      enddo
      modsa = ias2b(ibuf,ist(1),4)  ! read only 4 digits (or 35660 overflows)
      if (modsa.eq.-32767) then
        call logit7(0,0,0,0,-149,2hbo,1)
        goto 990
      endif
      amptol = das2b(ibuf,ist(2),nchar(2),ierr)
      ierrs = ierr
      gdytol = das2b(ibuf,ist(3),nchar(3),ierr)
      ierrs = ierrs + ierr
      diftol = das2b(ibuf,ist(4),nchar(4),ierr)
      ierrs = ierrs + ierr
      phatol = das2b(ibuf,ist(5),nchar(5),ierr)
      if (ierr.lt.0 .or. ierrs.lt.0) then
        call logit7(0,0,0,0,-150,2hbo,1)
        goto 990
      endif
C
C     5.2 Read and decode the second line.
C
      call readg(idcb,ierr,ibuf,ilen)
      ilen = iflch(ibuf,80)/2
      if (ierr.lt.0) then
        call logit7(0,0,0,0,-147,2hbo,2)
        goto 990
      endif
      ifc = 1
      do i=1,9
        call gtfld(ibuf,ifc,ilen*2,ist(i),ic2)
        nchar(i) = ic2 + 1 - ist(i)
        if (nchar(i).le.0 .or. ist(i).le.0) then
          call logit7(0,0,0,0,-148,2hbo,2)
          goto 990
        endif
      enddo
      nprset = ias2b(ibuf,ist(1),nchar(1))
      intpha = ias2b(ibuf,ist(2),nchar(2))
      intamp = ias2b(ibuf,ist(3),nchar(3))
      lvsens = ias2b(ibuf,ist(4),nchar(4))
      if (nprset.eq.-32768 .or. intpha.eq.-32768 .or.
     ^    intamp.eq.-32768 .or. lvsens.eq.-32768) then
        call logit7(0,0,0,0,-149,2hbo,2)
        goto 990
      endif
      son2hi = das2b(ibuf,ist(5),nchar(5),ierr)
      ierrs = ierr
      son2lo = das2b(ibuf,ist(6),nchar(6),ierr)
      ierrs = ierrs + ierr
      sof2hi = das2b(ibuf,ist(7),nchar(7),ierr)
      ierrs = ierrs + ierr
      cpkmin = das2b(ibuf,ist(8),nchar(8),ierr)
      ierrs = ierrs + ierr
      phjmax = das2b(ibuf,ist(9),nchar(9),ierr)
      if (ierr.lt.0 .or. ierrs.lt.0) then
        call logit7(0,0,0,0,-150,2hbo,2)
        goto 990
      endif
C
600   continue
      call fmpopen
     &   (idcb,FS_ROOT//'/control/rxdiode.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-160,2hbo,ierr)
        goto 990
      endif
C
C  6.1 Read and decode each line.
C
      ilen=0
      do while(ilen.ge.0)
        call readg(idcb,ierr,ibuf,ilen)
        if (ierr.lt.0) then
          call logit7(0,0,0,1,-161,2hbo,ierr)
          goto 990
        endif
        if (ilen.gt.0) then
          if (nrx_fs.eq.maxnrx_fs) then
            call logit7(0,0,0,1,-165,2hbo,maxnrx_fs)
            goto 990
          end if
          nrx_fs = nrx_fs + 1
          ifc = 1
          call gtfld(ibuf,ifc,ilen,ic1,ic2)
          call gtprm(ibuf,ic1,ic2,2,tmpk_fs(nrx_fs),ierr)
          if (ierr.lt.0) then
            call logit7(0,0,0,1,-162,2hbo,nrx_fs)
            goto 990
          endif
          call gtfld(ibuf,ifc,ilen,ic1,ic2)
          call gtprm(ibuf,ic1,ic2,2,pvolt_fs(nrx_fs),ierr)
          if (ierr.lt.0) then
            call logit7(0,0,0,1,-162,2hbo,nrx_fs)
            goto 990
          endif
C  Check if the values are either ascending or descending order for
C  each array.
          if (nrx_fs.ge.2) then
            if (tmpk_fs(nrx_fs).gt.tmpk_fs(nrx_fs-1)) then
              kasct=.true.
            else if (tmpk_fs(nrx_fs).lt.tmpk_fs(nrx_fs-1)) then
              kdest=.true.
            else
              tierr = -166
            endif
            if (pvolt_fs(nrx_fs).gt.pvolt_fs(nrx_fs-1)) then
              kascp=.true.
            else if (pvolt_fs(nrx_fs).lt.pvolt_fs(nrx_fs-1)) then
              kdesp=.true.
            else
              pierr = -167
            endif
          endif !(nrx_fs>=2)
        endif  !(ilen>0)
      enddo  !(ilen>0)
      if ((kasct).and.(kdest)) call logit7(0,0,0,0,-163,2hbo,0)
      if ((kascp).and.(kdesp)) call logit7(0,0,0,0,-164,2hbo,0)
      if (tierr.ne.0) call logit7(0,0,0,0,tierr,2hbo,0)
      if (pierr.ne.0) call logit7(0,0,0,0,pierr,2hbo,0)
      call fmpclose(idcb,ierr)
C
700   continue
      call fmpopen
     &   (idcb,FS_ROOT//'/control/time.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-180,2hbo,ierr)
        goto 990
      endif
C
C  7.1 Read and decode each line.
C
      ilen=0
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7(0,0,0,1,-189,2hbo,ierr)
        goto 990
      endif
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call gtprm(ibuf,ic1,ic2,2,rate,ierr)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-181,2hbo,0)
        goto 990
      endif
      rate0ti_fs=rate/86400.
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call gtprm(ibuf,ic1,ic2,2,span,ierr)
      if (ierr.lt.0) then
        call logit7(0,0,0,1,-182,2hbo,0)
        goto 990
      endif
      span0ti_fs=span*3600d2
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call hol2char(ibuf,ic1,ic2,model)
      if(model.ne.'none'.and.model.ne.'offset'.and.model.ne.'rate')
     &  then
        call logit7(0,0,0,1,-183,2hbo,0)
        goto 990
      endif
      call char2hol(model(1:1),model0ti_fs,1,2)
      call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &   rateti_fs,spanti_fs, modelti_fs)
      rateti_fs=rate0ti_fs
      spanti_fs=span0ti_fs
      modelti_fs=model0ti_fs
      call fs_set_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &   rateti_fs,spanti_fs, modelti_fs)
      call fmpclose(idcb,ierr)
      goto 990
C
C  This is the error return section
C
900   call logit7(0,0,0,1,-118,2hbo,ierr)
      goto 990
910   call logit7(0,0,0,1,-121,2hbo,ierr)
      goto 990
920   call logit7(0,0,0,1,-152,2hbo,ierr)
      goto 990
930   call logit7(0,0,0,1,-155,2hbo,ierr)
      goto 990
C
C
990   call fmpclose(idcb,ierr)
      ip(3) = -1
      end
