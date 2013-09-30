      SUBROUTINE LISTS()    !LIST ONE STATION'S SCHEDULE

C This routine lists on the printer a schedule
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'                                        '
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C INPUT:
! functions
      integer julda
      integer trimlen

C OUTPUT: none
C LOCAL:
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN)
      character*2 ccable(max_stn)
      equivalence (ccable,lcable)

      character*(max_sorlen) csname
      character*2 cstn(max_stn)
      character*2 cfreq
      equivalence (csname,lsname),(lstn,cstn),(cfreq,lfreq)

      integer*2 LMON(2),LDAY(2),LMID(3),LPRE(3),LPST(3),LDIR(MAX_STN)
      integer ipas(max_stn),ift(max_stn),idur(max_stn)
      integer ioff(max_stn)
      character*1 cs
      integer ipasp,iftold,idirp,idir,ituse
      integer i,j,id
      integer ld
      real wlon,alat,al11,al12,al21,al22,rt1,rt2
      real az,el,x30,y30,x85,y85,dc,ha1
      real speed
      integer irah,iram,idecd,idecm
      integer*2 lhsign,ldsign
      integer irh3,irh2,irm3,irh1,irm1,irm2,ihah,iham
      integer*2 lds3,lds1,lds2
      integer idd3,idm3,idd1,idm1,idd2,idm2
      real ras,decs,ras3,ras2,ras1,dcs1,dcs2,dcs3,has,d
      real tslew,dum
      integer iyr,idayr,ihr,imin,isc,mjd,mon,ida,ical,icod
      integer mjdpre,ispre,iyr2,idayr2,ihr2,imin2,isc2
      integer*2 lfreq,lcbpre,lcbnew
      double precision UT,GST,utpre ! previous value required for slewing
      integer nstnsk,istnsk,isor,nsat
      character*7 cwrap ! cable wrap string returned from CBINF 
C NSTNSK - number of stations in current observation
C ISTNSK - which station corrresponds to ISTN
      integer nlobs,nlines,ntapes,ierr,ilen,npage
      integer maxline,maxwidth
C NLOBS - number of observation lines written for this station
C NLINES, iobs, NTAPES - number of lines on a page, observations, tapes
C NLMAX - number of lines max per page
      INTEGER IC
      LOGICAL KNEWT,knewtp,ks2,kk4
C function to determine if a new tape has started
      double precision TJD
C for precession routines
      double precision HA
C     integer*2 LAXIS(2,7),
!      integer*2 laxis(2)
      character*4 laxis
      integer iobs
      LOGICAL KUP ! true if source is up at station
      logical kwrap
      integer*2 HHR
      character*2 csize
      integer iheader_Space

      double precision speed_k4 ! speed for K4
      double precision conv_k4 ! speed scaling for feet-->counts
      double precision conv_s2 ! speed scaling for feet-->minutes
      integer ifeet
      double precision ffeet0_k4 ! initial counts
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
C     DATA LAXIS /2HHA,2HDC,2HXY,2HEW,2HAZ,2HEL,2HXY,2HNS,2HRI,2HCH,
C    .2hSE,2hST,2hAL,2hGO/
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
C 970303 nrv For S2, don't try to print the Mk3 configuration. Update
C            footage with duration only (assumes no stops).
C 970304 nrv Add COPTION for defaults.
C 970307 nrv Use pointer array ISKREC to insure time order of obs.
C 971003 nrv Add a check for S2 and determine tape changes for it separately.
C 980916 nrv Change date header on source page to yyyy.ddd
C 981202 nrv Add warning message about negative slewing times.
C 990527 nrv Add option for S2 and K4 non-VEX outputs. 
C 991118 nrv Removed LAXIS variable and use AXTYP subroutine.
C 991209 nrv Add ITUSE to iftold calculation.
! 2007   jmg Removed obsolete call to m3inf.  Not used.
! 2007Jul20 JMG.  Added character LD
! 2013Sep19  JMGipson made sample rate station dependent
C
C 1. First initialize counters.  Read the first observation,
C unpack the record, and set the PREvious variables to the
C current values for initialization.
C
      iheader_space=11
      call setup_printer(cpaper_size,coption(1),csize,
     >    maxwidth,maxline,ierr)

      if(maxwidth .ge. 135) then
        cs="S"
      else
        cs="L"
      endif

      if (ierr.ne.0) then
        write(luscn,9061) ierr
