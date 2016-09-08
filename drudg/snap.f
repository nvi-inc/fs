        SUBROUTINE SNAP(cr2)
C
C     SNAP reads a schedule file and writes a file with SNAP commands
C
      include 'hardware.ftni'           !This contains info only about the recorders.
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/constants.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'   !This includes info about

C INPUT
      character*(*) cr2  ! Responses to three prompts for
C          1) epoch 1950 or 2000 <<<<<<< moved to control file
C          2) add checks Y or N <<<< not for S2
C          3) force checks Y or N <<<<<<< removed

! functions
      integer iTimeDifSec               !difference in seconds between two times
      real   speed ! functions
      integer trimlen ! functions
      integer julda

C  LOCAL:
C     IFTOLD - foot count at end of previous observation
C     TSPINS - time, in seconds, to spin tape

! Arguments to UNPSK
      integer ilen
      integer*2 lsname(max_sorlen/2)
      integer   ical
      integer*2 lfreq
      integer ipas(max_stn)
      integer ift(max_stn)
      integer*2 lpre(3),lmid(3),lpst(3)
      character*6 cpre,cmid,cpst
      equivalence (lpre,cpre),(lmid,cmid),(lpst,cpst)
      integer   nstnsk
      integer*2 lstn(max_stn)
      integer*2 lcable(max_stn)
      integer*2 ldir(max_stn)
      double precision ut,gst
      integer mjd,mon,ida
      integer*2 lmon(2),lday(2)
!      logical kflg(4)
      integer ierr
    
      integer isec_beg,isec_end   !integer part of disk2file offset
      real    rsec_beg,rsec_end   !total seconds part of disk2file beg or end
      integer idur(max_stn)

      integer ioff(max_stn)

      character*2 ccable(max_stn)
      equivalence (ccable,lcable)
      character*2 cdir(max_stn)
      equivalence (cdir,ldir)

      character*(max_sorlen) csname
      character*2 cstn(max_stn)
      character*2 cfreq
      equivalence (csname,lsname),(lstn,cstn),(cfreq,lfreq)

! Arguments to UNPSK for the next scan
      integer*2 ibuf_next(ibuf_len)
      integer ilen_next
      integer*2 lsname_next(max_sorlen/2)
      integer   ical_next
      integer*2 lfreq_next
      integer ipas_next(max_stn)
      integer ift_next(max_stn)
      integer*2 lpre_next(3),lmid_next(3),lpst_next(3)
      character*6 cpre_next,cmid_next,cpst_next
      equivalence (lpre_next,cpre_next),(cmid_next,lmid_next)
      equivalence (lpst_next,cpst_next)
      integer   nstnsk_next
      integer*2 lstn_next(max_stn)
      integer*2 lcable_next(max_stn)
      integer*2 ldir_next(max_stn)
      double precision ut_next,gst_next
      integer mjd_next,mon_next,ida_next
      integer*2 lmon_next(2),lday_next(2)
      logical kflg_next(4)
      integer ierr_next   
      integer ilast_wait_time(5)
      integer idur_next(max_stn)
      integer ioff_next(max_stn)

      character*(ibuf_len*2) cbuf_next
      equivalence (ibuf_next,cbuf_next)

      character*2 cdir_next(max_stn)
      equivalence (cdir_next,ldir_next)

      character*(max_sorlen) csname_next
      character*2 cstn_next(max_stn)
      character*2 cfreq_next
      equivalence (csname_next,lsname_next),(lstn_next,cstn_next)
      equivalence (cfreq_next,lfreq_next)
      character*2 cstat_code
! End arguments to unpsk

! Other variables dealing with next scan
      integer istnsk_next,isor_next,icod_next

      integer istnsk,isor,icod

      integer*2 ldirp,lds
      character*2 cds,cdirp
      equivalence (lds,cds)
      equivalence (cdirp,ldirp)
      character*8 cmodep          !previous mode
    
      character*8 cspeed          !speed of the recorder in ascii IPS or SLP for S2

      integer iobs_now,iobs_this_stat,iobs,iobsp,iobs_this_stat_rec

      integer iblen,icheck,icheckp,isorp,ipasp,kerr

! Stuff dealing with datatransfer
      logical kin2net,kdisk2file   !data transfer options
      logical kdisk2file_prev
      logical kdata_xfer_prev
      character*128 ldest          !destination
      integer ixfer_ptr !points to the appropriate plac

!  Variables dealing with source position
      integer irah,iram,iras,iras_frac,idcd,idcm,idcs,idcs_frac
      real ras,dcs
      double precision SORRA,SORDEC
      double precision TJD
      logical kup
      real az,el,x30,y30,x85,y85,ha1,dc
! end source position.

      integer nch,nch2,nch3

      integer l,idirp,idurp,iftchk,idirn,iftrem,ilatestop
      integer ic,ichk,iset,isppl,mjdpre

      real d,epoc,tslew,dum
      integer itemp                  !short lived temporary variable
      logical kdo_monitor            !used as flag to determine if we should do a monitor. 
      logical kPhaseRefNext          !Phase reference data.  No stop between this scan and next scan.
      logical kPhaseRefPrev          !Phase reference data.  No stop between this scan and previous scan. 
 
      integer*2 lcbpre,lcbnow        !must be integer*2

      integer idt,ituse
      double precision utpre
C     character*28 cpass,cvpass  

C     LMODEP - mode of previous observation
C     LDIRP  - direction of previous observation
C     IPASP - previous pass

C     IOBSP - number of obs. this pass
C     IOBS - number of obs in the schedule
C     iobs_this_stat - number of obs for this station
C     iobs_this_stat_rec - number of obs for this station that are recorded on tape

      character*7 cwrap ! cable wrap from CBINF
      character*8 cwrap2
      logical KNEWTP
C      - true if a new tape needs to be mounted before
C        beginning the current observation

      logical krec  ! true if the recorder is NOT "none"
      integer ntape ! count of tapes used in the schedule
      character*12 csetup_name

! JMG variables
      integer iwait5sec
      parameter (iwait5sec=5)
      integer itime_scan_end(5)             !end of scan    =istart+idur
      integer itime_early(5)                !early start    =istart-itearl
      integer itime_tape_stop(5)            !late end       =iend+ilate
      integer itime_cal(5)         	    !cal		=istart-ical
      integer itime_check(5)                !time to do a check.
      integer itime_tape_start(5)           !
      integer itime_data_valid(5)           !when is the scan valid?
   !
      integer itime_scan_beg_prev(5)        !ditto for previous measurement
      integer itime_scan_end_prev(5)
      integer itime_early_prev(5)
      integer itime_tape_stop_prev(5)
      integer itime_data_valid_prev(5)      !
      integer itime_scan_beg_next(5)
      integer itime_scan_beg(5)   !iyr,iday,ihr,imin,isec
      integer itime_disk_abort(5) !time to end disk2file
      integer itime_disk2file_beg(5)
      integer itime_disk2file_end(5)

      integer itime_pass_end(5)              !Time when we reach the end of this pass
      real    speed_ft          !Speed in feet.
      real    rmax_scan_time    !Length of scan in time.
      integer icod_old          !previous code.

