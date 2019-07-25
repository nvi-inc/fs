	SUBROUTINE POINT(cr1,cr2,cr3,cr4)   !MAKE FILES FOR TELESCOPE POINTING
C Write a file or a tape with pointing controls
C
	INCLUDE 'skparm.ftni'
	INCLUDE 'drcom.ftni'
	INCLUDE 'statn.ftni'
	INCLUDE 'sourc.ftni'
	INCLUDE 'freqs.ftni'
C INPUT
      character*(*) cr1,cr2,cr3,cr4
C
C LOCAL:
      LOGICAL KINTR,kmatch,knewtp,knewt
      real*8 dvc(14) !VC frequencies
      integer*4 idvc(14)
      integer*2 lif1(2),lif2(2),lalt(2),lnor(2)
      integer*2 ldirword(4)
      integer nch,i,ierr,ilen,iblk,ical,nstnsk,lu_outfil2
      integer idirp,ipasp,iobs,iftold,idir,icode,
     .idrate,i2lo,i2hi,i1lo,i1hi
      integer*2 lfreq,lsga
      integer mon,ida,mjd,iyr,idayr,ihr,imin,isc,iyr2,idayr2,
     .ihr2,min2,isc2,ihrp,minp,iscp,idayp,idayrp,irecp
      integer isor,istnsk,icod,idummy,istin,itype
      real*4 decs,has,ras,ras2,decs2,has2
      integer irah,iram,idecd,idecm,ihah,iham,
     .irah2,iram2,idecd2,idecm2,ihah2,iham2,
     .iras,isra,idecs
      integer*2 ldsign,lhsign,ldsign2,lhsign2,ldsn
	integer*2 LPROC(4) !  The procedure name for NRAO
	integer*2 ldirr,ldirf !REV,FOR
      integer ilennr,nchar,j,idum,itnum,ilenef,ilenwe,
     .ilenha,ilenon
      real*4 dut,eeq
	character*128 cbuf
	integer*2 LRAS(3),LDEC(3)
        integer ih
	integer*2 LSNAME(4),LSTN(MAX_STN),LCABLE(MAX_STN),LMON(2),
     .          LDAY(2),LPRE(3),LMID(3),LPST(3),ldir(max_stn)
        integer IPAS(MAX_STN),
     .          IFT(MAX_STN),IDUR(MAX_STN)
	CHARACTER   UPPER,lower
	CHARACTER*3 STAT,lc
	character*128 dsnname
	CHARACTER*4 RESPONSE
        character*2 scode
        integer*2 lna(4)
	real*8 GST,UT,HA,HA2
	integer IC
	LOGICAL*4 EX
Cinteger*4 ifbrk
	integer Z20,Z24
      integer ias2b,ichcm,trimlen,jchar,ichmv,ir2as,ib2as ! functions
      integer ichmv_ch,ichcm_ch
      real*4 speed ! function
	DATA Z20/Z'20'/, Z24/Z'24'/

C Initialized:
	DATA ILENNR/40/, ILENHA/9/, ILENON/40/, ILENEF/40/, ILENWE/39/
C record word lengths
	data ldirr/2hR /,ldirf/2hF /, lsga/2hA /
	data lalt/2hAL,2hT /,lnor/2hNO,2hR /
        data lu_outfil2/42/

C LAST MODIFIED:
C 850605 MWH put 1950 coordinates in NRAO pointing file
C 880411 NRV DE-COMPC'D
C 880804 NRV Added Westerbork, Pie Town
C            Removed CALL CODE
C 890303 NRV REMOVED QUERY FOR DISK/TAPE OUTPUT, AND
C            DISABLED TAPE OUTPUT TOTALLY
C 890505 NRV CHANGED IDUR TO AN ARRAY BY STATION
C 900328 NRV Cleaned up file names
C 901023 NRV Added break
C 910513 gag Added logic to handle multiple vlba station with the use of
C            common variable nvset.
C 910701 nrv Removed IN2A2 calls and replaced with I2.2 in format.
C 910827 NRV Add DSN output, removed Onsala
C 910830 NRV Add NRAO 85-3 output, removed Haystack
C 930201 nrv Stop the VLBA tape at end of the file
C 930407 nrv implicit none
C 930609 nrv Change logic for DSN output for narrow heads
C 930708 nrv Check for head positions for VLBA output
C 940623 nrv Add batch mode
c 940701 nrv Change VLBA output file names

	kintr = .false.
      if (kbatch) then
        read(cr1,*,err=991) istin
