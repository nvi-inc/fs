      subroutine sincom(ip)
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
C     INITIALIZE FIELD SYSTEM COMMON
C
      integer idcb(2)
      integer*4 ip(5)
      integer*2 ibuf(50)
      integer ist(9),nchar(9),ibaud(7), ibauddb(8)
C  Local variables used in the 600 section.
      integer tierr,pierr
      logical kasct,kascp,kdesp,kdest
      double precision das2b
C  End 600 variables
      character*80 ibc, model
      equivalence (ibc,ibuf)
      data ibaud  /110,300,600,1200,2400,4800,9600/
      data ibauddb/110,300,600,1200,2400,4800,9600,115200/
      data kasct,kascp,kdesp,kdest/4*.false./

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
C  rdg 010529   sincom is called with (ip) parameters.
C
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
      itrkpa(1,1)=0
      itrkpa(2,1)=0
      itrkpa(1,2)=0
      itrkpa(2,2)=0
      ierr = 0
      pethr(1) =600.0
      pethr(2) =600.0
      isethr(1) = 12
      isethr(2) = 12
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
      do i=1,23
        icheck(i)=0
        call fs_set_icheck(icheck(i),i)
      enddo
      do i=1,19
        ichvlba(i)=0
        call fs_set_ichvlba(ichvlba(i),i)
      enddo
      iadcrx =  0
      lswcal = 0
      call char2hol(' ',laxfp,1,4)
      call char2hol(' ',ldevfp,1,2)
      call char2hol(' ',ldv1nf,1,2)
      call char2hol(' ',ldv2nf,1,2)
      do i=1,2
        fastfw(i,1)=0.
        fastfw(i,2)=0.
        slowfw(i,1)=0.
        slowfw(i,2)=0.
        fastrv(i,1)=0.
        fastrv(i,2)=0.
        slowrv(i,1)=0.
        slowrv(i,2)=0.
        foroff(i,1)=0.
        foroff(i,2)=0.
        revoff(i,1)=0.
        revoff(i,2)=0.
        pslope(i,1)=0.
        pslope(i,2)=0.
        rslope(i,1)=0.
        rslope(i,2)=0.
        posnhd(i,1)=-3999.
        posnhd(i,2)=-3999.
        ipashd(i,1)=0
        ipashd(i,2)=0
      enddo
      call fs_set_ipashd(ipashd,1)
      call fs_set_ipashd(ipashd,2)
      call fs_set_posnhd(posnhd,1)
      call fs_set_posnhd(posnhd,2)
      i70kch=0
      i20kch=0
      nrx_fs=0
      do i=1,maxnrx_fs
        tmpk_fs(i) = 0.0
        pvolt_fs(i) = 0.0
      end do
      tierr = 0
      pierr = 0
C
      do i=1,16
         ifp2vc(i) = 0
      enddo
      call fs_set_ifp2vc(ifp2vc)
      
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
      call fs_set_stchk(stchk(2),2)
      stchk(3)=0
      call fs_set_stchk(stchk(3),3)
      stchk(4)=0
      call fs_set_stchk(stchk(4),4)
c
      sterp=0
      call fs_set_sterp(sterp)
c
      erchk=0
      call fs_set_erchk(erchk)
C
C     2. Now initialize everything which is non-zero.
C
      do i=1,MAX_HOR
        horaz(i) = -1.0
        horel(i) = -1.0
      enddo
C
C FS version number
C
      sVerMajor_FS = VERSION
      sVerMinor_FS = SUBLEVEL
      sVerPatch_FS = PATCHLEVEL
