	SUBROUTINE POINT(cr1,cr2,cr3,cr4)

C Write a file or a tape with pointing controls
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C INPUT
      character*(*) cr1,cr2,cr3,cr4
C
C LOCAL:
      LOGICAL KINTR,knewtp,knewt,ksw
      integer*2 ldirword(4)
      integer nch,i,ierr,ilen,iblk,ical,nstnsk,lu_outfil2
      integer idirp,ipasp,iobs,iftold,idir,ix,icodp
      integer*2 lfreq
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
        integer ih
	integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .          LMON(2),LDAY(2),LPRE(3),LMID(3),LPST(3),ldir(max_stn)
        integer IPAS(MAX_STN),
     .          IFT(MAX_STN),IDUR(MAX_STN)
	CHARACTER   UPPER
	CHARACTER*3 STAT,lc
	character*128 dsnname
	CHARACTER*4 RESPONSE
        character*2 scode
        integer*2 lna(4)
	real*8 GST,UT,HA,HA2
	integer IC
	LOGICAL EX
Cinteger*4 ifbrk
	integer Z20,Z24
      integer ias2b,trimlen,jchar,iflch,ichmv,ib2as ! functions
      integer ichmv_ch,ichcm_ch
      real*4 speed ! function
	DATA Z20/Z'20'/, Z24/Z'24'/

C Initialized:
	DATA ILENNR/40/, ILENHA/9/, ILENON/40/, ILENEF/40/, ILENWE/39/
C record word lengths
	data ldirr/2hR /,ldirf/2hF /
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
C 951012 nrv Remove DSN output to separate subroutine
C 960223 nrv Call chmod to change permissions.
C 960810 nrv Change ITEARL to an array
C 970114 nrv Write out first 8 char of source name only.

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

         icodp=0
	if (istin.eq.5.or.istin.eq.6) then
          ih=0
          do i=1,max_pass
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
       iobs=0
C      CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
       call ifill(ibuf,1,ibuf_len*2,oblank)
       if (iobs+1.le.nobs) then
         idum = ichmv(ibuf,1,lskobs(1,iobs+1),1,ibuf_len*2)
         ilen = iflch(ibuf,ibuf_len*2)
       else
         ilen=-1
       endif
	IBLK=0
	IPASP=-1
	IDIRP=0
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
	       write(lu_outfile,9302) (lsname(i),i=1,4),irah,
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
		WRITE(CBUF,9420) (LSNAME(i),i=1,4),
     .            IRAH,IRAM,IRAS,ISRA,LDSIGN,
     .            IDECD,IDECM,IDECS,IHR2,MIN2,ISC2,LPROC
9420        FORMAT('S ',4A2,5X,'2 ',3i2.2,'.',I1,1X,A1,3i2.2,14X,
     .             'GMT ',3i2.2,'    1',10X,4A2)
		CALL CHAR2HOL(CBUF,IBUF,1,80)
		NCHAR = ILENNR*2
		CALL writf_asc(LU_OUTFILE,IERR,IBUF,NCHAR/2)
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
	      if (itearl(istn).gt.0) call tmsub(iyr,idayr,ihr,
     .        imin,isc,itearl(istn),iyr,idayr,ihr,imin,isc)
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
	      write(lu_outfile,9100) (lsname(i),i=1,4),
     .        irah2,iram2,ras2,ldsign2,
     .        idecd2,
     .        idecm2,decs2,ihrp,minp,iscp,ihr2,min2,isc2,ihr,imin,isc,
     .        ihr2,min2,isc2,lc,itype
9100          format(6x,4a2,6x,i2,':',i2,':',f9.6,1x,a1,i2,':',i2,':',
     .        f8.5,1x,4(i2,':',i2,':',i2,1x),'12',1x,a3,19x,i1)
	      ipasp = ipas(istnsk)
	      idirp = idir
	      IFTOLD=IFT(ISTNSK)+IFIX(IDIR*
     .        (ITEARL(istn)+IDUR(ISTNSK))*SPEED(ICOD,istn))
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
     .        (lsname(i),i=1,4),ldirword
9408          format(1x,i2,':',i2,':',i2,' - ',i2,':',i2,':',i2,3x,
     .        4a2,4x,'Press ',4a2,'& RECORD  -  Press STOP')

	    else IF (ISTIN.EQ.4) THEN !Bonn pointing
		IRAS = RAS
		ISRA = (RAS-IRAS)*10.0
		IDECS = IFIX(DECS)
		WRITE(CBUF,9440) (LSNAME(i),i=1,4),
     .            IRAH,IRAM,IRAS,ISRA,LDSIGN,
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
            if (icodp.ne.0.and.icod.ne.icodp) then ! write header again
              call vlbah(istin,icod,lu_outfile,ierr)
            endif
	    if (itearl(istn).gt.0) call tmsub(iyr,idayr,ihr,imin,
     .      isc,itearl(istn),iyr,idayr,ihr,imin,isc)
            do ix=1,nchan(istn,icod) ! find out if switched
              ksw=cset(invcx(ix,istn,icod),istn,icod).ne.'   '
            end do
	    CALL VLBAT(ksw,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .       IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,
     .       MJD,UT,GST,MON,IDA,LMON,LDAY,ISTNSK,ISOR,ICOD,
     .       IPASP,IBLK,IDIRP,IFTOLD,NCHAR,
     .       IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .       IYR2,IDAYR2,IHR2,MIN2,ISC2,LU_OUTFILE,IDAYP,
     .       idayrp,ihrp,minp,iscp,iobs,irecp)
            icodp=icod
C
	    END IF !if istin
C
C  Write out the formatted line.  Not needed for VLBA or DSN routine.
C  ***REMOVED: write the line in each section above
C           IF (ISTIN.ne.5.and.istin.ne.6.and.istin.ne.3.and.istin.ne.1)
C    .      CALL writf_asc(LU_OUTFILE,IERR,IBUF,NCHAR/2)
	  END IF ! istnsk
C  CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	    iobs=iobs+1
          call ifill(ibuf,1,ibuf_len*2,oblank)
          if (iobs+1.le.nobs) then
            idum = ichmv(ibuf,1,lskobs(1,iobs+1),1,ibuf_len*2)
            ilen=iflch(ibuf,ibuf_len*2)
          else
            ilen=-1
          endif
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
          call dsnout(ldsn)
	endif !DSN file
C
	IF (IERR.NE.0) WRITE(LUSCN,9901) IERR
9901  FORMAT(/' POINT05 - ERROR ',I3,' READING FILE'/)
990   CLOSE(LU_OUTFILE)
      call drchmod(pntname,iperm,ierr)
C
	RETURN

	END