991     if (istin.lt.1.or.istin.gt.6) then
          write(luscn,9991)
9991      format(' Invalid pointing output selection.')
          return
        endif
      else
 1    WRITE(LUSCN,9019) (lantna(I,ISTN),I=1,4)
9019  FORMAT(' Select type of pointing output for: ',4a2/
     .       ' 1 - NRAO 85-3            2 - NRAO_140 '/
     .       ' 3 - DSN stations         4 - Bonn     '/
     .       ' 5 - VLBA terminal only   6 - VLBA antenna'/
     .       ' 7 - Westerbork           0 - QUIT '/' ? ',$)

	call gtrsp(ibuf,80,luusr,nch)
	istin= ias2b(ibuf(1),1,1)
	IF (ISTIN.EQ.0) RETURN
	IF (ISTIN.LT.1.OR.ISTIN.GT.6) GOTO 1
      endif
C
C 2. First get output file or LU for pointing commands.
C If problems, quit.

	if (istin.eq.5.or.istin.eq.6) then
	  if (.not.kvlba) then
	   write(luscn,9200)
9200       format(/' POINT01 - No $VLBA section in schedule file'/)
	   return
	  end if
	  kmatch = .false.
	  do i=1,ncodes
	    if (ivix(i,istn).ne.0) kmatch = .true.
	  enddo
	  if (.not.kmatch) then
	    write(luscn,9210) (lantna(I,ISTN),I=1,4)
9210      format(/'POINT03 - No VLBA information for station ',4a2/)
	    return
	  end if
          ih=0
          do i=1,2*max_pass
            if (ihdpos(i,istn,1).ne.0) ih=ih+1
          enddo
          if (ih.eq.0) then
            write(luscn,9211) (lantna(i,istn),i=1,4)
9211        format(/'POINT03 - No head position information for ',4a2/)
            return
          endif
	end if

	IC = TRIMLEN(LSKDFI)
	WRITE(LUSCN,9900) (LSTNNA(I,ISTN),I=1,4), LSKDFI(1:ic)
9900  FORMAT(' POINTING FILE FOR ',4A2,' FROM SCHEDULE ',A,/
     .  ' Only observations scheduled for ',
     .  'this station will be processed.')
C

C check to see if the file exists first
	IC=TRIMLEN(PNTNAME)
	if (istin.eq.3) then !adjust DSN name
	  pntname = pntname(1:ic-3)//'nss'
	else if (istin.eq.1) then !adjust 85-3 name
	  pntname = pntname(1:ic-3)//'853'
	else if (istin.eq.6) then !adjust VLBA name
          idummy = ichmv(lna,1,lstnna(1,istn),1,8)
          if (ichcm_ch(lna,1,'PIETOWN ').eq.0) then
            idummy = ichmv_ch(lna,1,'PT')
          endif
          call hol2lower(lna,8)
          call hol2char(lna,1,2,scode)
	  pntname = pntname(1:ic-5)//'.'//scode
	endif
	INQUIRE(FILE=PNTNAME,EXIST=EX,IOSTAT=IERR)
	IF (EX) THEN
          if (.not.kbatch) then
110         WRITE(LUSCN,9130) PNTNAME(1:IC)
9130        FORMAT(' OK TO PURGE EXISTING FILE ',A,' (Y/N) ? ',$)
	    READ(LUUSR,'(A)') RESPONSE
	    RESPONSE(1:1) = UPPER(RESPONSE(1:1))
	    IF (RESPONSE(1:1).EQ.'N') THEN
	      GOTO 990
            ELSE IF (RESPONSE(1:1).EQ.'Y') THEN
	    ELSE
	      GOTO 110
	    ENDIF
          endif
	  open(lu_outfile,file=pntname)
	  close(lu_outfile,status='delete')
        ENDIF