C                   Initialize the time-like variables
C                   Initialize previous segment name for LINKP
      do i=1,15
        idummy = ichmv_ch(lfreqv(1,i),1,'000.00')
        freqvc(i)=0.0
        extbwvc(i)=-1.0
        itpivc(i)=-1
      enddo
      call fs_set_lfreqv(lfreqv)
      call fs_set_freqvc(freqvc)
      call fs_set_extbwvc(extbwvc)
      call fs_set_itpivc(itpivc)
      iratfm = -1
      call fs_set_iratfm(iratfm)
      imodfm = 1
      call fs_set_imodfm(imodfm)
      imoddc = 4
      ispeed(1) = 0
      ispeed(2) = 0
      call fs_set_ispeed(ispeed,1)
      call fs_set_ispeed(ispeed,2)
      idirtp(1) = -1
      idirtp(2) = -1
      call fs_set_idirtp(idirtp,1)
      call fs_set_idirtp(idirtp,2)
      idummy = ichmv_ch(lgen(1,1),1,'000')
      idummy = ichmv_ch(lgen(1,2),1,'000')
      call fs_set_lgen(lgen,1)
      call fs_set_lgen(lgen,2)
      ilowtp(1) = 1
      ilowtp(2) = 1
      ibyp=1
      lexper = ' '
      call char2hol(lexper,ilexper,1,8)
      call fs_set_lexper(ilexper)
      call char2hol('00000000',ltrken(1),1,8)
      call char2hol('00000000',ltpnum(1,1),1,8)
      call char2hol('00000000',ltpnum(1,2),1,8)
      call char2hol(' ',lsorna(1),1,10)
      call fs_set_lsorna(lsorna)
      call char2hol('0000',ltpchk(1,1),1,4)
      call char2hol('0000',ltpchk(1,2),1,4)
      call char2hol('test/reset',ltsrs,1,10)
      ilents = 10
      call char2hol('alarm',lalrm,1,6)
      ilenal = 5
      kecho = .false.
      call fs_set_kecho(kecho)
      kcheck = .false.
      khalt = .false.
      call fs_set_khalt(khalt)
      imonds = -1
      ichper(1) = 0
      ichper(2) = 0
      tperer(1) = 0.5
      tperer(2) = 0.5
      insper(1) = 2
      insper(2) = 2
      azhmwv(1) = 0.0
      azhmwv(2) = 360.0
      elhmwv(1) = 15.0
      nhorwv = 1
      iacttp(1) = 10
      iacttp(2) = 10
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
      idchrx = 1
      ibxhrx = 1
      ifamrx(1) = 1
      ifamrx(2) = 1
      ifamrx(3) = 1
      do j=1,2
         do i=1,100
            itapof(i,j)= -13000
         enddo
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
      klvdt_fs(1)=.false.
      klvdt_fs(2)=.false.
      call fs_set_klvdt_fs(klvdt_fs,1)
      call fs_set_klvdt_fs(klvdt_fs,2)
      ihdpk_fs(1)=0
      ihdpk_fs(2)=0
      iterpk_fs(1)=0
      iterpk_fs(2)=0
      nsamppk_fs(1)=0
      nsamppk_fs(2)=0
      vltpk_fs(1)=0.0
      vltpk_fs(2)=0.0
      kvrevw_fs(1)=.false.
      kvrevw_fs(2)=.false.
      kv15rev_fs(1)=.false.
      kv15rev_fs(2)=.false.
      kv15for_fs(1)=.false.
      kv15for_fs(2)=.false.
      kv15scale_fs(1)=.false.
      kv15scale_fs(2)=.false.
      kv13_fs(1)=.false.
      kv13_fs(2)=.false.
      kv15flip_fs(1)=.false.
      kv15flip_fs(2)=.false.
      rvrevw_fs(1)=0.0
      rvrevw_fs(2)=0.0
      rv15rev_fs(1)=0.0
      rv15rev_fs(2)=0.0
      rv15for_fs(1)=0.0
      rv15for_fs(2)=0.0
      rv15scale_fs(1)=0.0
      rv15scale_fs(2)=0.0
      rv13_fs(1)=0.0
      rv13_fs(2)=0.0
      rv15flip_fs(1)=0.0
      rv15flip_fs(2)=0.0
      ksread_fs(1)=.false.
      ksread_fs(2)=.false.
      kswrite_fs(1)=.false.
      kswrite_fs(2)=.false.
      ksdread_fs(1)=.false.
      ksdread_fs(2)=.false.
      ksdwrite_fs(1)=.false.
      ksdwrite_fs(2)=.false.
      kbdwrite_fs(1)=.false.
      kbdwrite_fs(2)=.false.
      kbdread_fs(1)=.false.
      kbdread_fs(2)=.false.
      rsread_fs(1)=0.0
      rsread_fs(2)=0.0
      rswrite_fs(1)=0.0
      rswrite_fs(2)=0.0
      rsdread_fs(1)=0.0
      rsdread_fs(2)=0.0
      rsdwrite_fs(1)=0.0
      rsdwrite_fs(2)=0.0
      rbdwrite_fs(1)=0.0
      rbdwrite_fs(2)=0.0
      rbdread_fs(1)=0.0
      rbdread_fs(2)=0.0
      khecho_fs=.false.
      ihdlc_fs(1)=0
      ihdlc_fs(2)=0
      steplc_fs(1)=0
      steplc_fs(2)=0
      nsamplc_fs(1)=0
      nsamplc_fs(2)=0
      rnglc_fs(1)=0.0
      rnglc_fs(2)=0.0
      ihdwo_fs(1)=0
      ihdwo_fs(2)=0
      fowo_fs(1,1)=-1.
      fowo_fs(2,1)=-1.
      fowo_fs(1,2)=-1.
      fowo_fs(2,2)=-1.
      sowo_fs(1,1)=-1.
      sowo_fs(2,1)=-1.
      sowo_fs(1,2)=-1.
      sowo_fs(2,2)=-1.
      fiwo_fs(1,1)=-1.
      fiwo_fs(2,1)=-1.
      fiwo_fs(1,2)=-1.
      fiwo_fs(2,2)=-1.
      siwo_fs(1,1)=-1.
      siwo_fs(2,1)=-1.
      siwo_fs(1,2)=-1.
      siwo_fs(2,2)=-1.
      kvw0_fs(1)=.false.
      kvw0_fs(2)=.false.
      kvw8_fs(1)=.false.
      kvw8_fs(2)=.false.
      rvw0_fs(1)=0.0
      rvw0_fs(2)=0.0
      rvw8_fs(1)=0.0
      rvw8_fs(2)=0.0
      kpeakv_fs(1)=.false.
      kpeakv_fs(2)=.false.
      wrhd_fs(1)=-1
      wrhd_fs(2)=-1
      call fs_set_wrhd_fs(wrhd_fs,1)
      call fs_set_wrhd_fs(wrhd_fs,2)
      rdhd_fs(1)=-1
      rdhd_fs(2)=-1
      call fs_set_rdhd_fs(rdhd_fs,1)
      call fs_set_rdhd_fs(rdhd_fs,2)
      rpro_fs(1)=-1
      rpro_fs(2)=-1
      rpdt_fs(1)=-1
      rpdt_fs(2)=-1
      kadapt_fs(1)=.false.
      kadapt_fs(2)=.false.
      kenastk(1,1)=.false.
      kenastk(2,1)=.false.
      kenastk(1,2)=.false.
      kenastk(2,2)=.false.
      call fs_set_kenastk(kenastk,1)
      call fs_set_kenastk(kenastk,2)
      kiwslw_fs(1)=.false.
      kiwslw_fs(2)=.false.
      lvbosc_fs(1)=5.0
      lvbosc_fs(2)=5.0
      ilvtl_fs(1)=0
      ilvtl_fs(2)=0
      vminpk_fs(1)=.2
      vminpk_fs(2)=.2
      lmtn_fs(1,1)=+11.0
      lmtn_fs(2,1)=+11.0
      lmtn_fs(1,2)=+11.0
      lmtn_fs(2,2)=+11.0
      lmtp_fs(1,1)=-11.0
      lmtp_fs(2,1)=-11.0
      lmtp_fs(1,2)=-11.0
      lmtp_fs(2,2)=-11.0
      iclwo_fs(1)=0
      iclwo_fs(2)=0
      krdwo_fs(1)=.false.
      krdwo_fs(2)=.false.
      kwrwo_fs(1)=.false.
      kwrwo_fs(2)=.false.
      kposhd_fs(1,1)=.false.
      kposhd_fs(2,1)=.false.
      kposhd_fs(1,2)=.false.
      kposhd_fs(2,2)=.false.
      idecpa_fs(1)=0
      idecpa_fs(2)=0
      kdoaux_fs(1)=.true.
      kdoaux_fs(2)=.true.
      ierrdc_fs=1
      krptp_fs(1)=.false.
      krptp_fs(2)=.false.
      kmvtp_fs(1)=.false.
      kmvtp_fs(2)=.false.
      kentp_fs(1)=.false.
      kentp_fs(2)=.false.
      kldtp_fs(1)=.false.
      kldtp_fs(2)=.false.
