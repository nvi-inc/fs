        SUBROUTINE SNAP(cr2)
C
C     SNAP reads a schedule file and writes a file with SNAP commands
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include 'hardware.ftni'           !This contains info only about the recorders.

C INPUT
      character*(*) cr2  ! Responses to three prompts for
C          1) epoch 1950 or 2000 <<<<<<< moved to control file
C          2) add checks Y or N <<<< not for S2
C          3) force checks Y or N <<<<<<< removed

! functions
      integer iTimeDifSec               !difference in seconds between two times
      real   tspin,speed ! functions

C  LOCAL:
C     IFTOLD - foot count at end of previous observation
C     TSPINS - time, in seconds, to spin tape
      integer*2 IBUF2(ibuf_len)
      integer*2 ibuf_next(ibuf_len)
      integer*2 lmodep(4),ldirp,lds,lfreq
c     integer itrax(2,2,max_chan) ! fanned-out version of itras
      integer ilen_next,ical_next,ipas_next(max_stn),ift_next(max_stn),
     > idirsp,
     .idur_next(max_stn),nstnsk_next,mjd_next,mon_next,ida_next,
     .ierr_next,isor_next,istnsk_next,icod_next,iobs_now
      integer iblen,ilen,iobss,iobs,iobsp,icheck,icheckp,iobsst,
     .isorp,ipasp,kerr,ical,nstnsk,
     .mjd,mon,ida,isor,istnsk,icod,ierr,ix,
     .nch,nc,irah,iram,idcd,idcm,l,idirp,idurp,
     > iftchk,
     > idirn,iftrem,ilatestop,
     > idum,ispm,ic,ichk,iset,ihd,isppl,il,mjdpre
      real tspins,sps,d,epoc,ras,dcs,tslew,dum
      integer*2 lsname_next(max_sorlen/2),lfreq_next,lpre_next(3),
     .lmid_next(3),lpst_next(3),ldir_next(max_stn),lstn_next(max_stn),
     .lcable_next(max_stn),lmon_next(2),lday_next(2)

      integer*2 lcbpre,lcbnow        !must be integer*2

      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .          LMON(2),LDAY(2),LPRE(3),LPST(3),LMID(3),LDIR(MAX_STN)
      integer   IPAS(MAX_STN),IFT(MAX_STN),IDUR(MAX_STN)
      integer ioff(max_stn),ioff_next(max_stn)
      integer idt,ituse
      double precision UT,GST,ut_next,gst_next,utpre
      double precision SORRA,SORDEC
      double precision RA,DEC,TJD,RAH,DECD,RADH,DECDD
      logical kup
C                         even though the tape_motion_type is adaptive
      real az,el,x30,y30,x85,y85,ha1,dc
      character*3  stat
C     character*28 cpass,cvpass
      character*1  maxchk,dopre
      logical kflg_next(4)

C     LMODEP - mode of previous observation
C     LDIRP  - direction of previous observation
C     IPASP - previous pass

C     IOBSP - number of obs. this pass
C     IOBS - number of obs in the schedule
C     iobss - number of obs for this station
C     iobsst - number of obs for this station that are recorded on tape
      character*7 cwrap ! cable wrap from CBINF
      integer*2 lwrap(4)
      logical KNEWTP,KNEWT
C      - true if a new tape needs to be mounted before
C        beginning the current observation
      integer jchar,trimlen,ir2as,ib2as,ichmv,iscnc,mcoma ! functions
      integer julda,iflch,ichcm,ichcm_ch,ichmv_ch

      logical krec ! true if the recorder is NOT "none"
      integer ntape ! count of tapes used in the schedule

! JMG variables
      integer iwait5sec
      parameter (iwait5sec=5)
      integer ifeet_next
      integer itime_scan_beg(5)             !start of scan: iyr,idoy,ihr,imin,isec
      integer itime_scan_end(5)             !end of scan    =istart+idur
      integer itime_off(5)                  !               =istart+ioff
      integer itime_early(5)                !early start    =istart-itearl
      integer itime_late(5)                 !late end       =iend+ilate
      integer itime_cal(5)         	    !cal		=istart-ical
      integer itime_check(5)                !time to do a check.
      integer itime_tape_start(5)           !
!
      integer itime_scan_beg_prev(5)        !ditto for previous measurement
      integer itime_scan_end_prev(5)
      integer itime_early_prev(5)
      integer itime_late_prev(5)
      integer itime_delta                   !Difference between two times in seconds
      integer itime_scan_beg_next(5)         !next measurement

      integer itime_pass_end(5)              !Time when we reach the end of this pass
      integer itime_temp(5)
      integer itemp             !short lived variable
      real    speed_ft          !Speed in feet.