C
      stat = 'NEW'
      OPEN(UNIT=LU_OUTFILE,FILE=PNTNAME,STATUS=STAT,IOSTAT=IERR)
C
	IF (IERR.EQ.0) THEN
	  REWIND(LU_OUTFILE)
	  CALL INITF(LU_OUTFILE,IERR)
	  IC=TRIMLEN(PNTNAME)
	  WRITE(LUSCN,9140) PNTNAME(1:IC)
9140    FORMAT(' OUTPUT POINTING FILE: ',A) ! WAS A32
	ELSE
	  IC=TRIMLEN(PNTNAME)
	  WRITE(LUSCN,9131) IERR,PNTNAME(1:ic)
9131    FORMAT(/' POINT04 - ERROR ',I5,' CREATING FILE ',A/)
	  RETURN
	ENDIF

C If this is for a DSN station, a second output file
      if (istin.eq.3) then
	dsnname = pntname(1:ic-3)//'sum'
	INQUIRE(FILE=dsnNAME,EXIST=EX,IOSTAT=IERR)
	IF (EX) THEN
          if (.not.kbatch) then
111         WRITE(LUSCN,9130) dsnNAME(1:IC)
            READ(LUUSR,'(A)') RESPONSE
            RESPONSE(1:1) = UPPER(RESPONSE(1:1))
            IF (RESPONSE(1:1).EQ.'N') THEN
              GOTO 990
            ELSE IF (RESPONSE(1:1).EQ.'Y') THEN
            ELSE
              GOTO 111
            ENDIF
          endif
        open(lu_outfil2,file=dsnname)
        close(lu_outfil2,status='delete')
        ENDIF
C
      STAT='NEW'
      OPEN(UNIT=LU_OUTFIL2,FILE=dsnNAME,STATUS=STAT,IOSTAT=IERR)
C
	IF (IERR.EQ.0) THEN
	  REWIND(LU_OUTFIL2)
	  CALL INITF(LU_OUTFIL2,IERR)
	  WRITE(LUSCN,9140) dsnNAME(1:IC)
	ELSE
	  WRITE(LUSCN,9131) IERR,dsnNAME(1:ic)
	  RETURN
	ENDIF
      endif !DSN second file

C 3. Begin loop on schedule file records.  Check out the entry.
C
300   CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	IBLK=0
	IPASP=0
	IDIRP=0
	iobs=0
	IFTOLD=0
	DO WHILE (IERR.GE.0.AND.ILEN.GT.0.AND.JCHAR(IBUF,1).NE.Z24)
C DO BEGIN "Schedule file entries"

C  if (ifbrk().lt.0) goto 990

	  CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,
     .       LFREQ,IPAS,LDIR,IFT,LPRE,
     .       IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,
     .       NSTNSK,LSTN,LCABLE,
     .       MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG)
	  CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
	  IF (ISOR.EQ.0.OR.ICOD.EQ.0) GOTO 990
C
C 4. If station is in observation, process it.  Use block
C    appropriate to current station.
C
	  IF (ISTNSK.NE.0) THEN !Current station in observation
	    CALL RADED(RA50(ISOR),DEC50(ISOR),HA,
     .         IRAH,IRAM,RAS,LDSIGN,IDECD,IDECM,DECS,
     .         LHSIGN,IHAH,IHAM,HAS)
	    CALL RADED(SORP50(1,ISOR),SORP50(2,ISOR),HA2,
     .         IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .         LHSIGN2,IHAH2,IHAM2,HAS2)
	    CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,IDUR(ISTNSK),IYR2,IDAYR2,
     .         IHR2,MIN2,ISC2)
	    CALL IFILL(IBUF,1,80,oblank)
