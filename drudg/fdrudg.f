      subroutine fdrudg(cfile,cstn,command,cr1,cr2,cr3,cr4)
C
C     DRUDG HANDLES ALL OF THE DRUDGE WORK FOR SKED
C
C  Common blocks:
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

C Subroutine interface:
C     Called by: drudg (C routine)

C Input:
      character*(*) cfile   ! file name 
      character*(*) cstn    ! station
      character*(*) command ! command 
      character*(*) cr1
      character*(*) cr2
      character*(*) cr3
      character*(*) cr4

C
C LOCAL:
      real*8 DAS2B,R,D
      integer*2 lstn,lc
      integer TRIMLEN,pcode
      character*128 cdum
      character*128 cdrudg,csked,cexpna
      logical kskd,kskdfile,kdrgfile
      integer nch
      character*2  response
      character    lower, scode
      integer ivexnum,h2c,heqb,o36
      character*256 cbuf
      integer i,j,k,l,ncs,ix,ixp,ic,ierr,iret,
     .ilen,ich,ic1,ic2,idummy,inext,isatl,ifunc,nstnx
      real*4 val
      integer ichmv_ch,ichmv,ichcm,jchar,igtst,ichcm_ch ! functions
      integer nch1,nch2,nch3,iserr(max_stn)
      data h2c/2h::/, heqb/2h= /, o36/o'36'/
C
C  DATE   WHO CHANGES
C  830427 NRV ADDED TYPE-6 CARTRIDGE TO IRP CALLS
C  830818 NRV ADDED SATELLITES
C  840813 MWH Added printer LU lock
C  880411 NRV DE-COMPC'D
C  880422 NRV Changed DCNTL to call to RCNTL
C             Changed PRPOS to call to PRCES
C             Removed ICRTY6 variable - not needed any more
C  880708 NRV Added printer width option
C  881201 NRV Added laser jet bar code option for tape labels
C  890116 NRV Added deskjet LU
C  890123 NRV Changed PRCES to PREFR  for epoch precession
C  890130 NRV Changed PRCES to APSTAR for precession to date
C  890525 MWH Changed to use CI files
C  890613 NRV READ PARITY,SOURCE,SETUP,TAPE TIMES FROM PARAMETER
C             SECTION OF SCHEDULE FILE
C  891227 PMR ported to Unix environment
C  900207 NRV Added option 16 to print .LST file
C  900315 GAG Added control file subroutine call
C  900328 NRV Cleaned up!
C  900413 NRV Changed dummies in RDCTL call to pick up
C             printer commands
C             Added break set-up
C  900423 NRV If input schedule file begins with '/' then
C             don't pre-pend control file string
C  901018 NRV Add printer variables to RDCTL call
C  901121 NRV Add no-schedule option
C  901205 NRV Changed options to simplify
C  901211 NRV Changed RDCTl call to add iwidth
C  910513 GAG Changed nchanv to be an array. i.e. added parameter
C  910702 nrv removed iwidth from cal to rdctl
C  910703 NRV Change initializations, add KLAB to common
C  930407 nrv implicit none
C  930412 nrv changed to a subroutine, passed the schedule file
C             name from the command line
C  930702 nrv Check error when re-prompting to avoid looping
C  930708 nrv Initialize head position arrays
C  930714 nrv Add call to vprocs to make VLBA procedures
C  930803 nrv Check for "all stations" before trying to print a name
C             with the main menu
C  940620 nrv non-interactive (batch) mode
C  950626 nrv Case-sensitive station IDs
C  951003 nrv Try to open ".drg" file after trying ".skd" file
C  951213 nrv One call to PROCS with Mk3/VLBA as input flag
C 960208 nrv If inconsistent tracks/heads from GNPAS, set flag
C 960209 nrv GNPAS errors by station
C 960226 nrv Add cprtlab to RDCTL call
C 960307 nrv Move block data initializations to here.
C 960403 nrv Add another dum to RDCTL call for rec_cat
C 960513 nrv New release date.
C 960531 nrv Add vex.
C 960604 nrv Initialize NOBS before calling vob1inp.
C 960610 nrv Remove freqs.ftni initialization to SREAD and VREAD
C 960810 nrv Change ITEARL to an array by station
C 960817 nrv Add S2 option for procedures
C 960912 nrv Remove the procedure options from the menu if the
C            rack and recorder types are known from the VEX file.
C 961007 nrv Re-initialize kskdfile and kdrgfile to false if we didn't
C            find either one on the first two tries.
C 961022 nrv Add Mark IV as a procedures option
C 961031 nrv Change SNAP option to either Mk3/4 or VLBA rack.
C 961104 nrv change ISKLEN to be the same size as IBUF (why were they 
c            different variables?)
C 970114 nrv Change 8 to max_sorlen
C 970121 nrv Add iret to vob1inp call
C 970121 nrv Null terminate TMPNAME here. Add IIN to LABEL call. Add
C            option 61 for ps labels.
C 970123 nrv Revise option 61 description. Change date to 970123.
C
C Initialize some things.

