	SUBROUTINE SKDSHFT(IERR)

C   Shift a schedule

C 900112 PMR code extracted from SHFTR and ported to Unix
C 900628 GAG Structured (all GOTOs removed)
C 901108 NRV Informational messages added, Break added
C 901109 NRV Removed display of start times, added request for a time.
C 910826 NRV Always wrap by 1 day
c 930412 nrv implicit none
C 960223 nrv change permissions on output file
C 980831 nrv Mods for Y2000. Use IYR2 for 2-digit year, all other
C            year variables are fully specified.
C 990427 nrv Require 4-digit input year.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C Input: none
C Output:
      integer ierr

C LOCAL:
	integer iblen    !maximum buffer length
	INTEGER  IY,IM,IC,ICX,TRIMLEN
	LOGICAL KFNDMD,KFNDCH,kfndpr
     	integer iyr,idoyr       ! original first date, fully specified
        integer iyr2 ! 2-digit year
	integer*2 itim1(6)        ! first shifted obs time
	integer*2 itim0(6)        ! original first obs time
	integer*2 itimn(6)        ! user's target time
        integer*2 itimo(6)        ! original time of shifted obs
      integer ic1,ic2,imodp,ichngp,iprep,indoyr,inday,inyr,
     .inhr,inmin,insec,id1,ih1,im1,id,ihn,imn,
     .isn,idum,ilen,ifc,ilc,i,ih0,im0,is,
     .nh,idur,ispin,ndskd,ih,
     .iyx,idx,ihx,imx,isx,idnow,ihnow,imnow
      integer nhshft,ihshft,isshft,imshft,idshft
      logical kdone,kname,ktim,kearl
Cinteger*4 ifbrk
      integer ias2b,ichmv,iday0,ib2as,ichcm_ch,nhdif ! function
      INTEGER Z4202,Z4203
      DATA Z4202/Z'4202'/, Z4203/Z'4203'/
C Time variables:
C Original time of first observation: idoyr, ih0, im0
C First observation of shifted schedule: id1, ih1, im1
C Last observation of shifted schedule: idnow, ihnow, imnow

	iblen = ibuf_len*2

	IC = TRIMLEN(CINNAME)
	WRITE(LUSCN,9100) CINNAME(1:IC)
9100  FORMAT(' SHIFTING ',A)
	OPEN(LU_INFILE,FILE=CINNAME,STATUS='OLD',IOSTAT=IERR)
	REWIND(LU_INFILE)
	call initf(lu_infile,ierr)
	IF(IERR.NE.0) then
	WRITE(LUSCN,9110) IERR,CINNAME(1:IC)
9110  FORMAT(' SKDSHFT01 - ERROR ',I5,' OPENING FILE ',A)
	RETURN
	end if
C
C 1.0  Get output file name
	kdone = .false.
	kname = .false.
	do while (.not.kdone)
	  do while (.not.kname)
	    WRITE(LUSCN,'(" ENTER NAME OF OUTPUT FILE (:: TO QUIT): ",$)')
	    READ(LUUSR,'(A)') COUTNAME
	    ICX = TRIMLEN(COUTNAME)
	    IF (COUTNAME(1:2).EQ.'::') RETURN
	    IF (CINNAME.EQ.COUTNAME) THEN
		WRITE(LUSCN,'(" INPUT, OUTPUT MUST HAVE DIFFERENT NAMES")')
	    else
		kname = .true.
	    ENDIF
	  end do  ! kname
C
          call purge_file(coutname,luscn,luusr,kbatch,ierr)
          if(ierr .ne. 0) return
	end do ! kdone

	OPEN(LU_OUTFILE,FILE=COUTNAME,STATUS='NEW',IOSTAT=IERR)
	IF(IERR.nE.0) then
	  WRITE(LUSCN,9110) IERR,coutname
	  return
	end if