C
      iadcst = 0
      idcalst = 1
      ilohst = 1
      ibxhst = 1
      ifamst(1) = 1
      ifamst(2) = 1
      ifamst(3) = 1
C
      llog='        '
      call char2hol(llog,illog,1,8)
      call fs_set_llog(illog) 
  
      call char2hol(' ',lfeet_fs(1,1),1,6)
      call char2hol(' ',lfeet_fs(1,2),1,6)
      call fs_set_lfeet_fs(lfeet_fs,1)
      call fs_set_lfeet_fs(lfeet_fs,2)
c
      do i=1,4
        iswif3_fs(i)=1
      enddo
C
      ibr4tap(1)=-1
      ibr4tap(2)=-1
      ibwtap(1)=-1
      ibwtap(2)=-1
C
C  initialize "C" shared memory area
C
      call fc_cshm_init
C
C  3. Open the file which contains the station-dependent
C     information: LOCATION.CTL
C
      call fmpopen
     &  (idcb,FS_ROOT//'/control/location.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-117,'bo',ierr)
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
        call logit7ci(0,0,0,1,-119,'bo',1)
        goto 990
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
        call logit7ci(0,0,0,1,-119,'bo',2)
        goto 990
      endif
C LINE #3  LATITUDE
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      alat = das2b(ibuf,ic1,ic2-ic1+1,ierr)*DPI/180.0D0
      call fs_set_alat(alat)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-119,'bo',3)
        goto 990
      endif
