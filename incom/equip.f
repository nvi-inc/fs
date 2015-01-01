      subroutine equip(idcb,name,ip)
      integer idcb(2)
      character*(*) name
      integer*4 ip(5)
c
      integer ierr,idum,ilen,ich,il,ic1,ic2
      integer*2 ibuf(50)
      character*4 decoder,pcalc
      character*18 dbbcv
      double precision das2b
      character*7 m5bcrate
      logical kmove
c
      include '../include/fscom.i'
c
      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-139,'bo',ierr)
        goto 995
      endif
C LINE #1  TYPE OF RACK - rack
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) then
         call logit7ci(0,0,0,1,-140,'bo',1)
         goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',1)
        goto 990
      else
         il=ic2-ic1+1
      endif
      if (ichcm_ch(ibuf,ic1,'mk3').eq.0.and.il.eq.3) then
        rack = MK3
        rack_type = MK3
      else if (ichcm_ch(ibuf,ic1,'vlbag').eq.0.and.il.eq.5) then
        rack = VLBA
        rack_type = VLBAG
      else if (ichcm_ch(ibuf,ic1,'vlba').eq.0.and.il.eq.4) then
        rack = VLBA
        rack_type = VLBA
      else if (ichcm_ch(ibuf,ic1,'mk4').eq.0.and.il.eq.3) then
        rack = MK4
        rack_type = MK4
      else if (ichcm_ch(ibuf,ic1,'mk5').eq.0.and.il.eq.3) then
        rack = MK4
        rack_type = MK45
      else if (ichcm_ch(ibuf,ic1,'vlba4').eq.0.and.il.eq.5) then
        rack = VLBA4
        rack_type = VLBA4
      else if (ichcm_ch(ibuf,ic1,'vlba5').eq.0.and.il.eq.5) then
        rack = VLBA4
        rack_type = VLBA45
      else if (ichcm_ch(ibuf,ic1,'k41').eq.0.and.il.eq.3) then
        rack = K4
        rack_type = K41
      else if (ichcm_ch(ibuf,ic1,'k41u').eq.0.and.il.eq.4) then
        rack = K4
        rack_type = K41U
      else if (ichcm_ch(ibuf,ic1,'k42').eq.0.and.il.eq.3) then
        rack = K4
        rack_type = K42
      else if (ichcm_ch(ibuf,ic1,'k42a').eq.0.and.il.eq.4) then
        rack = K4
        rack_type = K42A
      else if (ichcm_ch(ibuf,ic1,'k42b').eq.0.and.il.eq.4) then
        rack = K4
        rack_type = K42B
      else if (ichcm_ch(ibuf,ic1,'k42bu').eq.0.and.il.eq.5) then
        rack = K4
        rack_type = K42BU
      else if (ichcm_ch(ibuf,ic1,'k42c').eq.0.and.il.eq.4) then
        rack = K4
        rack_type = K42C
      else if (ichcm_ch(ibuf,ic1,'k41/k3').eq.0.and.il.eq.6) then
        rack = K4K3
        rack_type = K41
      else if (ichcm_ch(ibuf,ic1,'k41u/k3').eq.0.and.il.eq.7) then
        rack = K4K3
        rack_type = K41U
      else if (ichcm_ch(ibuf,ic1,'k42/k3').eq.0.and.il.eq.6) then
        rack = K4K3
        rack_type = K42
      else if (ichcm_ch(ibuf,ic1,'k42a/k3').eq.0.and.il.eq.7) then
        rack = K4K3
        rack_type = K42A
      else if (ichcm_ch(ibuf,ic1,'k42bu/k3').eq.0.and.il.eq.8) then
        rack = K4K3
        rack_type = K42BU
      else if (ichcm_ch(ibuf,ic1,'k41/mk4').eq.0.and.il.eq.7) then
        rack = K4MK4
        rack_type = K41
      else if (ichcm_ch(ibuf,ic1,'k41u/mk4').eq.0.and.il.eq.8) then
        rack = K4MK4
        rack_type = K41U
      else if (ichcm_ch(ibuf,ic1,'k42/mk4').eq.0.and.il.eq.7) then
        rack = K4MK4
        rack_type = K42
      else if (ichcm_ch(ibuf,ic1,'k42a/mk4').eq.0.and.il.eq.8) then
        rack = K4MK4
        rack_type = K42A
      else if (ichcm_ch(ibuf,ic1,'k42b/mk4').eq.0.and.il.eq.8) then
        rack = K4MK4
        rack_type = K42B
      else if (ichcm_ch(ibuf,ic1,'k42bu/mk4').eq.0.and.il.eq.9) then
        rack = K4MK4
        rack_type = K42BU
      else if (ichcm_ch(ibuf,ic1,'k42c/mk4').eq.0.and.il.eq.8) then
        rack = K4MK4
        rack_type = K42C