C
C
C 2.0  Get target date and time.
C
	iy=-1
	im=-1
	id=-1
	do while (iy.lt.0.or.im.lt.0.or.id.lt.0)
          write(luscn,'(" Enter target date (yyyy,mm,dd) ",
     .    "(0,0,0 to quit): ",$)')
	  read(luusr,*,err=201) iy,im,id
	  if (iy.eq.0.and.im.eq.0.and.id.eq.0) return
c       Require 4-digit year.
201     if ((iy.lt.1000).or.(im.le.0.or.im.gt.12).or.(id.le.0.or.
     .  id.gt.31)) then
	    write(luscn,'(" Invalid number for year, month, or day.")')
	    iy=-1
	  endif
	enddo
Cif (iy.lt.100) then ! 2-digit year
C         iyr2=iy
C         if (iyr2.le.99.and.iyr2.ge.50) iy=iyr2+1900
C         if (iyr2.le.49.and.iyr2.ge. 0) iy=iyr2+2000
C       else ! 4-digit year
          if (iy.lt.2000) iyr2=iy-1900
          if (iy.ge.2000) iyr2=iy-2000
C       endif
	INDOYR = IDAY0(IY,IM) + ID
	inyr = iy

	ihn=-2
	imn=-1
	isn=-1
	do while (ihn.lt.0.or.imn.lt.0.or.isn.lt.0)
	  write(luscn,'(" Enter target start time (h,m,s) ",
     .  "(-1,0,0 to quit): ",$)')
	  read(luusr,*,err=202) ihn,imn,isn
	  if (ihn.eq.-1.and.imn.eq.0.and.isn.eq.0) return
202     if ((ihn.lt.0.or.ihn.gt.24).or.(imn.lt.0.or.imn.gt.59).or.
     .  (isn.lt.0.or.isn.gt.59)) then
	    write(luscn,'(" Invalid number for hour, minute, or "
     .    "seconds.")')
	    ihn=-2
	  endif
	enddo

	idum = ib2as(iyr2,itimn,1,z4202)
	idum = ib2as(indoyr,itimn,3,z4203)
	idum = ib2as(ihn,itimn,6,z4202)
	idum = ib2as(imn,itimn,8,z4202)
	idum = ib2as(isn,itimn,10,z4202)
	write(luscn,9202) iy,indoyr,ihn,imn,isn
9202  format(' Requested start time of shifted schedule: ',i4,1x,i3,
     .'-',i2.2,':',i2.2,':',i2.2)
C
C  2.6  Get desired length of schedule

	nhshft=-1
	do while (nhshft.lt.0)
	  write(luscn,'(" How long do you want the shifted schedule ",
     .  "to be "/"  (enter number of hours, 0 to quit): ",$)')
	  read(luusr,*,err=261) nhshft
261     if (nhshft.eq.0) return
	  if (nhshft.lt.0) write(luscn,
     .  '(" Invalid number of hours.  Try again.")')
	enddo
C
C 3.0 Check for proper start of schedule.
C
        cbuf="* "
	do while (cbuf(1:1) .eq. "*")
	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
  	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9300) IERR
9300      FORMAT(' SKDSHFT02 - READ ERROR ',I5)
	    RETURN !
	  ENDIF
	end do
C
	IF(ichcm_ch(IBUF,1,'$EXPER').NE.0) THEN
	  WRITE(LUSCN,9310)
9310    FORMAT(' Did not find $EXPER on first line.')
	  RETURN
	ENDIF
C
C 4.0  Locate change, modular, and prepass parameters.
C
	call char2hol('  ',ibuf,1,2)
	do while (ichcm_ch(IBUF,1,'$PARAM').NE.0)
   	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9400) IERR
9400      FORMAT(' SKDSHFT03 - READ ERROR ',i5,' looking for $PARAM')
	    RETURN
	  ENDIF
	  IF(iLEN.EQ.-1) THEN
	    WRITE(LUSCN,9410)
9410      FORMAT(' SKDSHFT04 - $PARAM not found.')
	    RETURN
	  ENDIF
	end do
