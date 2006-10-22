      SUBROUTINE VLBAT(ksw,cSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .            IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,
     .            MJD,UT,GST,MON,IDA,LMON,LDAY,ISTNSK,ISOR,ICOD,
     .            IPASP,IBLK,IDIRP,IFTOLD,NCHAR,
     .            IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .            IYR2,IDAYR2,IHR2,MIN2,ISC2,LU,IDAYP,
     .            idayrp,ihrp,minp,iscp,iobs,irecp,
     .            idayr_save,ihr_save,min_save,isc_save)
C
C     VLBAT makes an observing file for VLBA DAR/REC systems
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      logical ksw ! true if switching
      character cSNAME(max_sorlen)
      integer*2 LSTN(MAX_STN),LMON(2),
     .LDAY(2),LPRE(3),LMID(3),LPST(3),ldir(max_stn),lfreq,
     .ldsign2
      integer IPAS(MAX_STN),
     .IFT(MAX_STN),IDUR(MAX_STN),ical,
     .iyr,idayr,ihr,imin,isc,nstnsk,mjd,mon,ida,istnsk,isor,icod,
     .ipasp,iblk,idirp,iftold,nchar,irah2,iram2,idecd2,
     .idecm2,iyr2,idayr2,ihr2,min2,isc2,lu,idayp,idayrp,ihrp,minp,
     .iscp,iobs,irecp,idayr_save,ihr_save,min_save,isc_save
      double precision gst,ut
      real ras2,decs2
C
C  LOCAL
        integer itemp
      integer izero2
      character*1 cspdir ! tape direction
      integer iblen
      integer ispin,irec,idir,ispinoff,ierr,ihead,idx,
     .ispins,iyrs,idayrs,ihrs,mins,iscs,
     .iwr,iyr3,idayr3,ihr3,min3,isc3,iyro,idayro,ihro,iftrem,
     .mino,isco,isp,i,nch,ispm,itu,idayrt,iyrt,ihrt,mint,isct
      real spdips,sps
      logical ktape,ktrack,kcont,kauto
      logical kspin ! true if we need to spin tape to get to the
C                       next observation
      logical kspinoff ! true if we need to spin the tape down
C                          to the end before changing it
      logical kend ! true if tape is positioned at 0 or max
      integer Z4000,Z100

      integer*2 ldirr
      LOGICAL KNEWTP,KNEWT !true for a new tape; new tape routine
      INTEGER ichmv,ichmv_ch ! function
        real tspin,speed ! functions
      integer iSpinDelay

      Data iSpinDelay/0/

C  INITIALIZED:
      DATA ldirr/2HR /
      DATA Z4000/Z'4000'/, Z100/Z'100'/
