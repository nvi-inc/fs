      subroutine modet(kfield,kdbtst,ksplit,luop,pcal,pcala,idcb,iquit, 
     .ierr,ksa)
C 
C     Subroutine MODET determines whether the Field System is running.
C     It determines whether there is a data buffer, the d.b. LU and 
C     baud rate if applicable.  If there is no d.b., the user is
C     prompted for the name of the test data file, which is then opened.
C     The user is prompted for all necessary information which would
C     normally have been picked from FS common.
C     On first entry with no FS the user is prompted for input parameters.
C     On subsequent entries IERR=-1 will skip the no FS prompts.
C
C  WHO  WHEN    DESCRIPTION
C  GAG  901228  Changed IPGST call to KBOSS call to see if BOSS is running.
C
C
C  INPUT:
C
      include '../include/fscom.i'
C
C  OUTPUT:
C     LUDB - data buffer LU
C     IBDB - data buffer baud rate
C     IRATFM - sample rate code
C     LUOP - operator's LU
C     All of the above normally set in FS common.
      logical kdbtst,kfield,ksplit,rn_test
C      - True if we have a real data buffer.
C      - True if the field system is running
C      - True if we are to use split-mode
      double precision pcal,pcala
C     PCAL -  Phase cal. freq.
      integer idcb(1)
C      - DCB for the test data file.
C
C  LOCAL:
      logical ksa
      integer*2 itemp(32)
C      - buffer for responses.
      integer*2 ldfil(32)
      character*64 cdfil
      equivalence (ldfil,cdfil)
C      - buffer holding file name 
C      - buffer for getting file name 
      real bwdi(8) 
C      - allowed sample rates.
C 
C  INITIALIZED: 
      data bwdi/8.0,0.0,0.125,0.25,0.5,1.0,2.0,4.0/ 
C
C     Get run LU and check if FS running
C
      if (ksa) then
        kdbtst = .false.
        ksplit = .false.
      endif
      if (ierr.eq.-1) goto 600
      call ifill_ch(itemp,1,64,' ')
      kfield=rn_test('fs   ')
      if (kfield) goto 600
      if (ksa) return
      luop=6
      luopo=6
      luopi=5
      lu = luop
      pi = 3.141592653
      write(luopo,9360)
9360  format(" field system not running, will prompt for needed"
     . " parameters"/" a blank response will give the default "
     . "value indicated"/)
C
C     Ask for data buffer LU or file name.
C
115   write(luopo,9400)
9400  format(/" data buffer lu or file name ? ",$)
      call gtrsp(itemp,10,luopi,nch)
      if (ichcm_ch(itemp,1,'::').eq.0) goto 990
      call ichmv(ldfil,1,itemp,1,nch)
      if(cdfil(:4).eq.'/dev') goto 130
      call fmpopen(idcb,ierr,cdfil(1:nch),'r+',idum)
      write(6,8888) ierr
8888  format(10x,"the error opening file is: ",i6,/)
      if (ierr.ge.0) kdbtst = .false.
      if (ierr.ge.0) goto 301
      write(luopo,9455) ierr,cdfil(1:20)
9455  format(" error"i5" opening file "a20)
      goto 115
C
C     Ask for baud rate because we have a real d.b.
C
130   write(luopo,9410)
9410  format(/" baud rate (default 9600) ? ",$)
      call gtrsp(itemp,10,luopi,nch)
      if (ichcm_ch(temp,1,'::').eq.0) goto 990
      if (nch.ne.0) goto 135
      ibdb = 9600
      goto 301
135   ibdb = ias2b(itemp,1,nch)
C
C     Check if operator wants SPLIT mode and get channel A
C     phase cal. frequency
C 
301   write(luopo,9480)
9480  format(/" do you want split mode (y/n) ? ",$)
      call gtrsp(itemp,10,luopi,nch) 
      if (ichcm_ch(itemp(1),1,'n ').eq.0) ksplit = .false.
      if (ichcm_ch(itemp(1),1,'y ').eq.0) ksplit = .true. 
      if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      if ((ichcm_ch(itemp(1),1,'n ').ne.0).and.
     .    (ichcm_ch(itemp(1),1,'y ').ne.0)) goto 301 
      if (.not.ksplit) goto 501 