C LINE #4  STATION ELEVATION
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 900
      height = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      call fs_set_height(height)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-119,'bo',4)
        goto 990
      endif
C LINE #5  HORIZON MASK
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 900
      if (ilen.lt.0) goto 900
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
      ip(3)=0
      call equip(idcb,FS_ROOT//'/control/equip.ctl',ip)
      if(ip(3).ne.0) return
c
      call fs_get_drive(drive)
      if(drive(1).eq.VLBA.or.drive(1).eq.VLBA4) then
         call drivev(idcb,FS_ROOT//'/control/drivev1.ctl',ip,-219,1)
         if(ip(3).ne.0) return
      else if(drive(1).eq.MK3.or.drive(1).eq.MK4) then
         call drivem(idcb,FS_ROOT//'/control/drivem1.ctl',ip,-221,1)
         if(ip(3).ne.0) return
      endif
c
      if(drive(2).eq.VLBA.or.drive(2).eq.VLBA4) then
         call drivev(idcb,FS_ROOT//'/control/drivev2.ctl',ip,-223,2)
         if(ip(3).ne.0) return
      else if(drive(2).eq.MK3.or.drive(2).eq.MK4) then
         call drivem(idcb,FS_ROOT//'/control/drivem2.ctl',ip,-225,2)
         if(ip(3).ne.0) return
      endif
C
320   continue
C
C 3.2 Open the file with device LU information.
C
      call fmpopen(idcb,FS_ROOT//'/control/dev.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-120,'bo',ierr)
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
        call logit7ci(0,0,0,1,-122,'bo',3)
        goto 990
      endif
      ibx = -1
      do i=1,7
        if (ibmat.eq.ibaud(i)) ibx = i
      enddo
C                   Check that a legal value was specified
      if (ibx.le.0) then
        call logit7ci(0,0,0,1,-122,'bo',3)
        goto 990
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
        call logit7ci(0,0,0,1,-122,'bo',5)
        goto 990
      endif
      ibx = -1
      do i=1,8
        if (ibdb .eq.ibauddb(i)) ibx = i
      enddo
C                   Check that a legal value was specified
      if (ibx.le.0) then
        call logit7ci(0,0,0,1,-122,'bo',7)
        goto 990
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
      if (ibmcb.eq.-32768. or. ibmcb .ne.57600) then
        call logit7ci(0,0,0,1,-122,'bo',9)
        goto 990
      endif
C
      call fmpclose(idcb,ierr)
C
C 3.3 Open the file with tape head positioner information
C
330   continue
      call fs_get_drive(drive)
      if(drive(1).eq.VLBA.or.drive(1).eq.VLBA4.or.
     $     drive(1).eq.MK3.or.drive(1).eq.MK4) then
         call head(idcb,FS_ROOT//'/control/head1.ctl',ip,-227,1)
         if(ip(3).ne.0) return
      endif
      if(drive(2).eq.VLBA.or.drive(2).eq.VLBA4.or.
     $     drive(2).eq.MK3.or.drive(2).eq.MK4) then
         call head(idcb,FS_ROOT//'/control/head2.ctl',ip,-229,2)
         if(ip(3).ne.0) return
      endif
C
C
C  3.4 Open the file with antenna information
C
      call fmpopen(idcb,FS_ROOT//'/control/antenna.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-154,'bo',ierr)
        goto 990
      endif
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      diaman = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',1)
        goto 990
      endif
      call fs_set_diaman(diaman)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      slew1 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',2)
        goto 990

      endif
      call fs_set_slew1(slew1)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      slew2 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',3)
        goto 990

      endif
      call fs_set_slew2(slew2)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      lolim1 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',4)
        goto 990
      endif
      call fs_set_lolim1(lolim1)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      uplim1 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',5)
        goto 990
      endif
      call fs_set_uplim1(uplim1)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      lolim2 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',6)
        goto 990
      endif
      call fs_set_lolim2(lolim2)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      uplim2 = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-156,'bo',7)
        goto 990
      endif
      call fs_set_uplim2(uplim2)
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 930
      ich=1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 930
      idummy = ichmv(iaxis,1,ibuf,ic1,ic2-ic1+1)
      call fmpclose(idcb,ierr)
C
C  4. Read file of RX monitor points and scale factors: RXDEF.CTL
C
400   continue
      call fmpopen(idcb,FS_ROOT//'/control/rxdef.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-143,'bo',ierr)
        goto 990
      endif
C
C     4.1 Read and decode each line.
C
      rxncodes=0
      do n=1,MAX_RXCODES
        call readg(idcb,ierr,ibuf,ilen)
        if (ierr.lt.0) then
          call logit7ci(0,0,0,1,-144,'bo',n)
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
              call logit7ci(0,0,0,1,-145,'bo',n)
              goto 990
            endif
          else
            call logit7ci(0,0,0,1,-145,'bo',n)
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
        call logit7ci(0,0,0,1,-146,'bo',ierr)
        goto 990
      endif
C
C     5.1 Read and decode the first line.
C
      call readg(idcb,ierr,ibuf,ilen)
      ilen = iflch(ibuf,80)/2
      if (ierr.lt.0) then
        call logit7ci(0,0,0,0,-147,'bo',1)
        goto 990
      endif
      ifc = 1
      do i=1,5
        call gtfld(ibuf,ifc,ilen*2,ist(i),ic2)
        nchar(i) = ic2 + 1 - ist(i)
        if (nchar(i).le.0 .or. ist(i).le.0) then
          call logit7ci(0,0,0,0,-148,'bo',1)
          goto 990
        endif
      enddo
      modsa = ias2b(ibuf,ist(1),4)  ! read only 4 digits (or 35660 overflows)
      if (modsa.eq.-32767) then
        call logit7ci(0,0,0,0,-149,'bo',1)
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
        call logit7ci(0,0,0,0,-150,'bo',1)
        goto 990
      endif
C
C     5.2 Read and decode the second line.
C
      call readg(idcb,ierr,ibuf,ilen)
      ilen = iflch(ibuf,80)/2
      if (ierr.lt.0) then
        call logit7ci(0,0,0,0,-147,'bo',2)
        goto 990
      endif
      ifc = 1
      do i=1,9
        call gtfld(ibuf,ifc,ilen*2,ist(i),ic2)
        nchar(i) = ic2 + 1 - ist(i)
        if (nchar(i).le.0 .or. ist(i).le.0) then
          call logit7ci(0,0,0,0,-148,'bo',2)
          goto 990
        endif
      enddo
      nprset = ias2b(ibuf,ist(1),nchar(1))
      intpha = ias2b(ibuf,ist(2),nchar(2))
      intamp = ias2b(ibuf,ist(3),nchar(3))
      lvsens = ias2b(ibuf,ist(4),nchar(4))
      if (nprset.eq.-32768 .or. intpha.eq.-32768 .or.
     ^    intamp.eq.-32768 .or. lvsens.eq.-32768) then
        call logit7ci(0,0,0,0,-149,'bo',2)
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
        call logit7ci(0,0,0,0,-150,'bo',2)
        goto 990
      endif
C
600   continue
      call fmpopen
     &   (idcb,FS_ROOT//'/control/rxdiode.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-160,'bo',ierr)
        goto 990
      endif
C
C  6.1 Read and decode each line.
C
      ilen=0
      do while(ilen.ge.0)
        call readg(idcb,ierr,ibuf,ilen)
        if (ierr.lt.0) then
          call logit7ci(0,0,0,1,-161,'bo',ierr)
          goto 990
        endif
        if (ilen.gt.0) then
          if (nrx_fs.eq.maxnrx_fs) then
            call logit7ci(0,0,0,1,-165,'bo',maxnrx_fs)
            goto 990
          end if
          nrx_fs = nrx_fs + 1
          ifc = 1
          call gtfld(ibuf,ifc,ilen,ic1,ic2)
          call gtprm(ibuf,ic1,ic2,2,tmpk_fs(nrx_fs),ierr)
          if (ierr.lt.0) then
            call logit7ci(0,0,0,1,-162,'bo',nrx_fs)
            goto 990
          endif
          call gtfld(ibuf,ifc,ilen,ic1,ic2)
          call gtprm(ibuf,ic1,ic2,2,pvolt_fs(nrx_fs),ierr)
          if (ierr.lt.0) then
            call logit7ci(0,0,0,1,-162,'bo',nrx_fs)
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
      if ((kasct).and.(kdest)) call logit7ci(0,0,0,0,-163,'bo',0)
      if ((kascp).and.(kdesp)) call logit7ci(0,0,0,0,-164,'bo',0)
      if (tierr.ne.0) call logit7ci(0,0,0,0,tierr,'bo',0)
      if (pierr.ne.0) call logit7ci(0,0,0,0,pierr,'bo',0)
      call fmpclose(idcb,ierr)
C
C 7.0 time.ctl control file
C
700   continue
      call fmpopen
     &   (idcb,FS_ROOT//'/control/time.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-180,'bo',ierr)
        goto 990
      endif
C
C  7.1 Read and decode each line.
C
      ilen=0
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-189,'bo',ierr)
        goto 990
      endif
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call gtprm(ibuf,ic1,ic2,2,rate,ierr)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-181,'bo',0)
        goto 990
      endif
      rate0ti_fs=rate/86400.
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call gtprm(ibuf,ic1,ic2,2,span,ierr)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-182,'bo',0)
        goto 990
      endif
      span0ti_fs=span*3600d2
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call hol2char(ibuf,ic1,ic2,model)
      if(model.ne.'none'.and.model.ne.'offset'.and.model.ne.'rate'.and.
     &   model.ne.'ntp')
     &  then
        call logit7ci(0,0,0,1,-183,'bo',0)
        goto 990
      endif
      call char2hol(model(1:1),model0ti_fs,1,2)
      if(model.eq.'ntp') call char2hol('c',model0ti_fs,1,2)
      call fs_get_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &   rateti_fs,spanti_fs, modelti_fs)
      rateti_fs=rate0ti_fs
      spanti_fs=span0ti_fs
      modelti_fs=model0ti_fs
      call fs_set_time_coeff(secsoffti_fs,epochti_fs,offsetti_fs,
     &   rateti_fs,spanti_fs, modelti_fs)
      call fmpclose(idcb,ierr)
C
C 8.0 flagr.ctl control file
C
800   continue
      call fmpopen
     &   (idcb,FS_ROOT//'/control/flagr.ctl',ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-400,'bo',ierr)
        goto 990
      endif
C
C  8.1 Read and decode each line.
C
      ilen=0
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-401,'bo',ierr)
        goto 990
      endif
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      call gtprm(ibuf,ic1,ic2,1,iapdflg,ierr)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-402,'bo',0)
        goto 990
      endif
      call fs_set_iapdflg(iapdflg)
      call fmpclose(idcb,ierr)
      goto 995
C
C  This is the error return section
C
900   call logit7ci(0,0,0,1,-118,'bo',ierr)
      goto 990
910   call logit7ci(0,0,0,1,-121,'bo',ierr)
      goto 990
920   call logit7ci(0,0,0,1,-152,'bo',ierr)
      goto 990
930   call logit7ci(0,0,0,1,-155,'bo',ierr)
      goto 990
C
990   call fmpclose(idcb,ierr)
      ip(3)=-1
      return
C
 995  continue
      return
      end
