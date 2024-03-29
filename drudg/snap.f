*
* Copyright (c) 2020-2023 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
        SUBROUTINE SNAP(cr2)
! 2019Sep04
      implicit none 
C
C     SNAP reads a schedule file and writes a file with SNAP commands
C
      include 'hardware.ftni'           !This contains info only about the recorders.
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/broadband.ftni'
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
      integer trimlen ! functions
      integer julda

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
      logical kstaggered_start    !do all of the stations start at the same time (
!      logical kflg(4)
      integer ierr
    
      integer isec_beg,isec_end   !integer part of disk2file offset
      real    rsec_beg,rsec_end   !total seconds part of disk2file beg or end
      integer idur(max_stn)

      integer ioff(max_stn)

      character*2 ccable(max_stn)
      equivalence (ccable,lcable)
  
      character*(max_sorlen) csname
      character*2 cstn(max_stn)
      character*2 cfreq
      equivalence (csname,lsname),(lstn,cstn),(cfreq,lfreq)

! Arguments to UNPSK for the next scan
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
      integer icod_prev         !previous code.

      integer*2 lds
      character*2 cds
      equivalence (lds,cds)
      
      integer iobs_now,iobs_this_stat,iobs,iobs_this_stat_rec

      integer isorp

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
  
      logical kup
      real az,el,x30,y30,x85,y85,ha1,dc
! end source position.

      integer nch,nch2,nch3

      integer l,ilatestop
      integer ic,mjdpre

      real d,epoc,tslew,dum
      integer itemp                  !short lived temporary variable
      logical kdo_monitor            !used as flag to determine if we should do a monitor. 
      logical kPhaseRef              !Phase reference data.  No stop between this scan and next scan.
      logical kPhaseRef_Prev         !Phase reference data.  No stop between this scan and previous scan. 
 
      character*2 cwrap_pre
      character*2 cwrap_now

      integer idt
      integer iscan_gap              !time from end of last scan to start of current scan
      integer iscan_gap_prev
      double precision utpre

      character*4 lresponse            !
C     character*28 cpass,cvpass  

C     LMODEP - mode of previous observation
C     LDIRP  - direction of previous observation

C     IOBS - number of obs in the schedule
C     iobs_this_stat - number of obs for this station
C     iobs_this_stat_rec - number of obs for this station that are recorded on tape

      character*7 cwrap ! cable wrap from CBINF
      character*8 cwrap2
C      - true if a new tape needs to be mounted before
C        beginning the current observation

      logical krec  ! true if the recorder is NOT "none"
   
      character*12 csetup_name

! JMG variables 
      integer itime_scan_end(5)             !end of scan    =istart+idur
      integer itime_early(5)                !early start    =istart-itearl
      integer itime_tape_stop(5)            !late end       =iend+ilate
      integer itime_cal(5)         	    !cal		=istart-ical
      integer itime_tmp(5)                  !temporary variable to hold time
      integer itime_tape_start(5)           ! 
      integer itime_data_valid(5)           !when is the scan valid?
   !

      integer itime_scan_beg(5)   !iyr,iday,ihr,imin,isec
      integer itime_disk_abort(5) !time to end disk2file
      integer itime_disk2file_beg(5)
      integer itime_disk2file_end(5)
      integer itime_buf_write(5)     !end of time to write buffer
      integer itime_buf_write_prev(5)   !End of previous buffer write 
     
 ! Some times  for previous and next scan  
      integer itime_scan_beg_next(5)    
      integer itime_scan_end_prev(5) 


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
   
      logical klast_obs         ! doing last observation
      logical kfirst_obs   
      logical krestart_obs      !This is the first observation after restarting. 
      logical kcheck_done       !have we issued kcheck command 
      logical kcheck_done_prev 

      integer iscan_rec_dur           !duration of a scan including itearl itlate
! Variables associated with Mark6 recording       
      integer idata_mk6_scan_mb       !Data recorded for a scan.     
      integer imk6_buf_write_dur  


      character*180 ldum
      
      double precision speed_recorder   ! speed of recorder in this mode.

! counter
      integer i,j               !counters
      logical kdebug
C
C  INITIALIZED:    
C     data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
C     data cvpass /'abcdefghijklmnopqrstuvwxyzAB'/
C
C History:
! Now put in most recent first. 
! 2023-02-21 JMG. Now get session code from cexper. Was previously getting from experiment name.
! 2022-05-28 JMG. Memorial day weekend. I should be playing not working. 
!                 Fixed bug in 'disk2file'. Was not  setting iscan_gap_prev at end of loop.
! 2021-12-18 JMG. Got rid of some unused calculations.
!                 new: iscan_gap: time between end of current scan and start of next. 
!                 new: kcheck_done, kcheck_done_prev. Have we issued kcheck_done_prev 
!
! 2021-02-08 JMG lsetup_proc. now if changed the change sticks. You have to restart drudg
! 2021-01-20 JMG if lsetup_proc="YES" always use setup_proc. 
! 2021-01-20 JMG setup=SETUPBB if cstrack(istn)="BB" 
! 2020-12-30 JMG Removed variables which were not used.  Removed obsolete check procedure.
!                Added in new code for setup. 
! 2020-11-20 JMG If no observations return with warning. 
! 2020-06-30 JMG Got rid of test on kmissing (which indicated missing tape info)
! 2020-06-08 JMG. Added new broadband.ftni.  Added ibb_off to buffereing time
! 2020-05-29 JMG Fixed bug in schedules with early starts. Schedules were not getting written out.
!                Also got rid of element-by-element copy of one itime_xx to another itime_yy. 
! 2019Nov20 JMG. Fixed bug in index.  
! 2019Nov20 WEH. changed line from f90 to f77 for backwards  compatibility
! 2019Aug25 JMG. Merged in changes from BB version. Also removed some tape stuff, and changed lcbnew, lcbpre to ASCII
!
! 2018May02 snap.f: Fine tuning staggered start. If the station offset for OUR station is zero, assume non-staggered.
! 2018May02 snap.f: Take account of staggered start in calculating recording media. 
! 2018Apr02 snap.f: Fixed staggered start. I hope. 
! 2018May18 JMG. Staggered start stuff. 
! 2017Dec23 snap.f:  If staggered start (different stations start at different times) then change handling of 
!          calibrations.  A.) Uses nomimal data_valid_time to start recording data and do calibration. 
!          B.) ical_time later sets data valid flag.  
!          ical_time is either nominal cal_time (10 sec) or ical_time_staggered, or if cont_cal is on, then 1.

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
! 2007Feb01 JMG.  "Checkmk5" had clued off of "iobs_this_stat<>0". This didn't work if first
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


      if(nobs .eq. 0) then 
         write(*,*) "Snap: Schedule has no observations. Returning."
         return
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
! Previously extracted session code from experiment name.
! But should be session code from schedule file

      call init_hardware_common(istn)

      WRITE(LUSCN,'("SNAP output for ", a)') cSTNNA(ISTN)
      ierr=1

