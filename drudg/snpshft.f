	subroutine snpshft(ierr)
C
C Shift a SNAP file
C 900112 PMR code extracted from SHFTR and ported to Unix
C 930412 nrv implicit none
C 930429 nrv removed GTPRM call, changed to read yymmdd
C 930702 nrv Check for EOF when reading first lines.
C 960215 nrv Change permissions on output file
C 980831 nrv Mods for Y2000. Use IY2 for 2-digit year, all other
C            year variables are fully specified.

C Called by: DRUDG

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Output
      integer ierr

C LOCAL:
	integer iy,im,id,ic,trimlen
      integer*2 ldold,ldir,iyt
      integer nc,ich,ic1,ic2,idummy,iblen,ilen,i,icount,imodp,
     .irec,idum,ntap,itape,ilrec,isrec,icol
      integer idshft,ihshft,imshft,isshft,lsd,lsh
      integer idoyr,iyr,indoyr,isd,ish,inday,inhr,inmin,insec
      integer iy2 ! 2-digit year, iyr is fully specified
	logical KEARL,KNEWP
	logical kex ! true if file exists
	logical kdone
Cinteger*4 ifbrk
	integer*2 LM7(23)
	CHARACTER*80 CHT
	character*3 stat
             integer*2 HBB
	INTEGER Z46,Z39,Z30,H2C,HQUB,z4202
      integer iday0,ias2b,jchar,ib2as,ichcm,ichmv ! functions
      integer ichcm_ch
      data z4202/z'4202'/
      DATA HBB/2H  /, H2C/2H::/, HQUB/2H" /
      DATA Z46/Z'46'/, Z39/Z'39'/, Z30/Z'30'/
      DATA LM7/2H S,2HID,2HER,2HEA,2HL ,2HSH,2HIF,2HT ,2HIS,2H  ,2H  ,
     .2H D,2H A,2HND,2H  ,2H  ,2H H,2H  ,2H  ,2H M,2H  ,2H  ,2H S/

	DATA iblen/75/ !      -for READF
C
	ic = trimlen(cinname)
	inquire(file=cinname,exist=kex)
	if (.not.kex) then
	  write(luscn,9398) cinname(1:ic)
9398    format(' SNPSHFT01 - SNAP file ',A,' does not exist')
	  return
	else
	  write(luscn,9399) cinname(1:ic)
9399    format(' Shifting ',A)
	endif
C
	OPEN(LU_INFILE,file=cinname,status='OLD',iostat=IERR)
	IF(IERR.EQ.0) THEN
	  rewind(LU_INFILE)
	  call initf(LU_INFILE,ierr)
	ELSE
	  WRITE(LUSCN,9400) IERR,cinname(1:ic)
9400    FORMAT(' SNPSHFT02 - Error ',I5,' opening SNAP file ',A)
	  return    ! GOTO 200
	ENDIF
C
C 3.0  Get output file name
C
	kdone = .false.
	do while (.not.kdone)
	  write(luscn,'(" Enter name of output file (:: to quit): ",$)')
	  read(luusr,'(a)') coutname
	  IF(coutname(1:2).EQ.'::') return
	  IF (cinname.eq.coutname) then
	    write(luscn,9397)
9397      format(' SNPSHFT03 - Input, output must have different names')
	  else
	    kdone = .true.
	  ENDIF
C
          call purge_file(coutname,luscn,luusr,.false.,ierr)
	end do !"kdone"

	OPEN(LU_OUTFILE,file=coutname,status=stat,iostat=IERR)
	IF (IERR.ne.0) THEN
	  WRITE(LUSCN,9400) IERR
	else
	  rewind(LU_OUTFILE)
	  call initf(LU_OUTFILE,ierr)
	ENDIF
