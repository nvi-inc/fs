      subroutine fdrudg(cfile,cstnin,command,cr1,cr2,cr3,cr4)
C
C     DRUDG HANDLES ALL OF THE DRUDGE WORK FOR SKED
C
C  Common blocks:
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'   !This includes info about data transfer
      include 'bbc_freq.ftni' 

! called functions    
      

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
      double precision R,D
      character*2 cstn
      integer TRIMLEN,pcode
      character*128 cdum
      character*128 csnap,cproc,csked,cexpna
      logical kex,kskd,kskdfile,kdrgfile,kknown
      logical kequip_over,knew_sked
      integer nch,nci
      character*2  response,scode
      character*12 dr_rack_type, crec_def(2)
      character*12 crack_tmp_cap,crec_tmp_cap
      integer inew,ivexnum
      integer i,k,l,ncs,ix,ixp,ic,ierr,iret,nobs_stn
      integer inext,isatl,ifunc,nstnx
      integer nch1,nch2,nch3,iserr(max_stn)
      logical kexist 

      character*2 cbnd(2)   !used in count_freq_tracks
      integer     nbnd      ! ditto
      logical kallowpig
      character*39 clabline  !used to hold label description,e.g. 6= Make Postscript label
      character*39 clabprint !used to hold print line
      logical krec2_found
       character*20 cstat_tmp
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
C 970915 nrv Add "VLBA4" option for procedures.
C 971003 nrv Stop if schedule file name has > 6 characters.
C 971003 nrv NOT CHANGED in HPUX: in the mira version, the '=' option has been
C            removed, but you can use '==' to get the same effect.
C 971014 nrv With the 'D' option for an existing PS file, remember
C            to delete the file!
C 971211 nrv Initialize kparity and kprepass here.
C 980218 nrv Add K4 to menus for non-VEX.
C 980916 nrv Make option 21 print .txt file for non-drudg file.
C 980916 nrv Remove the "shift the .SNP file" option
C 980916 nrv Remove K4 for the initial Y2K version.
C 980924 nrv Remove .skd shift for the Y2K version.
C 980929 nrv Add K4 back in, but with a single option. Add call to "k4type".
C 990113 nrv Add call to "k4snap_type" to determine recorder type.
C            Change "k4type" to "k4proc_type".
C 990115 nrv Print initial prompt on two lines.
C 990115 nrv Remove "k4snap_type" because both types are the same.
C 990326 nrv Put drudg version date into a variable in common.
C 990427 nrv Add Mk3+VLBA and Mk3+VLBA4 option for proc types.
C 990523 nrv Remove VLBA SNAP option
C 990524 nrv Add S2 SNAP option
C 990527 nrv Add iin to LISTS call to support K4 and S2
C 990726 nrv Remove S2 from main menu, only valid with known equipment.
C 990730 nrv Change option 11 to be equipment type.
C 990819 nrv Add option 21. Change 21 to 51.
C 990910 nrv Print out rack and recorder, if known, at top.
C 991101 nrv Add equipment to RDCTL call. Remove the numerous options
C            for procedures. User must use Option 11, control file, or
C            schedule info to set them. Add call to skdrini.
C 991108 nrv Add another cdum to RDCTL call for modes-description.
C 991118 nrv Add another cdum to RDCTL call for modes-description.
C 991123 nrv Recorders 1 and 2.
C 000110 nrv Add 'fake' option for correlator. Remove this option for
C            FS distribution!
C 000329 nrv Add dummy for parameter program to rdctl
C 000516 nrv Add option for printing VEX cover info
C 001101 nrv Write out $SKED section generated from VEX input for
C            testing (commented out).
C 001114 nrv Remove call to VOB1INP because VOBINP is called in VREAD.
C 020304 nrv Add option 13 for Mk5 piggyback mode.
C 020614 nrv Change FS version to y/m/d digits for HPUX version.
C 021002 nrv Write comments about geo/astro VEX/standard schedule.
! 2004Sep04  JMGipson  Replaced setba_dr by count_freq_tracks
! 2004Nov12 JMGipson.  Replace csize, iwidth (which are font size and widht
!           by variable cpaper_size. First is orientation, second size.
! 2005Feb16 JMGipson added menu item for fake lvex files.
! 2005Mar01 JMGipson. Fixed equip_override.  Previously if it was set, you could not change
!                     equipment type using option 11.
! 2006Jun13 JMGipson.  Moved lmysql_** and, ldisk2file from rdctl argument list and put in common.
! 2006Jul21 JMGipson. Disabled shifting for VEX schedules.
! 2006Oct04 JMGipson. Disabled shifting for snap files.
!                     Shifting completely re-written.
! 2006Oct16 JMGipson. Small changes having to do with printing.
! 2007May28 JMGipson. Don't allow piggyback for Mark5B mode.
! 2007Jul07 JMGipson. Added "q" option for quitting.
! 2007Sep05 JMGipson. Changed entry point for re-reading schedules.
! 2008May23 JMGipson. Make sure output files are lowercase
! 2012Sep25 JMGipson. Modified to use drudg_rdctl.f instead of rdctl.f 
! 2013Jan23 JMGipson. Modified so that equipment_override is done when in batch mode. 
! 2013Jun18 JMGipson. Capitalize original rack equipment. 
! 2013Jul11 JMGipson. Issue error if file is not found and stop.
! 2015Jun05 JMG.      Increased size of dr_rack_type, crec_def from Char*8-->char*12
! 2015Jul06 JMG.      If recorder or rack is "UNKNOWN" change to none. 
! 2015Aug31 JMG.      Don't quit on "q"
! Get the version
      include 'fdrudg_date.ftni'
      call get_version(iverMajor_FS,iverMinor_FS,iverPatch_FS)

C Initialize FS version

C PeC Permissions on output files
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
! Initialize cpaper_Size to "default Defualt"
      cpaper_size="DD"
C Initialize the $PROC section location
      ksked_proc=.false.
C Initialize default epoch for source positions
      cepoch = '1950'
C Codes for passes and bandwidths
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
      tpid_prompt = 'no'
      itpid_period = 0
      cont_cal_prompt='OFF'
      do i=1,4
        ldbbc_if_inputs(i)=" "
      end do 

C  Initialize lots of things in the common blocks
100   continue
      call skdrini
C
C     1. Make up temporary file name, read control file.
C***********************************************************   


      call drudg_rdctl(csked,csnap,cproc,ctmpnam,            
     >           dr_rack_type,crec_def,kequip_over)
      kdr_type = .not.(dr_rack_type.eq.' '.and.
     >               crec_def(1).eq.' '.and.crec_def(2).eq.' ')
      klabel_ps = clabtyp.eq.'POSTSCRIPT' .or. clabtyp .eq. 'DYMO'
!      stop 

C
C     2. Initialize local variables
C
      km5A=.false.
200   continue
      knew_sked=.true.

      nch = trimlen(ctmpnam)
      if (ctmpnam.eq.'./') nch=0
! GetPID doesn't exist in linux
!      ipid=getpid()
!      write(cpidx,'(i5.5)') ipid

      if (nch.gt.0) then
         tmpname = ctmpnam(:nch)//'DR.tmp'
         labname = ctmpnam(:nch)//'DRlab.tmp'
!         labname = ctmpnam(:nch)//'DRlab.tmp'//cpidx
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
      kparity = .false.
      kprepass = .false.
      km5P_piggy = .false.
      km5A_piggy = .false.

C  In drcom.ftni
      kmissing = .false.

! Check for log file processing
201   continue
      nch1=trimlen(cfile)
      nch2=trimlen(cstnin)
      nch3=trimlen(command)
! Check for label.
      if(index(cfile,".log") .ne. 0) then
         call lablog(cfile,cstnin,command,cr1,cr2,ierr)
         stop
      endif

      cexpna = ' '
C   Check for non-interactive mode.
      if (nch1.ne.0.and.nch2.ne.0.and.nch3.ne.0) kbatch=.true.
    
C 3. Get the schedule file name
      DO WHILE (cexpna(1:1).EQ.' ') !get schedule file name
        if (.not.kskdfile.or.kdrgfile) then ! first or 3rd time
          if (kskdfile.and.kdrgfile) then ! reinitialize on 3rd time
           kskdfile=.false.
           kdrgfile=.false.
          endif
C       Opening message
          WRITE(LUSCN,'(a)')
     >   ' DRUDG: Experiment Preparation Drudge Work (NRV & JMGipson '//
     >    cversion(1:trimlen(cversion))//')'
	  write(luscn,'("Version: ",i2,2(".",i2.2))') iverMajor_fs,
     >     iverMinor_fs,iverpatch_fs

          nch = trimlen(cfile)
          if (nch.eq.0.or.ifunc.eq.8.or.ierr.ne.0) then ! prompt for file name
            if (kbatch) goto 990
            write(luscn,'(a,$)')
     >" Enter schedule file name (.skd, .vex or .drg default <return> "
            write(luscn,
     >          '("if using a .snp file, :: to quit) ?",$)')
            read(luusr,'(a)') cbuf
            nch=trimlen(cbuf)
          else ! command line file name
            cbuf=cfile
          endif 
        endif     
        IF (NCH.GT.0) THEN !got a name
          if(cbuf(1:2) .eq. "::" ) goto 990
          if (cbuf(1:1) .eq. "." .or. cbuf(1:1) .eq."/") then
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
          ctextname = ''        
          if (ix.eq.0) then ! automatic extension
            if (.not.kskdfile) then ! try .skd
              lskdfi=lskdfi(1:l)//'.skd'
              inquire(file=lskdfi,exist=kexist)
              if(.not.kexist) then 
                lskdfi=lskdfi(1:l)//'.vex'
                inquire(file=lskdfi,exist=kexist)
                if(.not.kexist) then
                   write(*,*) 
     >           "ERROR!  Did not find file "//lskdfi(1:trimlen(lskdfi))
                   stop
                endif
              endif 
              ctextname = lskdfi(1:l)//'.txt'
              kskdfile = .true.
              kdrg_infile=.false.
            else ! try .drg
              lskdfi=lskdfi(1:l)//'.drg'
              kdrgfile = .true.
              kdrg_infile=.true.
            endif
          else
            if (lskdfi(ix:l).eq.'.skd') then !
              kdrg_infile=.false.
              ctextname = lskdfi(1:ix-1)//'.txt'
            endif
            if (lskdfi(ix:l).eq.'.drg') kdrg_infile=.true.
          endif ! automatic extension
          inquire(file=lskdfi,exist=kexist)
          if(.not.kexist) then 
            write(*,*) 
     >         "ERROR!  Did not find file "//lskdfi(1:trimlen(lskdfi))
            stop
          endif           
        
          ixp=1
          ix=1
          do while (ix.ne.0) ! find the last '/'
            ix=index(lskdfi(ixp:),'/')
            if (ix.gt.0) ixp=ixp+ix
          enddo
          cexpna=lskdfi(ixp:) ! exp name is root of file name
          IX = INDEX(cexpna,'.')-1
          if (ix.gt.6) then ! too many letters
            write(luscn,'(a)')
     >      " ERROR: Schedule name is too long. Please rename the file "
            write(luscn,'(a)')
     >         "to have 6 characters or less before the file extension."
            goto 990
          endif
          kskd = .true.
        else ! none
          write(luscn,'(" Enter schedule name (e.g. ca036): ",$)')
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
      kgeo = .true.
      kpostpass = .false.
      if (.not.kskd) goto 500
        ix=trimlen(cexpna)
        IC=TRIMLEN(LSKDFI)
        WRITE(LUSCN,9300) LSKDFI(1:IC),cexpna(1:ix)
9300      FORMAT(' Opening file ',A,' for schedule ',A)
        CALL SREAD(IERR,ivexnum)
         IF (IERR.NE.0) goto 201

        if (kgeo) then
          write(luscn,'(a)') ' This is a geodetic schedule.'
        else
          write(luscn,'(a)') ' This is an astronomy schedule.'
        endif
        if(kvex) then
          write(luscn,'(a)') ' This is a VEX format schedule file.'
        else
          write(luscn,'(a)')' This is a standard non-Vex schedule file.'
        endif
        if (kdrgfile)
     >    write(luscn,"(' This is a .drg schedule file.')")
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
            write(luscn,9302) cdum(1:nch)
9302        format(' NOTE: This schedule uses ',a,' tape motion',$)
              if (tape_motion_type(1)(1:5).eq.'ADAPT') then 
                write(luscn,'(10x, "GAP   = ",i3," seconds.")') itgap(1)
              else
                write(luscn,'(".")') 
              endif
            endif
          endif
C     Reset for the next time through.
          kskdfile = .false.
          kdrgfile = .false.
C
C     Derive number of passes for each code
          CALL GNPAS(luscn,ierr,iserr)
          call count_freq_tracks(cbnd,nbnd,luscn)
          if (ierr.ne.0) then ! can't continue
            write(luscn,9999) 
9999        format(/'DRUDG00: WARNING! Inconsistent or missing ',
     .      'pass/track/head information.'/
     .      ' SNAP or procedure output may be incorrect',
     .      ' or may cause a program abort for:'/)
            do i=1,nstatn
              if (iserr(i).ne.0) write(luscn,9998) cstnna(i)
9998          format(1x,a,1x,$)
            enddo
            write(luscn,'()')
          endif
C
          WRITE(LUSCN,'(a,i4)')
     >       "  # of sources:         ",NSOURC
          if(nsatel .gt. 0) write(luscn,'(a,i4,a,i4)')
     >       "  # quasars: ",nceles, " # satellites ",nsatel

          WRITE(LUSCN,'(a,i4)')
     >       "  # of stations:        ",nstatn
          write(luscn,'(a,i4)')
     >       "  # of frequency codes: ", ncodes
          if(.not. kvex) write(luscn,'(a,i4)')
     >       "  # of scans:           ",nobs
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
!          IDUMMY = ICHMV(LSORNA(1,INEXT),1,LSORNA(1,ISATL),1,max_sorlen)
          csorna(inext)=csorna(isatl)
        END DO
C
C  Check for sufficient information
        IF (NSTATN.GT.0.AND.NSOURC.GT.0.AND.ncodes.GT.0) GOTO 500

        WRITE(LUSCN,"(' Insufficient information in file.')")
          ierr=-1
        GOTO 200
C
C     5. Ask for the station(s) to be processed.  These will be done
C        in the outer loop.
C
500   CONTINUE
! Set all second recorders to "none"
      krec2_found=.false.

      do istn=1,nstatn
           if(cstrec(istn,2) .ne. "none") then
           if(.not.krec2_found) then                 
             write(*,'(a)') 
     >        "Warning! All 2nd recorders set to 'none'"  
             krec2_found=.true.
           endif 
           cstrec(istn,2)="none"
          endif 
 

! Make a copy of the original configuration now
          cstrack_orig(istn) =cstrack(istn)
          cstrec_orig(istn,1)=cstrec(istn,1)
          cstrec_orig(istn,2)=cstrec(istn,2)
          call capitalize(cstrack_orig(istn))
          call capitalize(cstrec_orig(istn,1))
          call capitalize(cstrec_orig(istn,2))
      end do
!
      km5A_piggy=.false.
      km5p_piggy=.false.
      response=" "
      if (.not.kbatch) then
        if (kskd) then
          WRITE(LUSCN,9053) (cpocod(K),cstnna(K),K=1,NSTATN)
9053      FORMAT(' Stations: '/
     .     10(   '  ', 5(A,' (',A8,')',1X)/))
           WRITE(LUSCN,9050)
C9050      FORMAT(/' NOTE: Station codes are CaSe SeNsItIvE !'/
9050       format(/' Output for which station (type a code, ',
     >   ' :: or q to quit, = for all) ? ',$)
         else
           write(luscn,9051)
9051      format(' Enter station 2-letter code ',
     >     '(e.g. Wf, :: or q to quit)? ',$)
         endif
        read(luusr,'(A)') response(1:2)
      else
        response = cstnin
      endif
      if (response(1:2).eq.'::' .or. response(1:2) .eq. "q" ) goto 990
C     Convert to convention upper/lower for 2 letters
      call lowercase(response)
      cstn=response
      ISTN = 0
      if(response .eq. "=") goto 699
      if (kskd) then !check for valid ID
        DO I=1,NSTATN
          scode=cpocod(i)
          call lowercase(scode)
          IF (scode.EQ.response) ISTN = I
        END DO
        IF (ISTN.EQ.0) then
          if (.not.kbatch) then !try again interactively
            GOTO 500
          else ! no recovery in batch
            write(luscn,"(' No such station in schedule: ',a)") cstnin
            goto 990
          endif
        endif
      else !make up valid index
      istn=1
      nstatn=1
      cpocod(1)=cstn
      endif !check for validID
      kmissing=iserr(istn) .ne. 0
699   continue
      if(kvex) then !get the station's observations now
C getting all the scans (needed to generate scan names)
! This gets in all the scans.
         call VOBINP(ivexnum,LUscn,iret,IERR)
         if (ierr.ne.0) then
           write(luscn,'("FDRUDG02 - Error from vobinp=",i5,",
     >     iret=",i5,", scan#=",i5)') ierr,iret,nobs_stn
           call errormsg(iret,ierr,'SCHED',luscn)
        endif
      endif
C
C     7. Find out what we are to do.  Set up the outer and inner loops
C        on stations and schedules, respectively.  Within the loop,
C        schedule the appropriate segment.
C
700   continue
      if(kskd) then 
! This part sees if we should do equip_override. 
        if (istn.gt.0) then !one station
C  Set equipment from control file, if equipment is unknown, and
C  if it was not set by the schedule.      
 
          crec_tmp_cap=cstrec(istn,1)
          call capitalize(crec_tmp_cap)
          if(crec_tmp_cap .eq. "UNKNOWN") cstrec(istn,1)="none"

          crack_tmp_cap=cstrack(istn)
          call capitalize(crack_tmp_cap)
          if(crack_tmp_cap .eq. "UNKNOWN") cstrack(istn)="none" 


          if (kdr_type .and. kequip_over.and.knew_sked) then ! equipment is in control file
            if(cstrack(istn) .ne. dr_rack_type .or.
     >         cstrec(istn,1) .ne. crec_def(1) .or.
     >         cstrec(istn,2) .ne. crec_def(2)) then
              Write(luscn,*)
     >           "WARNING! Using equipment from skedf.ctl:"
              write(luscn,  '(5x,"Replacing rack ",a," by ", a)')
     >          cstrack(istn), dr_rack_type
              do i=1,2
                write(luscn,'(5x,"Replacing rec",i1,5x, a, " by ",a)')
     >              i, cstrec(istn,i), crec_def(i)
              end do
              cstrack(istn) =dr_rack_type
              cstrec(istn,1)=crec_def(1)
              cstrec(istn,2)=crec_def(2)
            endif
!This keeps us from only doing the override when the schedlue is read in.
            knew_sked=.false.
            if(cstrec(istn,2) .ne. 'none' .and.
     >        cstrec(istn,1) .ne. 'none') nrecst(istn)=2
          endif ! equipment is in control file
        else !all stations                 
          do i=1,nstatn
            if(cstrec(i,1)  .eq. 'unknown' .or.
     >         cstrack(i) .eq. 'unknown') kknown=.false.
          enddo
        endif
      endif
     
      if (.not.kbatch) then
! Several options for label line.
       

      if (kskd) then !schedule file
        l=trimlen(lskdfi)
    
C       Are the equipment types now known?
        if (istn.gt.0) then !one station check equipment
          kknown = .not.
     >    (cstrec(istn,1).eq.'unknown'.or. cstrack(istn) .eq. 'unknown')
          if (kknown) then  ! write equipment
            write(luscn,9069)
     >       cstnna(istn), cstrack(istn), cstrec(istn,1), cstrec(istn,2)
9069        format(/' Equipment at ',a,':'/'   Rack: ',a,
     .       ' Recorder 1: ',a,' Recorder 2: ',a)
            if (nrecst(istn).eq.2) write(luscn,9070) cfirstrec(istn)
9070        format(' Schedule will start with recorder ',a1,'.')         
          else
            write(luscn,9169) cstnna(istn)
9169        format(/' Equipment at ',a,' is unknown. Use Option 11',
     .       ' to specify equipment.')
          endif ! write equipment
          call init_hardware_common(istn)

        endif ! one station check equipment

        kallowpig=.false. 
        if (istn.gt.0) then !one station check equipment
          cstat_tmp=cstnna(istn)
        else
          cstat_tmp=" all stations"
        endif
        write(luscn,
     >   '("Select DRUDG option for schedule ", a, " at ",a)')
     >   lskdfi(1:l), cstat_tmp 
     
      
         write(luscn,'(a)')
     >      ' 1 = Print the schedule               '//
     >     '  7 = Re-specify stations'
          write(luscn,'(a)')
     >      ' 2 = Make antenna pointing file       '//
     >      '  8 = Get a new schedule file'

          write(luscn,'(a)')
     >      ' 3 = Make SNAP file (.SNP)            '//
     >      '  9 = Change output destination, format '

! Disable shifiting for vex files.
          if(kvex ) then
             write(luscn,'(a)') ' 4 = Print complete .SNP file'
          else
             write(luscn,'(a)')
     >        ' 4 = Print complete .SNP file         '//
     >        ' 10 = Shift the .SKD file  '
          endif

          write(luscn,'(a,$)')
     >      ' 5 = Print summary of .SNP file       '

          if(istn .gt. 0) then
            write(luscn,'(a)')
     >          ' 11 = Show/set equipment type'
          else
            write(luscn,'()')
          endif

          write(luscn,'(38x," 12 = Make procedures (.PRC) ")')
         
      
          if(istn .ne. 0 .and. km5Disk .and.
     >       (kstat_in2net(istn) .or. kstat_disk2file(istn))) then
             write(luscn,'(38x,a)') ' 15 = Data Transfer Overide '
          endif

           if (kdrg_infile.or.kvex) then
              write(luscn,'(" 51 = Print PI cover letter")')
            else ! .skd file
              write(luscn,'(" 51 = Print notes file (.TXT)")')
            endif ! .drg/.skd
            write(luscn,'(a)') ' 20 = Make fake lvex'
            write(luscn,'(a)') ' 0  = Done with DRUDG '
            write(luscn,'(a, $)') ' ?'
        else ! SNAP file
        l=trimlen(cexpna)
        WRITE(LUSCN,9071) cexpna(1:l),cpocod(1)
9071      FORMAT(/' Select DRUDG option for experiment ',A,' at ',A2/
     .    ' 4 = Print complete .SNP file          ',
     .    '  7 = Re-specify stations'/
     .    ' 5 = Print summary of .SNP file        ',
     .    '  8 = Get a new schedule file')

          write(luscn,'(a," 9 = Change output destination, format")')
     >         clabline
          if(klabel_ps .and. clabprint.ne." ")
     >        write(luscn,'(a)') clabprint

          write(luscn,'(39x," 11 = Show/set equipment type",/)')
          write(luscn,'(" 0 = Done with DRUDG           ",/,"?",$)')
        endif
      IFUNC = -1
      READ(LUUSR,*,ERR=700) IFUNC
      else
        read(command,*,err=991) ifunc
      endif

      if ((ifunc.lt.0).or.(ifunc.gt.21.and.ifunc.ne.33.and.ifunc.ne.61
     .  .and.ifunc.ne.32.and.ifunc.ne.102.and.ifunc.ne.103
     .  .and.ifunc.ne.51 .and. ifunc .ne. 62)
     .  .and..not.kbatch) GOTO 700 ! not recognized, interactive ask again
      if ((ifunc.lt.0).or.(ifunc.gt.21.and.ifunc.ne.33.and.ifunc.ne.61
     .  .and.ifunc.ne.32.and.ifunc.ne.102.and.ifunc.ne.103
     .  .and.ifunc.ne.51)
     .  .and.kbatch) GOTO 991 ! not recognized, batch quit
      if (.not.kbatch.and..not.kskd.and.((ifunc.gt.0.and.ifunc.lt.4)
     .  .or.ifunc.eq.10.or.(ifunc.ge.21.and.ifunc.ne.33.and.
     .   ifunc.ne.32.and.ifunc.ne.102.and.ifunc.ne.103.and.
     .   ifunc.ne.51.and.
     .   ifunc.ne.61))) goto 700 ! snp file not schedule
      if (ifunc.eq.6.and.clabtyp.eq.' ') then
        write(luscn,'(a)')
     >   "Unknown label printer type in the control file."
        goto 700
      endif

      if( ifunc.eq.11 .and. istn .le. 0) goto 700
      if((ifunc.eq.13 .or. ifunc.eq.14).and. .not.kallowpig) goto 700


      IF (IFUNC.EQ.9) THEN
          if (kbatch) goto 991
        call port
        goto 700
      ELSE IF (IFUNC.EQ.7) THEN
          if (kbatch) goto 991
        GOTO 500
      ELSE IF (IFUNC.EQ.8) THEN
          if (kbatch) goto 991
        GOTO 100
      ELSE IF (IFUNC.EQ.0) THEN
        GOTO 990
      ELSE IF (IFUNC.EQ.10) THEN
        if(kvex) then
          call write_error_and_pause(luscn,
     >       "DRUDG: Shifting of VEX files is not allowed!")
        else if(kbatch) then
          write(luscn,'(a)') "DRUDG: Can't shift files in batch mode."
          goto 991
        else
          CINNAME = LSKDFI
          call skdshft(ierr)
        endif
        GOTO 700
      ENDIF
C
      NSTNX = 1
      IF (cstn .eq."=") nstnx=nstatn
C
      I = 1
      do while (I.le.nstnx)  !loop over stations
        IF (cSTN.eq. "=") ISTN = I
        kmissing=.false.
        if (iserr(istn).ne.0) kmissing=.true.
        IX = INDEX(cexpna,'.')-1
        if (ix.lt.0) ix=trimlen(cexpna)
        scode=cpocod(istn)
        call lowercase(scode)
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
! Make sure we use lower case
        call lowercase(SNPNAME)
        call lowercase(PNTNAME)
        call lowercase(PRCNAME)
        ierr=0
        IF (IERR.EQ.0)  THEN
          IF (IFUNC.EQ.1) THEN
            CALL LISTS()
          ELSE IF (IFUNC.EQ.2) THEN
            CALL POINT(cr1,cr2,cr3,cr4)
c            I = nstnx
          ELSE IF (IFUNC.EQ.3) THEN
            call snap(cr1)
          ELSE IF (IFUNC.EQ.4) THEN
            CALL CLIST(kskd)
          ELSE IF (IFUNC.EQ.12) THEN
            call procs       
          else if(ifunc .eq. 15 .and. km5Disk) then
              call xfer_override(luscn)
          else if (ifunc.eq.51) then
            if (kdrg_infile) then ! .drg file
              call prcov
            else if (kvex) then ! vex file
              call prcov_vex
            else
              call prtxt
            endif
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
            if(.not.km5disk) then
              cinname = snpname
              klab = .true.
              call label(pcode,kskd,cr1,cr2,cr3,cr4,inew)
              klab = .false.
            endif
          ELSE IF (IFUNC.EQ.61.and..not.km5disk) then     !only print labels for tape.
              if (klabel_ps .and. i.eq.1) then
                klab = .true.
                call prtmp(0)
                inew=1 ! reset flag for new file
                klab = .false.
              endif
          ELSE IF (IFUNC.EQ.11) THEN
              call equip_type(cr1)
              cinname = snpname
              if (kbatch) then
                write(*,*)
     >            "DRUDG: Can't change equipment type in batch mode!"
                goto 991
              endif
              call init_hardware_common(istn)
          ELSE IF (IFUNC.EQ.5) THEN
              cinname = snpname
              call lstsum(kskd,ierr)
          ELSE IF (IFUNC.EQ.20) THEN
              call fakesum
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
      if (klabel_ps) then
        inquire(file=labname,exist=kex)
        if (kex) then 
          response='x'
C 001211 nrv Don't try to close this file because it may not
C            have been created by this program. Just delete it.
C         ierr=cclose(fileptr)
          if (.not.kbatch) then
            do while (response(1:1).ne.'p'.and.response(1:1).ne.'d')
              write(luscn,'("PostScript label file exists. Do you want",
     .        " to print it or delete it? (P/D) ?")')
              read(luusr,'(A)') response(1:2)
              call lowercase(response)
            enddo
          endif
          if (response(1:1).eq.'p') then
            klab = .true.
            call prtmp(0)
          else if (response(1:1).eq.'d'.or.kbatch) then
            open(luprt,file=labname,status='old')
            close(luprt,status='delete')
          endif
        endif
      endif
      WRITE(LUSCN,'("DRUDG DONE")')
      END