C **** Modified jfq
      else if (ichcm_ch(ibuf,ic1,'lba').eq.0.and.il.eq.3) then
        rack = LBA
        rack_type = LBA
      else if (ichcm_ch(ibuf,ic1,'lba4').eq.0.and.il.eq.4) then
        rack = LBA4
        rack_type = LBA
C **** end modify jfq
C **** Modified mb
      else if (ichcm_ch(ibuf,ic1,'s2').eq.0.and.il.eq.2) then
        rack = S2
        rack_type = S2
C **** end modify mb
      else if (ichcm_ch(ibuf,ic1,'dbbc').eq.0.and.il.eq.4) then
        rack = DBBC
        rack_type = DBBC
      else if (ichcm_ch(ibuf,ic1,'none').eq.0.and.il.eq.4) then
        rack = 0
        rack_type = 0
      else
        call logit7ci(0,0,0,1,-140,'bo',1)
        goto 990
      endif
      call fs_set_rack(rack)
      call fs_set_rack_type(rack_type)
C LINE #2  TYPE OF RECORDER - drive 1
      select=-1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) then
         call logit7ci(0,0,0,1,-140,'bo',2)
         goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',2)
        goto 990
      else
         il=ic2-ic1+1
      endif
      if (ichcm_ch(ibuf,ic1,'mk4b').eq.0.and.il.eq.4) then
        drive(1) = MK4
        drive_type(1) = MK4B
      else if (ichcm_ch(ibuf,ic1,'mk3').eq.0.and.il.eq.3) then
        drive(1) = MK3
        drive_type(1) = MK3
      else if (ichcm_ch(ibuf,ic1,'vlba2').eq.0.and.il.eq.5) then
        drive(1) = VLBA
        drive_type(1) = VLBA2
      else if (ichcm_ch(ibuf,ic1,'vlbab').eq.0.and.il.eq.5) then
        drive(1) = VLBA
        drive_type(1) = VLBAB
      else if (ichcm_ch(ibuf,ic1,'vlba').eq.0.and.il.eq.4) then
        drive(1) = VLBA
        drive_type(1) = VLBA
      else if (ichcm_ch(ibuf,ic1,'mk4').eq.0.and.il.eq.3) then
        drive(1) = MK4
        drive_type(1) = MK4
      else if (ichcm_ch(ibuf,ic1,'s2').eq.0.and.il.eq.2) then
        drive(1) = S2
        drive_type(1) = S2
      else if (ichcm_ch(ibuf,ic1,'vlba4').eq.0.and.il.eq.5) then
        drive(1) = VLBA4
        drive_type(1) = VLBA4
      else if (ichcm_ch(ibuf,ic1,'vlba42').eq.0.and.il.eq.6) then
        drive(1) = VLBA4
        drive_type(1) = VLBA42
      else if (ichcm_ch(ibuf,ic1,'k41').eq.0.and.il.eq.3) then
        drive(1) = K4
        drive_type(1) = K41
      else if (ichcm_ch(ibuf,ic1,'k42').eq.0.and.il.eq.3) then
        drive(1) = K4
        drive_type(1) = K42
      else if (ichcm_ch(ibuf,ic1,'k41/dms').eq.0.and.il.eq.7) then
        drive(1) = K4
        drive_type(1) = K41DMS
      else if (ichcm_ch(ibuf,ic1,'k42/dms').eq.0.and.il.eq.7) then
        drive(1) = K4
        drive_type(1) = K42DMS
      else if (ichcm_ch(ibuf,ic1,'mk5a').eq.0.and.il.eq.4) then
        drive(1) = MK5
        drive_type(1) = MK5A
      else if (ichcm_ch(ibuf,ic1,'mk5a_bs').eq.0.and.il.eq.7) then
        drive(1) = MK5
        drive_type(1) = MK5A_BS
      else if (ichcm_ch(ibuf,ic1,'mk5b').eq.0.and.il.eq.4) then
        drive(1) = MK5
        drive_type(1) = MK5B
      else if (ichcm_ch(ibuf,ic1,'mk5b_bs').eq.0.and.il.eq.7) then
        drive(1) = MK5
        drive_type(1) = MK5B_BS
      else if (ichcm_ch(ibuf,ic1,'mk5c').eq.0.and.il.eq.4) then
        drive(1) = MK5
        drive_type(1) = MK5C
      else if (ichcm_ch(ibuf,ic1,'mk5c_bs').eq.0.and.il.eq.7) then
        drive(1) = MK5
        drive_type(1) = MK5C_BS
      else if (ichcm_ch(ibuf,ic1,'none').eq.0.and.il.eq.4) then
        drive(1) = 0
        drive_type(1) = 0
      else
        call logit7ci(0,0,0,1,-140,'bo',2)
        goto 990
      endif
      call fs_set_drive(drive)
      call fs_set_drive_type(drive_type)
      if(drive(1).ne.0) then
         select=0
         call fs_set_select(select)
      endif
