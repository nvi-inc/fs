	SUBROUTINE LISTS    !LIST ONE STATION'S SCHEDULE 

C This routine lists on the printer a schedule
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C INPUT: none
C OUTPUT: none
C LOCAL:
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .LMON(2),
     . LDAY(2),LMID(3),LPRE(3),LPST(3),LDIR(MAX_STN)
      integer ipas(max_stn),ift(max_stn),idur(max_stn)
      integer ipasp,iftold,idirp,idir
      integer i,j,k,id
      real wlon,alat,al11,al12,al21,al22,rt1,rt2
      real az,el,x30,y30,x85,y85,dc,ha1
      real speed,spdips
      integer irah,iram,idecd,idecm
      integer*2 lhsign,ldsign
      integer irh3,irh2,irm3,irh1,irm1,irm2,ihah,iham
      integer*2 lds3,lds1,lds2
      integer idd3,idm3,idd1,idm1,idd2,idm2
      real ras,decs,ras3,ras2,ras1,dcs1,dcs2,dcs3,has,d
      real tslew,dum
      integer iyr,idayr,ihr,imin,isc,mjd,mon,ida,ical,icod,
     .mjdpre,ispre,iyr2,idayr2,ihr2,min2,isc2
      integer*2 lfreq,lcbpre,lcbnew
      double precision UT,GST,utpre ! previous value required for slewing
      integer nstnsk,istnsk,isor,nsat,ivc
      character*7 cwrap ! cable wrap string returned from CBINF 
C NSTNSK - number of stations in current observation
C ISTNSK - which station corrresponds to ISTN
      integer nlobs,nlmax,nlines,ntapes,ierr,ilen,npage
C NLOBS - number of observation lines written for this station
C NLINES, Lnobs, NTAPES - number of lines on a page, observations, tapes
C NLMAX - number of lines max per page
      INTEGER IC, TRIMLEN
      LOGICAL KNEWT
C function to determine if a new tape has started
      double precision RA,DEC
      double precision TJD,RAH,DECD,RADH,DECDD
C for precession routines
      double precision HA
      integer*2 LAXIS(2,7),lax1,lax2
      integer idum,lnobs
C names of axis types
      LOGICAL KUP ! true if source is up at station
      logical kwrap
Cinteger*4 ifbrk
      integer*2 HHR
      integer iflch,ichmv,julda,jchar ! functions
      DATA HHR/2HR /
C
C SUBROUTINES CALLED:
C  FMP routines to read schedule file
C  UNPSK - unpacks schedule file entry
C  CVPOS - calculates az, el, ha, and tests limit stops
C  TSTOP - calculates stop time
C  RADED - returns integers for hms
C  SLEWT - calculates slewing time
C
C INITIALIZED:
      DATA IPASP/-1/, IFTOLD/0/, IDIRP/0/
      DATA LAXIS /2HHA,2HDC,2HXY,2HEW,2HAZ,2HEL,2HXY,2HNS,2HRI,2HCH,
     .2hSE,2hST,2hAL,2hGO/
C
C WHO DATE   CHANGES
C NRV 830818 ADDED SATELLITE CALCULATIONS
C MWH 840813 Added printer LU lock, added exper name to header
C NRV 880708 Changed output for different print widths
C NRV 890130 Changed MOVE to APSTAR for apparent place
C NRV 890505 Changed IDUR to an array by station
C PMR 900108 changed to write to temp file
C NRV 900413 Added BREAK, changed printer call to use control file var.
C NRV 910306 Added an output line about early start.
C NRV 910703 Added PRTMP call at end.
C nrv 930407 implicit none
C nrv 931123 **************************************************
C            Removed call to SLEWT because the new routine now requires
C            sked common. Need to make another version for drudg.
C nrv 940107 Change SLEWT to SLEWO (old version)
C nrv 940131 Add types 6 and 7 to LAXIS
C            Write cable wrap on output line
C 960810 nrv Change itearl to array
C 961105 nrv Add one space to bandwidth so values >10 are correct.
C 970114 nrv Change lsname(4) to (max_sorlen/4). Change printing of
C            lsname to use first 8 char only.
C 970121 nrv Add NLOBS to keep proper track of scans for this station.
C
C 1. First initialize counters.  Read the first observation,
C unpack the record, and set the PREvious variables to the
C current values for initialization.
C
	if (iwidth.eq.80) then
	  nlmax = 23
	else
	  nlmax = 23
	end if
      NLINES = 0
      NTAPES = 0
      LNOBS = 0
      nlobs = 0 ! number of scan line written 
      kwrap=.false.
      if (iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn).eq.7)
     .kwrap=.true.