! New option.  lsetup_proc 
! Note that we preserve the original value.  
! Opps! changed our mind. See last line at the end of this section.
      lsetup_proc=lsetup_proc_orig
      if(lsetup_proc_orig .eq. "IGNORE") lsetup_proc ="NO"
    
      if(lsetup_proc .eq. "ASK") then
         lresponse="?"
         do while(.not.(lsetup_proc .eq. "YES" 
     &             .or. lsetup_proc .eq. "NO")) 
           write(*,'("Use setup_proc (Yes/No): ",$)') 
           read(*,*) lresponse
           call capitalize(lresponse) 
           if(lresponse .eq."YES" .or. lresponse .eq. "Y") then
              lsetup_proc="YES"
           else if(lresponse .eq. "NO" .or. lresponse .eq. "N") then 
              lsetup_proc="NO"
           else
              write(*,*) "Invalid response. Try again. " 
           endif 
         end do    
      endif      
      if(lsetup_proc .eq. "YES") then
         write(*,*) "Will use setup_proc"
      else
         write(*,*) "Will use normal setup" 
      endif 
      lsetup_proc_orig=lsetup_proc    !this makes the change permanent. 
         
      irec=1
C Initialize recorder information.     
      krec= .not.(knorec(1) .or. kk5rec(1))

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
      iobs_this_stat=0
      iobs_this_stat_rec=0
     
      kstop_tape = .false.
      krunning = .false.
      ilatestop=0
     
      do i=1,5