! Logical variables
      logical kcont 		! true for CONTINUOUS recording
      logical kadap 		! true for ADAPTIVE recording in VEX file
      logical kcontpass       	! true if a pass is actually continuous
      logical knewpass  	! true if this obs on new pass.
!
      character*1 crecorder     ! temporary characer
      integer isession_len      !length of session code
      character*80 ldum
      character*12 lsession      !filename

! counter
      integer i
C
C  INITIALIZED:
      integer Z20,Z4000,Z100,Z24
      DATA Z20/Z'20'/,Z4000/Z'4000'/,Z100/Z'100'/
      DATA Z24/Z'24'/
      DATA LDIRP/2H  /
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
C 970731 nrv Add IOBSST to count number of obs recorded on tape
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
C 020304 nrv Add for Mk5 piggyback mode: READY_DISC, DISC_POS, DISC_START,
C            DISC_END,DISC_CHECK.
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
C

      iblen = ibuf_len*2
      if (kmissing) then
        write(luscn,9111)
9111    format(' SNAP00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your SNAP file may be incorrect or ',
     .  ' cause a program abort.')
      endif

      if (ichcm_ch(lstrack(1,istn),1,'unknown').eq.0.or.
     .    ichcm_ch(lstrec(1,istn),1,'unknown').eq.0) then
        write(luscn,9102)
9102    format(/' SNAP01 - Rack or recorder type is unknown. Please',
     .  ' specify your '/
     .  ' equipment using Option 11 or the EQUIPMENT line in the ',
     .  ' control file.')
        return
      endif


      call strip_path(lskdfi,lsession)
      isession_len=index(lsession,".")
      lsession(isession_len:12)=" "

      call init_hardware_common(istn)
      MaxTapeLen=MaxTap(istn)
      krec_append = nrecst(istn).gt.1 .and. cstrec(istn)(1:4).ne."none"

C 2. Check the type of equipment so that bit density is correct.
C   For VEX files the rack and recorder info is taken from the schedule. 
C   For non-VEX, the user specified either Mk3/4 or VLBA back end.
C   For S2, since this must be a VEX file, we will rely on the schedule 
C   for the rack type.
C     ks2=.false.
C     kk4=.false.
C     if (ichcm_ch(lstrack(1,istn),1,'unknown').eq.0.or.
C    .    ichcm_ch(lstrec (1,istn),1,'unknown').eq.0) then ! take user input
C     Modify bit density and recording format according to formatter type.
C       if (iin.eq.1) then ! Mark III/IV formatter and DR format
C         do i=1,ncodes
C           Force the format to "M" as the only way this formatter can go.
C           idum = ichmv_ch(lmfmt(1,istn,i),1,'M')
C           if (bitdens(istn,i).lt.40000.d0) then
C             bitdens(istn,i) = 33333.0
C           else
C             bitdens(istn,i) = 56250.0 
C           endif
C         enddo
CC      else if (iin.eq.2) then ! VLBA formatter
CC        do i=1,ncodes
CC          Use the format taken from the mode name. Leave the bit
CC          density alone too.
CC          if (bitdens(istn,i).lt.40000.d0) then
CC            bitdens(istn,i) = 34020.0
CC          else
CC            bitdens(istn,i) = 56700.0 
CC          endif
CC        enddo
C       else if (iin.eq.3) then ! K4 recorder
C         kk4=.true.
C       else if (iin.eq.4) then ! S2 recorder
C         ks2=.true.
C       endif
C     else ! in the schedule file
C       ks2=   ichcm_ch(lstrec(1,istn),1,'S2').eq.0
C       kk4=   ichcm_ch(lstrec(1,istn),1,'K4').eq.0 
C     endif

C    1. Prompt for additional parameters, epoch of source positions
C    and whether maximal checks are wanted.

      WRITE(LUSCN,9100) (LSTNNA(I,ISTN),I=1,4)
9100  format(/'SNAP output for ',4a2)
      ierr=1

      if (ks2rec(1).or.ks2rec(2).or.kk41rec(1).or.kk41rec(2).or.
     .    kk42rec(1).or.kk42rec(2).or.km5rec(1).or.km5rec(2)) then
        maxchk = 'N'
        dopre = 'N'
      else
        call snap_info(cr2,maxchk,dopre)
      endif

C     1. Create output file for SNAP commands.  If problems, quit.
      stat='new'

C     check to see if the file exists first, and if so, purge it.
      call purge_file(snpname,luscn,luusr,kbatch,ierr)
      if(ierr .ne. 0) return

      luFile=lu_outFile

      ix = trimlen(lskdfi)
      WRITE(LUSCN,9900) cSTNNA(istn),LSKDFI(1:IX),
     >    SNPNAME(1:trimlen(snpname))
