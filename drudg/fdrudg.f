      subroutine fdrudg(cfile,cstnin,command,cr1,cr2,cr3,cr4)
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
      character*(*) cstnin    ! station
      character*(*) command ! command 
      character*(*) cr1
      character*(*) cr2
      character*(*) cr3
      character*(*) cr4

C
C LOCAL:
      double precision DAS2B,R,D
      integer*2 lstn,lc,l2
      integer TRIMLEN,pcode
      character*128 cdum
      character*128 csnap,cproc,csked,cexpna
      logical kex,kskd,kskdfile,kdrgfile
      integer nch,nci
      character*2  response,scode
      character    upper,lower
      integer cclose,inew,ivexnum,h2c,heqb,o36
      character*256 cbuf
      integer i,j,k,l,ncs,ix2,ix,ixp,ic,ierr,iret,nobs_stn,
     .ilen,ich,ic1,ic2,idummy,inext,isatl,ifunc,nstnx
      real val
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
C 970123 nrv Change description of option 61. Change date to 970123.
C 970124 nrv Change date to 970124.
C 970129 nrv Change VOB1INP call to return number of scans for the station.
C 970129 nrv Change date to 970129, to distinguish from FS 9.3.7.
C 970204 nrv Change date to 970204.
C 970205 nrv Print tape_motion_type as information at start.
C 970207 nrv Remove all but cr1 from call to SNAP.
c 970207 nrv Add CEPOCH to RDCTL call.
C 970207 nrv Initialize default printer width to -1.
C 970213 nrv List 2-letter codes for selection, read 2-letter codes from
C            user input, make file names with 2-letter codes.
C 970218 nrv Change sample prompt for SNAP file from PPMN3 to ca036.
C 970221 nrv Remove "(VLBA)" from description of option 2.
C 970228 nrv Add clabtyp and rlabsize to RDCTL call.
C 970228 nrv Change prompts to replace opt 61 with "print labels"
C            Add labname. Add inew.
C 970301 nrv Initialize CSIZE.
C 970303 nrv Different prompts depending on label printer type.
C 970303 nrv Prompt at end of label temp file exists.
C 970304 nrv Add "cproc" to RDCTL call, change "cdrudg" to "csnap"
C 970304 nrv Add "coption" to RDCTL call.
C 970310 nrv Check for prepend and station id when forming file names.
C 970311 nrv Allow "./" to preceed schedule names.
C 970317 nrv Remove reading ELEVATION lines, done in SREAD now.
C 970328 nrv Add station_cat to RDCTL
C 970603 nrv Add option for printing cover leter in .drg files.
C 970610 nrv Always print out postscript file in non-interactive mode.
C 971003 nrv New date.
C 971003 nrv Stop if schedule file name has more than 6 letters.
C 971003 nrv "All stations" not allowed with VEX file.
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
C Initialize ps label file to new.
      inew=1
C Initialize newpage for labels.
      inewpage=0
C Initialize printer width to default for each type
      IWIDTH=-1
C Initialize font size to default for each type
      CSIZE='D' ! default
C Initialize the $PROC section location
      IRECPR=0
      IRBPR=0
      IOFFPR=0
C Initialize default epoch for source positions
      cepoch = '1950'
C Codes for passes and bandwidths
      idummy=ichmv_ch(lbname,1,'D8421HQE')
c Initialize no. entries in lband (freqs.ftni)
      NBAND= 2

      luscn = STDOUT
      luusr = STDIN
      csked = './'
      csnap = './'
      cproc = './'
      ctmpnam = './'
      cprport = 'PRINT'
      cprttyp = 'LASER'
      clabtyp = ' '
      cprtpor = ' '
      cprtlan = ' '
      cprtlab = ' '
      coption(1)='LS'
      coption(2)='PS'
      coption(3)='PS'
      klab = .false.
      ifunc = -1
      ierr=0
C
C     1. Make up temporary file name, read control file.
C***********************************************************
      call rdctl(cdum,cdum,cdum,cdum,cdum,cdum,cdum,cdum,cdum,
     .           cdum,cdum,cdum,cdum,cdum,cdum,csked,csnap,cproc,
     .           ctmpnam,
     .           cprtlan,cprtpor,cprttyp,cprport,cprtlab,clabtyp,
     .           rlabsize,cepoch,coption,luscn)