C LINE #3  TYPE OF RECORDER - drive 2
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) then
         call logit7ci(0,0,0,1,-140,'bo',3)
         goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',3)
        goto 990
      else
         il=ic2-ic1+1
      endif
      if (ichcm_ch(ibuf,ic1,'mk4b').eq.0.and.il.eq.4) then
        drive(2) = MK4
        drive_type(2) = MK4B
      else if (ichcm_ch(ibuf,ic1,'mk3').eq.0.and.il.eq.3) then
        drive(2) = MK3
        drive_type(2) = MK3
      else if (ichcm_ch(ibuf,ic1,'vlba2').eq.0.and.il.eq.5) then
        drive(2) = VLBA
        drive_type(2) = VLBA2
      else if (ichcm_ch(ibuf,ic1,'vlbab').eq.0.and.il.eq.5) then
        drive(2) = VLBA
        drive_type(2) = VLBAB
      else if (ichcm_ch(ibuf,ic1,'vlba').eq.0.and.il.eq.4) then
        drive(2) = VLBA
        drive_type(2) = VLBA
      else if (ichcm_ch(ibuf,ic1,'mk4').eq.0.and.il.eq.3) then
        drive(2) = MK4
        drive_type(2) = MK4
      else if (ichcm_ch(ibuf,ic1,'vlba4').eq.0.and.il.eq.5) then
        drive(2) = VLBA4
        drive_type(2) = VLBA4
      else if (ichcm_ch(ibuf,ic1,'vlba42').eq.0.and.il.eq.6) then
        drive(2) = VLBA4
        drive_type(2) = VLBA42
      else if (ichcm_ch(ibuf,ic1,'none').eq.0.and.il.eq.4) then
        drive(2) = 0
        drive_type(2) = 0
      else
        call logit7ci(0,0,0,1,-140,'bo',3)
        goto 990
      endif
      call fs_set_drive(drive)
      call fs_set_drive_type(drive_type)
      if(select.eq.-1.and.drive(2).ne.0) then
         select=1
      else if(select.eq.-1) then
         select=0
      endif
      call fs_set_select(select)
c
c line 4 decoder field
c
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',4)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',4)
        goto 990
      endif
      call hol2char(ibuf,ic1,ic2,decoder)
      if(decoder.eq.'mk3') then
         decoder4=3
      else if(decoder.eq.'mk4') then
         decoder4=4
      else if(decoder.eq.'dqa') then
         decoder4=1
      else if(decoder.eq.'none') then
         decoder4=0
      else
        call logit7ci(0,0,0,1,-140,'bo',4)
        goto 990
      endif
