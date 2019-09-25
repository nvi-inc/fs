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
      integer*2 line1(16),line2(2)
c
      include '../include/fscom.i'
c                 1    2    3    4    5    6    7    8    9   10
      data line1/25,2heq,2hui,2hp.,2hct,2hl ,2hli,2hne,2h t,2hha,
     &         2ht ,2hfa,2hil,2hed,2h: ,2h' /
      data line2/ 1,2h' /

      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,-139,'bo',ierr)
        goto 995
      endif
C LINE #1  TYPE OF RACK - rack
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) then
         call logit7ci(0,0,0,1,-140,'bo',1)
         goto 991
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
      else if (ichcm_ch(ibuf,ic1,'vlbac').eq.0.and.il.eq.5) then
        rack = VLBA4
        rack_type = VLBA4C
      else if (ichcm_ch(ibuf,ic1,'cdas').eq.0.and.il.eq.4) then
        rack = VLBA4
        rack_type = VLBA4CDAS
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
      else if (ichcm_ch(ibuf,ic1,'dbbc_ddc').eq.0.and.il.eq.8) then
        rack = DBBC
        rack_type = DBBC_DDC
      else if (ichcm_ch(ibuf,ic1,'dbbc_ddc/fila10g').eq.0.and.
     &       il.eq.16) then
        rack = DBBC
        rack_type = DBBC_DDC_FILA10G
      else if (ichcm_ch(ibuf,ic1,'dbbc_pfb').eq.0.and.il.eq.8) then
        rack = DBBC
        rack_type = DBBC_PFB
      else if (ichcm_ch(ibuf,ic1,'dbbc_pfb/fila10g').eq.0.and.
     &       il.eq.16) then
        rack = DBBC
        rack_type = DBBC_PFB_FILA10G
      else if (ichcm_ch(ibuf,ic1,'rdbe').eq.0.and.il.eq.4) then
        rack = RDBE
        rack_type = RDBE
      else if (ichcm_ch(ibuf,ic1,'dbbc3').eq.0.and.il.eq.5) then
        rack = DBBC3
        rack_type = DBBC3
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
         goto 991
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
      else if (ichcm_ch(ibuf,ic1,'flexbuff').eq.0.and.il.eq.8) then
        drive(1) = MK5
        drive_type(1) = FLEXBUFF
      else if (ichcm_ch(ibuf,ic1,'mk6').eq.0.and.il.eq.3) then
        drive(1) = MK6
        drive_type(1) = MK6
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
         goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
        goto 991
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
         goto 991
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
      else
         call gtfld(ibuf,ich,ilen,ic1,ic2)
         if (ic1.eq.0) then
            call logit7ci(0,0,0,1,-140,'bo',16)
            goto 990
         else
            il=ic2-ic1+1
            if(il.gt.64) then
               call logit7ci(0,0,0,1,-140,'bo',16)
               goto 990
            else
               idum=ichmv(wx_host,1,ibuf,ic1,il)
               call pchar(wx_host,idum,0)
            endif
         endif
      endif
      call fs_set_wx_met(wx_met)
      call fs_set_wx_host(wx_host)
C **** end modify rdg
C mk4 synch test parameter
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',17)
        goto 991
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
        goto 991
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
        goto 991
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
        ind=index('0123456789',dbbcv(i:i))
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

      idbbcddc_subv=0
      ius=index(dbbcv(1:idbbcvc),'_')
      if(ius.ne.0) then
         do i=ius+1,idbbcvc
            ind=index('0123456789',dbbcv(i:i))
            if(ind.eq.0) then
               call logit7ci(0,0,0,1,-141,'bo',19)
               goto 990
            endif
            idbbcddc_subv=idbbcddc_subv*10+(ind-1)
         enddo
      endif
      icont_cal_pol=0
      if(idbbcv.ge.106 .or.(idbbcv.eq.105.and.idbbcddc_subv.ge.1)) then
         icont_cal_pol=icont_cal_pol+1
      endif
      if(idbbcv.ge.106) then
         icont_cal_pol=icont_cal_pol+2
      endif
c
      dbbcddcv =idbbcv
      dbbcddcvs= dbbcv
      dbbcddcvc=idbbcvc
      dbbcddcsubv=idbbcddc_subv
      dbbccontcalpol=icont_cal_pol
      call fs_set_dbbcddcv(dbbcddcv)
      call fs_set_dbbcddcvl(dbbcddcvl)
      call fs_set_dbbcddcvs(dbbcddcvs)
      call fs_set_dbbcddcvc(dbbcddcvc)
      call fs_set_dbbcddcsubv(dbbcddcsubv)
      call fs_set_dbbccontcalpol(dbbccontcalpol)
