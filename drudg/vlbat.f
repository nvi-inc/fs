	SUBROUTINE VLBAT(ksw,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .            IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,
     .            MJD,UT,GST,MON,IDA,LMON,LDAY,ISTNSK,ISOR,ICOD,
     .            IPASP,IBLK,IDIRP,IFTOLD,NCHAR,
     .            IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .            IYR2,IDAYR2,IHR2,MIN2,ISC2,LU,IDAYP,
     .            idayrp,ihrp,minp,iscp,iobs,irecp)
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
        integer*2 LSNAME(4),LSTN(MAX_STN),LMON(2),
     .LDAY(2),LPRE(3),LMID(3),LPST(3),ldir(max_stn),lfreq,
     .ldsign2
        integer IPAS(MAX_STN),
     .IFT(MAX_STN),IDUR(MAX_STN),ical,
     .iyr,idayr,ihr,imin,isc,nstnsk,mjd,mon,ida,istnsk,isor,icod,
     .ipasp,iblk,idirp,iftold,nchar,irah2,iram2,idecd2,
     .idecm2,iyr2,idayr2,ihr2,min2,isc2,lu,idayp,idayrp,ihrp,minp,
     .iscp,iobs,irecp
      real*8 gst,ut
      real*4 ras2,decs2
C
C  LOCAL
        integer itemp
	integer izero2,izero3
        integer*2 lspdir,lsodir ! tape direction
	integer iblen
	integer*2 isname(23),blank10(5)
	integer ispin,irec,idir,ispinoff,idum,ierr,ihead,idx,
     .ispins,iyrs,idayrs,ihrs,mins,iscs,iras,isra,idecs,idec2d,
     .iwr,iyr3,idayr3,ihr3,min3,isc3,iyro,idayro,ihro,
     .mino,isco,isp,i,nch,ispm,isps,in
      real*4 spdips
	logical ktape,ktrack
        logical kspin ! true if we need to spin tape to get to the
C                       next observation
        logical kspinoff ! true if we need to spin the tape down
C                          to the end before changing it
        logical kend ! true if tape is positioned at 0 or max
	integer Z4000,Z100
        integer*2 oapostrophe
	integer*2 ldirr
	LOGICAL KNEWTP,KNEWT !true for a new tape; new tape routine
	INTEGER ib2as,ichmv,iflch,ichmv_ch ! function
        real*4 tspin,speed ! functions

C  INITIALIZED:
	DATA ldirr/2HR /
        data blank10/'  ','  ','  ','  ','  '/
	DATA isname/'sn','am','e=',''' ','  ','  ','  ','  ',
     . ' r','a=','00',
     . 'h0','0m','00','.0','s ','de','c=',' 0','0d','00','''0','0"'/
	DATA Z4000/Z'4000'/, Z100/Z'100'/, oapostrophe/2h' /
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
C
C  Initialization

	izero2 = 2+Z4000 + Z100*2
	izero3 = 3+Z4000 + Z100*3
	iblen = 2*IBUF_LEN
C
C  Add a comment if a new tape is to mounted before the next observation

        irec=irecp
	IDIR=+1
	IF (LDIR(ISTNSK).EQ.ldirr) IDIR=-1
	KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .    IDIRP,IFTOLD)
        ispinoff=0
        kspinoff=.false.
	IF (KNEWTP) THEN
          if (nrecst(istn).eq.1.and.iftold.gt.10) then !spin down the tape to the end
            ispinoff = ifix((270.0/330.0)*tspin(iftold,ispm,isps))
            kspinoff = .true.
            iftold=0
          endif
          if (iobs.eq.0) then
            irec=1
          else ! Turn off recording on the current tape
            if (nrecst(istn).eq.2) then !dual recorders
              iftold=0
              call char2hol('write=(0,off) ',ibuf,1,14)
              idum = ib2as(irec,ibuf,8,1)
              call char2hol('tape=(0,stop) ',ibuf,15,28)
              idum = ib2as(irec,ibuf,21,1)
              call writf_asc(lu,ierr,ibuf,14)
C             Now swap recorders
              if (irec.eq.1) then
                irec=2
              else
                irec=1
              endif
            endif
          endif
	  call char2hol('  ',IBUF(1),1,2)
	  CALL writf_asc(LU,IERR,IBUF,1)
	  call char2hol('!*   ** NEW TAPE **   *!',ibuf(1),1,24)
	  CALL writf_asc(LU,IERR,IBUF,12)
	  call char2hol('  ',IBUF(1),1,2)
	  CALL writf_asc(LU,IERR,IBUF,1)
	  call ifill(ibuf,1,iblen,32)
	ENDIF