9061    format(' LISTS01 - Error ',I5,' opening printer')
        return
      end if
      NLINES = 0
      NTAPES = 0
      iobs = 0
      nlobs = 0 ! number of scan line written
      ks2=.false.
      kk4=.false.
      if(cstrack(istn) .ne. "unknown") then
        ks2= cstrec(istn,1) .eq. "S2"
        kk4= cstrec(istn,1) .eq. "K4"
      endif
      if (kk4) then ! K4 speed
C       scaling factor is 55 cpd/11.25 fps if the schedule
C       was produced using sked with Mk/VLBA footage calculations
C       and no fan-out or fan-in. Footages were therefore already
C       scaled by bandwidth calculations in sked.
        conv_k4 = 55.389387393 ! counts/sec
        speed_k4 = conv_k4*samprate(istn,1)/4.0 ! 55, 110, or 220 cps
        speed_k4=speed_k4*12.d0/80.d0 ! converts feet to counts
C       ifeet0_k4 = 54 ! this is the zero counts
        ffeet0_k4 = 54.d0/speed_k4 ! this is the zero feet
      endif
      if (ks2) then ! S2 scaling
C       Fake it with high density stations, long footage tapes.
C       Scale by sample rate.
        conv_s2 = 60.d0*6.667*(samprate(istn, 1)/4.0)
      endif
      kwrap=(iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn).eq.7)
C     CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
      if (iobs+1.le.nobs) then
        cbuf=cskobs(iskrec(iobs+1))
        ilen=trimlen(cbuf)
      else
        cbuf=" "
        ilen=-1
      endif
      do i=1,max_stn
	cstn(i)=" "
      end do
      CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .     LFREQ,IPAS,LDIR,IFT,LPRE,
     .     IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .     NSTNSK,LSTN,LCABLE,
     .     MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
      CALL CKOBS(cSNAME,cSTN,NSTNSK,cFREQ,ISOR,ISTNSK,ICOD)
      ituse=0
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
      WRITE(LUSCN,100) cSTNNA(ISTN),LSKDFI(1:ic) ! new
100   FORMAT(' Schedule listing for ',A,' from file ',A) ! was A32
      WLON = STNPOS(1,ISTN)*rad2deg
      ALAT = STNPOS(2,ISTN)*rad2deg
C     LAX1 = LAXIS(1,IAXIS(ISTN))
C     LAX2 = LAXIS(2,IAXIS(ISTN))
      call axtyp(laxis,iaxis(istn),2) ! convert code to name
      Rt1 = STNRAT(1,ISTN)*60.0*rad2deg
      Rt2 = STNRAT(2,ISTN)*60.0*rad2deg
      AL11 = STNLIM(1,1,ISTN)*rad2deg
      AL21 = STNLIM(2,1,ISTN)*rad2deg
      AL12 = STNLIM(1,2,ISTN)*rad2deg
      AL22 = STNLIM(2,2,ISTN)*rad2deg
C

      WRITE(luprt,99) cSTNNA(ISTN),cEXPER,
     .WLON,ALAT,laxis(1:2),laxis(3:4),
     .laxis(1:2),Rt1,AL11,AL21,laxis(3:4),Rt2,AL12,AL22
