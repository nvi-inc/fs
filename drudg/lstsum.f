	SUBROUTINE LSTSUM(kskd,IERR)
C Create SUMMARY of SNAP file
C
C NRV 901121 New routine, modeled on CLIST.BAS
C            NOTE: this gets pass numbers right only for 'SX' experiments
C NRV 901205 Removed output file, going directly to printer
C NRV 910703 Add PRTMP call at end
C NRV 910825 Change check for setup procedure to end, remove check
C            for "SX" and replace with check for '='. All other commands
C            have already been checked and processed. This is the only
C            procedure which has the '=' sign.
C nrv 930412 implicit none
C nrv 930430 Fix output for low density stations
C nrv 940114 Calculate ITEARL if we don't have a schedule file
c nrv 940131 Read cable wrap from SOURCE line and write to output
C nrv 940201 Write wrap only for azel mounts
C nrv 940609 Fix output for SOURCE=AZEL for satellites
C nrv 940610 Fix it again to avoid the trailing "D" on az,el

        INCLUDE 'skparm.ftni'
	INCLUDE 'drcom.ftni'
	include 'statn.ftni'
C
C Input:
      logical kskd
C Output:
      INTEGER   IERR
	INTEGER   IC,TRIMLEN
      integer idir,nline,ntapes,ncount,npage,maxline,iline,
     .ifeet,inewp,iyear,ix,ns,nsline,ns2,irh,irm,ns3,ns4,idd,
     .idm,ihd,imd,isd,id1,ih1,im1,is1,mjd,ival,id2,ih2,im2,is2,ids,
     .i,iaz,iel,idur,nm,l,ifdur,id,ieq
      real*4 rs,ds
      real*4 speed ! function
      integer julda ! function
	LOGICAL*4   KEX
	logical     kazel,kwrap,ksat
	character*128 cbuf
Cinteger*4 ifbrk
	character*8 csor,cexper,cstn
	character*3 cdir,cnewtap,cday
	character*9 cti,c1,c2,c3
	character*2 cpass
	character*1 cid,csgn
        character*7 cwrap
	real*8 xpos,ypos,zpos,rarad,dcrad,ut,az,el


C 1.0  Check existence of SNAP file.

	IC = TRIMLEN(CINNAME)
	INQUIRE(FILE=CINNAME,EXIST=KEX)
	IF (.NOT.KEX) THEN
	  WRITE(LUSCN,9398) CINNAME(1:IC)
9398    FORMAT(' LSTSUM01 - SNAP FILE ',A,' DOES NOT EXIST')
	 RETURN
	ENDIF
	OPEN(LU_INFILE,FILE=CINNAME,STATUS='OLD',IOSTAT=IERR)
C
	IF(IERR.EQ.0) THEN
	  REWIND(LU_INFILE)
	  CALL INITF(LU_INFILE,IERR)
	ELSE
	  WRITE(LUSCN,9400) IERR,CINNAME(1:IC)
9400    FORMAT(' LSTSUM02 - ERROR ',I3,' OPENING SNAP FILE ',A)
	  RETURN
	ENDIF
C
C 3. Set up printer and write header lines

	write(luscn,9200) cinname(1:ic)
9200  format(' Printing summary of SNAP file ',a)

	call setprint(ierr,iwidth,0)
	if (ierr.ne.0) return
C
C 4. Loop over SNAP file records

        cexper=' '
        iyear = 0
        cstn = ' '
        cid = ' '
        kazel=.false.
        kwrap=.false.
        ksat=.false.
	idir = 0
	nline = 0
	ntapes = 0
	ncount = 0
	npage = 0
	if (iwidth.eq.80) then
	  maxline = 48
	else
	  maxline = 50
	endif
	iline = maxline
	cday = '   '
	ifeet = 0
        inewp = 0
	cnewtap = 'XXX'
	do while (.true.) ! read loop
C  if (ifbrk().lt.0) goto 990
	  read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf
	  nline = nline + 1

C 5.  Read first lines of SNAP file to get year, experiment name, station.
C     If we have a schedule file, station position is already in common,
C     otherwise read it from the header line. If the first line in the
C     SNAP file is a comment, then the header lines are probably there.
C     In all cases, rewind the file at the end so the following program 
C     loop reads all lines.

	  if (nline.eq.1.and.cbuf(1:1).eq.'"') then !read first lines
            read(cbuf,9001) cexper,iyear,cstn,cid !header line
9001        format(2x,a8,2x,i4,1x,a8,2x,a1)
	    if (.not.kskd) then !read station position from SNAP file header
		read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf !A line
                read(cbuf(2:),*) c1,c2,c3
                if (c3.eq.'AZEL'.or.c3.eq.'SEST'.or.c3.eq.'ALGO') then
                  kwrap=.true.
                else
                  kwrap=.false.
                endif
		read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf !P line
		if (trimlen(cbuf).lt.40) then ! not there
		  write(luscn,9002)