C
C 4.0  Get target date.
C
	kdone= .false.
	do while (.not.kdone)
	  WRITE(LUSCN,'(" ENTER TARGET DATE (YYMMDD)(:: TO QUIT): ",$)')
	  CALL GTRSP(IBUF,ISKLEN,LUUSR,NC)
	  IF(ichcm(IBUF(1),1,H2C,1,2).eq.0) RETURN !"if two colons"
	  kdone = .true.
          iy2 = ias2b(ibuf,1,2)
          im = ias2b(ibuf,3,2)
          id = ias2b(ibuf,5,2)
	  IF(iy2.lt.0) then
	    WRITE(LUSCN,'(" INVALID NUMBER FOR YEAR.")')
	    kdone = .false.
	  end if
C
	  if (kdone) then
	    IF(IY2.Le.99.and.iy2.ge.50) IY=IY2+1900
	    IF(IY2.Lt.50.and.iy2.ge. 0) IY=IY2+2000
	    IF(IM.le.0.or.IM.gt.12) then
		WRITE(LUSCN,'(" MONTH MUST BE 1 TO 12.")')
		kdone = .false.
	    end if
	  end if
C
	  if (kdone) then
	    IF(ID.le.0.or.ID.gt.31) then
		WRITE(LUSCN,'(" DAY MUST BE 1 TO 31.")')
		kdone = .false.
	    end if
	    INDOYR = IDAY0(IY,IM) + ID
	  end if
	end do !"kdone for target date"
C
C Determine file type and branch to appropriate section.
C
	CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
9120    format(' SNPSHFT07 - READ error ',i5)
	  return
  	ENDIF
C
	IF ((ichcm_ch(IBUF,1,'SOURCE').ne.0).and.
     .   (ICHCM(IBUF,1,hqub,    1,2).ne.0)) THEN
	  write(luscn,'(" SNPSHFT08 - Improper schedule file format")')
	  return
	ENDIF
C
C************************************************************
C THIS SECTION SHIFTS A DRUDG-PRODUCED (SNAP) SCHEDULE FILE *
C************************************************************
C  15.0  Get first date in schedule.
C
1500  IF (IBUF(1).NE.hqub) GOTO 1510
C
C       WE HAVE THE ORIGINAL YEAR OF SCHEDULE AVAILABLE
	ICH=2
	CALL GTFLD(IBUF,ICH,iLEN*2,IC1,IC2)
	CALL GTFLD(IBUF,ICH,iLEN*2,IC1,IC2)
	IYR=IAS2B(IBUF,IC1,IC2-IC1+1)
	IF (IY.NE.IYR) IDUMMY = IB2AS(IY,IBUF,IC1,4)
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
 	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
9121    format(' SNPSHFT04 - WRITE error ',i5)
	  return ! GOTO 1201
	ENDIF
C
	GOTO 1511
1510  WRITE(LUSCN,9150)
9150  FORMAT(' Enter year of schedule (:: to quit): ',$)
	CALL GTRSP(IBUF,ISKLEN,LUUSR,NC)
	IF (ichcm(IBUF(1),1,h2c,1,2).eq.0)  return ! GOTO 1301
	IYR=IAS2B(IBUF,1,NC)
1511  CONTINUE
	IF(IYR.LT.0) GOTO 1510
	IF(IYR.EQ.0)  return ! GOTO 1301
        if (iyr.lt.100) then ! 2-digit year specified
          iy2=iyr
	  IF(IY2.Le.99.and.iy2.ge.50)IYR = IY2+1900
          IF(IY2.Lt.50.and.iy2.ge. 0)IYR = IY2+2000
        else ! 4-digi year
          iy2=iyr-2000
          if (iy2.lt.0) iy2=iyr-1900
        endif
C
1512  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
        if (ilen.lt.0) then !eof
          write(luscn,9119)
9119      format(' SNPSHFT09 - EOF before any schedule times.',
     .    '  No schedule lines in output file.')
          return
        endif
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
     	ENDIF
C
C Read up to the first time (! command)
1501  IF(cbuf(1:1) .ne. "!") goto 1512
C       If there is a ! line, re-set the day of year
	IDOYR = IAS2B(IBUF,2,3)