! Following are used in continuous/adaptive recording to keep track of:
! A.) Scan starting time.
! B.) Total time (seconds) until recording stops.
! C.) 
      integer itime_beg(5,Max_obs)        !     Time each scan begins
      integer itime_total_record(Max_obs) !     Total time from scan until recording stops
      integer iscan_calc_start            !     Scan to start calculating recording time on
      integer lu_in                       !     Logical lus
      character*128 ltmpfil               !     temporary file
      integer i1,i2                       !     temporary ints
    
! Logical variables
      logical kcont 		! true for CONTINUOUS recording
      logical kadap 		! true for ADAPTIVE recording in VEX file
      logical kcontpass       	! true if a pass is actually continuous
      logical kcontpass_prev    ! Continuous before this obs?
      logical knewpass  	! true if this obs on new pass.
      logical kfirst_tape       ! first tape
      logical klast_obs         ! doing last observation
      logical kfirst_obs   
     
!
      character*180 ldum
      character*60  lscan_name
      character*12 lsession      !filename
      
      double precision speed_recorder   ! speed of recorder in this mode.

! counter
      integer i,j               !counters
      logical kdebug
C
C  INITIALIZED:
      DATA cdirp/"  "/
C     data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
C     data cvpass /'abcdefghijklmnopqrstuvwxyzAB'/
C
C History:
C     NRV 830818 ADDED SATELLITE ORBIT COMMAND OUTPUT
C     NRV 840501 ADDED CHECK PROCEDURE, ADDED INTRO LINE
C     MWH 840813 FIXED ERROR CHECKING DURING SNAP FILE WRITING
C     NRV 890223 ADDED 2000 OPTION FOR POSITIONS
C     NRV 890321 If "check" flag is Y, do check only before second
C                obs of a pass.
C                Restore rewind on mode A tapes, but only for low
C                density stations.
C     NRV 890505 CHANGED DUR TO AN ARRAY BY STATION
C     MWH 890525 CHANGED TO CI OUTPUT
C     NRV 890613 PARITY CHECKS ALWAYS DONE IF ENOUGH TIME, USING
C                PARITY+SETUP FROM PARAMETER SECTION OF SCHEDULE.
C                CHANGED INDEX IN MAXPAS TO ISTN, NOT ISTNSK (WHICH
C                IS FOR THIS OBSERVATION ONLY).
C     NRV 900413 Added BREAK.
C     gag 901017 Moved header information to subroutine snapintr
C     NRV 901205 Added prompts for 1950 or 2000, additional checks
C     NRV 910306 Added "early start" algorithm changes
C     NRV 911101 Fixed too few checks for full length scans by
C                adding CHECK and CHECKP variables
C     nrv 930407 implicit none
C     nrv 930526 Add !+5S after FASTx if ST follows
C     nrv 930823 Mode A has only one setup procedure
C     nrv 940131 Write the cable wrap indicator at the end of SOURCE= line
C     nrv 940520 Changed output of satellite observations to write a
C                SOURCE=AZEL,<az>,<el> line instead of ra,dec
C     nrv 940610 Add a "D" to the az,el values
C     nrv 940622 Use cr1,cr2,cr3 already specified non-interactively.
C 951226 nrv New setup names for FS9/Mk4/VLBA. Remove speed from ST=.
C 951228 nrv Add speed back to ST=.
C 960116 nrv Select from a fixed list of speeds for the ST= command,
C            via new SPDSTR routine.
C 960126 nrv Always put the pass number on the setup command. No
C            remaining stations with low density tapes.
C 960201 nrv Change output to all lower case
C 960223 nrv Call chmod to change permissions.
C 960810 nrv Change itearl to an array
C 960810 nrv Add S2 changes. Add more comments.
C 960912 nrv Add LOADER if S2 group changes, other changes per Ed's
C            memo about SNAP for S2.
C 960913 nrv Don't try to calculate late stop on first obs.
C 960913 nrv Put TAPE commands at all ST's for S2 too.
C 961003 nrv Take a look at the second observation's cable wrap to
C            see if the first wrap needs to be corrected. *NOT FINISHED*
C 961031 nrv Add "iin" to calling sequence. iin=1 is Mk3/4 SNAP file
C            with speeds 135/270, iin=2 is VLBA back end with NDR
C            densities possible. Modify bit density in common based
C            on this input.
C 961126 nrv Reinitialize the TSPINS after a READY even if there was no
C            spin for the new tape.
C 970114 nrv Change 8 to max_sorlen
C 970130 nrv Change logic to have the next scan available, to check for
C            whether to stop the tape for continuous tape motion. 
C            This fixes a problem with ET for S2 schedules, where ET 
C            could not be issued at all unless itlate was non-zero.
C 970131 nrv Compute other times that are needed to determine whether
C            to stop the tape for adaptive.
C 970204 nrv Remove the +3 sec in calculating enough time for parity.
C 970206 nrv Remove query about 1950/2000 and put into control file.
C 970206 nrv Remove query about forcing parity checks.
C 970213 nrv Check for "adaptive" in both upper and lower case.
C 970213 nrv Add a wait until data-stop+late-stop before ET for S2.
C 970214 nrv Find out equipment type at start, before prompts.
C            Don't tell or ask about parity checks for S2.
C 970221 nrv When checking for enough time for parity, don't add in
C            setup time if we're not going to be doing setup.
C 970224 nrv Move PREPASS to after READY (it was after UNLOD)
C 970307 nrv For S2, don't issue two ET commands!
C 970307 nrv Use the ISKREC pointer array to insure time order of obs.
C 970311 nrv Always issue ST at either early start or data start, even
C            if adaptive tape motion and it has not stopped.
C 970317 nrv Trying continuous 
C 970319 nrv We'll get it right eventually. Do ST= either at early start
C            time or at data start time regardless of whether running.
C 970320 nrv Calculate adjusted times for continuous recording.
C 970320 nrv Precess the sources so we can calculate slewing.
C 970321 nrv No extra ST commands, no setup, for continuous.
C 970508 nrv Temporary change to calculate final tape stop for continuous
C            motion from initial start of the pass. This is because sked
C            is not getting the footages right on all the scans.
C 970513 nrv Set up new cable wrap from schedule before calling slewo.
C 970716 nrv Use subpass on CHECK, not direction
C 970718 nrv Put CHECK back the way it was, until automatic procedure
C            making for checks is in place. Existing procedures are set
C            up for forward/reverse and can't be changed.
C 970721 nrv Remove holleriths for FOR/REV/F/R and replace with strings.
C 970721 nrv Change first parameter in LSPIN to IDIR.
C 970721 nrv If scan has zero direction, don't do any tape motion commands.
C 970728 nrv No setup or preob for adaptive if the tape is running.
C 970729 nrv Compute good data start using offsets in VEX file
C 970730 nrv Don't write extra !time and TAPE for continuous scans.
C 970731 nrv Add iobs_this_stat_rec to count number of obs recorded on tape
C 970909 nrv Do PREOB if it's not a VEX file, only skip it if the
C            tape is continuously running.
C 970915 nrv When spinning a new tape forward to start on a non-zero
C            footage, always do a FASTF instead of using the direction
C            of the first scan which may be in the reverse direction.
C 970915 nrv In the loop searching for the first scan, check the error
C            return in case there are no scans on this station.
C 970915 nrv Add VLBA4 option.
C 970929 nrv Calculate ift_save only for non-S2. 
C 970929 nrv Calculate slewing time only for continuous motion.
C 971003 nrv For the last scan, don't stop if there's late stop.
C 971027 nrv Force direction to REV for FASTx command before UNLOD.
C 971028 nrv Force new tape for first scan of a schedule (this was
C            needed for S2 in case it starts in the middle of a tape).
C 971205 nrv Change "data start" to "data_valid=on" and "data stop" to
C            "data_valid=off"
C 971205 nrv Change CHECK2C1/2 to CHECKF/R 80 or 135.
C 971208 nrv The "data_valid" before and after midob are non-S2 only.
C 971209 nrv Reverse READY and SETUP procedures.
C 971209 nrv Confirm that user really wants prepass in the schedule.
C 971211 nrv Change some kadap logic to take care of the case when there
C            is no "next" scan. Remove "time5" calculation because it is
C            never used.
C 980218 nrv Add "iin" option 3 for K4 variants.
C 980831 nrv Improve the separate check for new tape with S2.
C 980910 nrv Remove all time formatting to a subroutine timout.
C 980916 nrv Change CHECK back to 2c1/2 until automatic checks are ready.
C 980917 nrv Change "data_valid" back to comments until command is ready.
C 981016 nrv Now can use data_valid command and checkf
C 990112 nrv Add REC=DRUM_ON before PREOB for K4 recorders.
C 990113 nrv Add "iin" option 4 for K4 type 2, option 5 other K4. Disable 3.
C 990304 nrv Move K4 drum on command before the ST for early start.
C 990524 nrv Add S2 non-VEX option. Add kk4,ks2 to snapintr call.
C 990715 nrv Do a SETUP for every scan for S2. Remove duplicate data_valid
C            =off for S2.
C 990716 nrv Don't fastr the tape to unload it if it's CONT.
C 990803 nrv Do a SETUP before READY if it's the first tape.
C 990901?nrv Remove iin=2 as an option because difference with VLBA
C            racks is no longer important.
C 990914 nrv Abort if there is an illegal head/pass.
C 991102 nrv Removed IIN options. Move prompts for maxchk and dopre to
C            subroutine SNAP_INFO. Remove kk4,ks2 from SNAPINTR call.
C            Move setup name generation to SETUP_NAME. 
C 991102 nrv Dual recorder mode. Recorders 1 and 2 (not A and B). Add crec
C            to LSPIN call.
C 991206 nrv Reverse f/r and 80/135 to make e.g. check80f.
C 991207 nrv Use PREPASSTHIN for thin tapes.
C 991208 nrv Count the tapes as READY is done. Add ready=n, unlod=n for K4.
C 991210 nrv Don't switch recorders until after the 'et' after SOURCE.
C 000315 nrv Don't put in the wait-until and "data_valid" if the time
C            is later than the scan.
C 000509 nrv Add call to S2INTRO from C. Klatt.
C 000522 nrv Add scan_name command, just before the SOURCE= command.
C 000602 nrv Add call to SNAME to set up scan name.
C 000623 nrv Remove DRUM_ON command.
C 000905 nrv Save _old info about S2 and K4 so that these can be a
C            used as mixed dual recorders.
C 001013 nrv Remove condition that no times are changed if it's a
C            new tape in continuous mode.
C 001109 nrv scan_name array is character.
C 001113 nrv Test for same pass, not same direction, in continuous.
C 010207 nrv Add UNLOADER/LOADER for S2 for group changes
C 010208 nrv Do parity checks only if the scan duration is long enough, and
C            if it's not then keep trying on that pass.
C 010508 nrv At the end of the scan, utpre was having idur added again.
C            but time4 already has it. This was causing some timing
C            events to be issued at incorrect times for the next scan. 
C 010726 nrv Add SCHED_END at the end of the file.
C 010820 nrv Don't append to rec commands if one of the recorders is none.
C 010831 nrv Send krec_append to LSPIN.
C 010927 nrv Initialize kk4_old and ks2_old, even if there are not two recs.
C 011130 nrv Force S2 tape stop if mode change.
C 020111 nrv Don't use early start time if tape is already running (JQ).
C 020304 nrv Add for Mk5 piggyback mode: READY_DISK, DISK_POS, DISK_START,
C            DISK_END,DISK_CHECK.
C 020923 nrv Recognize km5rec and don't put in any tape commands for Mk5-only.
C            Do early start for Mk5 if it's in the schedule.
C 021010 nrv Do post-pass for all thin tapes if the postpass flag is true. 
C            Postpass flag is set true for astro VEX schedules as default.
C 021011 nrv Add one more digit to output of RA seconds.
C 021014 nrv Change LSPIN and TSPIN "seconds" argument to real.
C 021017 nrv Use FSPIN for superfast tape spinning.
C 021021 nrv If last pass of a tape scheduled as ADAPTIVE is actually 
C            continuous, then don't need to postpass.
C 021111 jfq Add klrack into set_type call.