99    FORMAT(/////5X,'SCHEDULE FOR  ',
     . A,'  EXPERIMENT  ',A///
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
      WRITE(luprt,97) IYR,idayr
97    FORMAT(' ',////'     SOURCES IN THIS SCHEDULE',10X,
     .    '(DATE=',I4,'.',I3.3,')'///)
      if(cs .eq.'S') then
        WRITE(LUPRT,98)
98      FORMAT(8X,'NAME     -RA(1950)-  -DEC(1950)-      -RA(DATE)-  ',
     .   '-DEC(DATE)-      -RA(2000)-  -DEC(2000)-'/)
      else
        WRITE(luprt,94)
94      FORMAT(8X,'NAME     -RA(1950)-  -DEC(1950)-      -RA(DATE)-  ',
     .   '-DEC(DATE)-'/)
      ENDIF
C
      TJD = JULDA(MON,IDA,IYR-1900) + 2440000.0D0
      DO I=1,NCELES
        call apstar_Rad(tjd,sorp50(1,i),sorp50(2,i),
     >         sorpda(1,i),sorpda(2,i))
        CALL RADED(RA50(I),DEC50(I),0.d0,IRH3,IRM3,RAS3,LDS3,
     .        IDD3,IDM3,DCS3,lhsign ,ID,ID,D)
        CALL RADED(SORP50(1,I),SORP50(2,I),0.d0,IRH1,IRM1,RAS1,LDS1,
     .        IDD1,IDM1,DCS1,lhsign,ID,ID,D)
        CALL RADED(SORPDA(1,I),SORPDA(2,I),0.d0,IRH2,IRM2,RAS2,LDS2,
     .        IDD2,IDM2,DCS2,lhsign,ID,ID,D)
C
        IF (cs.EQ.'S') then
           WRITE(LUPRT,91) csorna(i)(1:8),IRH3,IRM3,RAS3,LDS3,
     .      IDD3,IDM3,DCS3,IRH2,IRM2,RAS2,LDS2,
     .      IDD2,IDM2,DCS2,IRH1,IRM1,RAS1,LDS1,IDD1,IDM1,DCS1
        else IF (cs.EQ.'L') then
            WRITE(luprt,91) csorna(i)(1:8),IRH3,IRM3,RAS3,LDS3,
     .      IDD3,IDM3,DCS3,IRH2,IRM2,RAS2,LDS2,IDD2,IDM2,DCS2
        endif
91      FORMAT(6X,A,3x,3(I2.2,':',I2.2,':',F5.2,'  ',
     .         A1,I2.2,':',I2.2,':',F4.1,'     '))
      end do
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
        WRITE(luprt,9150) I,csorna(i)(1:8),(SATP50(J,NSAT),J=1,7),
     .       ISATY(NSAT),SATDY(NSAT)
9150    FORMAT(I4,1X,A,1X,F7.2,F7.5,3F7.2,F11.1,F8.3,I5,F7.2)
150   CONTINUE
C
102   continue
      nlines=iheader_space
      NPAGE = 1
      call luff(luprt)
      WRITE(luprt,101) cSTNNA(ISTN),cEXPER,LDAY,LMON,IDA,IYR,IDAYR,NPAGE
101   FORMAT(' ',//' SCHEDULE FOR ',A8,' EXPERIMENT ',A8,
     .       'ON ',2A2,', ',2A2,' ',I2.2,', ',
     .       I4,' (DAY ',I3,')',10X,'Page ',I3//)
      if (itearl(istn).gt.0) then
        write(luprt,'(a,i3,a,/)')" ***** NOTE: Tape will start moving ",
     >             itearl(istn)," seconds before start time. *****"
      else
        write(luprt,'(/)')
      endif
C
      if (kwrap) then ! print cable wrap
        IF (cs.EQ.'S') THEN
          WRITE(LUPRT,1137)
        ELSE 
          WRITE(luprt,1080)
        ENDIF
      else ! no cable wrap output
        IF (cs.EQ.'S') THEN
          WRITE(LUPRT,9137)
        ELSE 
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
      do iobs=1,nobs
        if(iobs .ne. 1) then
          cbuf=cskobs(iskrec(iobs))
          ilen=trimlen(cbuf)
          if(cbuf(1:1) .eq. "$") goto 900
        endif
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .         LFREQ,IPAS,LDIR,IFT,LPRE,
     .         IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .         NSTNSK,LSTN,LCABLE,
     .         MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)

C DO BEGIN Loop on observations
        CALL CKOBS(cSNAME,cSTN,NSTNSK,cFREQ,ISOR,ISTNSK,ICOD)
        IF (ISOR.EQ.0.OR.ICOD.EQ.0) GOTO 900
C
C 3. Set up major block for calculations and printing.
C Skip this if the current station is not in the list
C of stations in this observation.
C Unless we are spinning blank tape, in which case list
C the observation with a message.
        IF (ISTNSK.NE.0)  THEN
C THEN BEGIN Current station in observation
          IF (NLINES.GE.maxline.OR.MJD.NE.MJDPRE) THEN
C THEN BEGIN new page
            NPAGE = NPAGE + 1
            call luff(luprt)
            WRITE(luprt,101) cSTNNA(ISTN),cEXPER,
     .            LDAY,LMON,IDA,IYR,IDAYR,NPAGE
            if (itearl(istn).gt.0) then
                write(luprt,'(a,i3,a,/)')
     >             " ***** NOTE: Tape will start moving ",
     >             itearl(istn)," seconds before start time. *****"
            else
              write(luprt,'(/)')
            endif
            if (kwrap) then
            IF (cs.EQ.'S') THEN
              WRITE(LUPRT,1137)
            ELSEIF (cs.EQ. 'L') THEN
              WRITE(luprt,1080)
            ENDIF
            else
            IF (cs.EQ.'S') THEN
              WRITE(LUPRT,9137)
            ELSEIF (cs.EQ. 'L') THEN
              WRITE(luprt,9080)
            ENDIF
            endif
            NLINES = iheader_space            !this leaves space for header.
C ENDT new page
          ENDIF
          IDIR=+1
          IF (LDIR(ISTNSK).EQ.HHR)IDIR=-1
          if (ks2) then
C           knewtp = ift(istnsk).eq.0.and.ipas(istnsk).eq.0
C           replaced with:
            knewtp = IPAS(istnsk).LT.IPASP.OR.
     .      (IPAS(istnsk).EQ.IPASP.AND.(IFT(istnsk).LT.(IFTOLD-300)))
          else if (idir.ne.0) then
            KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .      IDIRP,IFTOLD)
          else
            knewtp = .false.
          endif
C         IF (KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,
C    .        IDIR,IDIRP,IFTOLD)) THEN
C THEN BEGIN new tape
          if (knewtp) then
            WRITE(luprt,"('    *** NEW TAPE ***'/)")
            NTAPES = NTAPES + 1
            NLINES = NLINES + 2
          ENDIF