C
	KFNDMD = .FALSE.
	KFNDCH = .FALSE.
	kfndpr = .false.
	do while ((.not.kfndmd).or.(.not.kfndch).or.(.not.kfndpr))
 	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
      	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9420) IERR
9420      FORMAT(' SKDSHFT05 - READ ERROR ',i5,' in $PARAM section')
	    RETURN
	  ENDIF
	  IF(cbuf(1:1) .eq. "$") THEN
	    WRITE(LUSCN,9430)
9430      FORMAT(' SKDSHFT06 - Did not find MODULAR and/or CHANGE ',
     .    'and/or PREPASS in $PARAM section.')
	    RETURN
	  ENDIF
C
	  IFC = 1
	  ILC = iLEN*2
	  CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	  do while (ic1.ne.0)
	    IF (ichcm_ch(IBUF,IC1,'MODULAR').eq.0) then
C Found "MODULAR" - next field is parameter we want.
		KFNDMD = .TRUE.
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		IF(IC1.EQ.0) THEN
		  WRITE(LUSCN,9440)
9440          FORMAT(' SKDSHFT07 - No value field after MODULAR')
		  RETURN
		ENDIF
		IMODP = IAS2B(IBUF,IC1,IC2-IC1+1)

	    else IF (ichcm_ch(IBUF,IC1,'CHANGE').eq.0) then
C found "CHANGE" - next field is parameter we want
		KFNDCH = .TRUE.
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		IF(IC1.EQ.0) THEN
		  WRITE(LUSCN,9450)
9450          FORMAT(' SKDSHFT08 - No value field after CHANGE')
		  RETURN
		ENDIF
		ICHNGP = IAS2B(IBUF,IC1,IC2-IC1+1)

	    else IF (ichcm_ch(IBUF,IC1,'PREPASS').eq.0) then
C found "PREPASS" - next field is parameter we want
		kfndpr = .TRUE.
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		IF(IC1.EQ.0) THEN
		  WRITE(LUSCN,9460)
9460          FORMAT(' SKDSHFT081 - No value field after PREPASS')
		  RETURN
		ENDIF
		IPREP = IAS2B(IBUF,IC1,IC2-IC1+1)
	    end if
	    CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	  end do !"while ic1 = 0"
	end do !"while not kfndch or kfndmd"
	write(luscn,9470) ichngp,imodp,iprep
9470  format(' Tape change time = ',i5,
     .       '.  Modular start time = ',i5,
     .       '.  Prepass time = ',i5,'.')
C
C 5.0  Copy file up to $SKED section.
C
	REWIND(LU_INFILE)
	call initf(lu_infile,ierr)
	call char2hol('  ',ibuf,1,2)
	write(luscn,9501)
9501  format(' Writing out schedule file up to $SKED section.')
	do while (ichcm_ch(IBUF,1,'$SKED').ne.0)
C  if (ifbrk().lt.0) return
	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
 	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9500) IERR
9500      FORMAT(' SKDSHFT09 - READ ERROR ',I5,' searching for $SKED')
	    RETURN
	  ENDIF
	  IF(iLEN.EQ.-1) THEN
	    WRITE(LUSCN,9510)
9510      FORMAT(' SKDSHFT10 - Did not find $SKED before EOF.')
	    RETURN
	  ENDIF
C
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
      	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9520) IERR
9520      FORMAT(' SKDSHFT11 - WRITE ERROR ',I5,' before $SKED found.')
	    RETURN
	  ENDIF
	end do !"read until $SKED"
C
C 6.0  Get original date and compute shift.
C    File is positioned to read the first observation in $SKED section.
C
 	CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	IF(IERR.NE.0) THEN
	  WRITE(LUSCN,9600) IERR
9600      FORMAT(' SKDSHFT12 - READ ERROR ',I5,' first observation.')
	  RETURN
	ENDIF
	IF(iLEN.EQ.-1) THEN
	  WRITE(LUSCN,9610)
