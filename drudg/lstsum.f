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
C 960126 nrv Remove "9/8" multiplication on speed because SNAP files
C            now use the actual speeds.
C 960201 nrv Change input buffer to upper case before processing.
C 960810 nrv Change ITEARL to itearl_local
C 960819 nrv Changes for S2, non-numeric speed in ST command. Keep track
C            of footage if tapes are run continuously. Rearrange sections
C            so that a new SOURCE= command triggers output of previous
C            scan. Determine if this is an S2 SNAP file by reading it to
C            find a "data_valid" line.  "feet" is running time in seconds
C            for S2, footage in feet for other recorders.
C 960913 nrv Change logic for accumulating S2 running time and determining
C            whether tape has truly started.
C 960917 nrv If we come to end of file, output what's left at that point.
C 960920 nrv Remove line output to new routine LSTSUMO.
C 961105 nrv Check for READY instead of UNLOD so that the final scan
C            is correctly output.
C 961108 nrv Undo the final FASTR to spin down the tape so the last
C            footage is correct.
C 970131 nrv Put updating of IFEET back in here, after call to LSTSUMO.
C 970131 nrv Remove some checks for KS2 and replace with others.
C 970207 nrv Allow default orientation or force.
C 970214 nrv change id to 2 letters
C 970304 nrv Add COPTION for defaults
C 970312 nrv Add call to READ_SNAP1 to read first line in freefield
C 970313 nrv Compute itearl_local with full d/h/m/s instead of just seconds
C 970313 nrv Revise footage counts to correctly handle adaptive early start.
C 970321 nrv For continuous motion use "data comments.
C 970401 nrv Save variables for LSTSUMO and print them after the next
C            midob is found, so that we know if there was an ET.
C 970401 nrv Add itlate_local to LSTSUMO call.
C 970728 nrv Set ifeet_print=ifeet if ifeet_print=-1 when the previous 
C            output line is printed, because this means no ST or data_start
C            have occurred for a non-tape scan. Don't update the footage
C            on "data stop" if the tape is not running.
C 970730 nrv Don't set ifeet=0 at midtp because it might not be.
C 970801 nrv For non-tape scans set cnewtap='@  '
C 971003 nrv This is not fixed: If the last scan has late stop, the
C            listing shows the tape stop time and the data stop time
C            to be the same. 
C 971210 nrv Check "data_valid" commands instead of "data start/stop".
C 971210 nrv Guess it's an S2 .snp file if you find "st=for,slp".
C 980911 nrv Add a format string for the time field. Decide if it's
C            a new time by whether there's punctuation.
C 980914 nrv Print out the full date for each new day. Add IYEAR to
C            LSTSUMO call. Handle both new and old style SNAP dates.
C 980916 nrv Remove decoding time field to a subroutine TIMIN.
C 980917 nrv Recognize either "data_valid" command or "data xx" comment.
C 990115 nrv Recognize ST=RECORD in SNAP file as a K4 command.
C 990117 nrv Calculate K4 footage using K4 speeds
C 990304 nrv Use sample rate not bandwidth because all stations
C            may not be using all the channels.
C 990305 nrv Call WRDAY instead of WRDATE.
C 991102 nrv Recognize the dual recorder commands. Remove the code
C            to a subroutine for getting information from common 
C            or directly from the .snp file. 
C 991103 nrv Add crack,creca,crecb to lstsumo call for headers, and
C            to lstsum_info call.
C 991108 nrv Parse FAST command timing by finding the '='.
C 991115 nrv Change 'XXX' to 'AAA' or 'BBB'. To 'Rec1' or 'Rec2'
C 000107 nrv Reduce maxline by 5, because there are more header lines.
C 000529 nrv Read scan name from SNAP file.
C 000601 nrv If ctimin doesn't return a valid format statement then
C            don't try to read the time.
C 000606 nrv SCAN_NAME command starts the new scan, not SOURCE=.
C 000611 nrv Add KSCAN to call.
C 000622 nrv Don't try to decode a time command without a valid format.
C 000614 nrv Save the line number of the SCAN_NAME command, not SOURCE.
C 001114 nrv Don't upper-case SCAN_NAME command.
C 020531 nrv Don't reset footage to zero at the start of the next
C            forward pass. The schedule doesn't always return the tape
C            to zero footage but may leave it positioned to start the
C            next pass at that point.
C 021014 nrv If the footage is not reset to zero at the start of the next
C            pass, then slight errors in timing/footage calculations may 
C            accumulate and result in erroneous printed footages. If there 
C            is a FASTR after the MIDTP, consider it a signal from the
C            schedule and reset to zero.
C 021014 nrv Read new FAST commands from the .snp file with fractional seconds.
! 011503 JMG Completely rewritten.
! 2003Nov13  JMgipson Logic which calculats tape footage for spin commands
!            changed after change in tspin,fspin
! 2004Oct21  JMGipson Added "PREOB" as a condition for start time.
!            This is because some of D.Graham's schedules did not have tape or disks!
! 2004Nov21  Modified Maxline.  lstsumo (called by this) does better job of
!            calculating line position.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include 'lstsum.ftni'
      include 'hardware.ftni'