C Permissions on output files
      iperm=o'0666'
C Initialize LU's
      LU_INFILE = 20
      LU_OUTFILE =21
      LUPRT =     22
C The length of a schedule file record
      ISKLEN=ibuf_len
C Initialize the number of labels and lines/label
      NLAB=1
      NLLAB=9
C Initialize printer width
      IWIDTH=137
C Initialize the $PROC section location
      IRECPR=0
      IRBPR=0
      IOFFPR=0
C Codes for passes and bandwidths
      idummy=ichmv_ch(lbname,1,'D8421HQE')
c Initialize no. entries in lband (freqs.ftni)
      NBAND= 2

      luscn = STDOUT
      luusr = STDIN
      csked = './'
      cdrudg = './'
      ctmpnam = './'
      cprport = 'PRINT'
      cprttyp = 'LASER'
      cprtpor = ' '
      cprtlan = ' '
      cprtlab = ' '
      iwidth = 137
      klab = .false.
      ifunc = -1
      ierr=0
      kskdfile = .false.
      kdrgfile = .false.
C
C
C     0. Set up for break routines.
C
C     ierrset = SETUP_BRK()   ! sets up break interrupt
C     if (ierrset.lt.0) then
C       write(luscn,"(' Error from SETUP_BRK = ', i2)") ierrset
C       stop
C     endif
C
C
C     1. Make up temporary file name, read control file.
C***********************************************************
      call rdctl(cdum,cdum,cdum,cdum,cdum,cdum,cdum,cdum,
     .           cdum,cdum,cdum,cdum,cdum,cdum,csked,cdrudg,ctmpnam,
     .           cprtlan,cprtpor,cprttyp,cprport,cprtlab,luscn)
      nch = trimlen(ctmpnam)
      if (ctmpnam.eq.'./') nch=0
      if (nch.gt.0) then
        tmpname = ctmpnam(:nch)//'DR.tmp'
      else
        tmpname = 'DG.tmp'
      endif
      call null_term(tmpname)
      ncs=trimlen(csked)
      if (csked.eq.'./') ncs=0
C
C     2. Next read in the schedule file name.
C
200   continue
C     write(luscn,'("Initializing ...")')
C  Initialize variables.   Moved here from SREAD
C  In drcom.ftni
      kmissing = .false.
      idummy= ichmv_ch(lbarrel,1,'NONE')
C  In skobs.ftni
      NOBS = 0
      ISETTM=0
      IPARTM=0
      ITAPTM=0
      ISORTM=0
      IHDTM=0
C  In sourc.ftni
      NCELES = 0
      NSATEL = 0
      NSOURC = 0
C  In statn.ftni
      NSTATN = 0
      do i=1,max_stn
        ITEARL(i)=0
        itlate(i)=0
        itgap(i)=0
        tape_motion_type(i)=''
      enddo
C  In freqs.ftni
      NCODES = 0