C
C
C  HISTORY:
C  890223 NRV REMOVED THIS CODE TO A SEPARATE ROUTINE
C  890324 NRV DECIDED TO USE LOOPING FOR FREQ. SWITCHING
C  890405 NRV CHANGES PER C. WALKER AFTER R&D-1 EXPERIMENT
C  890505 NRV CHANGED IDUR TO AN ARRAY BY STATION
C  890713 NRV CHANGED FREQUENCIES FOR WIDE-BAND R&D-3
C             ADDED ARRAY FOR HEAD OFFSET POSITION
C  890721 NRV ADDED MODE OPTION
C  890919 NRV ADDED DATE CHANGE OUTPUT
C  900316 NRV Changes per C. Walker request to reduce number of characters
C  900504 NRV Changes for "mode 1" to reduce number of characters
C  900810 gag removed "modes" and replaced with kswitch
C  901025 gag fixed some !NEXT! output with wrtap
C  910524 NRV Changed call to WRBBSYN to write buffers
C  910530 NRV Added spin at start of schedule to position tape
C  910705 NRV Added date output whenever it changes
C  910809 NRV Change spin speed to 330
C  921022 NRV Change wrtap call to add irec
C  930304 NRV Don't reset footage to 0 with new tape because we might
C             have to rewind to footage 0. Write out correct date if
C             the date changes in between spin blocks. Write out a block
C             to spin the tape down before changing tapes.
C  930407 nrv Implicit none
C  930708 nrv Get headstack position from arrays read from schedule file.
C  940127 nrv Call wrtrack with the sub-pass ("corresponding pass").
C  940215 nrv Reverse the track selection (got it wrong the first time).
C***********************************************************
C special version to write extra header lines for Bob's pol
C nrv 940617
C***********************************************************
C 960219 nrv Add KSW to call, true if switching.
C 960810 nrv Change itearl to an array
C 970114 nrv Change 8 to max_sorlen. May need to check out the fixed
C            array used for the 'sname' line.
C 970321 nrv Only call wrdur when changing direction for CONTINUOUS
C 970402 nrv Add !NEXT! between stopping tape and postpass.
C 970505 nrv Calculate IFTOLD with ITU=whether to use ITEARL or not.
C 970509 nrv Save tape start time to calculate end time for continuous.
C 970509 nrv Output the first source of a new pass as a new scan before
C            the setup for the new pass. Otherwise the tape will stop
C            before it reaches EOT.
C 970509 nrv Move code to WRSOR for writing the line with source name.
C 971015 nrv Don't write duplicate blocks for non-continuous.
C 980728 nrv Comment out lines no longer needed because VLBA is
C            now using dynamic tape allocation. These are marked
C            with Cdyn.
C 980924 nrv Replace the commented code for RDV11.
C 981207 nrv Comment out again.
C 990404 nrv Set idir=idirp for autoallocate.
C 990528 nrv Remove idir=idirp and let Setup blocks and STOP commands
C            be written. The innitial setup block is needed by operations.
C            The STOP commands give time for tape readbacks.
C 000614 nrv Don't do the block that runs the tape to the end of a pass
C            if tape has auto allocation.
C 011011 nrv New variable KAUTO used to set up for autoallocate.
C 011011 nrv Add KAUTO to wrtap call.
C 021014 nrv Change "seconds" argument in TSPIN to real.
C 2003Nov13 JMGipson.  Added extra argument to TSPIn
! 2006Sep28 JMGipson. Got rid of holleriths. Changed lspdir to ASCII
C
C  Initialization

      izero2 = 2+Z4000 + Z100*2
      kcont = tape_motion_type(istn).eq.'CONTINUOUS'
C
C  Add a comment if a new tape is to mounted before the next observation

      kauto = tape_allocation(istn).eq.'AUTO'
       irec=irecp
      if (kauto) irec = 1 ! always, for dynamic
      IDIR=+1
      IF (LDIR(ISTNSK).EQ.ldirr) IDIR=-1
      KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .    IDIRP,IFTOLD)
        ispinoff=0
        kspinoff=.false.
Cdyn
      if (kauto) knewtp = .false. ! always, for dynamic
C     Try letting the setup commands appear at tape reversals.
      if (kauto) idirp = idir ! always, for dynamic
Cdyn
      IF (KNEWTP) THEN ! new tape
        idirp=-1
          if (nrecst(istn).eq.1.and.iftold.gt.10) then !spin down the tape to the end
            ispinoff = ifix((270.0/330.0)*
     >                  tspin(iftold,ispm,sps,iSpinDelay))
            kspinoff = .true.
            if (kcont) kspinoff=.false.
            iftold=0
          endif
          if (iobs.le.1) then
            irec=1
          else ! Turn off recording on the current tape and postpass it
            if (nrecst(istn).eq.2) then !dual recorders
              iftold=0
              write(lu,*) " "
C             Form the line
C               write=(1,off)   tape=(1,STOP)  dur=0  stop=xxhxxmxxs  !NEXT!
              call tmadd(iyr,idayrp,ihrp,minp,iscp,2,
     .          iyrs,idayrs,ihrs,mins,iscs)
              if (idayrp.ne.idayrs) call wrdate(lu,iyr,idayrs)
              write(lu,'("write(",i1,",off) tape=(",i1,"STOP) ",$ )')
     >           irec,irec
              write(lu,'(" dur=0  stop",2i2,"h",2i2,"m",2i2,"s")')
     >           ihrs,mins,iscs