C
C     2. Initialize local variables
C
200   continue
      nch = trimlen(ctmpnam)
      if (ctmpnam.eq.'./') nch=0
      if (nch.gt.0) then
        tmpname = ctmpnam(:nch)//'DR.tmp'
        labname = ctmpnam(:nch)//'DRlab.tmp'
      else
        tmpname = 'DR.tmp'
        labname = 'DRlab.tmp'
      endif
      call null_term(tmpname)
      call null_term(labname)
      ncs=trimlen(csked)
      if (csked.eq.'./') ncs=0
      kskdfile = .false.
      kdrgfile = .false.
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
        nch2=trimlen(cstnin)
        nch3=trimlen(command)
        cexpna = ' '
        if (nch1.ne.0.and.nch2.ne.0.and.nch3.ne.0) kbatch=.true.

C 3. Get the schedule file name

      DO WHILE (cexpna(1:1).EQ.' ') !get schedule file name
        if (.not.kskdfile.or.kdrgfile) then ! first or 3rd time
         if (kskdfile.and.kdrgfile) then ! reinitialize on 3rd time
           kskdfile=.false.
           kdrgfile=.false.
         endif
C       Opening message
        WRITE(LUSCN,9020)
9020    FORMAT(/' DRUDG: Experiment Preparation Drudge Work ',
     .  '(NRV 971003)')
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
          IF (ichcm_ch(IBUF(1),1,'::').eq.0) GOTO 990
          call hol2char(ibuf,1,256,cbuf)
          if (ichcm_ch(ibuf(1),1,'.').eq.0.OR.
     .      ichcm_ch(ibuf(1),1,'/').eq.0) then ! path 
            lskdfi = cbuf(1:nch) 
          else  ! no path given
            if (ncs.gt.0) then ! prepend
              LSKDFI = csked(:ncs) // CBUF(1:NCH)
            else
              lskdfi = cbuf(1:nch) 
            endif
          endif ! path/no path
          if (lskdfi(1:2).eq.'..') then
            ix=index(lskdfi(3:),'.')
          else if (lskdfi(1:1).eq.'.') then
            ix=index(lskdfi(2:),'.')
          else
            ix=index(lskdfi(1:),'.')
          endif
          l=trimlen(lskdfi)
          if (ix.eq.0) then ! automatic extension
            if (.not.kskdfile) then ! try .skd
              lskdfi=lskdfi(1:l)//'.skd'
              kskdfile = .true.
              kdrg_infile=.false.
            else ! try .drg
              lskdfi=lskdfi(1:l)//'.drg'
              kdrgfile = .true.
              kdrg_infile=.true.
            endif
          else
            if (lskdfi(ix:l).eq.'.skd') kdrg_infile=.false.
            if (lskdfi(ix:l).eq.'.drg') kdrg_infile=.true.
          endif ! automatic extension
          ixp=1
          ix=1
          do while (ix.ne.0) ! find the last '/'
            ix=index(lskdfi(ixp:),'/')
            if (ix.gt.0) ixp=ixp+ix
          enddo
        cexpna=lskdfi(ixp:) ! exp name is root of file name
        ix=index(cexpna,'.')-1
        if (ix.gt.6) then ! too many letters
          write(luscn,9022)
9022      format(' ERROR: Schedule file name is too long. Please ',
     .    'rename ',
     .    'the file to have 6 characters or less before the file ',
     .    'extension.')
          goto 990
        endif
        kskd = .true.
      else ! none
        write(luscn,9021)
9021      format(' Enter schedule name (e.g. ca036): ',$)
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
      kvex = .false. 
      if (.not.kskd) goto 500
        ix=trimlen(cexpna)
        IC=TRIMLEN(LSKDFI)
        WRITE(LUSCN,9300) LSKDFI(1:IC),cexpna(1:ix)
9300      FORMAT(' Opening file ',A,' for schedule ',A)
        CALL SREAD(IERR,ivexnum)
        IF (IERR.NE.0) goto 201

        if (itearl(1).gt.0) then
          write(luscn,9301) itearl(1)
9301        format(' NOTE: This schedule was created using early '
     .      ,'start with EARLY = ',i3,' seconds.')
        endif
          if (tape_motion_type(1)(1:5).ne.'START'.and.
     .        tape_motion_type(1).ne.'') then
            nch=trimlen(tape_motion_type(1))
            if (nch.gt.0) then
            call c2upper(tape_motion_type(1)(1:nch),cdum)
            write(luscn,9302) (cdum(1:nch))
9302        format(' NOTE: This schedule uses ',a,' tape motion.')
            if (tape_motion_type(1)(1:5).eq.'ADAPT') 
     .      write(luscn,9303) itgap(1)
9303        format('       Gap time = ',i3,' seconds.')
            endif
          endif
C     Reset for the next time through.
          kskdfile = .false.
          kdrgfile = .false.
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
          WRITE(LUSCN,9492) NSTATN,NCODES