C BLANKS 1ST 80 SPACES IN IBUF => NEW VALUES TO BE PLACED IN CBUF
C
C*** Removed Haystack
C            IF (ISTIN.EQ.1) THEN !Haystack pointing
C                WRITE(CBUF,9410) IDAYR,IHR,iMIN,IHR2,MIN2,ISOR
C9410        FORMAT(6I3)
C                CALL CHAR2HOL(CBUF,IBUF,1,18)
C                NCHAR = ILENHA*2
C*** Removed Haystack
	     if (istin.eq.1) then !NRAO 85-3
	       if (.not.kintr) then
		 write(lu_outfile,9301) lexper,iyr,
     .           (lstnna(i,istn),i=1,4),lstcod(istn),idayr,idayr,iyr
9301             format('--',1x,4a2,2x,i4,2x,4a2,2x,a1/
     .                  '-- Obs.List from day ',i3/
     .                  '-- OBSLIST DAY:',i3,'  YR: ',i4/
     .                  'VLBI'/'EPOCH  1950.0'/'TIME=UT')
		 kintr=.true.
	       endif
	       write(lu_outfile,9302) lsname,irah,
     .            iram,ras,ldsign,idecd,idecm,decs,ihr2,min2,isc2
9302              format(2x,4a2,2x,i2.2,':',i2.2,':',f4.1,1x,a1,i2.2,
     .            ':',i2.2,':',f4.1,1x,i2.2,':',i2.2,':',i2.2,
     .            '  TRACAL')
C
	    else IF (ISTIN.EQ.2) THEN !NRAO pointing
		IDUMMY = ichmv_ch(LPROC,1,'MARKIII ')
		IF (ICAL.EQ.0) IDUMMY = ichmv_ch(LPROC,1,'M3NOCAL ')
		IRAS = RAS
		ISRA = (RAS-IRAS)*10.0
		IDECS = IFIX(DECS)
		WRITE(CBUF,9420) LSNAME,IRAH,IRAM,IRAS,ISRA,LDSIGN,
     .            IDECD,IDECM,IDECS,IHR2,MIN2,ISC2,LPROC
9420        FORMAT('S ',4A2,5X,'2 ',3i2.2,'.',I1,1X,A1,3i2.2,14X,
     .             'GMT ',3i2.2,'    1',10X,4A2)
		CALL CHAR2HOL(CBUF,IBUF,1,80)
		NCHAR = ILENNR*2
		CALL writf_asc(LU_OUTFILE,IERR,IBUF,NCHAR/2)
C
C********** Removed Onsala output
C           else IF (ISTIN.EQ.3) THEN !Onsala pointing
C               WRITE(CBUF,9430) LSNAME,IHR2,MIN2,ISC2
c9430       FORMAT('$TRACK /',4A2,4X,'/',19X,'$CONTINUE ',3(i2.2,1X),
C    .             '                     ')
C               CALL CHAR2HOL(CBUF,IBUF,1,80)
C               NCHAR = ILENON*2
C********** Removed Onsala output
C
	    else if (istin.eq.3) then !DSN output
	      if (.not.kintr) then
		write(lu_outfile,9503)
9503            format('** RS CATALOG',57x,'J2000')
		do i=1,nceles
		  CALL RADED(SORP50(1,I),SORP50(2,I),HA2,
     .            IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .            LHSIGN2,IHAH2,IHAM2,HAS2)
		  write(lu_outfile,9501) (lsorna(j,i),j=1,4),irah2,
     .            iram2,ras2,ldsign2,idecd2,idecm2,decs2
9501              format(1x,4a2,6x,i2,':',i2,':',f9.6,2x,a1,i2,':',
     .            i2,':',f8.5,20x,'2000.0')
		enddo
		idum = ichmv(ldsn,1,lstnna(1,istn),4,2)
		dut = 0.0
		eeq = 0.0
		write(lu_outfile,9502) lexper,ldsn,iyr,idayr,ihr,
     .          imin,isc,dut,eeq