9610    FORMAT(' SKDSHFT13 - NO ENTRIES in $SKED section.')
	  RETURN
	ENDIF
	IFC = 1
	ILC = iLEN*2
C
	DO I=1,5
	  CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	  IF(IC1.EQ.0) THEN
	    WRITE(LUSCN,9620)
9620          FORMAT(' SKDSHFT14 - FIELD error skipping to start time')
	    RETURN
	  ENDIF
	end do
C
	IDUM = ICHMV(ITIM,1,IBUF,IC1,11)
        IYR2 = IAS2B(ITIM,1,2) ! 2-digit year
        if (IYR2.gt.50.and.iyr2.le.99) iyr=iyr2+1900 
        if (IYR2.ge. 0.and.iyr2.le.50) iyr=iyr2+2000 
	IDOYR = IAS2B(ITIM,3,3)
	ih0=ias2b(itim,6,2)
	im0=ias2b(itim,8,2)
	is=ias2b(itim,10,2)
	idum = ichmv(itim0,1,itim,1,11)
C   ITIM0 holds the original time of the first observation.
	write(luscn,9631) iyr,idoyr,ih0,im0,is
9631  format(' Original time of first observation   ',i4,1x,i3,'-',
     .i2.2,':',i2.2,':',i2.2)

C  6.5  If the new schedule time is later than the original time,
C       find out if the new time is actually within the schedule.
C       If so, there is no need for an initial shift.

	ktim = .false.
	if (kearl(itim0,itimn)) then ! search for new time in original
	  kdone = .false.
	  do while (.not.kdone) ! check each time
	    CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
 	    IF(IERR.NE.0) THEN
		WRITE(LUSCN,9650) IERR
9650        FORMAT(' SKDSHFT69 - READ ERROR ',I5,' looking for time')
		RETURN
	    ENDIF
	    IF(iLEN.EQ.-1.or.cbuf(1:1) .eq."$") THEN !eof
		kdone = .true.
		ktim = .false.
	    else !check time
		IFC = 1
		ILC = iLEN*2
		DO I=1,5
		  CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		  IF(IC1.EQ.0) THEN
		    WRITE(LUSCN,9652)
9652            FORMAT(' SKDSHFT64 - FIELD error')
		    RETURN
		  ENDIF
		end do
		IDUM = ICHMV(ITIM,1,IBUF,IC1,11)
		if (kearl(itimn,itim)) then
		  kdone = .true.
		  ktim = .true.
		ENDIF
	    endif ! eof/check time
	  enddo ! check each time
	  if (ktim) then !found the time
	    inyr = iyr
	    indoyr = idoyr
	  else !rewind, reposition
	    REWIND(LU_INFILE)
	    call initf(lu_infile,ierr)
	    call char2hol('  ',ibuf,1,2)
	    do while (ichcm_ch(IBUF,1,'$SKED').ne.0)
		CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
   	    end do !"read until $SKED"
	    CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
 	    IFC = 1
	    ILC = iLEN*2
	    DO I=1,5
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	    end do
	    IDUM = ICHMV(ITIM,1,IBUF,IC1,11)
	  endif !found/rewind
	endif !search for new time in original/compute shift

	CALL CMSHF(InYr,IYR,IDOYR,INDOYR,IMODP,
     .     ISSHFT,IMSHFT,IHSHFT,IDSHFT)
C
       WRITE(LUSCN,9630) idshft,ihshft,imshft,isshft
9630   FORMAT(' Sidereal shift is ',i5,' days, and ',i5,'h ',i5,
     .'m ',i5,'s')
C
C  7.0  Find the observation to start the new schedule with.
C       We have just read the first observation line, or we are
C       positioned to the first observation to use.
C       ITIM and ITIM1 holds the first observation time.

	CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,ISSHFT,IMSHFT,IHSHFT,
     .             IDSHFT)
	idum = ichmv(itim1,1,itim,1,11)
	IY = IAS2B(ITIM,1,2)
	ID1 = IAS2B(ITIM,3,3)
	ih1=ias2b(itim,6,2)
	im1=ias2b(itim,8,2)
	is=ias2b(itim,10,2)
	write(luscn,9789) iy,id1,ih1,im1,is