C   Check for non-interactive mode.
201     nch1=trimlen(cfile)
        nch2=trimlen(cstn)
        nch3=trimlen(command)
        cexpna = ' '
        if (nch1.ne.0.and.nch2.ne.0.and.nch3.ne.0) kbatch=.true.

      DO WHILE (cexpna(1:1).EQ.' ') !get schedule file name
        if (.not.kskdfile.or.kdrgfile) then ! first or 3rd time
         if (kskdfile.and.kdrgfile) then ! reinitialize on 3rd time
           kskdfile=.false.
           kdrgfile=.false.
         endif
C       Opening message
        WRITE(LUSCN,9020)
9020    FORMAT(/' DRUDG: Experiment Preparation Drudge Work ',
     .  '(NRV 970123)')
        nch = trimlen(cfile)
        if (nch.eq.0.or.ifunc.eq.8.or.ierr.ne.0) then ! prompt for file name
          if (kbatch) goto 990
          write(luscn,9920)
9920      format(' Schedule file name (.skd or .drg assumed, ',
     .    '<return> if none, :: to quit) ? ',$)
          CALL GTRSP(IBUF,ISKLEN,LUUSR,NCH)
        else ! command line file name
          call char2hol(cfile,ibuf,1,nch)
        endif 
        endif
        IF (NCH.GT.0) THEN !got a name
          IF (ichcm(IBUF(1),1,H2C,1,2).eq.0) GOTO 990
          call hol2char(ibuf,1,256,cbuf)
	  if ((cbuf(2:2).eq.':').OR.(CBUF(1:1).EQ.'/')) then
            lskdfi = cbuf(1:nch)
          else
            if (ncs.gt.0) then
              LSKDFI = csked(:ncs) // CBUF(1:NCH)
            else
              LSKDFI = CBUF(1:NCH)
            endif
          endif
          ix=index(lskdfi,'.')
          l=trimlen(lskdfi)
          if (ix.eq.0) then ! automatic extension
            if (.not.kskdfile) then ! try .skd
              lskdfi=lskdfi(1:l)//'.skd'
              kskdfile = .true.
            else ! try .drg
              lskdfi=lskdfi(1:l)//'.drg'
              kdrgfile = .true.
            endif
          endif
          ixp=1
          ix=1
          do while (ix.ne.0)
            ix=index(lskdfi(ixp:),'/')
            if (ix.gt.0) ixp=ixp+ix
          enddo
	  cexpna=lskdfi(ixp:)
	  kskd = .true.
	else ! none
	  write(luscn,9021)
9021      format(' Enter schedule name (e.g. PPMN3): ',$)
	  read(luusr,'(A)') cbuf
	  l = trimlen(cbuf)
	  if (l.gt.0) cexpna = cbuf(1:l)
	  kskd = .false.
        ENDIF !got a name
      END DO !get schedule file name
C  ********************************************************
C
C     3. Read the schedule file sections.
C
	if (.not.kskd) goto 500
	  ix=trimlen(cexpna)
	  IC=TRIMLEN(LSKDFI)
	  WRITE(LUSCN,9300) LSKDFI(1:IC),cexpna(1:ix)
9300    FORMAT(' Opening file ',A,' for schedule ',A)
	  CALL SREAD(IERR,ivexnum)
	  if (itearl(1).gt.0) then
	    write(luscn,9301) itearl(1)
9301      format(' NOTE: This schedule was created using early '
     .    ,'start with EARLY = ',i3,' seconds.')
	  endif
	  IF (IERR.NE.0) goto 201
          kskdfile = .false.
          kdrgfile = .false.
C
C     Now go back and pick up station elevations.
C
	  IF (IRECEL.EQ.-1.0) THEN   !no el limits
	    DO I=1,NSTATN
		STNELV(I)=0.0
	    ENDDO
	  ELSE                       !get el limits
	    IRECEL = IRECEL-1
	    call aposn(LU_INFILE,IERR,irecel)
	    CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	    DO WHILE (JCHAR(IBUF,1).NE.o36.AND.ILEN.NE.-1.AND.
     .      ichcm_ch(IBUF,1,'ELEVATION ').EQ.0) !process ELEVATION lines
		ICH = 11
		CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
		DO WHILE (IC1.GT.0) !scan this line
		  IDUMMY = ICHMV(L,1,IBUF,IC1,1)
		  IDUMMY = IGTST(L,ISTN)
		  CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
		  VAL = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
		  if (istn.gt.0) STNELV(ISTN) = VAL*PI/180.0
		  CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
		ENDDO
		CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
	    ENDDO
	  ENDIF