C 2003Jun11 JMGipson. Fixed bug with kcontpass. kcontpass was "off by 1".
C                     Solved by using kcontpass_old
C 2003Sep04 JMGipson. Added postob_mk5a for mark5a modes.
C 2004Jul13 JMGipson. Fixed bug in scan names.
! 2004Sep13 JMGipson.  Add midtape command for Mark5.
! 2004Nov17 JMGipson.  added data_valid=on,off if recorder is "none".
!   "                  For in2net, changed postob_mk5a to postob
! 2004Nov22-23 JMG    Fixed bug in S2 adaptive schedules. Drudg issued stop commands
!                     when it shouldn't have.
!                     Also stopped issuing st=for,slp commands in s2 case if tape is moving.
!
! 2005Feb15  JMG    Added "KK5" Data recorder. Same as "none" except issues
!                   ready_k5 after first source=, and checkk5 where checkmk5a is issued.
! 2005Apr22  JMG got rid of apstar code which converted from radians to HA, Dec, called apstar, and then
!                   converted back again. Used apstar_rad routine.
! 2005Oct26  JMGipson. Bug in writing out scan name.
!            Previously used scan_name(obs_now), but should have been scan_name(iskrec(obs_now))
! 2006Jun13  JMG.  Modified scan name to include station code.
!                  Changed default disk2file name to be: session_station_scanname.m5a
! 2006Jul17  JMG.  Fixed problem with icod_next was not initialized. Led to problems in linux version.
! 2006Jul18  JMG. To see if Mark5, was doing check on cstrec(irec). Should have been on cstrec(istn). Fixed.
!                 In writing scan_name, was using cpocod(istnsk), should have been using cpocod(istn)
! 2006Jul24  JMg. Fixed problem with adaptive.  When doing Mark5 and continous schedules, checks to see
!                 if correlator is VLBA before changing.
! 2006Jul28  JMG. Changed to make station code 3rd parameter in scan_name
! 2006Nov30  JMG. Fixed bug if recorder is "none".
!                 Use cstrec(istn,irec). Previously had two arrays
! 2007Dec03  JMG. Used to set itearl, itgap if correlator was VLBA. Now assume schedule does this.
! 2007Dec07  JMG. Got rid of last  postob_mk5
! 2007Dec11  JMG. IF idir=0 is now a flag for "don't record".
!                 In this case, don't output preob,midob,postob
! 2007Dec12 JMG.  Don't emit time for scan_Begin if not recording.
! 2007Dec27 JMG.  Moved ready_disk before 1st setup
! 2007Feb01 JMG.  "Checkm5" had clued off of "iobs_this_stat<>0". This didn't work if first
!                 several scans were not recored. Chagned to "iobs_this_stat_rec<>0".
! 2008Mar19 JMG.  Don't issue setup if recording.
! 2013Jan18 JMG.  Added in auto_ftp_abort_time. Will abort auto_ftp if longer than some specified time.
! 2013Jan22 JMG.  Don't do POSTOB if a a vex file and recording. (used for phase reference.) 
! 2014Jan17 JMG.  Modified call to setup_name   
! 2014Jan21-31 JMG.  Commented out various calls referencing tapes.        
! 2014Feb04 JMG. Introduced kphase_ref flag. This is true if the next scan starts IMMEDIATELY after the previous.
! 2015Mar10 JMG. A.) Set krunning=false after taking data. 2) Don't do setup if system is running. Theser were lost from 11.4-->11.5 
! 2015Mar30 JMG. Removed obsolete arg from drchmod.
! 2015Mar31 JMG. More changes to fix issues with phase_reference.
! 2015Apr04 JMG. Removed special handling if same source in consecutive scans. 
! 2015Jun05 JMG. Replaced squeezewrite by drudg_write. 
    
      kdebug=.false.
      kfirst_obs=.true. 
      klast_obs=.false. 

      icod_old=-1
      iblen = ibuf_len*2
      if (kmissing) then
        write(luscn,'(a)')
     >  ' SNAP00 - Missing or inconsistent head/track/pass information.'
        write(luscn,'(a)')
     >  ' Your SNAP file may be incorrect or  cause a program abort.'
      endif

      if(cstrack(istn) .eq. "unknown" .or.
     >    cstrec(istn,1) .eq. "unknown") then
        write(luscn,'(a)')
     >  ' SNAP01 - Rack or recorder type is unknown. '
        write(luscn, '(a)')
     >  '   Please  specify your equipment using Option 11 or'//
     >  '  the EQUIPMENT line in the  control file.'
        return
      endif

      call strip_path(lskdfi,lsession)
      nch=index(lsession,".")
      lsession(nch:12)=" "

      call init_hardware_common(istn)
      MaxTapeLen=MaxTap(istn)
      kcontpass=.true.  !Passes always start out as continous.
      kcontpass_prev=.true.
      kfirst_tape=   .true.
      kdisk2file_prev=.false.
      idirp=1           !

      iscan_calc_start=1      !which scan do we start calculating recording differences on

      WRITE(LUSCN,'("SNAP output for ", a)') cSTNNA(ISTN)
      ierr=1

      if (cfirstrec(istn)(1:1) .eq. "1") then
        irec=1
      else ! second recorder
        irec=2
      endif