C   Setup block

	call char2hol('  ',IBUF,1,2)
	CALL writf_asc(LU,IERR,IBUF,1)
	call char2hol('!* Setup *! ',ibuf(1),1,12)
	CALL writf_asc(LU,IERR,IBUF,6)
	call ifill(ibuf,1,iblen,32)
C  Set dur=0 so that stop time is used by the system
C  The stop time for the setup block is the start time of the scan,
C  unless we need to spin the tape to a new position.

C  Set up tape parameters

	call char2hol('-',LSPDIR,1,1)
	if (ift(istnsk).gt.iftold.or.iobs.eq.0.or.knewtp)
     .  call char2hol('+',LSPDIR,1,1)
C  ihead is the head offset position in microns
	IHEAD=ihdpos(IPAS(ISTNSK),istn,icod)
C  ihddir is not really "direction", it is the corresponding pass within
C  the mode. Use it to tell the wrtrack routine which tracks to record.
        idx = ihddir(ipas(istnsk),istn,icod)
        if (idx.eq.0) then
C         pause here
          itemp=1
        endif
C  The "corresponding pass" within the mode may be 1-28 depending on the
C  mode. It is not simply the direction, except for modes B and C. 

C  Calculate tape spin time and block stop time

	ispins = ifix((270.0/330.0)*TSPIN(
     .             IABS(IFT(ISTNSK)-IFTOLD),ISPM,ISPS))
	kend = ift(istnsk).eq.0.or.ift(istnsk).eq.maxtap(istn)
	kspin = ispins.gt.10 .and. .not.kend
	ispin=0
	if (ispins.gt.10.and.kend) ispin=330
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
	call wrdur(ksw,1,0,999,ihrs,mins,iscs,izero2,3,lu,1)

C  Source name, ra, dec in J2000 coordinates

	IRAS = RAS2+.05
	isra = ((ras2-iras)*10.0)+.5
	IDECS = DECS2+0.5
	if (idecs.ge.60) then
	  idecs=idecs-60
	  idecm2=idecm2+1
	endif
	if (idecm2.ge.60) then
	  idecm2=idecm2-60
	  idecd2=idec2d+1
	endif
        in=iflch(lsname,8)
        idum = ichmv(isname,8,blank10,1,9)
	idum = ichmv(isname,8,lsname,1,in)
        idum = ichmv(isname,8+in,oapostrophe,1,1)
	idum = ib2as(irah2,isname,21,izero2)
	idum = ib2as(iram2,isname,24,izero2)
	idum = ib2as(iras,isname,27,izero2)
	idum = ib2as(isra,isname,30,1)
	idum = ichmv(isname,37,ldsign2,1,1)
	idum = ib2as(idecd2,isname,38,izero2)
	idum = ib2as(idecm2,isname,41,izero2)
	idum = ib2as(idecs,isname,44,izero2)
	CALL writf_asc(LU,IERR,isname,23)
	call ifill(ibuf,1,iblen,32)

C  Set up tracks for forward or reverse

	iwr = 0
	ktape = .false.
        ktrack = .false.
        ktrack=.true. !****************** always write them for pol

        IF (IDIR.NE.IDIRP) THEN !change direction
          ktrack = .true.  ! always write new tracks when changing direction
	else
	  ktape = .true.
	ENDIF !change direction

	call wrtap(lspdir,ispin,ihead,lu,iwr,ktape,irec)
	ktape = .false.
	call ifill(ibuf,1,iblen,32)
C************************************************
C       call vlbap(lu,icod,ierr)
C************************************************
	if (ktrack) then ! write out new tracks
          call wrtrack(idx,lu,iblen,icod)
	  call ifill(ibuf,1,iblen,32)
	end if

C  Spin tape down to the end before changing it

        if (kspinoff) then !write spin block for old tape
	  call char2hol('!* Spin down old tape *!',ibuf,1,24)
	  CALL writf_asc(LU,IERR,IBUF,12)
	  call ifill(ibuf,1,iblen,32)
	  CALL TMADD(IYR,IDAYRp,IHRp,MINp,ISCp,ispinoff+isortm,
     .         IYR3,IDAYR3,IHR3,MIN3,ISC3)
C         Stop time of this block is previous stop+ispinoff+isortm
          if (idayr3.ne.idayrs) call wrdate(lu,iyr3,idayr3)
	  call wrdur(ksw,1,0,888,ihr3,min3,isc3,izero2,3,lu,1)
	  ktape = .true.
	  iwr = 0
	  ispin = 330
          call char2hol('-',LSoDIR,1,1)
	  call wrtap(lsodir,ispin,ihead,lu,iwr,ktape,irec)