9900  FORMAT(' TRANSLATION FOR ',A8,' FROM FILE ',A,
     .       ' TO SNAP FILE ',A)
      open(unit=LU_OUTFILE,file=SNPNAME,status=stat,iostat=IERR)
      IF (IERR.eq.0) THEN
        call initf(LU_OUTFILE,IERR)
        rewind(LU_OUTFILE)
      ELSE
        WRITE(LUSCN,9131) IERR,SNPNAME(1:IC)
9131    FORMAT(' SNAP02 - Error ',I6,' creating file ',A)
        return
      END IF
C
C     2. Initialize counts.  Begin loop on schedule file records.
C
      IOBSP = 0
      iobss=0
      iobsst=0

      icheck=0
      icheckp=0
      idum = ichmv_ch(lmodep,1,'        ')
      tspins=0.0
      IPASP = -1
      IFTOLD = 0
      kerr=0
      ilen = 999
      kspin = .false.
      ket = .false.
      krunning = .false.
      ilatestop=0
      istnsk=0
      ntape=0

      do i=1,5
        itime_scan_beg_prev(i)=0
        itime_scan_beg_next(i)=0
      end do

      kadap= (tape_motion_type(istn).eq.'ADAPTIVE')
      kcont= (tape_motion_type(istn).eq.'CONTINUOUS')

C Initialize recorder information.
      call hol2char(lfirstrec(istn),1,1,crecorder)
      if (crecorder.eq.'1') then ! first recorder
        irec=1
        kk4 = kk41rec(1).or.kk42rec(1)
        ks2 = ks2rec(1)
        krec= cstrec(istn) .ne. 'none'
        km5 = km5rec(1) .or. km5prec(1)
      else ! second recorder
        irec=2
        kk4 = kk41rec(2).or.kk42rec(2)
        ks2 = ks2rec(2)
        km5 = km5rec(2) .or. km5prec(2)
        krec= cstrec2(istn) .ne. 'none'
      endif

      iobs=0
      do while (istnsk.eq.0.and.ilen.ge.0) ! Get first scan for this station into IBUF
        call ifill(ibuf,1,iblen,oblank)
        IOBS = IOBS + 1
        if (iobs.le.nobs) then
          idum = ichmv(ibuf,1,lskobs(1,iskrec(iobs)),1,iblen)
          ilen = iflch(ibuf,iblen)
          CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     >      itime_scan_beg(1),itime_scan_beg(2),itime_scan_beg(3),
     >      itime_scan_beg(4),itime_scan_beg(5),
     >      IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     >      MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
          CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
          IF (ISOR.EQ.0.OR.ICOD.EQ.0) RETURN
        else
          ilen=-1
        endif
      enddo ! get first scan for this station into IBUF

C  Precess the sources to today's date for slewing calculations.
      TJD = JULDA(MON,IDA,itime_scan_beg(1)-1900) + 2440000.0D0
      DO I=1,NCELES
        RA = SORP50(1,I)
        DEC = SORP50(2,I)
        RAH = RA*12.D0/PI
        DECD = DEC*180.D0/PI
        CALL APSTAR(TJD,3,RAH,DECD,0.D0,0.D0,0.D0,0.D0,RADH,DECDD)
        SORPDA(1,I) = RADH*PI/12.D0
        SORPDA(2,I) = DECDD*PI/180.D0
      enddo

      call snapintr(1,itime_scan_beg(1))
C
      DO WHILE (ILEN.GT.0.AND.KERR.EQ.0.and.ierr.eq.0
     ..AND.JCHAR(IBUF,1).NE.Z24)
C
        istnsk_next=0
        iobs_now = iobs ! save current obs number for scan ID
        do while (istnsk_next.eq.0) ! Get NEXT scan for this station into ibuf_next
          call ifill(ibuf_next,1,iblen,oblank)
          IOBS = IOBS + 1
          if (iobs.le.nobs) then
            idum = ichmv(ibuf_next,1,lskobs(1,iskrec(iobs)),1,
     .      iblen)
            ilen_next = iflch(ibuf_next,iblen)
            CALL UNPSK(IBUF_next,ILEN_next,LSNAME_next,ICAL_next,
     >        LFREQ_next,IPAS_next,LDIR_next,IFT_next,LPRE_next,
     >        itime_scan_beg_next(1),itime_scan_beg_next(2),
     >        itime_scan_beg_next(3),
     >        itime_scan_beg_next(4),itime_scan_beg_next(5),
     >        IDUR_next,
     >        LMID_next,LPST_next,NSTNSK_next,LSTN_next,LCABLE_next,
     >        MJD_next,UT_next,GST_next,MON_next,IDA_next,
     >        LMON_next,LDAY_next,IERR_next,KFLG_next,ioff_next)
            CALL CKOBS(LSNAME_next,LSTN_next,NSTNSK_next,LFREQ_next,
     >        isor_next,ISTNSK_next,ICOD_next)