C Initialize recorder information.
      ks2 = ks2rec(irec)
      kk5 = kk5rec(irec)
      krec= .not.(knorec(irec) .or. kk5rec(irec))

C    1. Prompt for additional parameters, epoch of source positions
C    and whether maximal checks are wanted.
  

C     1. Create output file for SNAP commands.  If problems, quit.
C     check to see if the file exists first, and if so, purge it.
      call purge_file(snpname,luscn,luusr,kbatch,ierr)
      if(ierr .ne. 0) return

      lufile=lu_outfile

      WRITE(LUSCN,*) "Translation for ", cstnna(istn)
      write(luscn,*) "  From file: ",lskdfi(1:trimlen(lskdfi)),
     >  " To snap file: ",        SNPNAME(1:trimlen(snpname))

      open(unit=lufile,file=SNPNAME,status="NEW",iostat=IERR)
      IF (IERR.eq.0) THEN
        rewind(lufile)
      ELSE
        WRITE(LUSCN, "(' SNAP02 - Error ',I6,' creating file ',A)")
     >    IERR,SNPNAME(1:trimlen(snpname))
        return
      END IF
C
C     2. Initialize counts.  Begin loop on schedule file records.
C
      IOBSP = 0
      iobs_this_stat=0
      iobs_this_stat_rec=0

      icheck=0
      icheckp=0
      cmodep=" "
      IPASP = -1
      IFTOLD = 0
      kerr=0
      ilen = 999
     
      kstop_tape = .false.
      krunning = .false.
      ilatestop=0
      istnsk=0
      ntape=0

      do i=1,5
        itime_scan_beg_prev(i)=0
        itime_scan_beg_next(i)=0
      end do

      icod_next=1   !initialize

      kadap= (tape_motion_type(istn).eq.'ADAPTIVE')
      kcont= (tape_motion_type(istn).eq.'CONTINUOUS')

      do i=1,max_stn
        cstn(i)=" "          !initialize
        cstn_next(i)=" "     !ditto
      end do
      iobs=0
      do while (istnsk.eq.0.and.ilen.ge.0) ! Get first scan for this station into IBUF
        cbuf=" "
        IOBS = IOBS + 1
        if (iobs.le.nobs) then
          cbuf=cskobs(iskrec(iobs))
          ilen=trimlen(cbuf)
          CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     >      itime_scan_beg(1),itime_scan_beg(2),itime_scan_beg(3),
     >      itime_scan_beg(4),itime_scan_beg(5),
     >      IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     >      MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
          call ckobs(csname,cstn,nstnsk,cfreq,isor,istnsk,icod)
          IF (ISOR.EQ.0.OR.ICOD.EQ.0) RETURN
        else
          ilen=-1
        endif
      enddo ! get first scan for this station into IBUF

C  Precess the sources to today's date for slewing calculations.
      TJD = JULDA(MON,IDA,itime_scan_beg(1)-1900) + 2440000.0D0
      DO I=1,NCELES
        call apstar_Rad(tjd,sorp50(1,i),sorp50(2,i),
     >         sorpda(1,i),sorpda(2,i))
      enddo

      call snapintr(1,itime_scan_beg(1))
   
      DO WHILE (ILEN.GT.0.AND.KERR.EQ.0.and.ierr.eq.0 .AND.
     >             cbuf(1:1) .ne. "$")  
        istnsk_next=0
        iobs_now = iobs ! save current obs number for scan ID
        do while (istnsk_next.eq.0) ! Get NEXT scan for this station into ibuf_next
          cbuf_next=" "
          IOBS = IOBS + 1
          if (iobs.le.nobs) then
            cbuf_next=cskobs(iskrec(iobs))
            ilen_next=trimlen(cbuf_next)
            CALL UNPSK(IBUF_next,ILEN_next,LSNAME_next,ICAL_next,
     >        LFREQ_next,IPAS_next,LDIR_next,IFT_next,LPRE_next,
     >        itime_scan_beg_next(1),itime_scan_beg_next(2),
     >        itime_scan_beg_next(3),
     >        itime_scan_beg_next(4),itime_scan_beg_next(5),
     >        IDUR_next,
     >        LMID_next,LPST_next,NSTNSK_next,LSTN_next,LCABLE_next,
     >        MJD_next,UT_next,GST_next,MON_next,IDA_next,
     >        LMON_next,LDAY_next,IERR_next,KFLG_next,ioff_next)
            CALL CKOBS(cSNAME_next,cSTN_next,NSTNSK_next,cFREQ_next,
     >        isor_next,ISTNSK_next,ICOD_next)
            IF (ISOR_next.EQ.0.OR.ICOD_next.EQ.0) RETURN
          else
            ilen=-1         
            klast_obs=.true.
            istnsk_next=999
          endif
        enddo ! get NEXT scan for this station into ibuf_next

       