C LINE #5  if3 lo freq.
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',5)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',5)
        goto 990
      endif
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
      freqif3=ifrqu
      freqif3=100*freqif3+ifrqd
      if (ifrqu.lt.0.or.ifrqd.lt.0.or.
     &    freqif3.lt.50000.or.freqif3.gt.100000) then
        call logit7ci(0,0,0,1,-140,'bo',5)
        goto 990
      endif
      call fs_set_freqif3(freqif3)
C LINE #6  if3 switches
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',6)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',6)
        goto 990
      endif
      iswavif3_fs=ia2hx(ibuf,ic1)
      if (ic2-ic1.ne.0.or.iswavif3_fs.lt.0) then
        call logit7ci(0,0,0,1,-140,'bo',6)
      endif
C LINE #7 DS board in vlba FM ?
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',7)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',7)
        goto 990
      endif
      if (ichcm_ch(ibuf,ic1,'a/d').eq.0) then
         vfm_xpnt=0
      else if(ichcm_ch(ibuf,ic1,'dsm').eq.0) then
         vfm_xpnt=1
      else
        call logit7ci(0,0,0,1,-140,'bo',7)
        goto 990
      endif
      call fs_set_vfm_xpnt(vfm_xpnt)
C LINE #8 HARDWARE ID - hwid
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',8)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',8)
        goto 990
      endif
      hwid = ias2b(ibuf,ic1,ic2-ic1+1)
      if (hwid.le.100 .or. hwid.ge.255) then
        call logit7ci(0,0,0,1,-140,'bo',8)
        goto 990
      endif
      call fs_set_hwid(hwid)
C LINE #9 RECEIVER 70K STAGE CHECK TEMPERATURE - i70kch
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',9)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',9)
        goto 990
      endif
      i70kch = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-140,'bo',9)
        go to 990
      endif
      call fs_set_i70kch(i70kch)
C LINE #10 RECEIVER 20K STAGE CHECK TEMPERATURE - i20kch
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',10)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',10)
        goto 990
      endif
      i20kch = das2b(ibuf,ic1,ic2-ic1+1,ierr)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-140,'bo',10)
        go to 990
      endif
      call fs_set_i20kch(i20kch)
c pcal control
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',11)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',11)
        goto 990
      endif
C **** Modified rdg
      call hol2char(ibuf,ic1,ic2,pcalc)
      if(pcalc.eq.'if3') then
         pcalcntrl=3
      else if(pcalc.eq.'none') then
         pcalcntrl=0
      else
        call logit7ci(0,0,0,1,-140,'bo',11)
        goto 990
      endif
C ** Mk4 formatter firmware
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',12)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',12)
        goto 990
      endif
      imk4fmv = ias2b(ibuf,ic1,ic2-ic1+1)
      if (ierr.ne.0) then
        call logit7ci(0,0,0,1,-140,'bo',12)
        go to 990
      endif
      call fs_set_imk4fmv(imk4fmv)
C **** end modify rdg
C **** Modified jfq
C LINE #13 NO Of INSTALLED DAS - ndas
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',13)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',13)
        goto 990
      endif
      ndas = ias2b(ibuf,ic1,ic2-ic1+1)
      if (ndas.gt.MAX_DAS) then
        call logit7ci(0,0,0,1,-140,'bo',13)
        goto 990
      endif
      call fs_set_ndas(ndas)
C LINE #14 DAS IMAGE REJECT FILTERS - idasfilt
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',14)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',14)
        goto 990
      endif
      if (ichcm_ch(ibuf,ic1,'out').eq.0) then
         idasfilt=0
      else if(ichcm_ch(ibuf,ic1,'in').eq.0) then
         idasfilt=1
      else
        call logit7ci(0,0,0,1,-140,'bo',14)
        goto 990
      endif
      call fs_set_idasfilt(idasfilt)
C LINE #15 DAS DIGITAL INPUT FORMAT - idasbits
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',15)
        goto 990
      endif
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',15)
        goto 990
      endif
      if (ichcm_ch(ibuf,ic1,'8bit').eq.0) then
         idasbits=0
      else if(ichcm_ch(ibuf,ic1,'4bit').eq.0) then
         idasbits=1
      else
        call logit7ci(0,0,0,1,-140,'bo',15)
        goto 990
      endif
      call fs_set_idasbits(idasbits)