C
C 16.0 Determine amount of sidereal shift
1600  IMODP = 10
	CALL CMSHF(IY,IYR,IDOYR,INDOYR,IMODP,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	IDUMMY = IB2AS(IDSHFT,LM7,19,5)
	IDUMMY = IB2AS(IHSHFT,LM7,29,5)
	IDUMMY = IB2AS(IMSHFT,LM7,35,5)
	IDUMMY = IB2AS(ISSHFT,LM7,41,5)
	write(luscn,9701) (lm7(i),i=1,23)
9701  format(23A2)
C
C 17.0 Display tape start times.
	write(luscn,'(" Shifted pass start times")')
	WRITE(LUSCN,9175)
9175  FORMAT(4('   # ddd-hh:mm:ss D',$))
        write(luscn,'()')
	REWIND(LU_INFILE)
	call initf(LU_INFILE,ierr)
	ICOUNT = 0
	KNEWP = .TRUE.
	LDOLD = hbb
C
1700  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
Cif (ifbrk().lt.0) return
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
    	ENDIF
C
	IF(iLEN.EQ.-1)GOTO 1800
	IF(ichcm_ch(IBUF,1,'READY').EQ.0.OR.ICHCM_CH(IBUF,1,'MIDTP')
     .   .EQ.0) KNEWP = .TRUE.
	IF(ichcm_ch(IBUF,1,'ST=').NE.0) GOTO 1700
	IDUMMY = ICHMV(LDIR,1,IBUF,4,1)
	IF(.NOT.KNEWP.AND.ICHCM(LDIR,1,LDOLD,1,1).EQ.0) GOTO 1700
	LDOLD = LDIR
	KNEWP = .FALSE.
C
	ICOUNT = ICOUNT+1
	CALL LOCF(LU_INFILE,IREC)
	IF (IERR.NE.0) THEN
	  write(luscn,9125) ierr
9125    format(' SNPSHFT05 - LOCF error ',i5)
	  return ! GOTO 1205
	ENDIF
C
	ITPOS(ICOUNT) = IREC - 4
	LD(ICOUNT) = LDIR
	CALL POSNT(LU_INFILE,IERR,-3)
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
9126    format(' SNPSHFT06 - POSNT error ',i5)
	  return ! GOTO 1206
	ENDIF
C
	CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
  	ENDIF
C
	IDUMMY = IB2AS(IY2,IYT,1,Z4202)
	IDUM = ICHMV(ITIM,1,IYT,1,2)
	IDUM = ICHMV(ITIM,3,IBUF,2,9)
	CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	IF(ICOUNT.NE.1) GOTO 1702
	ISD=INDAY
	ISH=INHR
	icol = 1
C
1702  continue
      cbuf=" "
C     IF (MOD(ICOUNT,4).EQ.0) then !write a line
      if (icol.eq.5) then
	WRITE(LUSCN,9171) CHT
9171    FORMAT(A)
	icol = 1
      endif !write a line
      WRITE(CHT(ICOL*20-19:ICOL*20),9170)
     .     ICOUNT,INDAY,INHR,INMIN,INSEC,LDIR
9170  FORMAT(I4,1X,I3.3,'-',I2.2,':',I2.2,':',I2.2,1X,A2)
	icol=icol+1
	GOTO 1700
C
C 18.0 Get new start time for schedule.
1800  LSD=INDAY
	LSH=INHR
	NTAP = ICOUNT
C        Write remainder of pass starts
	if (icol.gt.1) WRITE(LUSCN,9171) CHT(1:(icol-1)*20)
	WRITE(LUSCN,9171)
	write(luscn,'(" Enter number of pass to start with, 0 to quit "
     .,$)')
	CALL GTRSP(IBUF,ISKLEN,LUUSR,NC)
	ITAPE=IAS2B(IBUF,1,NC)
	IF(ITAPE.EQ.0)  return ! GOTO 1301
	IF(ITAPE.GT.0)GOTO 1801
	write(luscn,'(" Invalid pass number.")')
	GOTO 1800
C
C1801 CALL POSNT(LU_INFILE,IERR,ITPOS(ITAPE),idum,idum)
1801  CALL APOSN(LU_INFILE,IERR,itpos(itape))
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
	  return ! GOTO 1206
	ENDIF
C
1803  CALL POSNT(LU_INFILE,IERR,-2)
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
	  return ! GOTO 1206
	ENDIF
	CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
C
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
 	ENDIF
	IF(ichcm_ch(IBUF,1,'SOURCE').NE.0)GOTO 1803
C
	CALL LOCF(LU_INFILE,IREC)
	IF (IERR.NE.0) THEN
	  write(luscn,9125) ierr
	  return ! GOTO 1205
	ENDIF
C
C 19.0 Write out shifted schedule.
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
   	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
1902  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
C
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
	ENDIF
C
C  Delete "UNLOD" and/or "FASTR" at beginning of new schedule
        if(cbuf(1:5) .eq. "UNLOD" .or. cbuf(1:4) .eq. "FAST" .or.
     >     cbuf(1:5) .eq. "MIDTP" .or. cbuf(1:4) .eq. "CHECK") goto 1902
C
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
  	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
C
        cbuf="READY"
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,3)
     	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