C     CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
      call ifill(ibuf,1,ibuf_len*2,oblank)
      if (lnobs+1.le.nobs) then
        idum = ichmv(ibuf,1,lskobs(1,lnobs+1),1,ibuf_len*2)
        ilen = iflch(ibuf,ibuf_len*2)
      else
        ilen=-1
      endif
      CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .     LFREQ,IPAS,LDIR,IFT,LPRE,
     .     IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .     NSTNSK,LSTN,LCABLE,
     .     MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG)
      CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
C
      IF (ISOR.EQ.0.OR.ICOD.EQ.0) THEN
        RETURN
      ENDIF
      IPASP=-1
      IDIRP=0
      MJDPRE = MJD
      UTPRE = UT
      ISPRE = ISOR
      CALL CHAR2HOL('  ',LCBPRE,1,2)
C
      IC = TRIMLEN(LSKDFI)
      WRITE(LUSCN,100) (LSTNNA(I,ISTN),I=1,4),LSKDFI(1:ic) ! new
100   FORMAT(' Schedule listing for ',4A2,' from file ',A) ! was A32
      WLON = STNPOS(1,ISTN)*180.0/PI
      ALAT = STNPOS(2,ISTN)*180.0/PI
      LAX1 = LAXIS(1,IAXIS(ISTN))
      LAX2 = LAXIS(2,IAXIS(ISTN))
      Rt1 = STNRAT(1,ISTN)*180.0*60.0/PI
      Rt2 = STNRAT(2,ISTN)*180.0*60.0/PI
      AL11 = STNLIM(1,1,ISTN)*180.0/PI
      AL21 = STNLIM(2,1,ISTN)*180.0/PI
      AL12 = STNLIM(1,2,ISTN)*180.0/PI
      AL22 = STNLIM(2,2,ISTN)*180.0/PI
C
C      open(unit=luprt,file=cportprn,iostat=ierr)
Cc     OPEN(UNIT=LUPRT,FILE=TMPNAME,STATUS='UNKNOWN',IOSTAT=IERR)
C      IF (IERR.NE.0) THEN
Cc       REWIND(LUPRT)
CC     ELSE
C        WRITE(LUSCN,9061) IERR
Cc9061   FORMAT(' LISTS01 - ERROR ',I5,' OPENING TEMP FILE ',A)
C9061    FORMAT(' LISTS01 - ERROR ',I5,' ACCESSING printer ')
C        RETURN
C      ENDIF
C
	call setprint(ierr,iwidth,1)
      if (ierr.ne.0) then
        write(luscn,9061) ierr
9061    format(' LISTS01 - Error ',I5,' opening printer')
        return
      end if

      WRITE(luprt,99) (LSTNNA(I,ISTN),I=1,4),(LEXPER(i),i=1,4),
     .WLON,ALAT,LAX1,LAX2,
     .LAX1,Rt1,AL11,AL21,LAX2,Rt2,AL12,AL22