9502            format('*OBSEQ WBRADIOASTRY ',4a2,5x,a2,10x,i4,'/',
     .          i3,1x,i2,':',i2,':',i2,2x,f7.5,2x,f7.5,1x,'2000')
		ihrp=ihr
		minp=imin
		iscp=isc
		write(lu_outfil2,9504)
9504            format(' Start      Stop      Source    Instruction ',
     .          'for 1st time-  for 2nd time')
		itnum=0
		kintr = .true.
	      end if
C          For each observation, write out command line
	      if (itearl.gt.0) call tmsub(iyr,idayr,ihr,imin,isc,
     .        itearl,iyr,idayr,ihr,imin,isc)
	      CALL RADED(SORP50(1,ISOR),SORP50(2,ISOR),HA2,
     .         IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .         LHSIGN2,IHAH2,IHAM2,HAS2)
	      idir=1
	      if (ldir(istnsk).eq.ldirr) idir=-1
	      KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .        IDIRP,IFTOLD)
	      itype = 1
	      if (idir.eq.-1.and.idirp.eq.1) itype = 3
	      if (idir.eq. 1.and.idirp.eq.-1) itype = 4
	      if (knewtp) itype = 2
              lc='   '
              if (ichcm_ch(lcable(istnsk),1,'C').eq.0) lc='CCW'
              if (ichcm_ch(lcable(istnsk),1,'W').eq.0) lc='CW '
	      write(lu_outfile,9100) lsname,irah2,iram2,ras2,ldsign2,
     .        idecd2,
     .        idecm2,decs2,ihrp,minp,iscp,ihr2,min2,isc2,ihr,imin,isc,
     .        ihr2,min2,isc2,lc,itype
9100          format(6x,4a2,6x,i2,':',i2,':',f9.6,1x,a1,i2,':',i2,':',
     .        f8.5,1x,4(i2,':',i2,':',i2,1x),'12',1x,a3,19x,i1)
	      ipasp = ipas(istnsk)
	      idirp = idir
	      IFTOLD=IFT(ISTNSK)+IFIX(IDIR*
     .        (ITEARL+IDUR(ISTNSK))*SPEED(ICOD))
	      ihrp = ihr2
	      minp = min2
	      iscp = isc2
C Also write out a line in the summary file
	      if (knewtp) then
		itnum=itnum+1
		write(lu_outfil2,9407) itnum
9407            format(/17x,'*** NEW TAPE #',i3,' ***'/)
	      endif
	      if (idir.eq.+1) idum=ichmv_ch(ldirword,1,'FORWARD ')
	      if (idir.eq.-1) idum=ichmv_ch(ldirword,1,'REVERSE ')
	      write(lu_outfil2,9408) ihr,imin,isc,ihr2,min2,isc2,
     .        lsname,ldirword
9408          format(1x,i2,':',i2,':',i2,' - ',i2,':',i2,':',i2,3x,
     .        4a2,4x,'Press ',4a2,'& RECORD  -  Press STOP')

	    else IF (ISTIN.EQ.4) THEN !Bonn pointing
		IRAS = RAS
		ISRA = (RAS-IRAS)*10.0
		IDECS = IFIX(DECS)
		WRITE(CBUF,9440) LSNAME,IRAH,IRAM,IRAS,ISRA,LDSIGN,
     .            IDECD,IDECM,IDECS,IHR2,MIN2,ISC2
9440        FORMAT('SNAM ',4A2,4X,' SLAM',3(1X,i2.2),'.',I1,'S  SBET ',
     .        A1,2(i2.2,1X),i2.2,'  ANGL',3(1X,i2.2),'S  STOP')
		CALL CHAR2HOL(CBUF,IBUF,1,80)
		NCHAR = ILENEF*2
		CALL writf_asc(LU_OUTFILE,IERR,IBUF,NCHAR/2)