C
	IF (JCHAR(LD(ITAPE),1).EQ.Z46) GOTO 1905
        cbuf='FASTF=6M42S'
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,6)
     	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
C
1905  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
     	ENDIF
C
        if(cbuf(1:5) .eq. "READY" .or. cbuf(1:4) .eq. "FAST") goto 1905
       	IDUMMY = IB2AS(IY2,ITIM,1,Z4202)
	IDUMMY = ICHMV(ITIM,3,IBUF,2,9)
	CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	IDUMMY = ICHMV(IBUF,2,ITIM,3,9)
C
C Main copying loop
1900  CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
  	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
1901  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
     	ENDIF
C
	IF(iLEN.EQ.-1)GOTO 1903
	IF(cbuf(1:1) .ne. "!")GOTO 1900
        if(cbuf(2:2) .lt. "0" .or. cbuf(2:2) .gt. "9") goto 1900
C Shift times appropriately.
	IDUMMY = IB2AS(IY2,ITIM,1,Z4202)
	IDUM = ICHMV(ITIM,3,IBUF,2,9)
	CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	IDUMMY = ICHMV(IBUF,2,ITIM,3,9)
	GOTO 1900
C
C Delete "UNLOD" at end of original schedule.
1903  IF(ITAPE.EQ.1) return ! GOTO 2010
	CALL POSNT(LU_INFILE,IERR,-1)
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
	  return ! GOTO 1206
	ENDIF
1904  CALL POSNT(LU_OUTFILE,IERR,-1)
	IF(IERR.NE.0) THEN
	   write(luscn,9126) ierr
	   return ! GOTO 1206
	ENDIF
C
	CALL POSNT(LU_INFILE,IERR,-2)
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
	  return ! GOTO 1206
	ENDIF
	CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
    	ENDIF
C
	IF(ichcm_ch(IBUF,1,'POSTOB').NE.0)GOTO 1904
	CALL LOCF(LU_INFILE,ILREC)
	IF (IERR.NE.0) THEN
	  write(luscn,9125) ierr
	  return ! GOTO 1205
	ENDIF