C           call sname(idayr_next,ihr_next,imin_next,
C    .      scan_namep,scan_name_next)
C           idum = ichmv(scan_namep,1,scan_name_next,1,16)
            IF (ISOR_next.EQ.0.OR.ICOD_next.EQ.0) RETURN
          else
            ilen=-1
            istnsk_next=999
          endif
        enddo ! get NEXT scan for this station into ibuf_next

        if(istnsk_next .ne. 999) ifeet_next=ift(istnsk_next)
C
        IF (ISTNSK.NE.0)  THEN ! our station is in this scan
          IF (ichcm_ch(LDIR(ISTNSK),1,'R').eq.0) IDIR=-1
          IF (ichcm_ch(LDIR(ISTNSK),1,'F').eq.0) IDIR=+1
          IF (ichcm_ch(LDIR(ISTNSK),1,'0').eq.0) idir=0
C         leave IDIR set to the previous value ?
C         or set a special flag for non-recording scans
          IF (ichcm_ch(LDIR_next(ISTNSK),1,'R').eq.0) IDIRn=-1
          IF (ichcm_ch(LDIR_next(ISTNSK),1,'F').eq.0) IDIRn=+1
          IF (ichcm_ch(LDIR_next(ISTNSK),1,'0').eq.0) IDIRn= 0

C****************************************************************
C This is the confusing part where certain timings are set up,
C depending on the type of tape motion. This part needs to be
C cleaned up and rationalized when sked and sched are both using
C the same logic.
C****************************************************************
C  2.5  Calculate all the times and flags we will need. 

C  Does this obs start a new tape?
          if (.not.km5.and.idir.ne.0) then
            KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .      IDIRP,IFTOLD)
          else
            knewtp = .false.
          endif
C         Force new tape on the first scan on tape.
          if (iobsst.eq.0) knewtp=.true.

          if(iobsst .gt. 0) then
            do i=1,5
              itime_early_prev(i)	=itime_early(i)
              itime_scan_beg_prev(i)	=itime_scan_beg(i)
              itime_scan_end_prev(i)	=itime_scan_end(i)
              itime_late_prev(i)	=itime_late(i)
            end do
          endif

          if(knewtp) then
            speed_ft=speed(icod,istn)
            call snap_recalc_speed(luscn,kvex,speed_ft,
     >          ls2speed(1,istn),ibuf)
          endif

          kNewPass = (ipasp.ne.ipas(istnsk))

! Data end time=itime_scan_beg+duration.
          call TimeAdd(itime_scan_beg,idur(istnsk),itime_scan_end)
! Cal time= itime_scan_beg-ical
          call TimeSub(itime_scan_beg,ical,itime_cal)

!     itime_early=itime_scan_beg - early_start
          call TimeSub(itime_scan_beg,itearl(istn),itime_early)
          do i=1,5
           itime_tape_start(i)=itime_early(i)
          end do
!     itime_late=itime_scan_end+itlate
          call TimeAdd(itime_scan_end,itlate(istn),itime_late)

C     Now determine whether the tape will be stopped (ket).
C     For "adaptive" motion, stop the tape if the time between one
C     tape stop and the next tape start is longer than the specified 
C     time gap. For "continuous" tape is nominally never stopped.
C  
        if(kadap) then
          if(ks2) then          !s2
            if (iobsst.gt.0) then ! got a previous scan
              idt = iTimeDifSec(itime_early,itime_late_prev)
              ket = idt.gt.itgap(istn)
            else ! first scan
              ket = .false.
            endif
C Restore the following for adaptive -- using gap time.
C This is restricted to "adaptive" coming from VEX files.
          else  		!not ks2
            if (istnsk_next.ne.999) then ! next scan
              if (idirn.eq.idir) then ! same direction, check gap
                idt=iTimeDifSec(itime_scan_beg_next,itime_late)-
     >                              itearl(istn)
                ket = idt.gt.itgap(istn)
                if (ket) kcontpass = .false. ! this pass not continuous
C               Use the offsets instead of slewing to determine good data time
C               time5 = data start = tape start + offset
                call TimeAdd(itime_scan_beg,ioff(istnsk),itime_off)
                do i=1,5
                  itime_tape_start(i)=itime_off(i)
                end do
              else ! new direction, must stop
                ket = .true.
                kcontpass = .true. ! reset to true at start of a new pass
              endif ! same/new direction
            else ! no next
              ket = .true.
            endif ! next/last
          endif                 !S2 OR NOT S2