C
C Input:
      logical kskd
C Output:
      INTEGER   IERR

! Functions.
      real counter_init        !Initialize counter
      integer itimedifsec       !function
      INTEGER TRIMLEN           !length of string excluding blanks.

C Local:
      integer itlate_local,itearl_local
      INTEGER IC
      integer nline,num_tapes,npage,maxwidth,maxline,iline
      integer inewp,ne,nm,l,ifdur,id,ieq
      real dif

      logical kvalidtime                !valid time read?

      integer num_scans                 !number of scans
      integer nsline                    !snapfile line
      integer itime_now(5)      	!time now. Latest time from snap file.
      integer itime_start(5)            !scan start.
      integer itime_stop(5)             !scan
      integer itime_source(5)
      integer itime_temp(5)             !time.
      integer itime_tape_start(5)       !time tape starts to move.
      integer itime_tape_stop(5)        !time tape stops moving.
      integer idur                      !duration of scan
      character*12 cscan
      character*128 ctmp_source         !buffer contianing source command
      character*3 cdir                  !direction
      character*2 cpass                 !Current pass
      character*6 cnewtap               !Newtape
      real counter_now                  !current counter. Stored as real for greater precision.
      real counter_source               !counter when on source given.
      real counter_tape_start           !counter when tape started.
      real counter_print                !counter we print.
      real counter_data_valid_on        !counter when we reached this.
      real counter_prev                 !counter at end of last scan.


! this is for previous scan.
      real counter_print_p              !counter we print.
      real counter_source_p
      integer nsline_p                  !snapfile line
      integer itime_start_p(5)          !scan start.
      integer itime_stop_p(5)           !scan
      integer itime_source_p(5)
      integer itime_tape_start_p(5)     !time tape starts to move.
      integer idur_p                    !duration of scan
      character*12 cscan_p
      character*128 ctmp_source_p       !buffer contianing source command
      character*3 cdir_p                !direction
      character*2 cpass_p               !Current pass
      character*6 cnewtap_p             !Newtape

      character*2 cpass_old

      real   spin_speed                 !Speed of tape in feet/sec.
! flags
! Note: most of these flags get reset when we write out a line.
      logical kdata_start               !Started taking data
      logical kdata_stop                !stoped taking data.
      logical ksource                   !found source command
      logical kmidtp                    !Found midtp command.
      logical kunload                   !Unload tape.

      real rifdur
      real speed_snap 			! speed from SNAP file
      double precision speed_recorder   ! speed of recorder in this mode.

      LOGICAL   kexist
      character*128 ctmp,ctmp_in

      real temp
      integer itemp
      integer i

      logical kdisk                     !mark5 or makr5p
      integer icode                     !Read from "SETUPxx" command
      integer icode_old                 !old version
      character*2 ccode_tmp
      integer iSpinDelay
      character*2 csize                 !what is paper orientation, font size
                                        !values are ls,ll,ps,pl


C 1.0  Check existence of SNAP file.
      IC = TRIMLEN(CINNAME)
      INQUIRE(FILE=CINNAME,EXIST=kexist)
      IF (.NOT.kexist) THEN
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
C 2. Set up printer and write header lines

      write(luscn,9200) cinname(1:ic)
9200  format(' Printing summary of SNAP file ',a)
      call setup_printer(cpaper_size,coption(3),csize,
     >     maxwidth,maxline,ierr)

      if (ierr.ne.0) then
        write(luscn,'("LSTSUM03 - Error ",i5," setting up printer.")')
     .  ierr
        return
      endif

C
C 3. Initialize local variables 

      cexpername=' '
      cstn = ' '
      cid = '  '
      kazel=.false.
      kwrap=.false.
      kdata_start=.false.
      ksource=.false.
      kmidtp=.false.
      kdata_stop=.false.
      krunning=.false.
      counter_prev=0
      counter_now=0
      counter_data_valid_on=0

      do i=1,5
        itime_tape_stop(i)=0
        itime_tape_start(i)=0
      end do