9789  format(' First observation shifts to: ',i2,1x,
     .i3,'-',i2.2,':',i2.2,':',i2.2)

	call gtshft(isshft,imshft,ihshft,idshft,itimn,itimo,ierr)
	if (ierr.eq.-1) return
C        We are now positioned with the first shifted observation
C        in IBUF, ITIM.
	IY = IAS2B(ITIM,1,2)
	ID1 = IAS2B(ITIM,3,3)
	ih1=ias2b(itim,6,2)
	im1=ias2b(itim,8,2)
	is=ias2b(itim,10,2)
	write(luscn,9790) iy,id1,ih1,im1,is
9790  format(' First observation of the shifted schedule   ',i2,1x,
     .i3,'-',i2.2,':',i2.2,':',i2.2)
	IYx = IAS2B(ITIMo,1,2)
	IDx = IAS2B(ITIMo,3,3)
	ihx=ias2b(itimo,6,2)
	imx=ias2b(itimo,8,2)
	isx=ias2b(itimo,10,2)
        write(luscn,9791) iyx,idx,ihx,imx,isx
9791    format(' (shifted from original time   ',i2,1x,i3,'-',i2.2,
     .  ':',i2.2,':',i2.2,')')

C 8.0  Shift and copy shifted schedule from specified start to end.
C
	call shfcop(isshft,imshft,ihshft,idshft,ilen,
     .id1,ih1,im1,nhshft,ierr)
	if (ierr.eq.-1) return
	IY = IAS2B(ITIM,1,2)
	IDnow = IAS2B(ITIM,3,3)
	ihnow=ias2b(itim,6,2)
	imnow=ias2b(itim,8,2)
	is=ias2b(itim,10,2)
	write(luscn,9890) iy,idnow,ihnow,imnow,is
9890  format(' Last shifted observation from original schedule   ',
     .i2,1x,i3,'-',i2.2,':',i2.2,':',i2.2)
C
C 9.0  Go back to beginning of schedule, shift by +1 day and add
C    on to the end of the shifted schedule.
C
	nh = nhshft - nhdif(idnow,ihnow,imnow,id1,ih1,im1)
	do while (nh.gt.0)  !need more
	  write(luscn,9901) nh
9901    format(' Going back to beginning of schedule to get ',i4,
     .  ' more hours.')
	  CALL POSNT(LU_INFILE,IERR,-2)
	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9900) IERR
9900      FORMAT(' SKDSHFT23 - POSNT ERROR ',I5)
	    RETURN
	  ENDIF
    	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
        	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9910) IERR
9910      FORMAT(' SKDSHFT24 - ERROR ',I5,' re-reading last obs.')
	    RETURN
	  ENDIF
	  CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	  IDUR = IAS2B(IBUF,IC1,IC2-IC1+1) !longest dur of all stations
	  ISPIN = 392 ! maximum time to spin whole tape down
          ISSHFT = IDUR + ISPIN + IPREP + ICHNGP
	  IDSHFT = 0
	  IHSHFT = 0
	  IMSHFT = 0
	  IDUM = ICHMV(ITIMS,1,ITIM,1,11)
C
	  CALL TSHFT(ITIMS,INDAY,INHR,INMIN,INSEC,
     .       ISSHFT,IMSHFT,IHSHFT,IDSHFT)
C       ITIMS is the time of the last shifted observation PLUS the
C       time required to change tapes.  This is the next allowable time.

C   Now compute a new shift one day later than the original.
          ndskd = 1  !length of schedule
	  INDOYR = INDOYR + ndskd
	  CALL CMSHF(InYr,IYR,IDOYR,INDOYR,IMODP,
     .       ISSHFT,IMSHFT,IHSHFT,IDSHFT)
       WRITE(LUSCN,9632) idshft,ihshft,imshft,isshft