C Use this section only for continuous
        else if (kcont) then
          ilatestop=0
          ket = .false.
          if (iobsst.ne.0) then    ! calculate new times based
            lcbnow=lcable(istnsk)  !need to do this becase slewo CHANGES lcable(istnsk)
            call slewo(isorp,mjdpre,utpre,isor,istn,lcbpre,
     >        lcbnow,tslew,0,dum)
            if (tslew.lt.0) tslew=0.0
            if (.not.kNewPass) then ! this obs on same pass
! If on same pass, data valid as soon as on source.
              call TimeAdd(itime_scan_end_prev,ifix(tslew)+ical,
     >                 itime_scan_beg)
              call TimeSub(itime_scan_beg,ical,itime_cal)
              call TimeSub(itime_scan_beg,itearl(istn),itime_early)
              do i=1,5
                itime_tape_start(i)=itime_early(i)
              end do
            else ! this obs on new pass
!              if(idirp .eq. +1) iftrem = maxtap(istn)-iftold
!              if(idirp .eq. -1) iftrem = iftold
              if(idirp .eq. +1) iftrem=ift(istnsk)-iftold
              if(idirp .eq. -1) iftrem=iftold-ift(istnsk)
!             iftrem= feet remaining on the pass from the ending footage of last scan
              ilatestop=max(nint(float(iftrem)/speed_ft),1)
              call TimeAdd(itime_scan_end_prev,ilatestop,itime_pass_end)
              call TimeSub(itime_scan_beg,itearl(istn),itime_tape_start)
!              do i=1,5
!                itime_tape_start(i)=itime_scan_beg(i)
!              end do
            endif ! same pass/new pass
          endif !  calculate new times
        else ! start& stop OR new direction
          ket = .true.
        endif

C       always stop on the last scan but not for late stop.
        if (istnsk_next.eq.999.and.itlate(istn).eq.0) ket=.true.
C         always stop if S2 mode changes for the next scan.
        if (ks2.and.ichcm(lmode(1,istn,icod_next),1,
     .    lmode(1,istn,icod),1,8).ne.0) ket=.true.

C <<<previous>>>>  <<<<<<<<<<current>>>>>>>>>>>>>>>>>>>>>>  <<<next>>>>>>>>>
C time4=   time6=  time5=         time= time2=       time6=  time5_next=
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
        nch=trimlen(scan_name(iobs_now))
        write(ldum,'("scan_name=",a,",",a,",",i4)')
     >    scan_name(iobs_now)(1:nch),lsession,idur(istnsk)
        call squeezewrite(lufile,ldum)       !get rid of spaces, and write it out.

C SOURCE command
        IOBSP = IOBSP+1
        CALL IFILL(IBUF2,1,iblen,32)
        NCH = ichmv_ch(IBUF2,1,'SOURCE=')
        ituse=0
C       For celestial sources, set up normal command
C               SOURCE=name,ra,dec,epoch 
        IF (ISOR.LE.NCELES) THEN !celestial source
          NC = ISCNC(LSORNA(1,ISOR),1,max_sorlen,Z20)
          IF (NC.EQ.0) NC=max_sorlen+1
          NCH = ICHMV(IBUF2,NCH,LSORNA(1,ISOR),1,NC-1)
          NCH = MCOMA(IBUF2,NCH)
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
C         Right ascension, hhhmmss.s
          nch = nch + ib2as(irah,ibuf2,nch,Z4000+2*Z100+2)
          nch = nch + ib2as(iram,ibuf2,nch,Z4000+2*Z100+2)
          nch = nch + ir2as(ras,ibuf2,nch,-5,-2)
          NCH = MCOMA(IBUF2,NCH)
C         Declination, sddmmss.s
          IF (ichcm_ch(LDS,1,'-').eq.0) NCH = ICHMV(IBUF2,NCH,LDS,1,1)
          if (dcs+0.5d0.ge.60.d0) then
            dcs=0.d0
            idcm=idcm+1
            if (idcm.ge.60) then
              idcm=idcm-60
              idcd=idcd+1
            endif
          endif
          nch = nch + ib2as(idcd,ibuf2,nch,Z4000+2*Z100+2)
          nch = nch + ib2as(idcm,ibuf2,nch,Z4000+2*Z100+2)
          nch = nch + ir2as(dcs,ibuf2,nch,-4,-1)

C         Epoch of position
          NCH = MCOMA(IBUF2,NCH)
          NCH = NCH + IR2AS(EPOC,IBUF2,NCH,6,1)