! for mark3 or mark4, takes a second to get the tapes moving.
      if(km3rec(1) .or. km3rec(2) .or. km4rec(1).or.km4rec(2)) then
         iSpinDelay=1
      else
         iSpinDelay=0
      endif

      counter_source_p=0
      cpass_old="NO"
      cpass= " "

      idir   = 1
      speed_snap=0
      iline  = maxline
      num_tapes = 0
      num_scans = 0
      npage  = 0
      idur   =-1
      itearl_local=0
      itlate_local=0

      inewp = 0
      cnewtap = '    '
      cscan   = '     '

C 4. Set other variables by reading the .snp file or getting
C    information from common.
! This initializes a common block.
      call lstsum_info(kskd)

      kdisk=km5A.or.km5p
C
C Calculate different kinds of scaling.

C   K4 scaling factor is 55 cpd/11.25 fps if the schedule
C   was produced using sked with Mk/VLBA counter calculations
C   and no fan-out or fan-in. counters were therefore already
C   scaled by bandwidth calculations in sked.

      icode=1
      icode_old=1
      call find_recorder_speed(icode,speed_recorder,kskd)


! Initialize count counter.
      counter_now=counter_init(kdisk,kk4,ks2,MaxTap(istn))
C 5. Main loop to read .snp file and print summary of observations.

441   rewind(lu_infile)
      nline=0
      do while (.true.) ! read loop
        read(lu_infile,'(a)',err=991,end=990,iostat=IERR) ctmp_in
        if (index(ctmp_in,'scan_name=').eq.0) then
          call c2upper(ctmp_in,ctmp) ! upper-case the input
        else
          ctmp = ctmp_in
        endif
        nline = nline + 1
        if (ctmp(1:1).eq.'"') then !non-comment line
          continue
        else if(ctmp(1:10) .eq."scan_name=") then
          cscan_p=cscan                 	!save old
          nsline_p=nsline               	!save old
          read(ctmp(11:),'(a)') cscan
          i=index(cscan,",")                    !trim "," if any.
          if(i .ne. 0) cscan(i:)=" "
          nsline=nline
        else if(ctmp(1:7) .eq. "SOURCE=") then
          if(npage.eq.0) then
C           Here is where we determine early start without the schedule
            if (kskd) then ! get from common
              itearl_local=itearl(istn)
              itlate_local=itlate(istn)
            else ! calculate local ITEARL here
              itearl_local
     >          = abs(itimedifsec(itime_tape_start,itime_start))
              itlate_local
     >          = abs(itimedifsec(itime_tape_stop,itime_stop))
            endif
          endif

! get ready to output a scan (Actually output previous scan.)
          idur_p        =idur
          do i=1,5
            itime_start_p(i)     =itime_start(i)
            itime_stop_p(i)  	 =itime_stop(i)
            itime_source_p(i)	 =itime_source(i)
            itime_tape_start_p(i)=itime_tape_start(i)
            itime_source(i)	 =itime_now(i)
          end do

          ctmp_source_p	=ctmp_source
          cnewtap_p	=cnewtap             !save old
          cdir_p        =cdir
          cpass_p       =cpass

          if(tape_motion_type(istn) .eq. "CONTINUOUS" .or.
     >       tape_motion_type(istn) .eq. "ADAPTIVE") then
            counter_print_p=counter_data_valid_on
          else
            counter_print_p=counter_tape_start
          endif

          counter_source=counter_now

          idur=-1                               !recalculate for next scan.
          cnewtap= " "
C       Now get the source info for the new scan
          ctmp_source=ctmp
          ksource=.true.
        else if (ctmp(1:5) .eq.'READY') then
          cnewtap = 'XXX '
          if (index(ctmp,'READY1').ne.0) then ! rec 1
            cnewtap = 'Rec1'
          elseif (index(ctmp,'READY2').ne.0) then ! rec 2
            cnewtap = 'Rec2'
          endif
          counter_now=counter_init(kdisk,kk4,ks2,MaxTap(istn))
        else if (index(ctmp,'MIDTP').ne.0) then
          inewp = 1
          idur=-1 ! reset duration so it gets calculated again
          kmidtp=.true.
        else if (index(ctmp,'MIDOB').ne.0) then ! data start time
! Print the PREVIOUS SCAN. Need to do this becuse sometimes get
! UNLOD command after a scan, but before the data starts. This allows to
! output tape unload correctly.
          if (kdata_stop) then
            call lstsumo(kskd,itearl_local,itlate_local,maxline,
     >        iline,npage,num_scans,num_tapes,             !These are modified by this routine
     >        nsline_p,
     >        itime_start_p,itime_stop_p,
     >        itime_tape_start_p,itime_tape_stop,
     >        iDur_p,counter_print_p,cpass_p,cnewtap_p,cdir_p,
     >        cscan_p,ctmp_source_p)
          endif
          kdata_stop=.false.