C
	  else IF (ISTIN.EQ.5.or.istin.eq.6) THEN !VLBA observe files
	    if (.not.kintr) then
		call snapintr(2,iyr)
		call vlbah(istin,icod,lu_outfile,ierr)
		idayp = 0
		kintr = .true.
	    end if
	    if (itearl.gt.0) call tmsub(iyr,idayr,ihr,imin,isc,itearl,
     .      iyr,idayr,ihr,imin,isc)
	    CALL VLBAT(LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .       IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,
     .       MJD,UT,GST,MON,IDA,LMON,LDAY,ISTNSK,ISOR,ICOD,
     .       IPASP,IBLK,IDIRP,IFTOLD,NCHAR,
     .       IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .       IYR2,IDAYR2,IHR2,MIN2,ISC2,LU_OUTFILE,IDAYP,
     .       idayrp,ihrp,minp,iscp,iobs,irecp)
C
	    else IF (ISTIN.EQ.7) THEN !Westerbork pointing
		I = IR2AS(RAS2,LRAS,1,-6,-3)
		CALL IFILL(LDEC,1,6,Z20)
		I = IR2AS(DECS2,LDEC,1,-5,-2)
		WRITE(CBUF,9450) LSNAME,IRAH,IRAM,LRAS,LDSIGN2,IDECD,
     .            IDECM,LDEC,IDAYR,IHR,iMIN,ISC,IHR2,MIN2,ISC2
9450        FORMAT(4A2,5X,2i2.2,3A2,1X,A1,2i2.2,3A2,'2000.0',
     .             1X,I3,1X,3i2.2,1X,3i2.2,18X,' ')
		CALL CHAR2HOL(CBUF,IBUF,1,80)
		NCHAR = ILENWE*2
		CALL writf_asc(LU_OUTFILE,IERR,IBUF,NCHAR/2)
C
	    END IF !if istin
C
C  Write out the formatted line.  Not needed for VLBA or DSN routine.
C  ***REMOVED: write the line in each section above
C           IF (ISTIN.ne.5.and.istin.ne.6.and.istin.ne.3.and.istin.ne.1)
C    .      CALL writf_asc(LU_OUTFILE,IERR,IBUF,NCHAR/2)
	    iobs=iobs+1
	  END IF ! istnsk
	  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	ENDDO
C
C  When finished with vlba point file, write the quit statement
C  at the end.
	if (istin.eq.5.or.istin.eq.6) then !vlba observe file
C         Turn off recording on the current tape
          call char2hol('write=(0,off) ',ibuf,1,14)
          idum = ib2as(irecp,ibuf,8,1)
          call char2hol('tape=(0,stop) ',ibuf,15,28)
          idum = ib2as(irecp,ibuf,21,1)
          call writf_asc(lu_outfile,ierr,ibuf,14)
	  write(lu_outfile,"('!QUIT!')")
	end if

C When finished with the DSN output file, write the other commands
C at the end.  **NOTE: this outputs for first freq. code ONLY.
	if (istin.eq.3) then !DSN file
	  icode=1
	  nfreq(1,icode)=8
	  nfreq(2,icode)=6
	  write(lu_outfile,"('*END'/' $FREQUENCIES')")
	  write(lu_outfile,9601) nfreq(1,icode),nfreq(2,icode)
9601      format(' BAND    = ',i1,'*2, ',i1,'*1,')
	  write(lu_outfile,9602) nfreq(1,icode),freqlo(1,istn,icode)
     .    ,nfreq(2,icode),freqlo(2,istn,icode)
9602      format(' BIAS    =',2(1x,i1,'*',f17.12,4x,','))
	  write(lu_outfile,9603)
9603      format(' DWELL   = 14*0.0000000000000000E+00,')
	  do i=1,nfreq(1,icode)
	    dvc(i) = (freqrf(i,icode)-freqlo(1,istn,icode))
	  enddo
	  do i=nfreq(1,icode)+1,nfreq(1,icode)+nfreq(2,icode)
	    dvc(i) = (freqrf(i,icode)-freqlo(2,istn,icode))
	  enddo
	  do i=1,14
	    idvc(i)=(dvc(i)+.001)*100.d0
	  enddo
	  write(lu_outfile,9604) (idvc(i),i=1,14)