! Here we see if we have a data transfer scan.
! See if have data transfer statements.
        kin2net=.false.
        kdisk2file=.false.    
        
        if(.not.kno_data_xfer .and. 
     >     (kstat_in2net(istn) .or. kstat_disk2file(istn))) then
          if(km5disk .and. ixfer_beg(iobs_now) .ne. 0) then
            do i=ixfer_beg(iobs_now),ixfer_end(iobs_now)
               if(istn .eq. ixfer_stat(i)) then
                  ixfer_ptr=i
                  ldest=lxfer_destination(ixfer_ptr)
                  if(ixfer_method(i) .eq. ixfer_in2net) then
                    if(kin2net_2_disk2file) then
                      kdisk2file=.true.
                      ldest=" "
                    else
                      kin2net=.true.
                      if(kglobal_in2net) then
                         ldest=lglobal_in2net
                      endif
                    endif
                  else if(ixfer_method(i) .eq. ixfer_disk2file) then
                    if(kdisk2file_2_in2net) then
                       kin2net=.true.
                       ldest=ldestin_in2net
                       if(kglobal_in2net) then
                         ldest=lglobal_in2net
                       endif
                    else
                       kdisk2file=.true.
                    endif
                  else
                    write(*,*) "Unknown data transer"
                  endif
                  goto 111
               endif
            end do
          endif
111       continue
        endif
C
        IF (ISTNSK.NE.0)  THEN ! our station is in this scan
          if(cdir(istnsk)(1:1) .eq. "R") then
             idir=-1
          else if(cdir(istnsk)(1:1) .eq. "F") then
             idir=1
          else if(cdir(istnsk)(1:1) .eq. "0") then
             idir=0
          endif
          if(cdir_next(istnsk)(1:1) .eq. "R") then
             idirn=-1
          else if(cdir_next(istnsk)(1:1) .eq. "F") then
             idirn=1
          else if(cdir_next(istnsk)(1:1) .eq. "0") then
             idirn=0
          endif

C****************************************************************
C This is the confusing part where certain timings are set up,
C depending on the type of tape motion. This part needs to be
C cleaned up and rationalized when sked and sched are both using
C the same logic.
C****************************************************************
C  2.5  Calculate all the times and flags we will need. 

C  Does this obs start a new tape?

C         Force new tape on the first scan on tape.
          if (iobs_this_stat_rec.eq.0) knewtp=.true.

          if(iobs_this_stat_rec .gt. 0) then
            call copy_time(itime_early,     itime_early_prev)
            call copy_time(itime_scan_beg,  itime_scan_beg_prev)
            call copy_time(itime_scan_end,  itime_scan_end_prev)
            call copy_time(itime_tape_stop, itime_tape_stop_prev)
            call copy_time(itime_data_valid,itime_data_valid_prev) 
          endif
          kcontpass_prev=kcontpass

          if(knewtp .or. icod .ne. icod_old) then
            speed_ft=speed(icod,istn)
            rmax_scan_time=maxtap(istn)/speed_ft        !time in seconds for scan
            if(krec) then
              call snap_recalc_speed(luscn,kvex,speed_ft,cs2speed(istn),
     >          cspeed, ierr)
              if(ierr .lt. 0) then
                write(luscn,'("Illegal speed! ",f6.2)') speed_ft*12.d0
                write(luscn,'("After: ",a)') cbuf(1:80)
                stop
               endif
            endif
            icod_old=icod
          endif

          kNewPass = (ipasp.ne.ipas(istnsk))       
    
! Data end time=itime_scan_beg+duration.
          call TimeAdd(itime_scan_beg,idur(istnsk),itime_scan_end)
! Cal time= itime_scan_beg-ical
          call TimeSub(itime_scan_beg,ical,itime_cal)

          kPhaseRefPrev=.false.
          
          if(iobs_this_stat .gt. 0) then 
! itime_disk_abort=itime_scan_beg-(ical+isettm+5)     
! Calculate how much time we have.                          
            idt=iTimeDifSec(iTime_scan_beg,iTime_scan_end_prev)
            kPhaseRefPrev= idt .eq. 0
 ! Calculate time to abort autoftp for previous scan. Only need to do if a previous scan.   
            idt=idt-(isettm+ical+5)     !isettm is time for setup. 
                                        ! 5 is for execution of disk2file         
            idt=min(idt,iautoftp_abort_time)        
            call TimeAdd(itime_scan_end_prev,idt,itime_disk_abort)
          endif        

! This indicates start of phase reference.     
          idt=iTimeDifSec(iTime_scan_beg_next,iTime_scan_end)
          kPhaseRefNext= idt .eq. 0     

!     itime_early=itime_scan_beg - early_start
          call TimeSub(itime_scan_beg,itearl(istn),itime_early)  
          call copy_time(itime_early,itime_tape_start)