9002          format(' SNAP file does not contain station position ',
     .        'data on line 3, therefore '/,
     .        ' az, el will not be calculated for this listing.')
		  kazel = .false.
		else ! it's there
                  ix=index(cbuf(6:),' ')
		  read(cbuf(6+ix:),*) xpos,ypos,zpos
		  nline = 3
		  kazel = .true.
		endif
	    else !get from common (from schedule file)
		xpos = stnxyz(1,istn)
		ypos = stnxyz(2,istn)
		zpos = stnxyz(3,istn)
		kazel = .true.
                kwrap=.false.
                if (iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn)
     .          .eq.7) kwrap=.true.
	    endif !kskd/not
            rewind(lu_infile)
            nline = 1
            read(lu_infile,'(a)',err=990,end=990,iostat=IERR) cbuf
            call initf(lu_infile,ierr)
	  endif !read first lines

	  if (cbuf(1:1).ne.'"') then !non-comment line
	  if (index(cbuf,'SOURCE=').ne.0) then
	    ns = index(cbuf,',')-1
	    csor = cbuf(8:ns)
	    nsline = nline
	    ns2 = ns+2+index(cbuf(ns+2:),',')-2
            if (csor.ne.'AZEL') then ! celestial source
              ksat=.false.
	      read(cbuf(ns+2:ns2),9101) irh,irm,rs
9101          format(i2,i2,f4.1)
	      rarad = (irh+irm/60.d0+rs/3600.d0)*PI/12.d0
	      ns3 = ns2+2+index(cbuf(ns2+2:),',')-1
              read(cbuf(ns2+2:ns2+2),'(a1)') csgn
	      if (csgn.eq.'-'.or.csgn.eq.'+') ns2=ns2+1
	      read(cbuf(ns2+2:ns3),9102) idd,idm,ds
9102          format(i2,i2,f4.1)
	      dcrad = (idd+idm/60.d0+ds/3600.d0)*PI/180.d0
	      if (csgn.eq.'-') dcrad=-dcrad
              ns4 = ns3+index(cbuf(ns3+2:),',')
              if (ns4.gt.ns3) then
                  read(cbuf(ns4+2:),'(a)') cwrap
                else
                  cwrap=' '
                endif
            else ! satellite AZEL
	      ns2 = ns+2+index(cbuf(ns+2:),'D')-2
	      read(cbuf(ns+2:ns2),*) az
	      ns3 = ns2+2+index(cbuf(ns2+2:),'D')-2
	      read(cbuf(ns2+3:ns3),*) el
              ksat = .true.
            endif

	  else if (index(cbuf,'UNLOD').ne.0) then
	    cnewtap = 'XXX'
	    ifeet = 0

	  else if (index(cbuf,'MIDTP').ne.0) then
	    inewp = 1
	    if (idir.eq.1) inewp = 0
	    if (inewp.eq.1) ifeet = 0

	  else if (index(cbuf,'MIDOB').ne.0) then
	    read(cti,'(i3,3i2)') idd,ihd,imd,isd

	  else if (index(cbuf,'!').ne.0) then
	    if (cbuf(2:2).ge.'0'.and.cbuf(2:2).le.'9') then ! valid day
	    cti = cbuf(2:10)
	    if (cti(1:3).ne.cday) then
		cday = cti(1:3)
		if (npage.gt.0) then
		  write(luprt,9320) cday
9320          format('  Day ',a)
		  iline=iline+1
		endif
	    endif
	    endif ! valid day

	  else if (index(cbuf(1:2),'ST').ne.0) then
	    read(cti,'(i3,3i2)') id1,ih1,im1,is1
	    ut = ih1*3600.d0+im1*60.d0+is1  ! UT in seconds
	    mjd = julda(1,id1,iyear-1900)
	    read(cbuf(8:10),*) ival
	    speed = ival*9.0/8.0
	    ifeet = 10*ifix(float(ifeet/10))
	    idir = 1
	    cdir = cbuf(4:6)
	    if (cdir.eq.'REV') idir=-1

	  else if (index(cbuf(1:2),'ET').ne.0) then
	    read(cti,'(i3,3i2)') id2,ih2,im2,is2
	    idm = im2 + 60*(ih2 + 24*(id2-idd) - ihd)
	    ids = is2
	    if (is2.lt.isd) then
		ids = is2 + 60
		idm = idm - 1
	    endif
	    idm = idm - imd
	    ids = ids - isd

	    if (iline.ge.maxline) then ! new page, write header
		if (npage.gt.0) call luff(luprt)
		npage = npage + 1
		write(luprt,9300) cinname(1:ic),npage