C **** end modify jfq
C **** Modified rdg
C **** MET3 Sensor line 16
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) then
         call logit7ci(0,0,0,1,-140,'bo',16)
         goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',16)
        goto 990
      else
         il=ic2-ic1+1
      endif
      wx_met = ias2b(ibuf,ic1,ic2-ic1+1)
      if(wx_met.lt.1) then
         if(ichcm_ch(ibuf,ic1,'cdp').eq.0.and.il.eq.3) then
            wx_met = 0
         else
            call logit7ci(0,0,0,1,-140,'bo',16)
            goto 990
         endif
      endif
      call fs_set_wx_met(wx_met)
C **** end modify rdg
C mk4 synch test parameter
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',17)
        goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',17)
        goto 990
      else
         il=ic2-ic1+1
      endif
      if (ichcm_ch(ibuf,ic1,'off').eq.0.and.il.eq.3) then
        mk4sync_dflt= -1
      else
         mk4sync_dflt = ias2b(ibuf,ic1,ic2-ic1+1)
         if (mk4sync_dflt.lt.0.or.mk4sync_dflt.gt.16) then
            call logit7ci(0,0,0,1,-140,'bo',17)
            goto 990
         endif
      endif
      call fs_set_mk4sync_dflt(mk4sync_dflt)
C mk4 decoder message terminator
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',18)
        goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',18)
        goto 990
      else
         il=ic2-ic1+1
      endif
      if (ichcm_ch(ibuf,ic1,'return').eq.0.and.il.eq.6) then
        mk4dec_fs = 13
      else if (ichcm_ch(ibuf,ic1,'$').eq.0.and.il.eq.1) then
        mk4dec_fs = ichar('$')
      else if (ichcm_ch(ibuf,ic1,'%').eq.0.and.il.eq.1) then
        mk4dec_fs = ichar('%')
      else
         call logit7ci(0,0,0,1,-140,'bo',18)
         goto 990
      endif
c DBBC DDC firmware version
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',19)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',19)
        goto 990
      endif
C
      call hol2char(ibuf,ic1,ic2,dbbcv)
      kmove=dbbcv(1:1).eq.'v'
      do i=1,17
         if(kmove) then
            dbbcv(i:i)=dbbcv(i+1:i+1)
         endif
         if(dbbcv(i:i).ne.' ') idbbcvc=i
      enddo
      if(idbbcvc.gt.16) then
         call logit7ci(0,0,0,1,-141,'bo',19)
         goto 990
      endif
      idbbcv=0
      do i=1,3
        ind=index('01234567890',dbbcv(i:i))
        if(ind.eq.0) then
           call logit7ci(0,0,0,1,-141,'bo',19)
           goto 990
        endif
        idbbcv=idbbcv*10+(ind-1)
      enddo
      if(idbbcv.lt.100.or.idbbcv.eq.103) then
         call logit7ci(0,0,0,1,-141,'bo',19)
      endif
      if(0.eq.index('abcdefghijklmnopqrstuvwxyz_ ',dbbcv(4:4))) then
c                    12345678901234567890123456
         call logit7ci(0,0,0,1,-141,'bo',19)
         goto 990
      endif
      if(idbbcv.gt.104.and.dbbcv(4:4).ne.'_') then
         dbbcddcvl=dbbcv(4:4)
      else if(idbbcv.lt.105.and.dbbcv(4:4).ne.' ') then
         call logit7ci(0,0,0,1,-141,'bo',19)
         goto 990
      else
         dbbcddcvl=' '
      endif
c
      dbbcddcv =idbbcv
      dbbcddcvs= dbbcv
      dbbcddcvc=idbbcvc
      call fs_set_dbbcddcv(dbbcddcv)
      call fs_set_dbbcddcvl(dbbcddcvl)
      call fs_set_dbbcddcvs(dbbcddcvs)
      call fs_set_dbbcddcvc(dbbcddcvc)
c DBBC PFB firmware version
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',20)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',20)
        goto 990
      endif