C             Do the postpass command:    tape=(1,POSTPASS)
              write(lu,"('tape=(',i1,',POSTPASS)')") irec
C             Now swap recorders
              if (irec.eq.1) then
                irec=2
              else
                irec=1
              endif
            endif
          endif
        write(lu,*) " "
        write(lu,'(a)') '!*   ** NEW TAPE **   *!'
        write(lu,*) " "
      ENDIF ! new tape

C   Setup block
        write(lu,*) " "

C     if (.not.kcont.or.(kcont.and.idir.ne.idirp)) then
C     Write setup for first scan iobs=0
      if ((kcont.and.iobs.eq.0).or.(kcont.and.idir.ne.idirp)) then 
C** Don't do this block if 'AUTO' -- no need to run to the end of the
C   tape with auto allocation. NRV 000614
        if (iobs.gt.1.and..not.knewtp.and.
     .    tape_allocation(istn).ne.'AUTO') then ! run to end of tape
          write(lu,'(a)') '!* New Scan *! '
          call wrsor(csname,irah2,iram2,ras2,ldsign2,idecd2,idecm2,
     .          decs2,lu)
          iftrem=float(maxtap(istn))/speed(icod,istn)
          call tmadd(iyr,idayr_save,ihr_save,min_save,
     .       isc_save,iftrem,IYRt,IDAYRt,IHRt,MINt,ISCt)
          call wrdur(ksw,1,0,1,ihrt,mint,isct,izero2,1,lu,0)
          write(lu,'(a)') " "
        endif ! run to end of tape
        write(lu,'(a)') '!* Setup *!    '
      else
        write(lu,'(a)') '!* New Scan *! '
      endif
C  Set dur=0 so that stop time is used by the system
C  The stop time for the setup block is the start time of the scan,
C  unless we need to spin the tape to a new position.

C  Set up tape parameters

      cspdir="-"

      if (ift(istnsk).gt.iftold.or.iobs.eq.0.or.knewtp) cspdir="+"
Cdyn
      if (kauto) cspdir="+"
C  ihead is the head offset position in microns
      IHEAD=ihdpos(1,IPAS(ISTNSK),istn,icod)
C  ihddir is not really "direction", it is the corresponding pass within
C  the mode. Use it to tell the wrtrack routine which tracks to record.
        idx = ihddir(1,ipas(istnsk),istn,icod)
        if (idx.eq.0) then
C         pause here
          itemp=1
        endif
C  The "corresponding pass" within the mode may be 1-28 depending on the
C  mode. It is not simply the direction, except for modes B and C. 

C  Calculate tape spin time and block stop time

      ispins = ifix((270.0/330.0)*
     >        TSPIN(IABS(IFT(ISTNSK)-IFTOLD),ISPM,SPS,ispindelay))
      kend = ift(istnsk).eq.0.or.ift(istnsk).eq.maxtap(istn)
      kspin = ispins.gt.10 .and. .not.kend .and. .not.kcont
      ispin=0
      if (ispins.gt.10.and.kend) ispin=330
      if (kcont) ispin=0
C  If this observation starts at either end of the tape,
C  then we don't need to have the spin blocks, just put REWIND in setup block.

      if (kspin.or.kspinoff) then !use previous stop+source time as the
C                                    stop time for the "setup" block
        if (iobs.eq.0) then !create fake previous stop
          call tmsub(iyr,idayr,ihr,imin,isc,2*isortm+ispins,
     .    iyr,idayrp,ihrp,minp,iscp)
        endif
        call tmadd(iyr,idayrp,ihrp,minp,iscp,isortm,
     .    iyrs,idayrs,ihrs,mins,iscs)
      else !use start time of scan
          iyrs=iyr
          idayrs=idayr
        ihrs=ihr
        mins=imin
        iscs=isc
      endif
        if (iobs.eq.0.or.idayrs.gt.idayrp) call wrdate(lu,iyr,idayrs)