C
C     Derive number of passes for each code
	  CALL GNPAS(luscn,ierr,iserr)
          call setba_dr
          if (ierr.ne.0) then ! can't continue
            write(luscn,9999) 
9999        format(/'DRUDG00: WARNING! Inconsistent or missing ',
     .      'pass/track/head information.'/
     .      ' SNAP or procedure output may be incorrect',
     .      ' or may cause a program abort for:'/)
            do i=1,nstatn
              if (iserr(i).ne.0) write(luscn,9998) (lstnna(j,i),j=1,4)
9998          format(1x,4a2,1x,$)
            enddo
            write(luscn,'()')
          endif
C
            WRITE(LUSCN,9490) NSOURC
	    IF (NSATEL.GT.0) WRITE(LUSCN,9496) NCELES,NSATEL
	    WRITE(LUSCN,9492) NSTATN,NOBS,NCODES
9490    FORMAT(' Number of sources: ',I5)
9496    FORMAT('(',1x,I5,' celestial, ',I5,' satellites)')
9492    FORMAT(' Number of stations: ',I5/
     .  ' Number of observations: ',I5/
     .  ' Number of frequency codes: ',I5)
C
C  Now change J2000 coordinates to 1950 and save for later use
	  DO I=1,NCELES
	    CALL PREFR(SORP50(1,I),SORP50(2,I),2000,R,D)
	    RA50(I) = R
	    DEC50(I) = D
	  END DO
	  DO I=1,NSATEL !MOVE NAMES
	    INEXT=NCELES+I
	    ISATL=MAX_CEL+I
	    IDUMMY = ICHMV(LSORNA(1,INEXT),1,LSORNA(1,ISATL),1,max_sorlen)
	  END DO
C
C  Check for sufficient information
	  IF (NSTATN.GT.0.AND.NSOURC.GT.0.AND.ncodes.GT.0) GOTO 500
	  WRITE(LUSCN,9491)
9491    FORMAT(' Insufficient information in file.'/)
          ierr=-1
	  GOTO 200
C
C
C     5. Ask for the station(s) to be processed.  These will be done
C        in the outer loop.
C
500   CONTINUE
      call clear_array(response)
      if (.not.kbatch) then
        if (kskd) then
          WRITE(LUSCN,9053) (lstcod(K),(lstnna(I,K),I=1,4),K=1,NSTATN)
9053      FORMAT(' Stations: ', 5(A2,'(',4A2,')',1X)/
     .     10(   '           ',5 (A2,'(',4A2,')',1X)/))
          WRITE(LUSCN,9050)
9050      FORMAT(/' NOTE: Station codes are CaSe SeNsItIvE !'/
     .    ' Output for which station (type a code, :: to ',
     .    'quit, = for all) ? ',$)
        else
          write(luscn,9051)
9051      format(' Enter station ID (e.g. M, :: to quit)? ',$)
        endif
        read(luusr,'(A)') response(1:2)
      else
        response = cstn
      endif
      if (response(1:2).eq.'::') goto 990
C     response(1:1) = upper(response(1:1))
      call char2hol(response(1:1),lstn,1,2)
      ISTN = 0
      iF (ichcm(LSTN,1,HEQB,1,1).eq.0) GOTO 699 ! all stations
      if (kskd) then !check for valid ID
        DO I=1,NSTATN
          IF (LSTCOD(I).EQ.LSTN) ISTN = I
        END DO
        IF (ISTN.EQ.0) then
          if (.not.kbatch) then !try again interactively
            GOTO 500
          else ! no recovery in batch
            write(luscn,9059) cstn
9059        format(' No such station in schedule: ',a)
            goto 990
          endif
        endif
      else !make up valid index
	istn=1
	nstatn=1
	lstcod(1)=lstn
      endif !check for validID
      kmissing=.true.
      if (iserr(istn).ne.0) kmissing=.true.