9490    FORMAT(' Number of sources: ',I5)
9496    FORMAT('(',1x,I5,' celestial, ',I5,' satellites)')
9492    FORMAT(' Number of stations: ',I5/
     .  ' Number of frequency codes: ',I5)
        if (.not.kvex) write(luscn,9493) nobs
9493    format(' Total number of scans in this schedule: ',I5)
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
          WRITE(LUSCN,9053) (lpocod(K),(lstnna(I,K),I=1,4),K=1,NSTATN)
C         WRITE(LUSCN,9053) (lstcod(K),(lstnna(I,K),I=1,4),K=1,NSTATN)
9053      FORMAT(' Stations: '/
     .     10(   '  ', 5(A2,' (',4A2,')',1X)/))
           if (.not.kvex) then ! all is OK
             WRITE(LUSCN,9050)
9050         format(/' Output for which station (type a code, :: to ',
     .      'quit, = for all) ? ',$)
           else ! all not allowed
             WRITE(LUSCN,9052)
9052         format(/' Output for which station (type a code, :: to ',
     .      'quit) ? ',$)
           endif
         else
           write(luscn,9051)
9051      format(' Enter station 2-letter code (e.g. Wf, :: to quit)? ',
     .    $)
         endif
        read(luusr,'(A)') response(1:2)
      else
        response = cstnin
      endif
      if (response(1:2).eq.'::') goto 990
C     Convert to convention upper/lower for 2 letters
      response(1:1)=lower(response(1:1))
      response(2:2)=lower(response(2:2))
      call char2hol(response(1:2),lstn,1,2)
      ISTN = 0
      iF (ichcm_ch(LSTN,1,'==').eq.0) goto 699 ! special all stations
      iF (ichcm(LSTN,1,HEQB,1,1).eq.0) then
        if (.not.kvex) GOTO 699 ! all stations
        if (kvex) goto 500 ! all stations not allowed
      endif
      if (kskd) then !check for valid ID
        DO I=1,NSTATN
C         Convert stored code to string for comparing
          call hol2char(lpocod(i),1,2,scode)
          scode(1:1)  = lower(scode(1:1))
          scode(2:2)  = lower(scode(2:2))
          IF (scode.EQ.response) ISTN = I
        END DO
        IF (ISTN.EQ.0) then
          if (.not.kbatch) then !try again interactively
            GOTO 500
          else ! no recovery in batch
            write(luscn,9059) cstnin
9059        format(' No such station in schedule: ',a)
            goto 990
          endif
        endif
      else !make up valid index
      istn=1
      nstatn=1
      lpocod(1)=lstn
      endif !check for validID
      kmissing=.true.
      if (iserr(istn).ne.0) kmissing=.true.
699   continue
      if (kvex) then !get the station's observations now
        nobs=0
        if (istn.eq.0) then ! get all in a loop
          do i=1,nstatn
            call vob1inp(ivexnum,i,luscn,ierr,iret,nobs_stn) 
            if (ierr.ne.0.or.iret.ne.0) then
              write(luscn,'("FDRUDG01 - Error from vob1inp=",
     .        i5,", iret=",i5,", scan#=",i5)') ierr,iret,nobs_stn
              call errormsg(iret,ierr,'SCHED',luscn)
            else
              write(luscn,'("  Number of scans for this station: ",i5)')
     .        nobs_stn
            endif
          enddo
          write(luscn,'("  Total number of scans in this schedule: ",
     .    i5)') 
     .    nobs
        else ! get one station's obs
          call vob1inp(ivexnum,istn,luscn,ierr,iret,nobs_stn)
          if (ierr.ne.0) then
            write(luscn,'("FDRUDG02 - Error from vob1inp=",
     .      i5,", iret=",i5,", scan#=",i5)') ierr,iret,nobs_stn
            call errormsg(iret,ierr,'SCHED',luscn)
          else
            write(luscn,'("  Number of scans for this station: ",i5)') 
     .      nobs_stn
            write(luscn,'("  Total number of scans in this schedule: ",
     .      i5)') 
     .      nobs
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
9068      FORMAT(/' Select DRUDG option for schedule ',A,
     .    ' at ',4A2/)
9067      FORMAT(/' Select DRUDG option for schedule ',A,
     .    ' (all stations)'/)
          if (.not.kvex) then ! unknown equipment
            write(luscn,9070)