!     itime_tape_stop=itime_scan_end+itlate
          call TimeAdd(itime_scan_end,itlate(istn),itime_tape_stop)
          call TimeAdd(itime_scan_beg,ioff(istnsk),itime_data_valid)

      if(kdebug) then
        write(*,'("Time_early ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_early(j),j=1,5)
        write(*,'("Scan Begin ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_scan_beg(j),j=1,5)
        write(*,'("Data Valid ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_data_valid(j),j=1,5)
        write(*,'("Tape Stop  ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_tape_stop(j),j=1,5)
!        pause
      endif

C     Now determine whether the tape will be stopped (kstop_tape).
C     For "adaptive" motion, stop the tape if the time between one
C     tape stop and the next tape start is longer than the specified 
C     time gap. For "continuous" tape is nominally never stopped.
C
! Default value for end of a pass. May change below.
        if (iobs_this_stat_rec.ne.0) then
          call TimeAdd(itime_scan_end_prev,itlate(istn),itime_pass_end)
        endif

        if(kadap) then
          if (.not.klast_obs) then ! next scan
C             Use the offsets instead of slewing to determine good data time
              if (idirn.eq.idir) then ! same direction, check gap
                idt=iTimeDifSec(itime_scan_beg_next,itime_tape_stop)-
     >                              itearl(istn)
                kstop_tape = idt.gt.itgap(istn)
                if (kstop_tape) then
                  kcontpass = .false. ! this pass not continuous
                endif
              else ! new direction, must stop
                kstop_tape = .true.
                kcontpass = .true. ! reset to true at start of a new pass
              endif ! same/new direction
            else ! no next
              kstop_tape = .true.
            endif ! next/last
C Use this section only for continuous
        else if (kcont) then
          ilatestop=0
          kstop_tape = .false.
          if (iobs_this_stat_rec.ne.0) then    ! calculate new times based
            lcbnow=lcable(istnsk)  !need to do this becase slewo CHANGES lcable(istnsk)
            call slewo(isorp,mjdpre,utpre,isor,istn,lcbpre,
     >        lcbnow,tslew,0,dum)
            if (tslew.lt.0) tslew=0.0
            if (kNewPass) then ! New pass.
              if(idirp .eq. +1) iftrem=ift(istnsk)-iftold
              if(idirp .eq. -1) iftrem=iftold-ift(istnsk)
!             iftrem= feet remaining on the pass from the ending footage of last scan
              ilatestop=max(nint(float(iftrem)/speed_ft),1)
              call TimeAdd(itime_scan_end_prev,ilatestop,itime_pass_end)
              call TimeSub(itime_scan_beg,itearl(istn),itime_tape_start)
            else ! Old pass.
              call TimeAdd(itime_scan_end_prev,ifix(tslew)+ical,
     >                 itime_scan_beg)
              call TimeSub(itime_scan_beg,ical,itime_cal)
              call TimeSub(itime_scan_beg,itearl(istn),itime_early)
              call copy_time(itime_early,itime_tape_start)  
            endif ! same pass/new pass
          endif !  calculate new times
        else ! start& stop OR new direction
          kstop_tape = .true.
        endif

C       always stop on the last scan but not for late stop.
        if (klast_obs.and.itlate(istn).eq.0) kstop_tape=.true.

C <<<previous>>>>  <<<<<<<<<<current>>>>>>>>>>>>>>>>>>>>>>  <<<next>>>>>>>>>
C data     tape    tape           data   data         tape    tape
C stop     stop    start          start  stop         stop    start
C  ^         ^      ^              ^      ^            ^      ^
C  |---------|------|--------------|------|------------|------|-------------|
C  <late stop><-idt-><-early start-><-dur-><-late stop-><-idt-><-early start>
C             (gap)                                     (gap)
C
C***************************************************************************
C
C     3. Output the SNAP commands. Refer to drudg documentation.

C scan_name command. 
        nch=trimlen(scan_name(iskrec(iobs_now)))      

        write(ldum,'("scan_name=",3(a,","),i4)')
     >    scan_name(iskrec(iobs_now))(1:nch),lsession, cpocod(istn),
     >    idur(istnsk)-ioff(istnsk)
        
        if(kdebug) write(*,*) ldum(1:50) 
        call drudg_write(lufile,ldum)       !get rid of spaces, and write it out.

        if(.false.) then
           write(*,*) kphaseRefPrev, " | ",kPhaseRefNext, " | ",
     >       lscan_name
        endif 

        if(ktarget_time) then
! This is test for phase reference.  If doing phase_reference then get there ASAP
          if(kPhaseRefNext) then 
            write(lufile,'("target_time=")')
          else
            write(lufile,
     >       '("target_time=",i4.4,".",i3.3,".",2(i2.2,":"),i2.2)')
     >       itime_cal
          endif 
        endif 
      
C SOURCE command
        IOBSP = IOBSP+1
        ituse=0
C       For celestial sources, set up normal command
C               SOURCE=name,ra,dec,epoch 
        IF (ISOR.LE.NCELES) THEN !celestial source
! do some intermediate processing.
          IF (cepoch.EQ.'1950') THEN
            SORRA = RA50(ISOR)
            SORDEC = DEC50(ISOR)
            EPOC = 1950.0
          ELSE !2000
            SORRA = SORP50(1,ISOR)
            SORDEC = SORP50(2,ISOR)
            EPOC = 2000.0
          endif
          CALL RADED(SORRA, SORDEC,0.0d0,IRAH,IRAM,RAS,
     >       LDS,IDCD,IDCM,DCS,L,I,I,D)
          if (ras+0.5d0.ge.60.d0) then
            ras=0.d0
            iram=iram+1
            if (iram.ge.60) then
              iram=iram-60
              irah=irah+1
            endif
          endif
          iras=int(ras)
          iras_frac=((ras-iras)*100.+.5)
          if(iras_frac .eq. 100) then
            iras_frac=0
            iras=iras+1
          endif

          if (dcs+0.5d0.ge.60.d0) then
            dcs=0.d0
            idcm=idcm+1
            if (idcm.ge.60) then
              idcm=idcm-60
              idcd=idcd+1
            endif
          endif
          idcs=int(dcs)
          idcs_frac=((dcs-idcs)*10.+.5)
          if(idcs_frac .eq. 10) then
            idcs_frac=0
            idcs=idcs+1
          endif

          cwrap2=" "
          if (iaxis(istn).eq.3.or.iaxis(istn).eq.6
     >                        .or.iaxis(istn).eq.7)  then
            call cbinf(ccable(istnsk),cwrap)
            cwrap2=","//cwrap(1:7)
          endif

          if(cds(1:1) .eq. "+") cds(1:1)=" "
          write(ldum,9010) csorna(isor),irah,iram,iras,iras_frac,
     >      cds(1:1), idcd,idcm,idcs,idcs_frac,epoc,cwrap2
9010      format("source=",a,",",  3(i2.2),".",i2.2,",",
     >                            a1,3(i2.2),".",i1.1,",",f6.1,a)
          call drudg_write(lufile,ldum)       !get rid of spaces, and write it out.
        else !satellite
          CALL CVPOS(ISOR,ISTN,MJD,UT,AZ,EL,HA1,DC,X30,Y30,X85,Y85,KUP)
          az=az*rad2deg
          el=el*rad2deg
          write(cbuf,'("SOURCE=AZEL,",f7.3,"D,",f6.3,"D")') Az,el
          call drudg_write(lufile,ldum)       !get rid of spaces, and write it out.
        endif !celestial/satellite

        if(iobs_this_stat .eq. 0 .and. kk5) then
           write(lufile,'("ready_k5")')
        endif
   
        if((iobs_this_stat_rec.ne.0).and.(idir.ne.0) .and.
     >     (km5disk.or.km5a_piggy.or.km5p_piggy.or.kk5).and.
     >     .not. (krunning .or. kdata_xfer_prev))  then
           if(kk5) then
              write(lufile,'("checkk5")')
           else
              write(lufile,'("checkmk5")')
           endif
        endif

        if(kdisk2file_prev) then
           call snap_wait_time(lufile,itime_disk_abort)
           call snap_disk2file_abort(lufile)
           kdisk2file_prev=.false.
        endif
    
C
C Check procedure
C For continuous tape motion, check after tape stops at end of a pass
        if (krec) then ! recording
          ICHK = 0
C         Add "not krunning" so we don't try a check while it's moving!
          IF (.not.krunning.and..not.knopass
     .      .and..NOT.KNEWTP.AND.iobs_this_stat_rec.GT.0) THEN !check procedure
          IF ((.not.kcont.and.KFLG(2).and.(iobsp.eq.2.or.icheckp.eq.1))
     .       .or.(kcont.and.kflg(2).and.iobsp.eq.1)) THEN ! see if there's time to do a check
C        Do check if flag is set, but only if there is enough time.
C        Or, do check if MAXCHK and if there is enough time.
C        Enough time = (SOURCE+SPIN+SETUP+TAPE+3S+head) < IPARTM
            iset=0
            if (ldirp.ne.ldir(istnsk).or..not.kflg(1)) iset=isettm
            ISPPL = ISET+ISORTM+ITAPTM+3
C           Add the procedure times to the previous data stop (time4).
            if (ilatestop.eq.0) then
              call TimeAdd(itime_scan_end_prev,isppl,itime_check)
            else
              call TimeAdd(itime_tape_stop_prev,isppl,itime_check)
            endif
C           Check against start-early for early <> early
C           check against start-cal   for early=0.
            if (itearl(istn).ne.0) then
              idt=iTimeDifSec(iTime_early,iTime_Check)
            else
              idt=iTimeDifSec(iTime_cal,iTime_Check)
            endif
C CHECK procedure 
C Needs 55 sec at 80 ips = 4400 in = 366.667 f
C NOTE: 55 sec should really be IPARTM
              iftchk = speed_ft*idurp ! feet in previous scan
              if (idt.ge.IPARTM.and.iftchk.ge.366) then ! enough time 
                ICHK = 1
                call snap_check(bitDens(istn,icod),idirp)
              else ! not enough time, so try later
                icheck = 1 ! do a check after this obs (or at least try)
              endif ! enough time OR force
            ENDIF !do the check
          END IF !check procedure
        endif ! recording 

! Do READY 
        IF (KNEWTP.and.krec) THEN ! new tape
          call snap_ready(ntape,kfirst_tape)
          if (iobs_this_stat.eq.0) then ! do a SETUP first
            if(kin2net) then
              call snap_in2net_connect(lufile,
     >           ldest,lxfer_options(ixfer_ptr))
            endif         
          endif ! do a SETUP first
          kfirst_tape=.false.
        END IF ! new tape
   
      
C SETUP procedure 
C This is called on the first scan, if the setup is wanted on this
C scan (flag 1=Y), if tape direction changes, or if a check was done
C prior to this scan. Do only on a new pass for continuous. 

      
      if(.not. (kPhaseRefPrev.or.krunning)) then    !issue SETUP          
        IF (iobs_this_stat.EQ.0.OR.KFLG(1).OR.LDIRP.NE.LDIR(ISTNSK)
     >       .OR.ICHK.EQ.1) THEN                
           if(kin2net) then
              call snap_in2net_connect(lufile,
     >           ldest,lxfer_options(ixfer_ptr))
            endif        
            if(kdisk2file_prev) then
              call snap_wait_time(lufile,itime_disk_abort)
              call snap_disk2file_abort(lufile)
              kdisk2file_prev=.false.
            endif      
            call setup_name(ccode(icod),csetup_name)
            call drudg_write(lufile,csetup_name)           
         END IF
       endif
!        pause 

C Early start 
        if (idir.ne.0.and.krec) then ! this is a non-zero recording scan
        if (itearl(istn).gt.0) then ! early start
        if (.not.kcont.or.(kcont.and..not.krunning)) then ! continuous
C       always do unless continuous and already running
       
C  Wait until ITEARL before start time
          if (.not.krunning) ituse=1 ! Don't use early start if already running
          call snap_wait_time(lufile,itime_tape_start)
          call snap_monitor(kin2net)
          if(.not. krunning) then
            call snap_start_recording(kin2net)
           endif
        endif ! continuous
        endif !start tape early/issue ST again
        endif !non-zero scan

C Wait until CAL time. Antenna is on-source as of this time.
        IF (ICAL.GE.1.and. .not. 
     >      (kPhaseRefPrev.or.krunning)) then ! PREOB
           call snap_wait_time(lufile,itime_cal)
C PREOB procedure       
           call drudg_write(lufile,cpre)          
        ENDIF ! cal and preob

!--------------------- Begin  DATA_VALID   -------------------------------------
! write out 
!   !YYYY.DDD.HH:MM:SS
!   disk_pos  OR in2net        <---only if MK5B
        if(krec .and. idir .ne. 0)  then                     !have a recorder and are recording
          if (kvex.and.kadap.and.krunning) then ! don't write time
            continue 
          else ! do write it             
!  Write out monitor command. 
            call snap_wait_time(lufile,itime_scan_beg)          
          endif ! don't/do write
!Turn on running if necessary. 
          kdo_monitor=.true.                  !indicate that we should issue monitor command before data_valid
          if(.not.krunning) then
! Need to insert a 'disk_pos' command if we start recording. 
! This also means that we do not need to insert it later. 
            call snap_monitor(kin2net)       
            kdo_monitor=.false. 
            call snap_start_recording(kin2net)    
          endif     
        endif
! Turn on flag indicating 
        krunning=.true.

! ISSUE:
!  !YYYY.DDD.HH:MM:SS    <--but only if differs from last time. 
!  data_valid=on
        call snap_get_last_wait_time(ilast_wait_time)        !Get the last wait time.

! First if:
!   A) Have recorder AND are recording OR B) recorder ='none'               
        if(krec .and. idir .ne. 0 .or. .not. krec) then
! Second if.
!   A) non VEX files OR B) VEX files if there is still good data left. 
          if(.not. kvex.   or. (kvex .and.
     >      iTimeDifSec(itime_scan_end,itime_tape_start) .gt. 0)) then   !some            