!        itime_scan_beg_prev(i)=0
        itime_scan_beg_next(i)=0  
      end do

      icod_next=1   !initialize
      icod_prev=-1

      kadap= (tape_motion_type(istn).eq.'ADAPTIVE')
      kcont= (tape_motion_type(istn).eq.'CONTINUOUS')
     
      istnsk=0
! The important part of this is it sets the second character to " ".
! This is important when calling ckobs. 
      do i=1,max_stn
        cstn(i)=" "          !initialize
        cstn_next(i)=" "     !ditto
      end do     
   
! Get first scan for this station into IBUF     
      do iobs=1,nobs  
        cbuf=cskobs(iskrec(iobs))
        ilen=trimlen(cbuf) 
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     >      itime_scan_beg(1),itime_scan_beg(2),itime_scan_beg(3),
     >      itime_scan_beg(4),itime_scan_beg(5),
     >      IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     >      MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)   
          call ckobs(csname,cstn,nstnsk,cfreq,isor,istnsk,icod)                 
          IF (ISOR.EQ.0.OR.ICOD.EQ.0) RETURN
          if(istnsk .ne. 0) goto 50      
      enddo ! get first scan for this station into IBUF
! Did  not find a scan with this station.
      write(luscn,*) "No scans for this station!"
      return  
   
50    continue 
      call snapintr(1,itime_scan_beg(1))

      kdebug         =.false.
      kfirst_obs     =.true. 
      klast_obs      =.false. 
      krestart_obs   =.false. 
      iscan_calc_start=1      !which scan do we start calculating recording differences on

      kcontpass=.true.  !Passes always start out as continous.   
      kdisk2file_prev=.false.        
      kcheck_done_prev=.true.
      kPhaseRef_Prev=.false.  

      DO WHILE (.not.klast_obs .AND. ierr.eq.0 .AND. cbuf(1:1) .ne. "$")  

100     continue 
! Can skip the first obs cause this was done above. 
! For the remaining observations, cbuf is found we read the next observation.
        if(.not.kfirst_obs) then
          ilen = trimlen(cbuf)
          CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     >      itime_scan_beg(1),itime_scan_beg(2),itime_scan_beg(3),
     >      itime_scan_beg(4),itime_scan_beg(5),
     >      IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     >      MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
            call ckobs(csname,cstn,nstnsk,cfreq,isor,istnsk,icod)
        endif 
        kfirst_obs=.false. 
        iobs_now = iobs ! save current obs number for scan ID