C     Setup block. None needed for continuous unless change of direction.
      if ((kcont.and.iobs.eq.0).or..not.kcont.or.
     .    (kcont.and.idir.ne.idirp))
     .call wrdur(ksw,1,0,999,ihrs,mins,iscs,izero2,3,lu,1)

C  Source name, ra, dec in J2000 coordinates

      call wrsor(csname,irah2,iram2,ras2,ldsign2,idecd2,idecm2,decs2,lu)

C  Set up tracks for forward or reverse

      iwr = 0
      ktape = .false.
      ktrack = .false.
C     ktrack=.true. !****************** always write them for pol

      IF (IDIR.NE.IDIRP.or.iobs.eq.0) THEN !change direction
        ktrack = .true.  ! always write new tracks when changing direction
      else
        ktape = .true.
      ENDIF !change direction
Cdyn
      if (kauto) ktrack = .false. ! always, for dynamic
      if (kauto) ktape = .true.   ! always, for dynamic
Cdyn
Cdyn comment out this call to wrtap. The tape=stop is not needed.
Cdyn Well, it is needed to get parity checks done.
      IF (.not.kcont.or.(kcont.and.(IDIR.NE.IDIRP.or.iobs.eq.0))) THEN ! 
        call wrtap(cspdir,ispin,ihead,lu,iwr,ktape,irec,kauto) ! stop/head
        ktape = .false.
      endif
C************************************************
C       call vlbap(lu,icod,ierr)
C************************************************
      if (ktrack) then ! write out new tracks
        call wrtrack(idx,lu,iblen,icod)
      end if

C  Spin tape down to the end before changing it

        if (kspinoff) then !write spin block for old tape
        write(lu,'(a)') '!* Spin down old tape *!'
        CALL TMADD(IYR,IDAYRp,IHRp,MINp,ISCp,ispinoff+isortm,
     .         IYR3,IDAYR3,IHR3,MIN3,ISC3)
C         Stop time of this block is previous stop+ispinoff+isortm
        if (idayr3.ne.idayrs) call wrdate(lu,iyr3,idayr3)
        call wrdur(ksw,1,0,888,ihr3,min3,isc3,izero2,3,lu,1)
        ktape = .true.
        iwr = 0
        ispin = 330
        call wrtap("-",ispin,ihead,lu,iwr,ktape,irec,kauto)
C  Wait block - wait either the time to change the tape
C               or until the start time
        write(lu,'(a)') '!* Wait until new tape is mounted *!'
        if (kspin) then ! will spin the new tape after it's mounted
          call tmsub(iyr,idayr,ihr,imin,isc,ispins+10,
     .      iyro,idayro,ihro,mino,isco)
        else ! the next thing is the start time
            iyro=iyr
            idayro=idayr
            ihro=ihr
            mino=imin
            isco=isc
        endif
        if (idayro.gt.idayr3) call wrdate(lu,iyro,idayro)
        call wrdur(ksw,1,0,888,ihro,mino,isco,izero2,3,lu,1)
        ktape = .true.
        iwr = 0
        ispin=0
        call wrtap(cspdir,ispin,ihead,lu,iwr,ktape,irec,kauto)
      endif !write spin block for old tape

C  Spin tape if required

      if (kspin) then !write spin blocks
        write(lu,'(a)') '!* Spin *!'
        if (kspinoff) then
C           Stop time of this block is just start time minus 10
          call tmsub(iyr,idayr,ihr,imin,isc,10,
     .      iyr3,idayr3,ihr3,min3,isc3)
            if (idayr3.gt.idayro) call wrdate(lu,iyr3,idayr3)
          else ! no previous spin