699   continue
      if (kvex) then !get the station's observations now
        nobs=0
        if (istn.eq.0) then ! get all in a loop
          do i=1,nstatn
            call vob1inp(ivexnum,i,luscn,ierr,iret) ! get the station's obs
            if (ierr.ne.0) then
              write(luscn,'("FDRUDGxx - Error from vob1inp=",
     .        i5,", iret=",i5)') ierr,iret
            else
              write(luscn,'("  Number of obs: ",i5)') nobs
            endif
          enddo
        else ! get one station's obs
          call vob1inp(ivexnum,istn,luscn,ierr,iret)
          if (ierr.ne.0) then
            write(luscn,'("FDRUDGxx - Error from vob1inp=",
     .      i5,", iret=",i5)') ierr,iret
          else
            write(luscn,'("  Number of obs: ",i5)') nobs
          endif
        endif ! get one/get all
      endif
C
C
C     7. Find out what we are to do.  Set up the outer and inner loops
C        on stations and schedules, respectively.  Within the loop,
C        schedule the appropriate segment.
C
700   if (.not.kbatch) then
	if (kskd) then !schedule file
	  l=trimlen(lskdfi)
          if (istn.gt.0) then !one station
            WRITE(LUSCN,9068) lskdfi(1:l),(lstnna(i,istn),i=1,4)
          else !all stations
            write(luscn,9067) lskdfi(1:l)
          endif
9068      FORMAT(/' Select *new* DRUDG option for schedule ',A,
     .    ' at ',4A2/)
9067      FORMAT(/' Select *new* DRUDG option for schedule ',A,
     .    ' (all stations)'/)
C         if (ichcm_ch(lstrack(1,istn),1,'unknown ').eq.0.or.
C    .        ichcm_ch(lstrec (1,istn),1,'unknown ').eq.0.or.
C    .        ichcm_ch(lstrack(1,istn),1,'        ').eq.0.or.
C    .        ichcm_ch(lstrec (1,istn),1,'        ').eq.0) then ! unknown
          if (.not.kvex) then ! unknown equipment
            write(luscn,9070)
9070        FORMAT(
     .      ' 1 = Print the schedule                ',
     .      '  7 = Re-specify stations'/
     .      ' 2 = Make antenna pointing file (VLBA) ',
     .      '  8 = Get a new schedule file'/
     .      ' 3 = Make Mark III/IV SNAP file (.SNP) ',
     .      '  9 = Change output destination, width '/
     .      ' 31= Make VLBA SNAP file (.SNP)        ',
     .      ' 10 = Shift the .SKD file  '/,
     .      ' 4 = Print complete .SNP file          ',
     .      ' 11 = Shift the .SNP file  '/,
     .      ' 5 = Print summary of .SNP file        ',
     .      ' 12 = Make Mark III procedures (.PRC) '/,
     .      ' 6 = Make Epson or laser (3x10) labels ',
     .      ' 13 = Make VLBA procedures (.PRC)'/,
     .      ' 61= Make PostScript (2x6) tape labels ',
     .      ' 14 = Make hybrid procedures (.PRC)'/,
     .      ' 0 = Done with DRUDG                   ',
     .      ' 15 = Make Mark IV procedures (.PRC)'/,
     .      '                                       ',
     .      ' 16 = Make 8-BBC procedures (.PRC)'/,
     .      ' ? ',$)
          else ! gotem in the vex file
            write(luscn,9073)
9073        FORMAT('Supporting VEX 1.5'/
     .      ' 1 = Print the schedule                ',
     .      '  7 = Re-specify stations'/
     .      ' 2 = Make antenna pointing file (VLBA) ',
     .      '  8 = Get a new schedule file'/
     .      ' 3 = Create SNAP command file (.SNP)   ',
     .      '  9 = Change output destination, width '/
     .      ' 4 = Print complete .SNP file          ',
     .      ' 10 = Shift the .SKD file  '/,
     .      ' 5 = Print summary of .SNP file        ',
     .      ' 11 = Shift the .SNP file  '/,
     .      ' 6 = Make Epson or laser (3x10) labels ',
     .      ' 12 = Make procedures (.PRC) '/,
     .      ' 61= Make PostScript (2x6) tape labels ',
     .      ' '/,
     .      ' 0 = Done with DRUDG                   ',
     .      ' '/,
     .      ' ? ',$)
          endif
        else ! SNAP file
	  l=trimlen(cexpna)
	  WRITE(LUSCN,9071) cexpna(1:l),lstcod(1)