9070        FORMAT(
     .      ' 1 = Print the schedule               ',
     .      '  7 = Re-specify stations'/
     .      ' 2 = Make antenna pointing file       ',
     .      '  8 = Get a new schedule file'/
     .      ' 3 = Make Mark III/IV SNAP file (.SNP)',
     .      '  9 = Change output destination, format '/
     .      ' 31= Make VLBA SNAP file (.SNP)       ',
     .      ' 10 = Shift the .SKD file  '/,
     .      ' 4 = Print complete .SNP file         ',
     .      ' 11 = Shift the .SNP file  '/,
     .      ' 5 = Print summary of .SNP file       ',
     .      ' 12 = Make Mark III procedures (.PRC) ')
            if (clabtyp.eq.'POSTSCRIPT') then
              write(luscn,9170)
9170          FORMAT(
     .        ' 6 = Make PostScript label file       ',
     .        ' 13 = Make VLBA procedures (.PRC)'/,
     .        ' 61= Print PostScript label file      ',
     .        ' 14 = Make hybrid procedures (.PRC)')
            else
              write(luscn,9270)
9270          FORMAT(
     .        ' 6 = Make tape labels                 ',
     .        ' 13 = Make VLBA procedures (.PRC)'/,
     .        '                                      ',
     .        ' 14 = Make hybrid procedures (.PRC)')
            endif
            if (kdrg_infile) then ! .drg file
              write(luscn,9370)
9370          FORMAT(
     .        ' 17 = Print PI cover letter           ',
     .        ' 15 = Make Mark IV procedures (.PRC)'/,
     .        ' 0 = Done with DRUDG                  ',
     .        ' 16 = Make 8-BBC procedures (.PRC)'/,
     .        ' ? ',$)
            else ! .skd file
              write(luscn,9369)
9369          FORMAT(
     .        '                                      ',
     .        ' 15 = Make Mark IV procedures (.PRC)'/,
     .        ' 0 = Done with DRUDG                  ',
     .        ' 16 = Make 8-BBC procedures (.PRC)'/,
     .        ' ? ',$)
            endif ! .drg/.skd
          else ! gotem in the vex file
            write(luscn,9073)
9073        FORMAT('Supporting VEX 1.5'/
     .      ' 1 = Print the schedule               ',
     .      '  7 = Re-specify stations'/
     .      ' 2 = Make antenna pointing file       ',
     .      '  8 = Get a new schedule file'/
     .      ' 3 = Create SNAP command file (.SNP)  ',
     .      '  9 = Change output destination, format '/
     .      ' 4 = Print complete .SNP file         ',
     .      ' 10 = Shift the .SKD file  '/,
     .      ' 5 = Print summary of .SNP file       ',
     .      ' 11 = Shift the .SNP file  ')
            if (clabtyp.eq.'POSTSCRIPT') then
              write(luscn,9173)
9173          FORMAT(
     .        ' 6 = Make PostScript label file       ',
     .        ' 12 = Make procedures (.PRC) '/,
     .        ' 61= Print PostScript label file   ')
            else
              write(luscn,9273)
9273          FORMAT(
     .        ' 6 = Make tape labels                 ',
     .        ' 12 = Make procedures (.PRC) ')
            endif
            write(luscn,9373)
9373        format(
     .      ' 0 = Done with DRUDG  '/
     .      ' ? ',$)
          endif
        else ! SNAP file
        l=trimlen(cexpna)
        WRITE(LUSCN,9071) cexpna(1:l),lpocod(1)
9071      FORMAT(/' Select DRUDG option for experiment ',A,' at ',A2/
     .    ' 4 = Print complete .SNP file          ',
     .    '  7 = Re-specify stations'/
     .    ' 5 = Print summary of .SNP file        ',
     .    '  8 = Get a new schedule file')
          if (clabtyp.eq.'POSTSCRIPT') then
            write(luscn,9171)
9171        format(
     .    ' 6 = Make PostScript label file        ',
     .    '  9 = Change output destination, format'/,
     .    ' 61= Print PostScript label file       ',
     .    ' 11 = Shift the .SNP file')
          else
            write(luscn,9271)
9271        format(
     .      ' 6 = Make tape labels                  ',
     .      '  9 = Change output destination, format'/,
     .      '                                       ',
     .      ' 11 = Shift the .SNP file')
          endif
          write(luscn,9371)