9632   FORMAT(' Sidereal shift of wrapped schedule is ',i5,
     .' days, and ',i5,'h ',i5,'m ',i5,'s')
C
	  REWIND(LU_INFILE)
	  call initf(lu_infile,ierr)
	  call char2hol('  ',ibuf,1,2)
	  do while (ichcm_ch(IBUF,1,'$SKED').ne.0)
    	    CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
   	  end do !"read until $SKED"
    	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
 	  IFC = 1
	  ILC = iLEN*2
	  DO I=1,5
	    CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
	  end do
	  IDUM = ICHMV(ITIM,1,IBUF,IC1,11)

	  CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,ISSHFT,IMSHFT,IHSHFT,
     .             IDSHFT)

	  call gtshft(isshft,imshft,ihshft,idshft,itims,itimo,ierr)
	  if (ierr.eq.-1) return
C        We are now positioned with the first shifted observation
C        in IBUF, ITIM.
	  IYr2 = IAS2B(ITIM,1,2)
          if (iyr2.ge.50.and.iyr2.le.99) iyr=iyr2+1900
          if (iyr2.ge. 0.and.iyr2.lt.50) iyr=iyr2+2000
	  ID = IAS2B(ITIM,3,3)
	  ih=ias2b(itim,6,2)
	  im=ias2b(itim,8,2)
	  is=ias2b(itim,10,2)
	  write(luscn,9920) iyr2,id,ih,im,is
9920    format(' First observation of the wrapped schedule   ',i2,1x,
     .  i3,'-',i2.2,':',i2.2,':',i2.2)

	  call shfcop(isshft,imshft,ihshft,idshft,ilen,
     .  id1,ih1,im1,nhshft,ierr)
	  if (ierr.eq.-1) return
	  idnow = ias2b(itim,3,3)
	  ihnow = ias2b(itim,6,2)
	  imnow = ias2b(itim,8,2)
	  nh = nhshft - nhdif(idnow,ihnow,imnow,id1,ih1,im1)
	enddo !need more

	IY = IAS2B(ITIM,1,2)
	ID = IAS2B(ITIM,3,3)
	ih=ias2b(itim,6,2)
	im=ias2b(itim,8,2)
	is=ias2b(itim,10,2)
	write(luscn,9990) iy,id,ih,im,is
9990  format(' Last observation of the shifted schedule   ',i2,1x,
     .i3,'-',i2.2,':',i2.2,':',i2.2)
C
C 10.0  Finish copying the rest of the file.
C
	IF(iLEN.EQ.-1) THEN
	  WRITE(LUSCN,8000) COUTNAME(1:ICX)
8000    FORMAT(' SHIFTED FILE ',A,' CREATED'/)
	else
	  write(luscn,9801)
9801    format(' Copying rest of schedule file beyond $SKED section.')
	end if
C
	do while (cbuf(1:1).ne."$" .and. ilen .ne.-1) !read to next $
     	  call readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
       	  IF(IERR.ne.0) THEN
	    WRITE(LUSCN,8020) IERR
8020      FORMAT(' SKDSHFT33 - Error ',I5,' finding end of $SKED')
	    RETURN
	  ENDIF
	enddo !read to next $

	do while (ilen.ne.-1) !copy to end
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,8010) IERR
8010      FORMAT(' SKDSHFT30 - WRITE ERROR ',I5)
	    RETURN
	  ENDIF
   	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
 	  IF(IERR.ne.0) THEN
	    WRITE(LUSCN,8030) IERR
8030      FORMAT(' SKDSHFT31 - READ ERROR ',I5)
	    RETURN
	  ENDIF
	  if (ilen.eq.-1) then
	    write(luscn,8000) coutname(1:icx)
	  end if
	end do !copy to end
C
990   close(lu_outfile)
      call drchmod(coutname,iperm,ierr)
      RETURN
      END