! Now read in the next obs. All we really need is the time. 
!    But in order not to overwrite anything else we give different names.
        istnsk_next=0
        do while (istnsk_next.eq.0 .and. .not. klast_obs) ! Get NEXT scan for this station into ibuf_next  
          IOBS = IOBS + 1
          if (iobs.le.nobs) then
            cbuf=cskobs(iskrec(iobs))
            ilen=trimlen(cbuf)
            CALL UNPSK(IBUF,ILEN,LSNAME_next,ICAL_next,
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
            klast_obs=.true.      
          endif
        enddo ! get NEXT scan for this station into ibuf_next
        kcheck_done=.false.

! figure out if staggered start....
        kstaggered_start=.false.  
        if(ioff(istnsk) .ne. 0) then 
          do itemp=2,nstnsk
            if(ioff(itemp) .ne. ioff(1)) kstaggered_start=.true.
          end do     
        endif      
            
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

C****************************************************************
C This is the confusing part where certain timings are set up,
C depending on the type of tape motion. This part needs to be
C cleaned up and rationalized when sked and sched are both using
C the same logic.
C****************************************************************
C  2.5  Calculate all the times and flags we will need.  
! Data end time=itime_scan_beg+duration.
          call TimeAdd(itime_scan_beg,idur(istnsk),itime_scan_end) 
          if(klast_obs) then
            iscan_gap=0
          else
            iscan_gap=iTimeDifSec(iTime_scan_beg_next,iTime_scan_end)       
          endif 
!          write(lufile,'("SCAN GAP", i7)') iscan_gap

! Cal time= itime_scan_beg-ical
          call TimeSub(itime_scan_beg,ical,itime_cal)                 
   
          if(iobs_this_stat .gt. 0) then 
! itime_disk_abort=itime_scan_beg-(ical+isettm+5)     
! Calculate how much time we have.                             
            idt=iscan_gap_prev 
 ! Calculate time to abort autoftp for previous scan. Only need to do if a previous scan.   
            idt=idt-(isettm+ical+5)     !isettm is time for setup. 
                                        ! 5 is for execution of disk2file         
            idt=min(idt,iautoftp_abort_time)      
            call TimeAdd(itime_scan_end_prev,idt,itime_disk_abort)   
          endif        

! This indicates start of phase reference.     
          idt=iTimeDifSec(iTime_scan_beg_next,iTime_scan_end)
          kPhaseRef = idt .le. itgap(istn)     

!     itime_early=itime_scan_beg - early_start
          call TimeSub(itime_scan_beg,itearl(istn),itime_early)  
          call copy_time(itime_early,itime_tape_start)
!     itime_tape_stop=itime_scan_end+itlate
          call TimeAdd(itime_scan_end,itlate(istn),itime_tape_stop)
          call TimeAdd(itime_scan_beg,ioff(istnsk),itime_data_valid)             
 
          if(km6disk) then        
            iscan_rec_dur=itearl(istn)+itlate(istn)+idur(istnsk)
            idata_mk6_scan_mb=iscan_rec_dur*idata_mbps(istn)
            if(isink_mbps(istn) .gt. 0) then 
              imk6_buf_write_dur =idata_mk6_scan_mb/isink_mbps(istn)        
            else
              imk6_buf_write_dur = iscan_Rec_dur
            endif 
            call TimeAdd(itime_tape_start,imk6_buf_write_dur,
     >              itime_buf_write)                        
          endif                    
         
!      kdebug=.true.
! Things are slightly different for staggered start. This is from a VEX schedule.
          if(kstaggered_start .and. 
     >      tape_motion_type(istn) .eq. "START&STOP") then           
            call copy_time(itime_data_valid, itime_tape_start)    ! copy itime_data_valid to itime_scan_beg
            call copy_time(itime_tape_start, itime_scan_beg) 
            call copy_time(itime_data_valid, itime_cal)           !this is the calibration time           
            call TimeAdd(itime_cal,ical,itime_data_valid) 
! *** check to see if have AT least ical time left. 
            idt= itimeDifSec(Itime_scan_end,itime_cal)
            if(idt .lt. 0) then  
              nch=trimlen(scan_name(iskrec(iobs_now)))      
              write(lufile,
     >     '("* Scan ",a," dropped because not enough time to record")')
     >       scan_name(iskrec(iobs_now))(1:nch)    
! skip everything else and get next scan...              
              goto 100
            endif                
         endif 

      if(kdebug) then
       write(*,'("Time_early ",i4,".",i3,3(".",i2.2))') itime_early
       write(*,'("Time_start ",i4,".",i3,3(".",i2.2))') itime_tape_start
       write(*,'("Scan_begin ",i4,".",i3,3(".",i2.2))') itime_scan_beg
       write(*,'("Data_valid ",i4,".",i3,3(".",i2.2))') itime_data_valid
       write(*,'("Tape_stop  ",i4,".",i3,3(".",i2.2))') itime_tape_stop
       write(*,'("Time_start ",i4,".",i3,3(".",i2.2))') itime_tape_start    
      endif
!      if(iobs .gt. 20) stop

C     Now determine whether the tape will be stopped (kstop_tape).
C     For "adaptive" motion, stop the tape if the time between one
C     tape stop and the next tape start is longer than the specified 
C     time gap. For "continuous" tape is nominally never stopped.
C

! Find how long to slew to next source. 
        tslew=0.d0 
        if (iobs_this_stat_rec.ne.0) then    ! calculate new times based
          cwrap_now=ccable(istnsk)  !need to do this becase slewo CHANGES lcable(istnsk)
          call slewo(isorp,mjdpre,utpre,isor,istn,cwrap_pre,
     >        cwrap_now,tslew,0,dum)
          if (tslew.lt.0) tslew=0.0
        endif   

        if(kadap) then
          if (.not.klast_obs) then ! next scan
C             Use the offsets instead of slewing to determine good data time
            idt=iTimeDifSec(itime_scan_beg_next,itime_tape_stop)-
     >                              itearl(istn)
             kstop_tape = idt.gt.itgap(istn)
             if (kstop_tape) then
                kcontpass = .false. ! this pass not continuous
             endif             
          else ! no next
             kstop_tape = .true.
          endif ! next/last
C Use this section only for continuous
        else if (kcont) then
          ilatestop=0
          kstop_tape = .false.
          if (iobs_this_stat_rec.ne.0) then    ! calculate new times based
             call TimeAdd(itime_scan_end_prev,ifix(tslew)+ical,
     >                 itime_scan_beg)
             call TimeSub(itime_scan_beg,ical,itime_cal)
             call TimeSub(itime_scan_beg,itearl(istn),itime_early)
             call copy_time(itime_early,itime_tape_start)  
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

! Restarting observing after a stop. 
! Emit "wait" until we are supposed to do the first command
!  ipre_time=time required after the first command to do everything: Slewing, postob, etc. 
        if(krestart_obs) then 
           call TimeSub(itime_Scan_beg,ipre_time+ical, itime_tmp)
           call snap_wait_time(lufile,itime_tmp)
           krestart_obs=.false.
        endif 

C scan_name command. 
        nch=trimlen(scan_name(iskrec(iobs_now)))             
        write(ldum,'("scan_name=",3(a,","),i4)')
     >    scan_name(iskrec(iobs_now))(1:nch),cexper, cpocod(istn),
     >    idur(istnsk)-ioff(istnsk)
        
        if(kdebug) write(*,*) ldum(1:50) 
        call drudg_write(lufile,ldum)       !get rid of spaces, and write it out.

        if(ktarget_time) then
! This is test for phase reference.  If doing phase_reference then get there ASAP
          if(kPhaseRef) then 
            write(lufile,'("target_time=")')
          else
            write(lufile,
     >       '("target_time=",i4.4,".",i3.3,".",2(i2.2,":"),i2.2)')
     >       itime_cal
          endif 
        endif       
 
C SOURCE command        
C       For celestial sources, set up normal command
C               SOURCE=name,ra,dec,epoch 
        IF (ISOR.LE.NCELES) THEN !celestial source
! do some intermediate processing.
          IF (cepoch.EQ.'1950') THEN
            SORRA =  sorp1950(1,ISOR)
            SORDEC = sorp1950(2,ISOR)
            EPOC = 1950.0
          ELSE !2000
            SORRA =  sorp2000(1,ISOR)
            SORDEC = sorp2000(2,ISOR)
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

        if(iobs_this_stat .eq. 0) then
          if(km6disk.or..not.krec) then
            continue
          else if(kk5rec(1)) then 
            write(lufile,'(a)') 'ready_k5'
          else if(km5disk) then
            write(luFile,'(a)') 'ready_disk'
          else
            write(lufile,'(a)') 'ready'
          endif 
        endif
       
! The check command can appear in two places. 
!  1. After the scan=,source= commands. This finishes up the previous scans.
!  2. After the postob. 
        if(.not. kcheck_done_prev) then     !did not do the check command for previous scan. Do it now.      
          call snap_check(lufile,itime_buf_write_prev,kdata_xfer_prev)        
        endif

        if(kdisk2file_prev) then
           call snap_wait_time(lufile,itime_disk_abort)
           call snap_disk2file_abort(lufile)
           kdisk2file_prev=.false.
        endif    
      
! SETUP procedure 
! Don't call if doing phase reference or we are recording.
! Do call on
! 1. First observation.
! 2. Change in code.
! 3. If sked flag is set.
! 4. If lsetup_proc="YES"

      if(kPhaseRef_Prev.or.krunning) then
        continue    !Don't issue in these 
      else IF (iobs_this_stat.EQ.0 
     &   .OR. Icod  .ne. icod_prev .or. kflg(1)) then 
        if(kin2net) then
          call snap_in2net_connect(lufile,
     >           ldest,lxfer_options(ixfer_ptr))
        endif        
        if(kdisk2file_prev) then             
          call snap_wait_time(lufile,itime_disk_abort)
          call snap_disk2file_abort(lufile)
          kdisk2file_prev=.false.
        endif  
        if(cstrack(istn) .eq. "BB") then
           csetup_name="setupbb"
        else
           call setup_name(ccode(icod),csetup_name)
        endif 
        if(lsetup_proc .eq. "YES") then
            write(lufile,'(a)') "setup_proc="//csetup_name
        else
            write(lufile,'(a)') csetup_name
        endif                            
        if(km6disk) then
           nch=trimlen(scan_name(iskrec(iobs_now)))
           write(ldum,'("mk6=record=",
     >       i4.4,"y",i3.3,"d",i2.2,"h", i2.2,"m",i2.2,"s",":",
     >       i6,":",i6,":",a,":",a,":",a,";")')
     >       (itime_scan_beg(i),i=1,5),
     >       idur(istnsk), idata_mk6_scan_mb/(1000*8) ,       
     >       scan_name(iskrec(iobs_now))(1:nch),
     >       cexper,
     >       cpocod(istn)                             
             call drudg_write(lufile,ldum)     
          endif            
       endif

C Early start 
      if(krec .and. itearl(istn).gt.0) then ! early start
        if(.not.kcont.or.(kcont.and..not.krunning)) then ! continuous
C       always do unless continuous and already running
       
 
! Two options.
! 1. ical < itearl(istn). In this case start recording, then do cal.
! 2. ical > itearl(istn). in this case do cal, then start recording.

! Case 1.         
          if(ical .le. itearl(istn)) then 
            call snap_wait_time(lufile,itime_tape_start)             
            call snap_monitor(kin2net)
            if(.not. krunning) then
              call snap_start_recording(kin2net)
! Preob procedure. 
              call snap_wait_time(lufile,itime_cal)
              call drudg_write(lufile,cpre) 
              if(km6disk) then 
                write(ldum,'("mk6=rtime?",i10,";")') idata_mbps(istn)
                call drudg_write(lufile,ldum)       
              endif  
            endif
          else
            if(.not.krunning) then
! Preob procedure. 
              call snap_wait_time(lufile,itime_cal)
              call drudg_write(lufile,cpre) 
              if(km6disk) then 
                write(ldum,'("mk6=rtime?",i10,";")') idata_mbps(istn)
                call drudg_write(lufile,ldum)       
              endif  
            endif
            call snap_wait_time(lufile,itime_tape_start)             
            call snap_monitor(kin2net)
            if(.not. krunning) then
              call snap_start_recording(kin2net)
            endif
          endif 
        endif ! continuous
        endif !start tape early/issue ST again
     
C Wait until CAL time. Antenna is on-source as of this time.
!        if(.false.) then 
! If doing staggered start, change where Cal is put
        if(kstaggered_start) then
           continue           
        else 
          IF (ICAL.GE.1.and. .not. 
     >      (kPhaseRef_Prev.or.krunning)) then ! PREOB          
            
! Preob procedure. 
           call snap_wait_time(lufile,itime_cal)
           call drudg_write(lufile,cpre) 
           if(km6disk) then 
             write(ldum,'("mk6=rtime?",i10,";")') idata_mbps(istn)
             call drudg_write(lufile,ldum)       
           endif  
                 
          ENDIF ! cal and preob
        endif 

!--------------------- Begin  DATA_VALID   -------------------------------------
! write out 
!   !YYYY.DDD.HH:MM:SS
!   disk_pos  OR in2net        <---only if MK5B
        if(krec)  then                     !have a recorder and are recording
          if (kvex.and.kadap.and.krunning) then ! don't write time
            continue 
          else ! do write it             
! Write out monitor command. 
! If doing staggered start, wait until we are on source. 
            if(kstaggered_start) then 
              call snap_wait_time(lufile,itime_data_valid)
            else
              call snap_wait_time(lufile,itime_scan_beg)          
            endif 
          endif ! don't/do write
!Turn on running if necessary. 
          kdo_monitor=.true.                  !indicate that we should issue monitor command before data_valid
          if(.not.krunning) then
! Need to insert a 'disk_pos' command if we start recording. 
! This also means that we do not need to insert it later. 
            call snap_monitor(kin2net)       
            kdo_monitor=.false. 
            call snap_start_recording(kin2net)   
            if(kstaggered_start) then
! Insert preob procedure     
              call drudg_write(lufile,cpre)   
              call snap_monitor(kin2net)       
            endif 
          endif     
        endif
! Turn on flag indicating 
        krunning=.true.
  
! ISSUE:
!  !YYYY.DDD.HH:MM:SS    <--but only if differs from last time. 
!  data_valid=on
        call snap_get_last_wait_time(ilast_wait_time)        !Get the last wait time.

! First if:

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
 
! end ---------------- DATA_VALID  -----------------------------------
  
C MIDOB procedure   
        if(km6disk) then 
          write(ldum,'("mk6=rtime?",i10,";")') idata_mbps(istn)
            call drudg_write(lufile,ldum)      
        endif        
        call drudg_write(lufile,cmid)     
C Wait until data end time
        call snap_wait_time(lufile,itime_scan_end)       
        call snap_data_valid('=off')
 
C Stop data flag      
        if (krec) then ! non-zero recording scan      
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
        isorp = isor
        cwrap_pre = ccable(istnsk)
        iobs_this_stat = iobs_this_stat + 1
! Find out when the scan starts for this station. 
        call TimeSub(itime_scan_beg,itearl(istnsk),itime_tmp)
        call TimeAdd(itime_tmp,ioff(istnsk),itime_beg(1,iobs_this_stat))    
            
        if(kstop_tape) then
           krunning=.false.      
           do i=iscan_calc_start, iobs_this_stat
              itime_total_record(i)=
     >           iTimeDifSec(iTime_tape_stop,itime_beg(1,i))      
           end do   
           iscan_calc_start=iobs_this_stat+1
        endif
      
        iobs_this_stat_rec = iobs_this_stat_rec + 1
   
C POSTOB        
        IF ((klast_obs .or. .not. (kPhaseRef .or.krunning))) then        
          call drudg_write(lufile, cpst)        
        endif  

! Output check commands 
        if(klast_obs .or. 
     >     iscan_gap .ge. max_gap_time .and. max_gap_time .ne. -1) then
           call snap_check(lufile,itime_buf_write,kdata_xfer_prev)  
           kcheck_done=.true.
           krestart_obs=.true.  !This is strictly only true if (iscan_gap .ge. max_gap_time), but no harm done. 
        endif  
           
        if(km5disk) then
          if(kdisk2file) then
            nch=trimlen(scan_name(iobs_now))
            nch2=trimlen(ldest)
            if(nch2 .eq. 0) then
              cstat_code=cpocod(istn)
              nch3=trimlen(cstat_code)
              call lowercase(cstat_code)
              ldest=cexper(1:trimlen(cexper))//"_"//
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

! Save some results from previous scan. 
        mjdpre = JULDA(1,itime_scan_end(2),itime_scan_end(1)-1900)
        utpre= itime_scan_end(3)*3600.+itime_scan_end(4)*60.
     >       +itime_scan_end(5)
        if (utpre.gt.86400.d0) then
          utpre=utpre-86400.d0
          mjdpre = mjdpre+1
        endif

       kcheck_done_prev=kcheck_done 
       kPhaseRef_Prev=KPhaseRef
       iscan_gap_prev=iscan_gap
       icod_prev=icod
       kdata_xfer_prev=kdisk2file .or. kin2net 
       call copy_time(itime_scan_end, itime_scan_end_prev)
       call copy_time(itime_buf_write,itime_buf_write_prev)
    
      END DO ! ilen.gt.0,kerr.eq.0,ierr.eq.0

! Do any cleanup we need to do
      do i=iscan_calc_start, iobs_this_stat
           itime_total_record(i)=
     >         iTimeDifSec(iTime_tape_stop,itime_beg(1,i))     
      end do             
  
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
          itemp=itime_total_record(iobs_this_stat)      
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
        i1=trimlen(ldum)+1   
        ldum(i1+1:i1+1)=char(0)      
        call system(ldum(1:i1))
      endif 

      call drchmod(snpname,ierr)
      IF (iERR.NE.0) WRITE(LUSCN,9902) iERR,SNPNAME(1:ic)
9902  FORMAT(' SNAP03 - Error ',I5,' writing SNAP output file ',A)

      RETURN
      END