99    FORMAT(/////5X,'SCHEDULE FOR  ',
     . 4A2,'  EXPERIMENT  ',4A2///
     .10X,'Longitude ',F8.2,' degrees WEST'/
     .10X,'Latitude  ',F8.2,' degrees NORTH'/
     .10X,'Axis type ',A2,'-',A2//
     .2(10X,A2,' axis:  slew rate ',F6.1,' deg/min,  limits ',
     .F6.1,' to ',F6.1,' degrees'/)////)
C
Cif (ifbrk().lt.0) goto 900
      WRITE(luprt,96)
96    FORMAT(' Headings for schedule listings have the following meaning
     .s:'///
     .'    START         - the time this observation starts (UT)'/
     .'    STOP          - the time this observation stops (UT)'/
     .'    SOURCE        - the source name'/
     .'    RA(1950)      - 1950 right ascension'/
     .'    DEC(1950)     - 1950 declination'/
     .'    HA,AZ,EL      - the current hour angle (computed using positi
     .on of date)'/
     .'    SLEW          - time in minutes needed to slew from the PREVI
     .OUS source'/
     .'    CAL           - time in seconds allowed for calibration befor
     .e the observation begins'/
     .'    CONFIGURATION - the Mark III configuration'/
     .'      ff (e.g. SX)  frequency code'/
     .'      m  (e.g. B)   observing mode'/
     .'      b  (e.g. 2)   bandwidth (MHz)'/
     .'      pd (e.g. 1F)  pass number and direction of tape'/
     .'      foot          approx. tape footage at start of observation'
     ./'      speed         tape speed, ips'/
     . )
C
      CALL LUFF(LUPRT)
      WRITE(luprt,97) IYR,MON,IDA