C  Wait block - wait either the time to change the tape
C               or until the start time
          call char2hol('!* Wait until new tape is mounted *!',
     .    ibuf,1,36)
	  CALL writf_asc(LU,IERR,IBUF,18)
	  call ifill(ibuf,1,iblen,32)
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
	  call wrtap(lspdir,ispin,ihead,lu,iwr,ktape,irec)
	endif !write spin block for old tape

C  Spin tape if required

	if (kspin) then !write spin blocks
	  call char2hol('!* Spin *!',ibuf,1,10)
	  CALL writf_asc(LU,IERR,IBUF,5)
	  call ifill(ibuf,1,iblen,32)
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
	  call wrtap(lspdir,ispin,ihead,lu,iwr,ktape,irec)
	  call char2hol('!* Wait *!',ibuf,1,10)
	  CALL writf_asc(LU,IERR,IBUF,5)
	  call ifill(ibuf,1,iblen,32)
C  Wait block - wait until start time
          if (idayr.gt.idayr3) call wrdate(lu,iyr,idayr)
	  call wrdur(ksw,1,0,888,ihr,imin,isc,izero2,3,lu,1)
	  ktape = .true.
	  iwr = 0
	  ispin=0
	  call wrtap(lspdir,ispin,ihead,lu,iwr,ktape,irec)
	endif !write spin blocks

C  This is the block for recording

	call char2hol('!* Record *!',ibuf,1,12)
	CALL writf_asc(LU,IERR,IBUF,6)
	call ifill(ibuf,1,iblen,32)
        if (idayr2.gt.idayr) call wrdate(lu,iyr2,idayr2)

C *** First cycle: specify channel assignments
C  Start the tape moving

	CALL M3INF(ICOD,SPDIPS,ISP)
	ISP=SPDIPS*135.0/120.0
	IF (IDIR.EQ.+1) then
	  call char2hol('+',LSPDIR,1,1)
	else
	  call char2hol('-',LSPDIR,1,1)
	end if
	iwr = 1
        ktape=.false.
	call wrtap(lspdir,isp,ihead,lu,iwr,ktape,irec)

C  Loop begins in this block

	IF (ksw) THEN

C  Scan stop time = end of loop blocks

C wrdur(istart,idur,iqual,ih,im,is,izero2,izero3,lu,setup)
	  call wrdur(ksw,14,15,1,ihr2,min2,isc2,izero2,1,lu,0)
	ELSE
	  call wrdur(ksw,1,0,1,ihr2,min2,isc2,izero2,1,lu,0)
	ENDIF

C  Set up converter frequencies

	IF (ksw) THEN !write loop
	  call ifill(ibuf,1,iblen,32)

C       Write out set 1 of BBC frequencies
	  do i=1,nbbcbuf(1)
	    call ifill(ibuf,1,iblen,32)
	    nch = ichmv(ibuf,1,ibbcbuf(1,1,i),1,ibbclen(1,i))
	    if (i.eq.nbbcbuf(1)) nch = ichmv_ch(ibuf,nch+1,'!NEXT! ')
	    call writf_asc(lu,ierr,ibuf,nch/2)
	  enddo

	  call ifill(ibuf,1,iblen,32)
	  call char2hol(' qual=2 ',ibuf,1,8)
	  CALL writf_asc(LU,IERR,IBUF,4)

C       Write out set 2 of BBCs
	  do i=1,nbbcbuf(2)
	    call writf_asc(lu,ierr,ibbcbuf(1,2,i),ibbclen(2,i)/2)
	  enddo

C       Mark end of loop
	  call char2hol('!LOOP BACK! !NEXT!',ibuf,1,18)
	  CALL writf_asc(LU,IERR,IBUF,9)
	  call ifill(ibuf,1,iblen,32)

	end if ! write loop

C  (save the last write for the end of outer loop)
C  Save tape info for checking on next pass

	IPASP=IPAS(ISTNSK)
        IFTOLD=IFT(ISTNSK)+IFIX(IDIR*(ITEARL(istn)+IDUR(ISTNSK))*
     .              SPEED(ICOD,istn))
	IDIRP=IDIR
	IDAYP=IDAYR
	idayrp=idayr2
	ihrp=ihr2
	minp=min2
	iscp=isc2
        irecp=irec
C
	RETURN
	END