! Wait till time. command.
        else if (index(ctmp,'!').ne.0) then ! time
          call snap_readTime(ctmp,itime_temp,kvalidtime)
          if(kvalidtime) then
            if(krunning) then   !if recorder is going, update count.
              dif = itimedifsec(itime_temp,itime_now)
! if mark5, should subtract 0.9 seconds from idif.
!              counter_now=counter_now+(dif-0.9)*idir*speed_recorder
              counter_now=counter_now+dif*idir*speed_recorder

            endif
            if (counter_now.lt.0) then
              counter_now=counter_init(kdisk,kk4,ks2,MaxTap(istn))
             endif
             do i=1,5
               itime_now(i)=itime_temp(i)       !update running time.
             end do
          endif
! Data start command.
        else if(ctmp(1:10) .eq. "DISK_START" .or.
     >          ctmp(1:10) .eq. "DISC_START" .or.
     >          ctmp(1:14) .eq. "DISK_RECORD=ON") then

          idur=-1 ! make sure we calculate duration from this point
          if(kdisk) idir=1  ! disks always go forward.
          do i=1,5
            itime_tape_start(i)=itime_now(i)
          end do
          krunning=.true.
          counter_tape_start=counter_now
        else if (ctmp(1:2) .eq. "ST") then
          idur=-1 ! make sure we calculate duration from this point
          do i=1,5
            itime_tape_start(i)=itime_now(i)
          end do
          if (.not.krunning) then ! this is a true start
              if(.not. ks2 .and. .not. kk4) then
                nm = index(ctmp,',') ! find the ,
                read(ctmp(nm+1:),*,iostat=ierr) speed_snap
                speed_recorder=speed_snap/12.    !convert to count.
                if (ierr.ne.0) then ! valid speed
                  write(*,*)"LSTSUM: Error reading speed ",ctmp(1:40)
                endif
              endif
              idir = 1
              nm = index(ctmp,'=') ! find the =
              cdir = ctmp(nm+1:nm+3) ! really should parse this
              if (cdir.eq.'REV') idir=-1
          else ! update counter
            continue
          endif
          krunning=.true.
          counter_tape_start  =counter_now
! Data start command.          123456789x123
        else if(ctmp(1:10).eq.'DATA START'   .or.
     >          ctmp(1:13).eq.'DATA_VALID=ON' .or.
     >          ctmp(1:14).eq.'DATA_VALID1=ON'.or.
     >          ctmp(1:14).eq.'DATA_VALID2=ON'.or.
     >          ctmp(1:5) .eq.'PREOB') then

           do i=1,5
             itime_start(i)=itime_now(i)
           end do
           if(itime_tape_start(1) .eq. 0) then
             do i=1,5
               itime_tape_start(i)=itime_start(i)
             end do
           endif

           kdata_start=.true.
           counter_prev=counter_data_valid_on           !previous start of data.
           counter_data_valid_on=counter_now
        else if (ctmp(1:2) .eq. 'ET' .or.
     >           ctmp(1:10) .eq. 'DISK_END' .or.
     >           ctmp(1:10) .eq. 'DISC_END' .or.
     >           ctmp(1:15) .eq. 'DISK_RECORD=OFF') then
          krunning = .false. 
          kdata_stop=.true.
          do i=1,5
            itime_tape_stop(i)=itime_now(i)
          end do
          if (idur.eq.-1) then ! no dur yet this scan
            idur = itimedifsec(itime_tape_stop,itime_start)
C           Update running time
          endif ! no dur yet this scan
        else if(ctmp(1:5) .eq. 'UNLOD') then
          kunload=.true.
        else if (index(ctmp(1:15),'DATA_VALIDA=OFF').ne.0  .or.
     .           index(ctmp(1:15),'DATA_VALIDB=OFF').ne.0  .or.
     .           index(ctmp(1:10),'"DATA STOP').ne.0.or.
     .           index(ctmp(1:6),'POSTOB').ne.0) then ! data stop time
          kdata_stop=.true.
          do i=1,5
            itime_stop(i)=itime_now(i)
          end do

          if (idur.eq.-1) then ! no stop yet
            idur = itimedifsec(itime_stop,itime_start)
          endif ! no stop yet
        else if (ctmp(1:4) .eq. 'FAST'.or.
     >           ctmp(1:5) .eq. 'SFAST') then !add spin count