! Check if we need to issue a wait command. 
            if(iTimeDifSec(itime_data_valid,ilast_wait_Time).gt.0) then  
! If we insert a wait time, need to insert a 'disk_pos' command before 'data_valid=on'
               call snap_wait_time(lufile,itime_data_valid)              
               kdo_monitor=.true.                            
            endif ! good data time
            if(kdo_monitor) call snap_monitor(kin2net)
            call snap_data_valid('=on')         
          endif ! some valid data
        endif  
! end ---------------- DATA_VALID  -----------------------------------

  
C MIDOB procedure
        if(idir .ne. 0) then        
          call drudg_write(lufile,cmid)     
        endif
C Wait until data end time
        call snap_wait_time(lufile,itime_scan_end)

        if((krec .and. idir .ne.0) .or. .not. krec) then
          call snap_data_valid('=off')
        endif
 

C Stop data flag      
        if (krec.and.idir.ne.0) then ! non-zero recording scan      
          if(.not.kcont .and. kstop_tape) then     
!         Wait until late stop time before issuing ET
            if (itlate(istn).gt.0) then
               call snap_wait_time(lufile,itime_tape_stop)
            endif    
            krunning=.false.       
            if (km5disk) then
              if(kin2net) then
                write(lufile,'(a)') 'in2net=off'
              else
                write(lufile,'(a)') 'disk_record=off'
              endif
            endif          
          endif! ET command
          call snap_monitor(kin2net)
        endif ! non-zero recording scan     
   