97    FORMAT(' ',////'     SOURCES IN THIS SCHEDULE',10X,
     .    '(DATE=',I4,2I2.2,')'///)
      IF (IWIDTH.EQ.137.OR.IWIDTH.EQ.106) THEN
        WRITE(LUPRT,98)
98      FORMAT(8X,'NAME     -RA(1950)-  -DEC(1950)-      -RA(DATE)-  ',
     .   '-DEC(DATE)-      -RA(2000)-  -DEC(2000)-'/)
      ELSE IF (IWIDTH.EQ.80) THEN
        WRITE(luprt,94)
94      FORMAT(8X,'NAME     -RA(1950)-  -DEC(1950)-      -RA(DATE)-  ',
     .   '-DEC(DATE)-'/)
      ENDIF
C
	DO 90 I=1,NCELES
C  if (ifbrk().lt.0) goto 900
        RA = SORP50(1,I)
        DEC = SORP50(2,I)
        RAH = RA*12.D0/PI
        DECD = DEC*180.D0/PI
        TJD = JULDA(MON,IDA,IYR-1900) + 2440000.0D0
C
        CALL APSTAR(TJD,3,RAH,DECD,0.D0,0.D0,0.D0,0.D0,RADH,DECDD)
        SORPDA(1,I) = RADH*PI/12.D0
        SORPDA(2,I) = DECDD*PI/180.D0
        CALL RADED(RA50(I),DEC50(I),0.d0,IRH3,IRM3,RAS3,LDS3,
     .        IDD3,IDM3,DCS3,LD,ID,ID,D)
        CALL RADED(SORP50(1,I),SORP50(2,I),0.d0,IRH1,IRM1,RAS1,LDS1,
     .        IDD1,IDM1,DCS1,LD,ID,ID,D)
        CALL RADED(SORPDA(1,I),SORPDA(2,I),0.d0,IRH2,IRM2,RAS2,LDS2,
     .        IDD2,IDM2,DCS2,LD,ID,ID,D)
C
        IF (IWIDTH.EQ.137.OR.IWIDTH.EQ.106)
     .  WRITE(LUPRT,91) (LSORNA(J,I),J=1,4),IRH3,IRM3,RAS3,LDS3,
     .      IDD3,IDM3,DCS3,IRH2,IRM2,RAS2,LDS2,
     .      IDD2,IDM2,DCS2,IRH1,IRM1,RAS1,LDS1,IDD1,IDM1,DCS1
91      FORMAT(6X,4A2,'  ',3(I2.2,':',I2.2,':',F5.2,'  ',
     .         A1,I2.2,':',I2.2,':',F4.1,'     '))
        IF (IWIDTH.EQ.80)
     .  WRITE(luprt,91) (LSORNA(J,I),J=1,4),IRH3,IRM3,RAS3,LDS3,
     .      IDD3,IDM3,DCS3,IRH2,IRM2,RAS2,LDS2,IDD2,IDM2,DCS2
90    CONTINUE
C
      IF (NSATEL.EQ.0) GOTO 102
      WRITE(luprt,9141)
9141  FORMAT(' ',/'  #  SATELLITE INC    ECC    PERIG  NODE   ANOM   ',
     .        'AXIS       MOTION  YEAR DAY'/
     .        '               (deg)         (deg)  (deg)  (deg)  ',
     .        '(km)       (rv/dy)         ')
	DO 150 NSAT=1,NSATEL
C  if (ifbrk().lt.0) goto 900
        I=NCELES+NSAT
        WRITE(luprt,9150) I,(LSORNA(K,I),K=1,4),(SATP50(J,NSAT),J=1,7),
     .       ISATY(NSAT),SATDY(NSAT)
9150    FORMAT(I4,1X,4A2,1X,F7.2,F7.5,3F7.2,F11.1,F8.3,I5,F7.2)
150   CONTINUE
C
102   NPAGE = 1
      call luff(luprt)
	WRITE(luprt,101) (LSTNNA(I,ISTN),I=1,4),LEXPER,
     .      LDAY,LMON,IDA,IYR,IDAYR,NPAGE
101   FORMAT(' ',//' SCHEDULE FOR ',4A2,' EXPERIMENT ',4A2,
     .       'ON ',2A2,', ',2A2,' ',I2.2,', ',
     .       I4,' (DAY ',I3,')',10X,'Page ',I3//)
	if (itearl(istn).gt.0) then
	  write(luprt,'(" ***** NOTE: Tape will start moving ",i3,
     .  " seconds before start time. *****"/)') itearl(istn)
	else
	  write(luprt,'(/)')
	 endif
C
      if (kwrap) then ! print cable wrap
        IF (IWIDTH.EQ.137) THEN
          WRITE(LUPRT,1137)
        ELSE IF (IWIDTH.EQ. 80) THEN
          WRITE(luprt,1080)
        ENDIF
      else ! no cable wrap output
        IF (IWIDTH.EQ.137) THEN
          WRITE(LUPRT,9137)
        ELSE IF (IWIDTH.EQ. 80) THEN
          WRITE(luprt,9080)
        ENDIF
      endif
9137  FORMAT('  START  - STOP     -SOURCE-  -RA(1950)-- -DEC(1950)- ',
     .'--HA-- -AZ--  -EL- SLEW CAL MARK III CONFIGURATION'//)
9080  FORMAT('  START  - STOP     -SOURCE- ',
     .       '--HA-- -AZ--  -EL- SLEW --TAPE---'//)
1137  FORMAT('  START  - STOP     -SOURCE-  -RA(1950)-- -DEC(1950)- ',
     .'--HA-- -AZ--  -EL- CABLE SLEW CAL MARK III CONFIGURATION'//)
1080  FORMAT('  START  - STOP     -SOURCE- ',
     .       '--HA-- -AZ--  -EL- CABLE SLEW --TAPE---'//)
C
C 2. Begin the loop on schedule entries.  Check that the source
C is in the list, and the requested station is in the observation.
      DO WHILE (IERR.GE.0.AND.ILEN.GT.0.AND.JCHAR(IBUF,1).NE.ODOLLAR)
C DO BEGIN Loop on observations
        CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
        IF (ISOR.EQ.0.OR.ICOD.EQ.0) GOTO 900
C
C 3. Set up major block for calculations and printing.
C Skip this if the current station is not in the list
C of stations in this observation.
C Unless we are spinning blank tape, in which case list
C the observation with a message.
        IF (ISTNSK.NE.0)  THEN
C THEN BEGIN Current station in observation
          IF (NLINES.GE.NLMAX.OR.MJD.NE.MJDPRE) THEN
C THEN BEGIN new page
            NPAGE = NPAGE + 1
            call luff(luprt)
		WRITE(luprt,101) (LSTNNA(I,ISTN),I=1,4),LEXPER,
     .            LDAY,LMON,IDA,IYR,IDAYR,NPAGE
		if (itearl(istn).gt.0) then
		  write(luprt,'(" ***** NOTE: Tape will start moving ",i3,
     .        " seconds before start time. *****"/)') itearl(istn)
		else
		  write(luprt,'(/)')
		 endif
            if (kwrap) then
            IF (IWIDTH.EQ.137) THEN
              WRITE(LUPRT,1137)
            ELSEIF (IWIDTH.EQ. 80) THEN
              WRITE(luprt,1080)
            ENDIF
            else
            IF (IWIDTH.EQ.137) THEN
              WRITE(LUPRT,9137)
            ELSEIF (IWIDTH.EQ. 80) THEN
              WRITE(luprt,9080)
            ENDIF
            endif
            NLINES = 0
C ENDT new page
          ENDIF
          IDIR=+1
          IF (LDIR(ISTNSK).EQ.HHR)IDIR=-1
          IF (KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,
     .        IDIR,IDIRP,IFTOLD)) THEN
C THEN BEGIN new tape
            WRITE(luprt,9320)
9320        FORMAT('    *** NEW TAPE ***'/)
            NTAPES = NTAPES + 1
            NLINES = NLINES + 1
          ENDIF
C
C ENDT new tape
C 4. Calculate all of the numbers we need now.
          ID=IDUR(ISTNSK)
          CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,ID,
     .               IYR2,IDAYR2,IHR2,MIN2,ISC2)
          HA1 = HA
C CONVERT TO SINGLE PRECISION
          CALL CVPOS(ISOR,ISTN,MJD,UT,AZ,EL,HA1,DC,X30,Y30,X85,Y85,
     .               KUP)
          HA = HA1
C CONVERT BACK TO DOUBLE
          AZ = AZ*180.0/PI
          EL = EL*180.0/PI
          IF (ISOR.LE.NCELES) THEN
            CALL RADED(RA50(ISOR),DEC50(ISOR),HA,
     .           IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,
     .           LHSIGN,IHAH,IHAM,HAS)
          ELSE
            CALL RADED(0.D0,0.D0,HA,
     .           IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,
     .           LHSIGN,IHAH,IHAM,HAS)
          ENDIF
C
          IF (KUP) THEN !source is up
            lcbnew=lcable(istnsk)
            CALL SLEWo(ISPRE,MJDPRE,UTPRE,ISOR,ISTN,
     .           LCBPRE,LCBNEW,TSLEW,0,dum)
            TSLEW = TSLEW/60.0
            MJDPRE = MJD
            LCBPRE = LCBNEW
            ISPRE = ISOR
            UTPRE = UT+IDUR(ISTNSK)
          ELSE !source not up
            TSLEW = 9999.9
            WRITE(luprt,9330)
9330        FORMAT('  THE FOLLOWING SOURCE IS OUTSIDE TELESCOPE ',
     .             'LIMITS.  INFORM THE SCHEDULER!'/)
                  NLINES = NLINES + 1
C ENDE source not up
          ENDIF
C
C     5. Now write out the observation line.
          CALL M3INF(ICOD,SPDIPS,IVC)
          call cbinf(lcable(istnsk),cwrap)
          if (kwrap) then ! print cable wrap
          IF (IWIDTH.EQ.137) WRITE(LUPRT,9510) IHR,iMIN,ISC,IHR2,MIN2,
     .      ISC2,(LSNAME(i),i=1,4),
     .      IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,LHSIGN,
     .      IHAH,IHAM,AZ,EL,cwrap,TSLEW,ICAL,LFREQ,LMODE(1,istn,ICOD),
     .      VCBAND(1,istn,ICOD),IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK),
     .      12.0*speed(icod,istn)
9510      FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',4A2,'  ',I2.2,':',I2.2,':',F5.2,' ',A1,I2.2,':',
     .      I2.2,':',F4.1,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,
     .      ' ',a5,' ',F4.1,' ',I3,'  ',A2,' ',A1,' ',F4.1,' ',I2,
     .      A1,' ',I5,' ',F4.0,
     .      ' ____________________________________________________'/)
          IF (IWIDTH.EQ. 80) WRITE(luprt,9518) IHR,iMIN,ISC,IHR2,MIN2,
     .      ISC2,(LSNAME(i),i=1,4),
     .      LHSIGN,IHAH,IHAM,AZ,EL,cwrap,TSLEW,
     .      IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK)
9518      FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',4A2,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,' ',
     .      a5,' ',F4.1,I3,A1,' ',I5,' ',' ________________'/)
          else ! no cable wrap
          IF (IWIDTH.EQ.137) WRITE(LUPRT,8510) IHR,iMIN,ISC,IHR2,MIN2,
     .      ISC2,(LSNAME(i),i=1,4),
     .      IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,LHSIGN,
     .      IHAH,IHAM,AZ,EL,TSLEW,ICAL,LFREQ,LMODE(1,istn,ICOD),
     .      VCBAND(1,istn,ICOD),IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK),
     .      12.0*speed(icod,istn)