9071      FORMAT(/' Select DRUDG option for experiment ',A,' at ',A2/
     .    ' 4 = Print complete .SNP file          ',
     .    '  7 = Re-specify stations'/
     .    ' 5 = Print summary of .SNP file        ',
     .    '  8 = Get a new schedule file'/
     .    ' 6 = Make Epson or laser (3x10) labels ',
     .    '  9 = Change output destination, width'/,
     .    ' 61= Make PostScript (2x6) tape labels ',
     .    ' 11 = Shift the .SNP file'/,
     .    ' 0 = Done with DRUDG                   ',
     .   /' ? ',$)
        endif
	IFUNC = -1
	READ(LUUSR,*,ERR=700) IFUNC
      else
        read(command,*,err=991) ifunc
      endif

	if ((ifunc.lt.0).or.(ifunc.gt.16.and.ifunc.ne.31.and.ifunc.ne.61)
     .  .and..not.kbatch) GOTO 700
	if ((ifunc.lt.0).or.(ifunc.gt.16.and.ifunc.ne.31.and.ifunc.ne.61)
     .  .and.kbatch) GOTO 991
	if (.not.kbatch.and..not.kskd.and.((ifunc.gt.0.and.ifunc.lt.4)
     .  .or.ifunc.eq.10.or.(ifunc.ge.16.and.ifunc.ne.31.and.
     .   ifunc.ne.61))) goto 700

	IF (IFUNC.EQ.9) THEN
          if (kbatch) goto 991
	  call port
	  goto 700
	ELSE IF (IFUNC.EQ.7) THEN
          if (kbatch) goto 991
	  GOTO 500
	ELSE IF (IFUNC.EQ.8) THEN
          if (kbatch) goto 991
	  GOTO 200
	ELSE IF (IFUNC.EQ.0) THEN
	  GOTO 990
	ELSE IF (IFUNC.EQ.10) THEN
	  CINNAME = LSKDFI
          if (kbatch) then
            write(luscn,9994)
9994        format(' Batch mode not available for shifting.')
            goto 991
          endif
	  call skdshft(ierr)
	  GOTO 700
	ENDIF
C
      NSTNX = 1
	IF (ichcm(LSTN,1,HEQB,1,1).eq.0) NSTNX = NSTATN
C
      I = 1
      do while (I.le.nstnx)  !loop over stations
        IF (ichcm(LSTN,1,HEQB,1,1).eq.0) ISTN = I
        kmissing=.false.
        if (iserr(istn).ne.0) kmissing=.true.
        IX = INDEX(cexpna,'.')-1
	  if (ix.lt.0) ix=trimlen(cexpna)
        call char2hol('  ',lc,1,2)
        idummy = ichmv(lc,2,lstcod(istn),1,1)
        call hol2char(lc,2,2,scode)
	  scode  = lower(scode)
	  nch = trimlen(cdrudg)
          if (cdrudg(1:2).eq.'./') nch=0
	  if (cexpna(2:2).eq.':'.or.cexpna(1:1).eq.'/') nch=0
          if (nch.gt.0) then ! prepend
	    SNPNAME=cdrudg(:nch)//cexpna(1:ix)//scode//'.snp'
            if (scode.eq.' ') SNPNAME=cdrudg(:nch)//cexpna(1:ix)//'.snp'
	    PRCNAME = cdrudg(:nch)//cexpna(1:ix)//scode//'.prc'
            LSTNAME = cdrudg(:nch)//cexpna(1:ix)//scode//'.lst'
            PNTNAME = cdrudg(:nch)//cexpna(1:ix)//scode//'.pnt'
          else ! no prepend
	    SNPNAME=cexpna(1:ix)//scode//'.snp'
            if (scode.eq.' ') SNPNAME=cexpna(1:ix)//'.snp'
	    PRCNAME = cexpna(1:ix)//scode//'.prc'
            LSTNAME = cexpna(1:ix)//scode//'.lst'
            PNTNAME = cexpna(1:ix)//scode//'.pnt'
          endif
        ierr=0