C           Stop time of this block is previous stop+ispin+isortm
            CALL TMADD(IYR,IDAYRp,IHRp,MINp,ISCp,ispins+isortm,IYR3,
     .      IDAYR3,IHR3,MIN3,ISC3)
            if (idayr3.gt.idayrs) call wrdate(lu,iyr3,idayr3)
          endif
        call wrdur(ksw,1,0,888,ihr3,min3,isc3,izero2,3,lu,1)
        ktape = .true.
        iwr = 0
        ispin = 330
        call wrtap(cspdir,ispin,ihead,lu,iwr,ktape,irec,kauto)
        write(lu,'(a)') '!* Wait *!'
C  Wait block - wait until start time
        if (idayr.gt.idayr3) call wrdate(lu,iyr,idayr)
        call wrdur(ksw,1,0,888,ihr,imin,isc,izero2,3,lu,1)
        ktape = .true.
        iwr = 0
        ispin=0
        call wrtap(cspdir,ispin,ihead,lu,iwr,ktape,irec,kauto)
      endif !write spin blocks

C  This is the block for recording

      if (.not.kcont.or.(kcont.and.idir.ne.idirp)) then ! write setup comment
        write(lu,"(a)")'!* Record *!'
      endif
      if (idayr2.gt.idayr) call wrdate(lu,iyr2,idayr2)

C *** First cycle: specify channel assignments
C  Start the tape moving

      CALL M3INF(ICOD,SPDIPS,ISP)
      ISP=SPDIPS*135.0/120.0
Cdyn  The tape direction has already been set up above
      IF (IDIR.EQ.+1) then
        cspdir="+"
      else
        cspdir="-"
      end if
Cdyn  Comment out the above for auto
      iwr = 1
      ktape=.false.
      if (.not.kcont.or.(kcont.and.(idir.ne.idirp))
     ..or.(kcont.and.iobs.eq.0))
     .call wrtap(cspdir,isp,ihead,lu,iwr,ktape,irec,kauto)

C  Loop begins in this block

      IF (ksw) THEN

C  Scan stop time = end of loop blocks

C wrdur(ksw,istart,idur,iqual,ih,im,is,izero2,izero3,lu,setup)
        call wrdur(ksw,14,15,1,ihr2,min2,isc2,izero2,1,lu,0)
      ELSE
        call wrdur(ksw,1,0,1,ihr2,min2,isc2,izero2,1,lu,0)
      ENDIF

C  Set up converter frequencies

      IF (ksw) THEN !write loop
C       Write out set 1 of BBC frequencies
        do i=1,nbbcbuf(1)
          cbuf=" "
          nch = ichmv(ibuf,1,ibbcbuf(1,1,i),1,ibbclen(1,i))
          if (i.eq.nbbcbuf(1)) nch = ichmv_ch(ibuf,nch+1,'!NEXT! ')
          call writf_asc(lu,ierr,ibuf,nch/2)
        enddo

        write(lu,'(a)')' qual=2 '

C       Write out set 2 of BBCs
        do i=1,nbbcbuf(2)
          call writf_asc(lu,ierr,ibbcbuf(1,2,i),ibbclen(2,i)/2)
        enddo

C       Mark end of loop
        write(lu,'(a)') '!LOOP BACK! !NEXT!'
      end if ! write loop

C  (save the last write for the end of outer loop)
C  Save tape info for checking on next pass

      IPASP=IPAS(ISTNSK)
C     IFTOLD=IFT(ISTNSK)+IFIX(IDIR*(ITEARL(istn)+IDUR(ISTNSK))*
C    .              SPEED(ICOD,istn))
      itu=itearl(istn)
      if (tape_motion_type(istn).eq.'CONTINUOUS'.and.
     .idir.eq.idirp) itu=0
      IFTOLD=IFT(ISTNSK)+IFIX(IDIR*(itu+IDUR(ISTNSK))*
     .              SPEED(ICOD,istn))
      IDAYP=IDAYR
      idayrp=idayr2
      ihrp=ihr2
      minp=min2
      iscp=isc2
        irecp=irec
      if (idir.ne.idirp) then ! save tape start time
        idayr_save=idayr
        ihr_save=ihr
        min_save=imin
        isc_save=isc
      endif ! save tape start time
      IDIRP=IDIR
C
      RETURN
      END