C         examples: fastf=3m42.34s   fastr=2.35m   fastf=34.56s
          krunning=.false.      !recorder is stopped after this command.
          ne = index(ctmp,'=')
          nm = index(ctmp,'M')
          if (nm.gt.0) then ! "M" found
            read(ctmp(ne+1:nm-1),*) temp
            ifdur = ifix(60.0*temp)
          else
            nm=ne
            ifdur=0
          endif ! "M" found
          l=trimlen(ctmp)
          read(ctmp(nm+1:l-1),*) temp

          rifdur = ifdur + temp -iSpinDelay ! seconds of time for spin

          if(ctmp(1:1) .eq. "S") then
             spin_speed=27.5                  !330 ips
          else
             spin_speed=22.5                  !270 ips
          endif
          ifdur=rifdur*Spin_Speed

          id=+1
          if (ctmp(5:5).eq.'R') id=-1
          if (counter_now.gt.0) counter_now=counter_now+ifdur*id
          if (counter_now.lt.0) then          !if spins us off, then reset tape to 0.
            counter_now=counter_init(kdisk,kk4,ks2,MaxTap(istn))
          endif

! If the last source command was within 5 minutes, command is probably meant to position tape to start of scan.
          if(itimedifsec(itime_now,itime_source) .le. 300) then
            counter_source=counter_now
          endif

! update itime_now because of command.
          itemp=ifix(rifdur)
          call timeadd(itime_now,itemp,itime_now)

C If there was a recent MIDTP then assume that this FASTR is meant to return
C the counter to zero to start the new forward pass.
!
!          if (id.eq.-1 .and. kmidtp) then
!             count_now=counter_init(km5,kk4,ks2,MaxTap(istn))
!             kmidtp=.false.
!          endif ! this was FASTR

        else if (ctmp(1:5) .eq. 'CHECK') then
          cnewtap = ' *  '
        else if (ctmp(1:5) .eq. "SETUP" .and. kskd) then  !We get code info from Setup. Can only do if have sked file.
          do itemp=1,NCodes
             call c2upper(ccode(itemp),ccode_Tmp)
             if(ccode_tmp .eq. ctmp(6:7)) then
                 icode=itemp
                 if(icode .ne. icode_old) then
                   call find_recorder_speed(icode,speed_recorder,kskd)
                   write(cnewtap,"('Mode',i2)") icode
                   icode_old=icode
                 endif
             endif
           end do
        else if (index(ctmp,'=').ne.0) then !might be setup proc
          if (index(ctmp,'DATA_VALID').eq.0.and.
     .        index(ctmp,'ST1=').eq.0.and.index(ctmp,'ST2=').eq.0) then ! setup
            ieq = index(ctmp,'=')
            cpass_old=cpass ! previous pass
            cpass = '  '
            cpass = ctmp(ieq+1:ieq+2)
            if (cpass(2:2).eq.' ') then ! shift right
              cpass(2:2)=cpass(1:1)
              cpass(1:1)=' '
            endif ! shift right
            if (ks2.and.cpass.ne.cpass_old) then
              counter_now=counter_init(kdisk,kk4,ks2,MaxTap(istn))
            endif
          endif ! setup
        endif ! might be setup proc

      enddo !read loop

990   continue
      ierr=0

!      counter_print=counter_data_valid_on
       if(tape_motion_type(istn) .eq. "CONTINUOUS" .or.
     >       tape_motion_type(istn) .eq. "ADAPTIVE") then
          counter_print=counter_data_valid_on
       else
            counter_print=counter_tape_start
       endif



      call lstsumo(kskd,itearl_local,itlate_local,maxline,
     >        iline,npage,num_scans,num_tapes,             !These are modified by this routine
     >        nsline,
     >        itime_start,itime_stop,
     >        itime_tape_start,itime_tape_stop,
     >        iDur,counter_print,cpass,cnewtap,cdir,
     >        cscan,ctmp_source)

      write(luprt, "()") ! skip line
      if(kdisk) then
         write(luprt,'("   Total",f8.1, " Gbytes")') counter_print/1000
      else
        write(luprt, '("   Total number of tapes: ",i3)')num_tapes
      endif
      write(luprt,   '("   Total number of scans: ",i5)')num_scans

      call luff(luprt)
      close(luprt)
      if(csize(1:1) .eq. "L") then
        call prtmp(1)
      else
        call prtmp(0)
      endif

991   if (ierr.ne.0) then
         write(luscn,9900) ierr
9900     format('LSTSUM04 - Error ',i5,' reading SNAP file.')
        return
      endif

      RETURN
      end