C
C ENDT new tape
C 4. Calculate all of the numbers we need now.
          ID=IDUR(ISTNSK)
          CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,ID,
     .               IYR2,IDAYR2,IHR2,imin2,ISC2)
          HA1 = HA
C CONVERT TO SINGLE PRECISION
          CALL CVPOS(ISOR,ISTN,MJD,UT,AZ,EL,HA1,DC,X30,Y30,X85,Y85,
     .               KUP)
          HA = HA1
C CONVERT BACK TO DOUBLE
          AZ = AZ*rad2deg
          EL = EL*rad2deg
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
          if (tslew.lt.0.0) then 
            WRITE(luprt,9331)
9331        FORMAT('  THE FOLLOWING SOURCE REQUIRES NEGATIVE ',
     .             'SLEWING TIME.  INFORM THE SCHEDULER!'/)
                  NLINES = NLINES + 2
          endif
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
                  NLINES = NLINES + 2
C ENDE source not up
          ENDIF
C
C     5. Now write out the observation line.
          call cbinf(ccable(istnsk),cwrap)
          if (kwrap) then ! print cable wrap
          IF (cs.EQ.'S') then
            WRITE(LUPRT,9510) IHR,iMIN,ISC,IHR2,imin2,ISC2,
     >      cSNAME(1:8),  IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,LHSIGN,
     .      IHAH,IHAM,AZ,EL,cwrap,TSLEW,ICAL,LFREQ,LMODE(1,istn,ICOD),
     .      VCBAND(1,istn,ICOD)
9510        FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',A,'  ',I2.2,':',I2.2,':',F5.2,' ',A1,I2.2,':',
     .      I2.2,':',F4.1,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,
     .      ' ',a5,' ',F4.1,' ',I3,'  ',A2,' ',A1,' ',F4.1,' ',$)
            if (ks2) then
              write(luprt,9511) IFT(ISTNSK)/conv_s2 ! in minutes
9511          format(I5,
     .        ' _________________________________________________'/)
            else if (kk4) then
              ifeet=(dble(IFT(ISTNSK)+ffeet0_k4))*speed_k4
              write(luprt,9513) ifeet
9513          format(i8,
     .        ' _________________________________________________'/)
            else
              write(luprt,9512) IPAS(ISTNSK),LDIR(ISTNSK),
     .        IFT(ISTNSK),12.0*speed(icod,istn)