8510      FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',4A2,'  ',I2.2,':',I2.2,':',F5.2,' ',A1,I2.2,':',
     .      I2.2,':',F4.1,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,
     .      ' ',' ',F4.1,' ',I3,'  ',A2,' ',A1,' ',F4.1,' ',I2,
     .      A1,' ',I5,' ',F4.0,
     .      ' ____________________________________________________'/)
          IF (IWIDTH.EQ. 80) WRITE(luprt,8518) IHR,iMIN,ISC,IHR2,MIN2,
     .      ISC2,(LSNAME(i),i=1,4),
     .      LHSIGN,IHAH,IHAM,AZ,EL,TSLEW,
     .      IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK)
8518      FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',4A2,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,' ',
     .      ' ',F4.1,I3,A1,' ',I5,' ',' ________________'/)
          endif
C
          NLINES = NLINES + 1
          nlobs = nlobs + 1
	    IPASP = IPAS(ISTNSK)
	    IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ITEARL(istn)+IDUR(ISTNSK))
     .    *speed(icod,istn))
          IDIRP=IDIR
        ENDIF
C ENDT Current station in observation
C
C  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          LNOBS = LNOBS + 1
      call ifill(ibuf,1,ibuf_len*2,oblank)
      if (lnobs+1.le.nobs) then
        idum = ichmv(ibuf,1,lskobs(1,lnobs+1),1,ibuf_len*2)
        ilen = iflch(ibuf,ibuf_len*2)
      else
        ilen=-1
      endif
        IF (IERR.GE.0.AND.ILEN.GT.0.AND.JCHAR(IBUF,1).NE.ODOLLAR) then
          CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .         LFREQ,IPAS,LDIR,IFT,LPRE,
     .         IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .         NSTNSK,LSTN,LCABLE,
     .         MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG)
        ENDIF
C ENDW Loop on observations
      ENDDO
C
      WRITE(luprt,9900) NTAPES,NLOBS
9900  FORMAT(' NUMBER OF MARK III TAPES: ',I5/
     .       ' NUMBER OF OBSERVATIONS:   ',I5/)
900   call luff(luprt)
C     if (cprttyp.eq.'FILE') CLOSE(LUPRT)
      close(luprt)
      call prtmp
C
      RETURN
      END