9604      format(' ONEWAYFREQ      =',2(3x,i5,'0000.0000000',4x,',')
     .    4(/3x,i5,'0000.0000000',4x,','2x,i5,'0000.0000000',4x,',',
     .    2x,i5,'0000.0000000',4x,','))
	  write(lu_outfile,9605) ldsn
9605      format(' STATIONID       = ',6x,a2/' $END')
	  write(lu_outfile,9606)
9606      format(' $CONFIGDATA'/
     .           ' AMPNUMBER1      =          1,'/
     .           ' AMPNUMBER2      =          2,'/
     .           ' AMPSELECT1      = ''MAS'','/
     .           ' AMPSELECT2      = ''MAS'','/
     .           ' BANDCOMB        = ''OFF'','/
     .           ' DRIFT1  =  0.1494000    ,'/
     .           ' DRIFT2  =  0.2968000    ,'/
     .           ' JITTERTHRESH1   =         10,'/
     .           ' JITTERTHRESH2   =         20,'/
     .           ' MAGTOLER1       =  7.0000000000000000E-03,'/
     .           ' MAGTOLER2       =  7.0000000000000000E-03,'/
     .           ' PCGCOMBDIV1     =          5,'/
     .           ' PCGCOMBDIV2     =          5,'/
     .           ' PCGPOWER1       =   6.000000    ,'/
     .           ' PCGPOWER2       =   6.000000    ,'/
     .           ' POLARIZ1        = ''RCP'','/
     .           ' POLARIZ2        = ''RCP'',')
	  idrate = 2.d0*vcband(icode)
	  idum=ichmv_ch(lif1,1,'NOR ')
	  idum=ichmv_ch(lif2,1,'NOR ')
	  if (lsginp(1,icode).eq.lsga) idum=ichmv_ch(lif1,1,'ALT ')
	  if (lsginp(2,icode).eq.lsga) idum=ichmv_ch(lif2,1,'ALT ')
	  i2lo=0
	  i2hi=0
	  do i=1,nfreq(1,icode)
	    if (dvc(i).lt.220.0) i2lo=i2lo+1
	    if (dvc(i).gt.220.0) i2hi=i2hi+1
	  enddo
	  i1lo=0
	  i1hi=0
	  do i=nfreq(1,icode)+1,nfreq(1,icode)+nfreq(2,icode)
	    if (dvc(i).lt.220.0) i1lo=i1lo+1
	    if (dvc(i).gt.220.0) i1hi=i1hi+1
	  enddo
	  write(lu_outfile,9607) lmode(icode),idrate,ldsn,lif1,lif2,
     .    i2lo,i2hi,i1lo,i1hi,vcband(icode)
9607      format(' RECORDERMODE    = ''',a1,''','/
     .           ' SAMPLERATE      =     ',i1,'000000,'/
     .           ' TESTWORD        =        12,        34,',
     .                                '    56,      78,'/
     .           ' WCBINSRC1N      =         2,'/
     .           ' WCBINSRC2N      =         3,'/
     .           ' SESSIONTYPE     = ''WBRADIOASTRY'','/
     .           ' STATIONID       =        ',a2,','/
     .           ' WCBIF1SEL       = ''',a2,a1,''','/
     .           ' WCBIF2SEL       = ''',a2,a1,''','/
     .           ' WCBVCINP        = ',i1,'*''2LO'', ',i1,'*''2HI'', ',
     .                                 i1,'*''1LO'', ',i1,'*''1HI'','/
     .           ' WCBVCBW =   ',f8.6,'    ,'/
     .           ' WCBAUXDAT       = ''WCBAUXDAT   '','/
     .           ' WCBFRQ15        =   110990000.0000000'/' $END')
	endif !DSN file
C
	IF (IERR.NE.0) WRITE(LUSCN,9901) IERR
9901  FORMAT(/' POINT05 - ERROR ',I3,' READING FILE'/)
990   CLOSE(LU_OUTFILE)
C
	RETURN

	END