C Save information about this scan before going on to the next one
        cmodep=cmode(istn,icod)
        IPASP = IPAS(ISTNSK)
        isorp = isor
        icheckp=icheck
        lcbpre = lcable(istnsk)
        iobs_this_stat = iobs_this_stat + 1
        call copy_time(itime_scan_beg,itime_beg(1,iobs_this_stat))
            
        if(kstop_tape) then
           krunning=.false.      
           do i=iscan_calc_start, iobs_this_stat
              itime_total_record(i)=
     >           iTimeDifSec(iTime_tape_stop,itime_beg(1,i))      
           end do   
           iscan_calc_start=iobs_this_stat+1
        endif

        if (idir.ne.0) then ! update direction and footage
          iobs_this_stat_rec = iobs_this_stat_rec + 1
          LDIRP = LDIR(ISTNSK)
          idirp=idir
          idurp=idur(istnsk)
          IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ituse*ITEARL(istn)+
     &        IDUR(ISTNSK))*speed_ft)
        endif ! update direction and footage

C POSTOB        
        IF (idir .ne. 0 .and. (klast_obs .or. 
     &     .not. (kPhaseRefNext .or.krunning))) then        
          call drudg_write(lufile, cpst)        
        endif   
           
        if(km5disk) then
          if(kdisk2file) then
            nch=trimlen(scan_name(iobs_now))
            nch2=trimlen(ldest)
            if(nch2 .eq. 0) then
              cstat_code=cpocod(istn)
              nch3=trimlen(cstat_code)
              call lowercase(cstat_code)
              ldest=lsession(1:trimlen(lsession))//"_"//
     >           cstat_code(1:nch3)//"_"//
     >           scan_name(iobs_now)(1:nch)//".m5a"
              nch2=trimlen(ldest)
            endif
            nch3=trimlen(lxfer_options(ixfer_ptr))
            if(nch3.eq. 0) nch3=1
            isec_beg=int(xfer_beg_time(ixfer_ptr))
            isec_end=int(xfer_end_time(ixfer_ptr))
            rsec_beg=xfer_beg_time(ixfer_ptr)-isec_beg   !get fractional part.
            rsec_end=xfer_end_time(ixfer_ptr)-isec_end

            call TimeAdd(itime_scan_beg,isec_beg,itime_disk2file_beg)
            call TimeAdd(itime_scan_beg,isec_end,itime_disk2file_end)

            rsec_beg=rsec_beg+itime_disk2file_beg(5)
            rsec_end=rsec_end+itime_disk2file_end(5)

            nch3=max(1,trimlen(ldisk2file_dir))
            write(ldum,
     >         "('disk2file=,',a,',',2(i2.2,'h',i2.2,'m',f5.2,'s,'),a)")
     >        ldisk2file_dir(1:nch3)//ldest(1:nch2),
     >        itime_disk2file_beg(3),itime_disk2file_beg(4),rsec_beg,
     >        itime_disk2file_end(3),itime_disk2file_end(4),rsec_end,
     >        lxfer_options(ixfer_ptr)(1:nch3)

            call drudg_write(lufile,ldum)       !get rid of spaces, and write it out.
! find speed of recorder
            call find_recorder_speed(icod,speed_recorder,.true.)
! factor of 5 is too give extra time for scan to complete.
            idt=5+(xfer_end_time(ixfer_ptr)-xfer_beg_time(ixfer_ptr))*
     >                      speed_recorder*(8./110.)
            idt=idt*2
            call TimeAdd(itime_scan_end,idt,itime_disk_abort)
            kdisk2file_prev=.true.
          endif
        endif     

        mjdpre = JULDA(1,itime_scan_end(2),itime_scan_end(1)-1900)
        utpre= itime_scan_end(3)*3600.+itime_scan_end(4)*60.
     >       +itime_scan_end(5)
        if (utpre.gt.86400.d0) then
          utpre=utpre-86400.d0
          mjdpre = mjdpre+1
        endif
      END IF  ! istnsk.ne.0 means our station is in this scan
C
C     Copy ibuf_next into IBUF and unpack it.
      if (ilen.ne.-1) then ! more scans to come
        cbuf=cbuf_next
        ilen = trimlen(cbuf)
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     >      itime_scan_beg(1),itime_scan_beg(2),itime_scan_beg(3),
     >      itime_scan_beg(4),itime_scan_beg(5),
     >      IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     >      MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
        call ckobs(csname,cstn,nstnsk,cfreq,isor,istnsk,icod)
      endif       
!      pause  

      kdata_xfer_prev=kdisk2file .or. kin2net

      END DO ! ilen.gt.0,kerr.eq.0,ierr.eq.0

! Do any cleanup we need to do
      do i=iscan_calc_start, iobs_this_stat
           itime_total_record(i)=
     >         iTimeDifSec(iTime_tape_stop,itime_beg(1,i))     
      end do             
  
      if(.not.(krunning .or. kdata_xfer_prev)) then        
         if(kk5) then
           write(lufile,'("checkk5")')
        else if(km5disk) then 
           write(lufile,'("checkmk5")')
        endif
      endif

      if(kdisk2file_prev) then
         call TimeAdd(itime_scan_end,iautoftp_abort_time,
     >     itime_disk_abort)
         call snap_wait_time(lufile,itime_disk_abort)
         call snap_disk2file_abort(lufile)
         kdisk2file_prev=.false.
      endif

C End of schedule
      write(lufile,'(a)') "sched_end"
      close(lufile,iostat=IERR)


! Here we fixup the snap file     
      lu_in=9
      open(lu_in,file=snpname)
      i=trimlen(snpname)
      ltmpfil=snpname(1:i)//".tmp"
      open(lufile,file=ltmpfil)

      iobs_this_stat=0
      do while(.true.) 
        read(lu_in,'(a)',end=1100) ldum
        if(ldum(1:9) .eq. "scan_name") then
          iobs_this_stat=iobs_this_stat+1
          i=trimlen(ldum)+1
          itemp=itime_total_record(iobs_this_stat)+itearl(istn)        
          write(ldum(i:),'(",",i10)') itemp
          call drudg_write(lufile,ldum)
        else
         i=trimlen(ldum)
         write(lufile,'(a)') ldum(1:i)    
        endif            
      end do       


1100  continue
      close(lu_in)
      close(lufile)

      if(.true.) then 
      i1=trimlen(ltmpfil)
      i2=trimlen(snpname)
      write(ldum,*) "mv ",ltmpfil(1:i1+1),ltmpfil(1:i2)
      i1=trimlen(ldum)
      i1=i1+1
      ldum(i1+1:i1+1)=char(0)      
      call system(ldum(1:i1))
      endif 


      call drchmod(snpname,ierr)
      IF (KERR.NE.0) WRITE(LUSCN,9902) KERR,SNPNAME(1:ic)
9902  FORMAT(' SNAP03 - Error ',I5,' writing SNAP output file ',A)

      RETURN
      END