9512          format(I2,A1,' ',I5,' ',F4.0,
     .        ' ______________________________________________'/)
            endif
          else IF (cs.EQ. 'L') then
            WRITE(luprt,9518) IHR,iMIN,ISC,IHR2,imin2,ISC2,
     >      csNAME(1:8), LHSIGN,IHAH,IHAM,AZ,EL,cwrap,TSLEW
9518        FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',A,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,' ',
     .      a5,' ',F4.1,$)
            if (ks2) then
              write(luprt,9517) IFT(ISTNSK)/conv_s2
9517          format(I5,' ',' ________________'/)
            else if (kk4) then
              ifeet=(dble(IFT(ISTNSK)+ffeet0_k4))*speed_k4
              write(luprt,9519) ifeet
9519          format(I8,' ',' ________________'/)
            else
              write(luprt,9516) IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK)
9516          format(I3,A1,' ',I5,' ',' ________________'/)
            endif
          endif ! wid 137/80
          else ! no cable wrap
          IF (cs.EQ.'S') then
            WRITE(LUPRT,8510) IHR,iMIN,ISC,IHR2,imin2,ISC2,
     >       cSNAME(1:8),IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,LHSIGN,
     .      IHAH,IHAM,AZ,EL,TSLEW,ICAL,LFREQ,LMODE(1,istn,ICOD),
     .      VCBAND(1,istn,ICOD)
8510        FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',A,'  ',I2.2,':',I2.2,':',F5.2,' ',A1,I2.2,':',
     .      I2.2,':',F4.1,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,
     .      ' ',' ',F4.1,' ',I3,'  ',A2,' ',A1,' ',F4.1,' ',$)
            if (ks2) then
              write(luprt,8511) IFT(ISTNSK)/conv_s2
8511          format(i5,
     .        ' ____________________________________________________'/)
            else if (kk4) then
              ifeet=(dble(IFT(ISTNSK)+ffeet0_k4))*speed_k4
              write(luprt,8513) ifeet
8513          format(i8,
     .        ' ____________________________________________________'/)
            else
              write(luprt,8512) IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK),
     .        12.0*speed(icod,istn)
8512          format( I2, A1,' ',I5,' ',F4.0,
     .        ' ____________________________________________________'/)
            endif
          else IF (cs.EQ. 'L') then
            WRITE(luprt,8518) IHR,iMIN,ISC,IHR2,imin2,ISC2,
     >        cSNAME(1:8),LHSIGN,IHAH,IHAM,AZ,EL,TSLEW
8518        FORMAT(1X,I2.2,':',I2.2,':',I2.2,'-',I2.2,':',I2.2,':',I2.2,
     .      '  ',A,' ',A1,I2.2,':',I2.2,' ',F5.1,'  ',F4.1,' ',F4.1,$)
            if (ks2) then
              write(luprt,8517) IFT(ISTNSK)/conv_s2
8517          format(I5,' ',' ________________'/)
            else if (kk4) then
              ifeet=(dble(IFT(ISTNSK)+ffeet0_k4))*speed_k4
              write(luprt,8519) ifeet
8519          format(i8,
     .        ' ____________________________________________________'/)
            else
              write(luprt,8516) IPAS(ISTNSK),LDIR(ISTNSK),IFT(ISTNSK)
8516          format(I3,A1,' ',I5,' ',' ________________'/)
            endif 
          endif ! wid 137/80
          endif ! cable/no cable
C
          NLINES = NLINES + 2
          nlobs = nlobs + 1
          IPASP = IPAS(ISTNSK)
          if (ks2) then
            IFTOLD = IFT(ISTNSK)+IDUR(ISTNSK)
          else if (kk4) then
            IFTOLD = IFT(ISTNSK)
          else
            IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ituse*ITEARL(istn)+
     .      IDUR(ISTNSK)) *speed(icod,istn))
          endif
          IDIRP=IDIR
        ENDIF
C ENDT Current station in observation
      ENDDO
C
      WRITE(luprt,9900) NTAPES,NLOBS
9900  FORMAT(' NUMBER OF TAPES: ',I5/
     .       ' NUMBER OF SCANS:   ',I5/)
900   call luff(luprt)
      close(luprt)
      if(csize(1:1) .eq. "L") then
        call prtmp(1)
      else
        call prtmp(0)
      endif
C
      RETURN
      END