C
      call hol2char(ibuf,ic1,ic2,dbbcv)
      if(dbbcv.eq.'v12') then
         dbbcpfbv=12
      else
        call logit7ci(0,0,0,1,-140,'bo',20)
        goto 990
      endif
      call fs_set_dbbcpfbv(dbbcpfbv)
C number of conditioning modules
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',21)
        goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',21)
        goto 990
      else
         il=ic2-ic1+1
      endif
      dbbc_cond_mods = ias2b(ibuf,ic1,ic2-ic1+1)
      if (dbbc_cond_mods.lt.1.or.dbbc_cond_mods.gt.4) then
         call logit7ci(0,0,0,1,-140,'bo',21)
         goto 990
      endif
      call fs_set_dbbc_cond_mods(dbbc_cond_mods)
C DBBC IF count conversion factors
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',22)
        goto 990
      endif
      call lower(ibuf,ilen)
      icount=0
      ich = 1
      do i=1,5
         call gtfld(ibuf,ich,ilen,ic1,ic2)
         if (ic1.eq.0.and.icount.ne.dbbc_cond_mods) then
            call logit7ci(0,0,0,1,-140,'bo',22)
            goto 990
         else if(ic1.ne.0.and.icount.ge.dbbc_cond_mods) then
            call logit7ci(0,0,0,1,-140,'bo',22)
            goto 990
         else if(ic1.ne.0.and.icount.lt.dbbc_cond_mods) then
            if_factor = ias2b(ibuf,ic1,ic2-ic1+1)
            if (if_factor.lt.1.or.if_factor.gt.65535) then
               call logit7ci(0,0,0,1,-140,'bo',22)
               goto 990
            endif
            icount=icount+1
            dbbc_if_factors(icount)=if_factor
         endif
      enddo
      call fs_set_dbbc_if_factors(dbbc_if_factors)
C 5B clock rate
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',23)
        goto 990
      endif
      call lower(ibuf,ilen)
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',23)
        goto 990
      endif
      call hol2char(ibuf,ic1,ic2,m5bcrate)
      call fs_get_dbbcddcvl(dbbcddcvl)
      call fs_get_dbbcddcv(dbbcddcv)
      if(m5bcrate.eq.'nominal') then
         if(drive(1).eq.MK5.and.
     &        (drive_type(1).eq.MK5B.or.drive_type(1).eq.MK5B_BS.or.
     &         drive_type(1).eq.MK5C.or.drive_type(1).eq.MK5C_BS)) then
C note that MK45 and VLBA45 cannot connect to MK5C or MK5C_BS,
c      so only DBBC matters for 5C
            if((rack.eq.MK4.and.rack_type.eq.MK45) .or.
     &           (rack.eq.VLBA4.and.rack_type.eq.VLBA45).or.
     &           (rack.eq.DBBC.and.
     &           (dbbcddcv.le.104.or.dbbcddcvl.eq.' '))) then
               m5b_crate=32
            else if(rack.eq.DBBC.and.
     &             (dbbcddcv.ge.105.and.
     &              0.ne.index('ef',dbbcddcvl))) then
               m5b_crate=64
            else if(rack.eq.DBBC.and.
     &             (dbbcddcv.ge.105.and.
     &              0.eq.index(' ef',dbbcddcvl))) then
               call logit7ci(0,0,0,1,-142,'bo',23)
               goto 990
            else if(rack.eq.0) then
               call logit7ci(0,0,0,1,-140,'bo',23)
               goto 990
            else
               m5b_crate=0
            endif
         else
            m5b_crate=0
         endif
      else if(m5bcrate.eq.'none') then
         m5b_crate=0
      else
         m5b_crate = ias2b(ibuf,ic1,ic2-ic1+1)
         do i=1,6
            if(m5b_crate.eq.2**i) then
               goto 2300
            endif
         enddo
         call logit7ci(0,0,0,1,-140,'bo',23)
         goto 990
      endif
 2300 continue
      call fs_set_m5b_crate(m5b_crate)
c
      return
c
 990  call fmpclose(idcb,ierr)
  995  continue
      ip(3) = -1
       return
      end