c DBBC PFB firmware version
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',20)
        goto 991
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
      kmove=dbbcv(1:1).eq.'v'
      do i=1,17
         if(kmove) then
            dbbcv(i:i)=dbbcv(i+1:i+1)
         endif
         if(dbbcv(i:i).ne.' ') idbbcvc=i
      enddo
      if(idbbcvc.gt.16) then
         call logit7ci(0,0,0,1,-141,'bo',20)
         goto 990
      endif
      idbbcv=0
      do i=1,2
        ind=index('0123456789',dbbcv(i:i))
        if(ind.eq.0) then
           call logit7ci(0,0,0,1,-141,'bo',20)
           goto 990
        endif
        idbbcv=idbbcv*10+(ind-1)
      enddo
      if(idbbcv.lt.12) then
         call logit7ci(0,0,0,1,-141,'bo',20)
      endif
      if(0.eq.index('abcdefghijklmnopqrstuvwxyz_ ',dbbcv(3:3))) then
c                    12345678901234567890123456
         call logit7ci(0,0,0,1,-141,'bo',20)
         goto 990
      endif
      if(idbbcv.gt.15.and.dbbcv(3:3).ne.'_') then
         dbbcpfbvl=dbbcv(3:3)
      else if(idbbcv.lt.15.and.dbbcv(3:3).ne.' ') then
         call logit7ci(0,0,0,1,-141,'bo',20)
         goto 990
      else
         dbbcpfbvl=' '
      endif

      idbbcpfb_subv=0
      ius=index(dbbcv(1:idbbcvc),'_')
      if(ius.ne.0) then
         do i=ius+1,idbbcvc
            ind=index('0123456789',dbbcv(i:i))
            if(ind.eq.0) then
               call logit7ci(0,0,0,1,-141,'bo',20)
               goto 990
            endif
            idbbcpfb_subv=idbbcpfb_subv*10+(ind-1)
         enddo
      endif

      dbbcpfbv =idbbcv
      dbbcpfbvs= dbbcv
      dbbcpfbvc=idbbcvc
      dbbcpfbsubv=idbbcpfb_subv
      call fs_set_dbbcpfbv(dbbcpfbv)
      call fs_set_dbbcpfbvl(dbbcpfbvl)
      call fs_set_dbbcpfbvs(dbbcpfbvs)
      call fs_set_dbbcpfbvc(dbbcpfbvc)
      call fs_set_dbbcpfbsubv(dbbcpfbsubv)
c
C number of conditioning modules and cores per each
C
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',21)
        goto 991
      endif
      call lower(ibuf,ilen)
      ich = 1
      dbbc_cores=0
      do i=1,5
         call gtfld(ibuf,ich,ilen,ic1,ic2)
         if (ic1.eq.0.and.i.eq.1) then
            call logit7ci(0,0,0,1,-140,'bo',21)
            goto 990
         else if(ic1.eq.0) then
            goto 2100
         else if(ic1.ne.0.and.i.eq.5) then
            call logit7ci(0,0,0,1,-140,'bo',21)
            goto 990
         else
            il=ic2-ic1+1
         endif
         dbbc_cond_mods = i
         dbbc_como_cores(i)= ias2b(ibuf,ic1,ic2-ic1+1)
         if (dbbc_como_cores(i).lt.0.or.dbbc_como_cores(i).gt.4) then
            call logit7ci(0,0,0,1,-140,'bo',21)
            goto 990
         endif
         dbbc_cores=dbbc_cores+dbbc_como_cores(i)
      enddo
c
 2100 continue
      if(dbbc_cores.lt.1.or.dbbc_cores.gt.4) then
         call logit7ci(0,0,0,1,-140,'bo',21)
         goto 990
      endif
c
      call fs_set_dbbc_como_cores(dbbc_como_cores)
      call fs_set_dbbc_cores(dbbc_cores)
      call fs_set_dbbc_cond_mods(dbbc_cond_mods)
C DBBC IF count conversion factors
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',22)
        goto 991
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
        goto 991
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
     &         drive_type(1).eq.MK5C.or.drive_type(1).eq.MK5C_BS.or.
     &         drive_type(1).eq.FLEXBUFF)) then