C
C Compute and save next allowable time.
	IDUM = ICHMV(ITIMS,1,ITIM,1,11)
	IDSHFT = 0
	IHSHFT = 0
	IMSHFT = 0
	ISSHFT = 420
	CALL TSHFT(ITIMS,INDAY,INHR,INMIN,INSEC,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
C
C 20.0  Adjust shift and Write front of schedule at end.
C Add one more day to shift.
	INDOYR = INDOYR+1
	IF(LSH-ISH.LT.0) LSD=LSD-1
	IF(LSD-ISD.GT.1) INDOYR=INDOYR+LSD-ISD-1
	CALL CMSHF(IY,IYR,IDOYR,INDOYR,IMODP,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
C
C Locate first record that won't overlap current schedule.
2002  REWIND(LU_INFILE)
	call initf(LU_INFILE,ierr)
C
C Read input until next time is encountered.
	DO 2004 I=1,NTAP
	  IF (ichcm_ch(LD(I),1,'R').EQ.0) GOTO 2004
	  CALL APOSN(LU_INFILE,IERR,itpos(i))
	  IF(IERR.NE.0) THEN
	    write(luscn,9126) ierr
	    return ! GOTO 1206
	  ENDIF
C
2003    CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	  IF(IERR.NE.0) THEN
	    write(luscn,9120) ierr
	    return ! GOTO 1200
     	  ENDIF
	  IF(cbuf(1:1).ne."$")GOTO 2003
          if(cbuf(2:2) .lt. "0" .or. cbuf(2:2) .gt. "9") goto 2003
C
C Decode time and compare with last time in current schedule.
	  IDUMMY = IB2AS(IY2,ITIM,1,Z4202)
	  IDUMMY = ICHMV(ITIM,3,IBUF,2,9)
	  CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,
     .             ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	  IF(KEARL(ITIMS,ITIM))GOTO 2005
2004  CONTINUE
C
C  Find beginning of next record to be copied.
2005  CALL POSNT(LU_INFILE,IERR,-2)
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
	  return ! GOTO 1206
	ENDIF
	CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
C
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
 	ENDIF
	IF(ichcm_ch(IBUF,1,'SOURCE').NE.0)GOTO 2005
C
C  Shift and copy remainder of schedule.
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
     	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
C
C  Pick up UNLOD, etc. from end of input file.
	CALL LOCF(LU_INFILE,ISREC)
	IF (IERR.NE.0) THEN
	  write(luscn,9125) ierr
	  return ! GOTO 1205
	ENDIF
	CALL APOSN(LU_INFILE,IERR,ilrec)
	IF(IERR.NE.0) THEN
	   write(luscn,9126) ierr
	   return ! GOTO 1206
	ENDIF
C
2006  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
 	ENDIF
	IF(iLEN.EQ.-1)GOTO 2007
	CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
    	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
	GOTO 2006
C
2007  CALL APOSN(LU_INFILE,IERR,isrec)
	IF(IERR.NE.0) THEN
	  write(luscn,9126) ierr
	  return ! GOTO 1206
	ENDIF
C
2008  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
  	ENDIF
	IF (ichcm_ch(IBUF,1,'MIDTP').EQ.0) GOTO 2008
	IF (ichcm_ch(IBUF,1,'CHECK').EQ.0) GOTO 2008
	IF(ichcm_ch(IBUF,1,'UNLOD').NE.0)GOTO 2009
C
2000  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  write(luscn,9120) ierr
	  return ! GOTO 1200
 	ENDIF
C
2009  IF(iLEN.EQ.-1) then
	write(luscn,9209) coutname
9209    format(' Shifted SNAP file completed: ',a)
        close(lu_outfile)
        call drchmod(coutname,iperm,ierr)
	return ! GOTO 2010
      endif
	IF(cbuf(1:1).ne."$")GOTO 2001
        if(cbuf(2:2) .lt. "0" .or.cbuf(2:2) .gt. "9") goto 2001
        	IDUMMY = IB2AS(IY2,ITIM,1,Z4202)
	IDUMMY = ICHMV(ITIM,3,IBUF,2,9)
	CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,
     .           ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	IDUM = ICHMV(IBUF,2,ITIM,3,9)
C
2001  CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
    	IF (IERR.NE.0) THEN
	  write(luscn,9121) ierr
	  return ! GOTO 1201
	ENDIF
C
	GOTO 2000
	END