9300        format(' Schedule file: ',a,35x,'Page ',i3)

		if (kskd) then
		  write(luprt,9302) (lstnna(i,istn),i=1,4),lstcod(istn),
     .        (lexper(i),i=1,4)
9302          format(' Station: ',4a2,' (',a1,')'/' Experiment: ',4a2)
		else
		  write(luprt,9303) cstn,cid,cexper
9303          format(' Station: ',a8,' (',a1,')'/' Experiment: ',a8)
		endif
C           Here is where we can determine early start without the schedule
            if (npage.eq.1.and..not.kskd) then ! calculate ITEARL here
              itearl = isd-is1
              if (itearl.lt.0) itearl=itearl+60
            endif
            write(luprt,9304) itearl
9304        format(' Early tape start: ',i3,' seconds'/)
C
            if (kwrap) write(luprt,9310)
            if (.not.kwrap) write(luprt,9390)
9310        format(22x,'         Start     Start     Stop',20x,
     .      ' Change/'/
     .      ' Line#  Source    Az El Cable   Tape      Data      ',
     .      'Tape     Dur Pass Dir Feet Check')
9390        format(22x,'     Start     Start     Stop',20x,
     .      ' Change/'/
     .      ' Line#  Source    Az El    Tape      Data      ',
     .      'Tape     Dur Pass Dir Feet Check')
		write(luprt,9311)
9311        format('-----------------------------------------',
     .      '-------------------------------------')
		write(luprt,9320) cday
		iline=0
	    endif
	    if (kazel.and..not.ksat) then
		call cazel(rarad,dcrad,xpos,ypos,zpos,mjd,ut,az,el)
		iaz = (az*180.d0/PI)+0.5
		iel = (el*180.d0/PI)+0.5
	    else if (ksat) then ! already got az,el
                iaz = az
                iel = el
            else
		iaz = 0
		iel = 0
	    endif
            if (kwrap) then
              write(luprt,9330) nsline,csor,iaz,iel,cwrap,ih1,im1,is1,
     .        ihd,imd,isd,ih2,im2,is2,idm,ids,cpass,cdir,ifeet,cnewtap
9330          format(1x,i5,1x,a8,2x,i3,1x,i2,1x,a5,1x,i2.2,':',i2.2,':',
     .        i2.2,2x,i2.2,':',i2.2,':',i2.2,2x,i2.2,':',i2.2,':',i2.2,
     .        2x,i2.2,':',i2.2,2x,a2,1x,a3,1x,i5,1x,a3)
            else
              write(luprt,9380) nsline,csor,iaz,iel,ih1,im1,is1,ihd,imd,
     .        isd,ih2,im2,is2,idm,ids,cpass,cdir,ifeet,cnewtap
9380          format(1x,i5,1x,a8,2x,i3,1x,i2,1x,1x,i2.2,':',i2.2,':',
     .        i2.2,2x,i2.2,':',i2.2,':',i2.2,2x,i2.2,':',i2.2,':',i2.2,
     .        2x,i2.2,':',i2.2,2x,a2,1x,a3,1x,i5,1x,a3)
            endif
	    iline=iline+1
	    ncount = ncount + 1
	    if (cnewtap.eq.'XXX') ntapes=ntapes+1
	    cnewtap = '   '
            cpass = '  '
	    idur = 60*idm + ids
C           Calculate footage at the end of the current scan
            ifeet = ifeet + idir*(idur+itearl)*(speed/12.0)

	  else if (index(cbuf,'FAST').ne.0) then !add spin feet
	    nm = index(cbuf,'M')
	    if (nm.gt.0) then
		read(cbuf(7:nm-1),*) ival
		idur = 60*ival
	    else
		nm=6
		idur=0
	    endif
	    l=trimlen(cbuf)
	    read(cbuf(nm+1:l-1),*) ival
	    idur = idur + ival 
	    ifdur = 160 + (idur-10)*(270.0/12.0)
	    id=+1
	    if (cbuf(5:5).eq.'R') id=-1
	    if (inewp.eq.0.or.ifeet.gt.0) ifeet=ifeet+ifdur*id

	  else if (index(cbuf,'CHECK').ne.0) then
	    if (cnewtap.eq.'   ') cnewtap = ' * '

C         else if (index(cbuf,'SX').ne.0) then
          else if (index(cbuf,'=').ne.0) then !probably setup proc
	    ieq = index(cbuf,'=')
	    cpass = cbuf(ieq+1:ieq+2)

	  endif
	  endif !non-comment line
	enddo !read loop

990   write(luprt,'(/" Total number of observations: ",i5/
     .               " Total number of tapes: ",i3)') ncount, ntapes

	call luff(luprt)
	if (cprttyp.eq.'FILE') close(LUprt)
        call prtmp

      RETURN
      end