C note that MK45/VLBA45/VLBAC/VLBACDAS cannot connect to MK5C/MK5C_BS/FLEXBUFF,
c      so only DBBC matters for 5C/5C_BS/FLEXBUFF
            if (rack.eq.DBBC.and.rack_type.eq.DBBC_DDC_FILA10G
     &              .and.(dbbcddcv.ge.107.and.dbbcddcvl.eq.' ')
     &              .and..not.(drive(1).eq.MK5.and.
     &     (drive_type(1).eq.MK5B.or.drive_type(1).eq.MK5B_BS))) then
               m5b_crate=128
            else if((rack.eq.VLBA4.and.rack_type.eq.VLBA4CDAS).or.
     &              (rack.eq.DBBC.and.(rack_type.eq.DBBC_DDC.or.
     &              rack_type.eq.DBBC_DDC_FILA10G).and.
     &              (dbbcddcv.ge.105.and.
     &              0.ne.index('ef',dbbcddcvl))).or.
     &              (rack.eq.DBBC.and.(rack_type.eq.DBBC_PFB.or.
     &              rack_type.eq.DBBC_PFB_FILA10G)).or.
     &              (rack.eq.DBBC.and.(rack_type.eq.DBBC_DDC.or.
     &               rack_type.eq.DBBC_DDC_FILA10G).and.
     &              (dbbcddcv.ge.107.and.dbbcddcvl.eq.' '))) then
               m5b_crate=64
            else if((rack.eq.MK4.and.rack_type.eq.MK45) .or.
     &           (rack.eq.VLBA4.and.rack_type.eq.VLBA45).or.
     &           (rack.eq.VLBA4.and.rack_type.eq.VLBA4C).or.
     &           (rack.eq.DBBC.and.(rack_type.eq.DBBC_DDC.or.
     &           rack_type.eq.DBBC_DDC_FILA10G).and.
     &           (dbbcddcv.le.104.or.dbbcddcvl.eq.' '))) then
               m5b_crate=32
            else if(rack.eq.DBBC.and.
     &             (dbbcddcv.ge.105.and.(rack_type.eq.DBBC_DDC.or.
     &              rack_type.eq.DBBC_DDC_FILA10G).and.
     &              0.eq.index(' ef',dbbcddcvl))) then
               call logit7ci(0,0,0,1,-142,'bo',23)
               goto 990
            else if(rack.eq.0) then
               call logit7ci(0,0,0,1,-142,'bo',23)
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
         do i=1,7
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
c FiLA10G VSI input
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',24)
        goto 991
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',24)
        goto 990
      endif
C
      call hol2char(ibuf,ic1,ic2,fila10gvsi_in)
      if(fila10gvsi_in.ne.'vsi1' .and.
     &     fila10gvsi_in.ne.'vsi2' .and.
     &     fila10gvsi_in.ne.'vsi1-2' .and.
     &     fila10gvsi_in.ne.'vsi1-2-3-4' .and.
     &     fila10gvsi_in.ne.'gps'.and.
     &     fila10gvsi_in.ne.'tvg'
     & ) then
        call logit7ci(0,0,0,1,-140,'bo',24)
        goto 990
      endif
      call fs_set_fila10gvsi_in(fila10gvsi_in)
c
c DBBC3 DDC firmware version
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0.or.ilen.le.0) then
        call logit7ci(0,0,0,1,-140,'bo',24)
        goto 990
      endif
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',24)
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
         call logit7ci(0,0,0,1,-141,'bo',24)
         goto 990
      endif
      idbbcv=0
      do i=1,3
        ind=index('01234567890',dbbcv(i:i))
        if(ind.eq.0) then
           call logit7ci(0,0,0,1,-141,'bo',24)
           goto 990
        endif
        idbbcv=idbbcv*10+(ind-1)
      enddo
      if(idbbcv.lt.121) then
         call logit7ci(0,0,0,1,-141,'bo',24)
         goto 990
      endif
c
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',24)
        goto 990
      else
         il=ic2-ic1+1
      endif
      dbbc3_ddc_bbcs_per_if = ias2b(ibuf,ic1,ic2-ic1+1)
      if (dbbc3_ddc_bbcs_per_if.ne.8.and.
     &     dbbc3_ddc_bbcs_per_if.ne.12.and.
     &     dbbc3_ddc_bbcs_per_if.ne.16) then
         call logit7ci(0,0,0,1,-140,'bo',24)
         goto 990
      endif
c
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if (ic1.eq.0) then
        call logit7ci(0,0,0,1,-140,'bo',24)
        goto 990
      else
         il=ic2-ic1+1
      endif
      dbbc3_ddc_ifs = ias2b(ibuf,ic1,ic2-ic1+1)
      if ( dbbc3_ddc_ifs.lt.1.or.
     &     dbbc3_ddc_ifs.gt.8) then
         call logit7ci(0,0,0,1,-140,'bo',24)
         goto 990
      endif

      dbbc3_ddcv =idbbcv
      dbbc3_ddc_vs= dbbcv
      dbbc3_ddc_vc=idbbcvc
      call fs_set_dbbc3_ddc_v(dbbc3_ddc_v)
      call fs_set_dbbc3_ddc_vs(dbbc3_ddc_vs)
      call fs_set_dbbc3_ddc_vc(dbbc3_ddc_vc)
      call fs_set_dbbc3_ddc_bbcs_per_if(dbbc3_ddc_bbcs_per_if)
      call fs_set_dbbc3_ddc_ifs(dbbc3_ddc_ifs)
c
      return
c
 990  continue
      call put_cons_raw(line1(2),line1(1))
      call put_cons_raw(ibuf,ilen)
      call put_cons(line2(2),line2(1))
 991  continue
      call fmpclose(idcb,ierr)
  995  continue
      ip(3) = -1
       return
      end