C         Add cable wrap indicator for azel stations.
          if (iaxis(istn).eq.3.or.iaxis(istn).eq.6
     >                        .or.iaxis(istn).eq.7)  then
            NCH = MCOMA(IBUF2,NCH)
            call cbinf(lcable(istnsk),cwrap)
            il=trimlen(cwrap)
            call char2hol(cwrap,lwrap,1,il)
            nch=ichmv(ibuf2,nch,lwrap,1,il)
          endif
        else !satellite
          NCH = ichmv_ch(IBUF2,NCH,'AZEL')
          NCH = MCOMA(IBUF2,NCH)
          CALL CVPOS(ISOR,ISTN,MJD,UT,AZ,EL,HA1,DC,X30,Y30,X85,Y85,KUP)
          az=az*180.0/pi
          nch = nch + ir2as(az,ibuf2,nch,7,-3)
          nch = ichmv_ch(ibuf2,nch,'D')
          NCH = MCOMA(IBUF2,NCH)
          el=el*180.0/pi
          nch = nch + ir2as(el,ibuf2,nch,6,-3)
          nch = ichmv_ch(ibuf2,nch,'D')
        endif !celestial/satellite
        NCH = ichmv_ch(IBUF2,NCH,' ')-1
        call hol2lower(ibuf2,(nch+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
C
C  For S2 or continuous, stop tape if needed after the SOURCE command
        if ((krec.and.idir.ne.0.and.
     .       ks2.and.itlate(istn).gt.0.and.iobsst.ne.0.and.
     .       ipasp.ge.0.and.(knewtp.or.ket.or.kNewPass.or.
     .       ichcm(lmodep,1,lmode(1,istn,icod),1,8).ne.0))
     .      .or.
     .       (.not.ks2.and.kcont.and.iobsst.ne.0.and.idir.ne.0.and.
     >           krec.and.
     .          (ilatestop.gt.0.or.knewtp .or.idirp.ne.idir))) then
            krunning=.false.
! This is time to reach end of tape.
!           TSPINS = TSPIN(IFTREM,ISPM,SPS)
            call snap_wait_time(itime_pass_end)
            call snap_et
        endif

        if (idir.ne.0.and.krec) then ! skip tape stuff if not recording
C MIDTP procedure when changing direction
C Note this will never be called for S2 because it only records forward.
          if (.not.(kk4 .or. ks2.or.km5)) then ! check for mid-tape
            IF (KNEWTP) IOBSP = 1  ! first observation on this pass
            IF (LDIR(ISTNSK).NE.LDIRP.AND..NOT.KNEWTP.AND.IPASP.GT.-1)
     >        THEN
              icheck = 1 !do a check after this observation
              IOBSP = 1
              call snap_midtp()
            else
              icheck=0
            END IF
          endif ! check for mid-tape

C Calculate tape spin time. But don't do for ks2,kk4,km5 or continuous.
         if (.not.(ks2 .or.kk4.or.km5.or.kcont)) then
            TSPINS = TSPIN(IABS(IFT(ISTNSK)-IFTOLD),ISPM,SPS)
            IF (IFT(ISTNSK).LT.IFTOLD) idirsp=-1
            IF (IFT(ISTNSK).gT.IFTOLD) idirsp=+1
          endif
C
C Unload tape.
          IF (.not.km5.and.(KNEWTP.AND.IOBSst.NE.0)) THEN !unload old tape
            call snap_unload_tape(itime_late, nrecst(istn),ntape,
     >                     kpostpass,kcontpass,kcont)
            iobsst=0
C Switch recorders if we have two of them, and they are both used.
            if(nrecst(istn) .eq. 2 .and. .not.
     >        (cstrec(istn) .eq."unused".or.cstrec(istn).eq."none" .or.
     >         cstrec2(istn).eq."unused".or.cstrec2(istn).eq."none"))
     >                                                             then
              if (irec.eq.1) then
                irec=2
                kk4 = kk41rec(2).or.kk42rec(2)
                ks2 = ks2rec(2)
                krec=cstrec(istn) .ne. "none"
              else
                irec=1
                kk4 = kk41rec(1).or.kk42rec(1)
                ks2 = ks2rec(2)
                krec=cstrec2(istn) .ne. "none"
              endif
            endif ! don't/switch
! do end of tape housework
          END IF !unload old tape.
        endif ! skip the tape stuff if not recording
C
C Check procedure
C For continuous tape motion, check after tape stops at end of a pass
        if (krec) then ! recording
          ICHK = 0
C         Add "not krunning" so we don't try a check while it's moving!
          IF (.not.krunning.and..not.(ks2.or.kk4.or.km5)
     .      .and..NOT.KNEWTP.AND.IOBSst.GT.0) THEN !check procedure
          IF ((.not.kcont.and.KFLG(2).and.(iobsp.eq.2.or.icheckp.eq.1))
     .       .or.(kcont.and.kflg(2).and.iobsp.eq.1)
     .       .or.MAXCHK.eq.'Y') THEN ! see if there's time to do a check
C        Do check if flag is set, but only if there is enough time.
C        Or, do check if MAXCHK and if there is enough time.
C        Enough time = (SOURCE+SPIN+SETUP+TAPE+3S+head) < IPARTM
            IHD = 0
            if (ldirp.ne.ldir(istnsk)) ihd=ihdtm
            iset=0
            if (ldirp.ne.ldir(istnsk).or..not.kflg(1)) iset=isettm
            ISPPL = TSPINS + ISET+ISORTM+ITAPTM+ihd+3
C           Add the procedure times to the previous data stop (time4).
            if (ilatestop.eq.0) then
              call TimeAdd(itime_scan_end_prev,isppl,itime_check)
            else
              call TimeAdd(itime_late_prev,isppl,itime_check)
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
C
C Put READY before SETUP as of 12/97. Do SETUP READY SETUP for first tape.
C 
C READY
        IF (KNEWTP.and.idir.ne.0.and.krec) THEN ! new tape
          if (iobss.eq.0) then ! do a SETUP first
             call snap_setup(ipas,istnsk,icod,iobs,kerr)
          endif ! do a SETUP first
          call snap_ready(ntape)

C Prepass new tape
          IF (dopre.eq.'Y'.and.KFLG(3)) THEN !prepass
            call snap_prepass()
          END IF !prepass
          IF (.not.(km5.or.ks2.or.kk4) .and.IFT(ISTNSK).GT.100) THEN !spin up
            TSPINS=TSPIN(IFT(ISTNSK),ISPM,SPS)
            call snap_fast(ifstfor,ISPM,SPS,nrecst(istn))     !fast forward
          END IF ! spin up
C Set TSPINS zero here so that no other spin is done
C (move out from previous if test)
          TSPINS=0.0
        END IF ! new tape

C UNLOADER 
C Called for S2 if the group changed since the last pass
        if (ks2.and..not.knewtp.and.ipasp.ne.-1.and.
     .      kNewPass) then
          call snap_s2_unloader()
        endif

C SETUP procedure 
C This is called on the first scan, if the setup is wanted on this
C scan (flag 1=Y), if tape direction changes, or if a check was done
C prior to this scan. Do only on a new pass for continuous. But
C do it every scan for S2.
         if ((.not.kvex.and..not.kcont).or.(kcont.and..not.krunning).or.
     >        (kvex.and..not.krunning).or.ks2) then
        IF (IOBSs.EQ.0.OR.KFLG(1).OR.LDIRP.NE.LDIR(ISTNSK)
     >       .OR.ICHK.EQ.1) THEN
          if (iobss.eq.0.and.(ks2.or.km5)) then
               ! don't do second setup at start for S2 or Mk5
          else ! do it
              call snap_setup(ipas,istnsk,icod,iobs,kerr)
          endif ! don't do second setup at start for S2 or Mk5
        END IF
        endif
C
C LOADER 
C Called for S2 if the group changed since the last pass
        if (ks2.and..not.knewtp.and.ipasp.ne.-1.and. knewPass) then
          call snap_s2_loader()
        endif
C
C Spin new tape if necessary to reach footage
C Don't spin if we're already running. (? shouldn't happen?)
        IF (idir.ne.0.and..not.krunning.and..not.(ks2.or.kk4.or.km5)
     .     .and.TSPINS.GT.5.0.and.krec) THEN
          call snap_fast(idirsp,ISPM,SPS, nrecst(istn))
          TSPINS = 0.0
        END IF
C K4 initialize whether drum command was written.
        kdrum=.false.

C Early start 
        if (idir.ne.0.and.krec) then ! this is a non-zero recording scan
        if (itearl(istn).gt.0) then ! early start
        if (.not.kcont.or.(kcont.and..not.krunning)) then ! continuous
C       always do unless continuous and already running
C         If FASTx preceeded, add a wait for tape to slow down
          if (kspin) then
            call snap_wait_sec(iwait5sec)
            kspin = .false.
          endif
C  Wait until ITEARL before start time
          if (.not.krunning) ituse=1 ! Don't use early start if already running
          call snap_wait_time(itime_tape_start)
C   Write out tape monitor command at early start
          call snap_monitor()
          if(.not. krunning) call snap_start_recording()
        endif ! continuous
        endif !start tape early/issue ST again
        endif !non-zero scan
C Wait until CAL time. Antenna is on-source as of this time.
C No PREOB if tape is running in a VEX file.
        IF (ICAL.GE.1.and.(.not.kvex.or.(kvex.and..not.krunning))) THEN ! cal and preob
           call snap_wait_time(itime_cal)
C PREOB procedure
           call snap_hol_wrt(lu_outfile,lpre,6)
        ENDIF ! cal and preob

C Wait until data start time
        if (kvex.and.kadap.and.krunning.and..not.ks2) then ! don't write time
        else ! do write it
           call snap_wait_time(itime_scan_beg)
        endif ! don't/do write

C S2 DATA_VALID 
        if (krec.and.idir.ne.0) then ! non-zero recording scan
          if (ks2) then
            call snap_data_valid('=on')
          endif

C TAPE monitor command
          if (kvex.and.kadap.and.krunning.and..not.ks2) then ! don't write tape
          else ! do write it
            call snap_monitor()
          endif ! don't/do write

C Start tape if not already running.
          if (.not.krunning)  call snap_start_recording

C Wait until good data time for VEX files
          idt = iTimeDifSec(itime_scan_end,itime_tape_start)
          if (idt.gt.0) then ! some valid data
            if (kvex.and.kadap.and..not.ks2) then ! good data time
              call snap_wait_time(itime_tape_start)
              call snap_monitor()
            endif ! good data time
C Good data flag -- AFTER the ST command or good-data time
            if (.not.ks2) then ! non-S2 data valid
              call snap_data_valid('=on')
            endif ! non-S2 data valid
          endif ! some valid data
        endif ! non-zero recording scan
C MIDOB procedure
        call snap_hol_wrt(lu_outfile,lmid,6)

C Wait until data end time
        call snap_wait_time(itime_scan_end)
C Stop data flag
        if (krec.and.idir.ne.0) then ! non-zero recording scan
          call snap_data_valid('=off')
C ET command
          if ((.not.ks2.and..not.kcont.and.
     .        (ket.or.ipas_next(istnsk).ne.ipas(istnsk)))
     .        .or.
     .        (ks2.and.ket.and.itlate(istn).eq.0)) then !ET command
C         Wait until late stop time before issuing ET
            if (itlate(istn).gt.0) then
               call snap_wait_time(itime_late)
            endif

            krunning = .false.
            if (km5) then ! disk
              call snap_disc_end()
            else ! tape
              call snap_et()
            endif
          endif! ET command
          call snap_monitor()
C Do DISC_CHECK for Mk5 in piggyback mode.
          if (km5 .or. km5a_piggy .or. km5p_piggy) then
            call snap_disc_check()
          endif
C S2 DATA_VALID 
          if (ks2.and..not.krunning) then ! need another data_valid off
            call snap_data_valid('=off')
          endif
        endif ! non-zero recording scan

C Save information about this scan before going on to the next one
        idum = ichmv(lmodep,1,LMODE(1,istn,ICOD),1,8)
        IPASP = IPAS(ISTNSK)
        isorp = isor
        icheckp=icheck
        lcbpre = lcable(istnsk)
        IOBSs = IOBSs + 1
        if (idir.ne.0) then ! update direction and footage
          IOBSst = IOBSst + 1
          LDIRP = LDIR(ISTNSK)
          idirp=idir
          idurp=idur(istnsk)
          IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ituse*ITEARL(istn)+
     .        IDUR(ISTNSK))*speed_ft)
        endif ! update direction and footage
C POSTOB
        call snap_hol_wrt(lu_outfile,lpst,6)

!       utpre = ihr4*3600.d0+min4*60.d0+isc4 + idur(istnsk)
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
        idum = ichmv(ibuf,1,ibuf_next,1,iblen)
        ilen = iflch(ibuf,iblen)
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     >      itime_scan_beg(1),itime_scan_beg(2),itime_scan_beg(3),
     >      itime_scan_beg(4),itime_scan_beg(5),
     >      IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     >      MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
        CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
      endif

      END DO ! ilen.gt.0,kerr.eq.0,ierr.eq.0


! Finish up.
      call snap_unload_tape(itime_late,nrecst(istn),ntape,
     >                     kpostpass,kcontpass,kcont)
C End of schedule
      write(Lu_outFile,'(a)') "sched_end"
C
      close(LU_OUTFILE,iostat=IERR)
      call drchmod(snpname,iperm,ierr)
      IF (KERR.NE.0) WRITE(LUSCN,9902) KERR,SNPNAME(1:ic)
9902  FORMAT(' SNAP03 - Error ',I5,' writing SNAP output file ',A)
      RETURN
      END