C No longer need this because the schedule is stored in memory.
C  IF (kskd) THEN
C         open(unit=LU_INFILE,file=LSKDFI,iostat=IERR)
C         rewind(LU_INFILE)
C         call initf(LU_INFILE,IERR)
C    IF (IFUNC.NE.12.and.ifunc.ne.13) 
C    .        call aposn(LU_INFILE,IERR,irecsk)
C    IF ((IFUNC.EQ.12.or.ifunc.eq.13).AND.IRECPR.NE.0)
C    .        call aposn(LU_INFILE,IERR,irecpr)
C       END IF
        IF (IERR.EQ.0)  THEN
          IF (IFUNC.EQ.1) THEN
            CALL LISTS
          ELSE IF (IFUNC.EQ.2) THEN
            CALL POINT(cr1,cr2,cr3,cr4)
c            I = nstnx
	    ELSE IF (IFUNC.EQ.3) THEN
	      CALL SNAP(cr1,cr2,cr3,cr4,1)
	    ELSE IF (IFUNC.EQ.31) THEN
	      CALL SNAP(cr1,cr2,cr3,cr4,2)
	    ELSE IF (IFUNC.EQ.4) THEN
	      CALL CLIST(kskd)
	    ELSE IF (IFUNC.EQ.12) THEN
              CALL PROCS(1) ! Mark III backend procedures
            ELSE IF (IFUNC.EQ.13) THEN
              CALL PROCS(2) ! VLBA backend procedures
	    ELSE IF (IFUNC.EQ.14) THEN
              CALL PROCS(3) ! hybrid backend procedures
	    ELSE IF (IFUNC.EQ.15) THEN
              CALL PROCS(4) ! Mark IV backend procedures
	    ELSE IF (IFUNC.EQ.16) THEN
              CALL PROCS(5) ! 8-BBC VLBA backend procedures
	    ELSE IF (IFUNC.EQ.6) THEN
	      if (nstnx.eq.1) then ! just one station
		pcode = 1
	      else if (i.eq.1) then ! first station
		pcode = 2
	      else if (i.eq.nstnx) then ! last station
		pcode = 3
	      else
		pcode = 0
	      end if
	      cinname = snpname
              klab = .true.
              call label(pcode,kskd,cr1,cr2,cr3,cr4,1)
              klab = .false.
	    ELSE IF (IFUNC.EQ.61) THEN
	      if (nstnx.eq.1) then ! just one station
		pcode = 1
	      else if (i.eq.1) then ! first station
		pcode = 2
	      else if (i.eq.nstnx) then ! last station
		pcode = 3
	      else
		pcode = 0
	      end if
	      cinname = snpname
              klab = .true.
              call label(pcode,kskd,cr1,cr2,cr3,cr4,2)
              klab = .false.
	    ELSE IF (IFUNC.EQ.11) THEN
              cinname = snpname
              if (kbatch) then
                write(luscn,9994)
                goto 991
              endif
              call snpshft(ierr)
	    ELSE IF (IFUNC.EQ.5) THEN
              cinname = snpname
              call lstsum(kskd,ierr)
          END IF
          close(LU_INFILE,iostat=IERR)
          close(LU_OUTFILE,iostat=IERR)
        ELSE
	    WRITE(LUSCN,9072) IERR,lskdfi
9072      FORMAT(' Error ',I3,' opening schedule file ',A32)
        END IF
        I = I + 1
      END DO
      if (.not.kbatch) GOTO 700
      goto 990
C
C
C     8. This is the end, folks.
C
991   write(luscn,9911)
9911  format(' Invalid function requested.')
990   close(LU_INFILE,iostat=IERR)
      WRITE(LUSCN,9090)
9090  FORMAT(' DRUDG DONE')
      END