302   write(luopo,9485)
9485  format(/" phase cal. freq. channel a (khz, default 10) ? ",$)
      call gtrsp(itemp,10,luopi,nch) 
      if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      if (nch.ne.0) goto 303
      pcala = 10.0
      goto 307
303   pcala = das2b(itemp,1,nch,ierr) 
      if (pcala.le.0.0.or.ierr.lt.0.or.pcala.gt.50.) then
        goto 306
      else
        goto 307
      end if
306   write(luopo,9470)
      goto 302
307   pcala = pcala*1.e3
C 
C     Ask for phase cal frequency (channel B) - this is usually in FSCOM
C 
501   write(luopo,9420)
9420  format(/" phase cal. freq. channel b (khz, default 10) ? ",$)
      call gtrsp(itemp,10,luopi,nch) 
      if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      if (nch.ne.0) goto 505
      pcal = 10.
      goto 507
505   pcal = das2b(itemp,1,nch,ierr)
      if (pcal.le.0.0.or.ierr.lt.0.or.pcal.gt.50.) then
        goto 506
      else
        goto 507
      end if
506   write(luopo,9470)
9470  format(" phase cal. freq. must be >0 and <50khz, try again")
      goto 501
507   pcal = pcal*1.e3
C 
C     Get sample rate 
C 
508   write(luopo,9370)
9370  format(/" sample rate (mbit/s, default 4.0) ? ",$) 
      call gtrsp(itemp,10,luopi,nch) 
      if (nch.ne.0) goto 511
      smprt = 4.0 
      ism = 8 
      goto 520
511   if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      smprt = das2b(itemp,1,nch,ierr) 
      do 515 ism=1,8
          if (smprt.eq.bwdi(ism)) goto 520
515       continue
      write(luopo,9380) bwdi(1),(bwdi(i),i=3,8)
9380  format(" sample rate not one of "7(f5.3",") 
     . " try again")
      goto 508
520   iratfm = ism-1
C 
C     Set up ITRKPC 
C 
      if (.not.ksplit) itrkpc(1) = 100
      if (ksplit) itrkpc(1) = 2 
      do 530 i = 2,28 
        itrkpc(i) = 0 
530     continue
C 
C     Ask for # of cycles 
C 
540   write(luopo,9430)
9430  format(/" # of cycles through pcalr (default 1) ? ",$) 
      call gtrsp(itemp,10,luopi,nch) 
      if (nch.ne.0) goto 545
      ncycpc = 1
      goto 560
545   if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      ncycpc = ias2b(itemp,1,nch) 
      if (ncycpc.lt.0) goto 540 
C 
C     Ask for # of blocks to process
C 
560   write(luopo,9435)
9435  format(/" # of blocks to process (default 25) ? ",$) 
      call gtrsp(itemp,10,luopi,nch) 
      if (nch.ne.0) goto 565
      nblkpc = 25 
      goto 570
565   if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      nblkpc = ias2b(itemp,1,nch) 
      if (nblkpc.le.0) goto 560 
570   continue
C 
C     Ask for the debug level required. 
C 
      ipaupc = 0
      iquit = 0 
580   write(luopo,9460)
9460  format(/" debug level required (default 0) ? ",$)
      call gtrsp(itemp,10,luopi,nch) 
      if (nch.ne.0) goto 585
      ibugpc = 0
      goto 600
585   if (ichcm_ch(itemp(1),1,'::').eq.0) goto 990
      ibugpc = ias2b(itemp,1,nch) 
      if (ibugpc.eq.-32768) goto 580
      if (ibugpc.lt.0) iquit = ibugpc 
      ibugpc = iabs(ibugpc) 
600   continue
      ierr = 0
      if (.not.kfield) goto 990 
      luop = lu 
C 
990   continue
      if (ichcm_ch(itemp(1),1,'::').eq.0) ierr = -1 
C
      return
      end 