9371      format(
     .    ' 0 = Done with DRUDG           ',
     .   /' ? ',$)
        endif
      IFUNC = -1
      READ(LUUSR,*,ERR=700) IFUNC
      else
        read(command,*,err=991) ifunc
      endif

      if ((ifunc.lt.0).or.(ifunc.gt.17.and.ifunc.ne.31.and.ifunc.ne.61)
     .  .and..not.kbatch) GOTO 700
      if ((ifunc.lt.0).or.(ifunc.gt.17.and.ifunc.ne.31.and.ifunc.ne.61)
     .  .and.kbatch) GOTO 991
      if (.not.kbatch.and..not.kskd.and.((ifunc.gt.0.and.ifunc.lt.4)
     .  .or.ifunc.eq.10.or.(ifunc.ge.17.and.ifunc.ne.31.and.
     .   ifunc.ne.61))) goto 700
      if (ifunc.eq.6.and.clabtyp.eq.' ') then
        write(luscn,'("Unknown label printer type in the",
     .  " control file.")')
        goto 700
      endif

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
        idummy = ichmv_ch(lc,1,'  ')
        idummy = ichmv(lc,1,lpocod(istn),1,2)
        call hol2char(lc,1,2,scode)
        scode(1:1)  = lower(scode(1:1))
        scode(2:2)  = lower(scode(2:2))
        ncs = trimlen(scode)
        nch = trimlen(csnap)
        nci = trimlen(cproc)
        if (csnap(1:2).eq.'./') nch=0
        if (cproc(1:2).eq.'./') nci=0
        if (cexpna(2:2).eq.':'.or.cexpna(1:1).eq.'/') nch=0
        if (nch.gt.0) then ! prepend
          if (ncs.gt.0) then ! station id present
            SNPNAME=csnap(:nch)//cexpna(1:ix)//scode(1:ncs)//'.snp'
            PNTNAME = csnap(:nch)//cexpna(1:ix)//scode(1:ncs)//'.pnt'
          else
            SNPNAME=csnap(:nch)//cexpna(1:ix)//'.snp'
            PNTNAME = csnap(:nch)//cexpna(1:ix)//'.pnt'
          endif
        else ! no prepend
          if (ncs.gt.0) then ! station id present
            SNPNAME=cexpna(1:ix)//scode(1:ncs)//'.snp'
            PNTNAME = cexpna(1:ix)//scode(1:ncs)//'.pnt'
          else
            SNPNAME=cexpna(1:ix)//'.snp'
            PNTNAME = cexpna(1:ix)//'.pnt'
          endif
        endif ! prepend
        if (nci.gt.0) then ! prepend
          if (ncs.gt.0) then ! station id present
            PRCNAME = cproc(:nci)//cexpna(1:ix)//scode(1:ncs)//'.prc'
          else
            PRCNAME = cproc(:nci)//cexpna(1:ix)//'.prc'
          endif
        else
          if (ncs.gt.0) then ! station id present
            PRCNAME = cexpna(1:ix)//scode(1:ncs)//'.prc'
          else
            PRCNAME = cexpna(1:ix)//'.prc'
          endif
        endif
        ierr=0
        IF (IERR.EQ.0)  THEN
          IF (IFUNC.EQ.1) THEN
            CALL LISTS
          ELSE IF (IFUNC.EQ.2) THEN
            CALL POINT(cr1,cr2,cr3,cr4)
c            I = nstnx
          ELSE IF (IFUNC.EQ.3) THEN
            CALL SNAP(cr1,1)
          ELSE IF (IFUNC.EQ.31) THEN
            CALL SNAP(cr1,2)
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
          else if (ifunc.eq.17) then
              call prcov
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
              call label(pcode,kskd,cr1,cr2,cr3,cr4,inew)
              klab = .false.
          ELSE IF (IFUNC.EQ.61) THEN
              if (clabtyp.eq.'POSTSCRIPT'.and.i.eq.1) then ! only first station
                klab = .true.
                ierr=cclose(fileptr)
                call prtmp(0)
                inew=1 ! reset flag for new file
                klab = .false.
              endif
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
      if (clabtyp.eq.'POSTSCRIPT') then
        inquire(file=labname,exist=kex)
        if (kex) then 
          response='x'
          ierr=cclose(fileptr)
          if (.not.kbatch) then
            do while (response(1:1).ne.'p'.and.response(1:1).ne.'d')
              write(luscn,'("PostScript label file exists. Do you want",
     .        " to print it or delete it? (P/D) ?",$)')
              read(luusr,'(A)') response(1:2)
              response(1:1)=lower(response(1:1))
            enddo
          endif
          if (response(1:1).eq.'p') then
            klab = .true.
            call prtmp(0)
          else if (response(1:1).eq.'d'.or.kbatch) then
C           open(luprt,file=labname,status='old')
C           close(luprt,status='delete')
          endif
        endif
      endif
      WRITE(LUSCN,9090)
9090  FORMAT(' DRUDG DONE')
      END
