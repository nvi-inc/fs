        SUBROUTINE SNAP(cr2,iin)
C
C     SNAP reads a schedule file and writes a file with SNAP commands
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C INPUT
      character*(*) cr2  ! Responses to three prompts for
C          1) epoch 1950 or 2000 <<<<<<< moved to control file
C          2) add checks Y or N <<<< not for S2
C          3) force checks Y or N <<<<<<< removed
      integer iin ! 1=Mk3/4 back end, 2=VLBA back end. This is ignored
C                   for VEX files which already have this information.
C
C  LOCAL:
C     IFTOLD - foot count at end of previous observation
C     TSPINS - time, in seconds, to spin tape
      integer*2 IBUF2(ibuf_len),ibuf_save(5)
      integer*2 ibuf_next(ibuf_len)
      integer*2 lmodep(4),ldirp,lspdir,lds,lfreq,lspd(4)
      integer itrax(2,2,max_chan) ! fanned-out version of itras
      integer ilen_next,ical_next,ipas_next(max_stn),ift_next(max_stn),
     .iyr_next,idayr_next,ihr_next,imin_next,isc_next,
     .idur_next(max_stn),nstnsk_next,mjd_next,mon_next,ida_next,
     .ierr_next,isor_next,istnsk_next,icod_next
      integer iblen,i,ilen,iobss,iobs,iobsp,icheck,icheckp,
     .ipasp,iftold,kerr,ical,iyr,idayr,ihr,imin,isc,nstnsk,
     .mjd,mon,ida,isor,istnsk,icod,idir,id,iyr2,ierr,ix,idayr2,
     .ihr2,min2,isc2,iyr3,idayr3,ihr3,min3,isc3,iyr5,idayr5,ihr5,
     .min5,isc5,nch,nc,irah,iram,idcd,idcm,l,idirp,nspd,
     .iyr6,idayr6,ihr6,min6,isc6,
     .iyr7,idayr7,ihr7,min7,isc7,
     .iyr5_next,idayr5_next,ihr5_next,min5_next,isc5_next,
     .idum,ispm,isps,ic,ichk,iset,ihd,isppl,iyr4,idayr4,ihr4,
     .min4,isc4,iyrch,idayrch,ihrch,minch,iscch,ndx,isp,il
      real tspins,d,epoc,ras,dcs,spdips
      integer*2 lsname_next(max_sorlen/2),lfreq_next,lpre_next(3),
     .lmid_next(3),lpst_next(3),ldir_next(max_stn),lstn_next(max_stn),
     .lcable_next(max_stn),lmon_next(2),lday_next(2)
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .          LMON(2),LDAY(2),LPRE(3),LPST(3),LMID(3),LDIR(MAX_STN)
      integer   IPAS(MAX_STN),IFT(MAX_STN),IDUR(MAX_STN)
      integer npmode,itrk(max_track),nco,idt
      integer*2 lpmode(2)
      double precision UT,GST,ut_next,gst_next
      double precision SORRA,SORDEC
      real az,el,x30,y30,x85,y85,ha1,dc
      character*4  response
      character*3  stat
      character*28 cpass,cvpass
      character    upper
      character*1  maxchk
      logical    ex
      logical kintr ! false until intro lines have been written
      logical kflg_next(4)
      logical      kdone,kspin,kup
      logical ks2 ! true for S2 recorder
      logical kadaptive ! true for adaptive tape motion type
      logical ket ! true if the tape is going to be stopped for this scan
      logical krunning ! true when the tape is running
C     LMODEP - mode of previous observation
C     LDIRP  - direction of previous observation
C     IPASP - previous pass

C     IYR ,IHR , etc. - start time of obs.
C     IYR2,IHR2, etc. - stop time
C     IYR3,IHR3, etc. - start time minus cal time
C     IYR4,IHR4, etc. - previous stop time + spin + check
C     IYR5,IHR5, etc. - start time minus early
C     IYR6,IHR6, etc. - previous stop time + late-stop
C     IOBSP - number of obs. this pass
C     IOBS - number of obs in the schedule
C     iobss - number of obs for this station
      character*7 cwrap ! cable wrap from CBINF
      integer*2 lwrap(4)
      real spd
      logical KNEWTP,KNEWT
C      - true if a new tape needs to be mounted before
C        beginning the current observation
Cinteger*4 ifbrk
      integer jchar,trimlen,ir2as,ib2as,ichmv,iscnc,mcoma ! functions
      integer iflch,ichcm,ichcm_ch,ichmv_ch,isecdif
      real tspin,speed ! functions
C
C  INITIALIZED:
      integer*2   LFOR  (  2 )
      integer*2   LREV  (  2 )
      integer*2   ldirc,hrb,hmb
      integer Z20,Z41,Z4000,Z100,Z8000,Z24
      DATA Z20/Z'20'/,Z41/Z'41'/,Z4000/Z'4000'/,Z100/Z'100'/
      DATA Z8000/Z'8000'/, Z24/Z'24'/
      data HRB/2HR /, HMB/2H- /
      DATA LFOR /2Hfo,2Hr,/
      DATA ldirc/2HF /
      DATA LREV /2Hre,2Hv,/
      DATA LDIRP/2H  /
      data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
      data cvpass /'abcdefghijklmnopqrstuvwxyzAB'/
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
C
C
      iblen = ibuf_len*2
      if (kmissing) then
        write(luscn,9111)
9111    format(' SNAP00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your SNAP file may be incorrect or ',
     .  ' cause a program abort.')
      endif

C 2. Check the type of equipment so that bit density is correct.
C   For VEX files the rack and recorder info is taken from the schedule. 
C   For non-VEX, the user specified either Mk3/4 or VLBA back end.
C   For S2, since this must be a VEX file, we will rely on the schedule 
C   for the rack type.
      ks2=.false.
      if (ichcm_ch(lstrack(1,istn),1,'unknown ').ne.0.and.
     .    ichcm_ch(lstrec (1,istn),1,'unknown ').ne.0) then ! in VEX file
        ks2=   ichcm_ch(lstrec(1,istn),1,'S2').eq.0
      else ! take user input 
C     Modify bit density and recording format according to formatter type.
        if (iin.eq.1) then ! Mark III/IV formatter and DR format
          do i=1,ncodes
C           Force the format to "M" as the only way this formatter can go.
            idum = ichmv_ch(lmfmt(1,istn,i),1,'M')
            if (bitdens(istn,i).lt.40000.d0) then
              bitdens(istn,i) = 33333.0
            else
              bitdens(istn,i) = 56250.0 
            endif
          enddo
        else if (iin.eq.2) then ! VLBA formatter
C         do i=1,ncodes
C           Use the format taken from the mode name. Leave the bit
C           density alone too.
C           if (bitdens(istn,i).lt.40000.d0) then
C             bitdens(istn,i) = 34020.0
C           else
C             bitdens(istn,i) = 56700.0 
C           endif
C         enddo
        endif
      endif

C    1. Prompt for additional parameters, epoch of source positions
C    and whether maximal checks are wanted.

      WRITE(LUSCN,9100) (LSTNNA(I,ISTN),I=1,4)
9100  format(/'SNAP output for ',4a2)
      ierr=1

      ierr=1
       if (kbatch) then ! batch
         maxchk = upper(cr2)
         if (maxchk.ne.'Y'.and.maxchk.ne.'N') then
           write(luscn,9104) maxchk
           return
         endif
       else ! interactive
        if (ks2) then
          maxchk = 'N'
        else
        if (kparity) then
          write(luscn,9102)
9102      format(' Parity checks will be inserted after the first ',
     .    'scan of each pass,'/' if there is enough time to do them.')
        else
          write(luscn,9101)
9101      format(' No parity checks will be inserted unless you ',
     .    'request them ',/' with the following response.')
        endif
        do while (ierr.ne.0)
          if (kparity) then
            write(luscn,9103)
9103        format(' Add more parity checks whenever there is ',
     .      'enough time?'/' Enter Y or N, 0 to quit ? [default N] ',$)
          else
            write(luscn,9105)
9105        format(' Insert parity checks whenever there is ',
     .      'enough time?'/' Enter Y or N, 0 to quit ? [default N] ',$)
          endif
          read(luusr,'(a)') response
          if (response(1:1).eq.'0') return
          response(1:1) = upper(response(1:1))
          if (response(1:1).eq.' ') response(1:1) = 'N'
          if (response(1:1).ne.'Y'.and.response(1:1).ne.'N') then
            write(luscn,9104) response(1:1)
9104      format(' Invalid parity check response ',a,'. Enter Y or N.')
          else
            maxchk = response(1:1)
            ierr=0
          endif
        enddo
        endif ! parity
      endif ! batch/interactive

C     1. Create output file for SNAP commands.  If problems, quit.

      stat='new'
      ic = trimlen(snpname)
      ix = trimlen(lskdfi)

C     check to see if the file exists first

      inquire(file=snpname,exist=ex,iostat=ierr)
      if (ex) then
      if (kbatch) then
        response='Y'
      else 
        kdone = .false.
        do while (.not.kdone)
          write(luscn,9130) snpname(1:ic)
9130      format(' OK to purge existing file ',A,' (Y/N) ? ',$)
          read(luusr,'(A)') response
          response(1:1) = upper(response(1:1))
          if (response(1:1).eq.'N') then
            return
          else if (response(1:1).eq.'Y') then
            kdone = .true.
          end if
        end do
      end if
      if (response(1:1).eq.'Y') then
        open(lu_outfile,file=snpname)
        close(lu_outfile,status='delete')
        stat='new'
      endif
      endif
C
      WRITE(LUSCN,9900) (LSTNNA(I,ISTN),I=1,4),LSKDFI(1:IX),
     .SNPNAME(1:IC)
9900  FORMAT(' TRANSLATION FOR ',4A2,' FROM FILE ',A,
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
      IOBS = -1
      iobss=-1
      IOBSP = 0
      icheck=0
      icheckp=0
      idum = ichmv_ch(lmodep,1,'        ')
      tspins=0.0
      IPASP = -1
      IFTOLD = 0
      iyr4=0
      kerr=0
      ilen = 999
      kspin = .false.
      ket = .false.
      kintr = .false.
      krunning = .false.
      istnsk=0
      do while (istnsk.eq.0) ! Get first scan for this station into IBUF
        call ifill(ibuf,1,ibuf_len*2,oblank)
        IOBS = IOBS + 1
        if (iobs+1.le.nobs) then
          idum = ichmv(ibuf,1,lskobs(1,iskrec(iobs+1)),1,ibuf_len*2)
          ilen = iflch(ibuf,ibuf_len*2) 
          CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .    IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     .    MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG)
          CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
          IF (ISOR.EQ.0.OR.ICOD.EQ.0) RETURN
        else
          ilen=-1
        endif
      enddo ! get first scan for this station into IBUF
C
      DO WHILE (ILEN.GT.0.AND.KERR.EQ.0.and.ierr.eq.0
     ..AND.JCHAR(IBUF,1).NE.Z24)
C
        istnsk_next=0
        do while (istnsk_next.eq.0) ! Get NEXT scan for this station into ibuf_next
          call ifill(ibuf_next,1,ibuf_len*2,oblank)
          IOBS = IOBS + 1
          if (iobs+1.le.nobs) then
            idum = ichmv(ibuf_next,1,lskobs(1,iskrec(iobs+1)),1,
     .      ibuf_len*2)
            ilen_next = iflch(ibuf_next,ibuf_len*2) 
            CALL UNPSK(IBUF_next,ILEN_next,LSNAME_next,ICAL_next,
     .      LFREQ_next,IPAS_next,LDIR_next,IFT_next,LPRE_next,
     .      IYR_next,IDAYR_next,IHR_next,iMIN_next,ISC_next,IDUR_next,
     .      LMID_next,LPST_next,NSTNSK_next,LSTN_next,LCABLE_next,
     .      MJD_next,UT_next,GST_next,MON_next,IDA_next,
     .      LMON_next,LDAY_next,IERR_next,KFLG_next)
            CALL CKOBS(LSNAME_next,LSTN_next,NSTNSK_next,LFREQ_next,
     .      isor_next,ISTNSK_next,ICOD_next)
            IF (ISOR_next.EQ.0.OR.ICOD_next.EQ.0) RETURN
          else
            ilen=-1
            istnsk_next=999
          endif
        enddo ! get NEXT scan for this station into ibuf_next
C
        IF (.not.kintr)   THEN
          call snapintr(1,iyr)
          kintr=.true.
          iobss=0
        END IF
        IF (ISTNSK.NE.0)  THEN ! our station is in this scan
          IDIR = +1
          IF (LDIR(ISTNSK).EQ.hrb) IDIR=-1
          ID=IDUR(ISTNSK)
C     Get all the times we will need calculated.
C     time2 = data stop time = data start + duration
          CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,ID,
     .              IYR2,IDAYR2,IHR2,MIN2,ISC2)
C     time7 = data stop time + late stop
          CALL TMADD(IYR2,IDAYR2,IHR2,MIN2,ISC2,itlate(istn),
     .              IYR7,IDAYR7,IHR7,MIN7,ISC7)
C     time3 = data start - ICAL 
          CALL TMSUB(IYR,IDAYR,IHR,iMIN,ISC,ICAL,IYR3,IDAYR3,IHR3,
     .              MIN3,ISC3)
C     time5 = tape start = data start - early start
          call tmsub(iyr,idayr,ihr,imin,isc,ITEARL(istn),iyr5,idayr5,
     .              ihr5,min5,isc5)
C     time5_next = next tape start = next data start - early start
          call tmsub(iyr_next,idayr_next,ihr_next,imin_next,isc_next,
     .              ITEARL(istn),iyr5_next,idayr5_next,
     .              ihr5_next,min5_next,isc5_next)
C     time4 = previous data stop (saved from the last scan)
C     time6 = previous tape stop = Previous data stop + late stop
C         Now determine whether the tape will be stopped (ket).
C         For "adaptive" motion, stop the tape if the time between one
C         tape stop and the next tape start is longer than the specified 
C         time gap.
        if (tape_motion_type(istn).eq.'ADAPTIVE'  .or.
     .      tape_motion_type(istn).eq.'adaptive') then
          kadaptive = .true.
          if (ks2) then ! check the previous scan
            if (iobss.gt.0) then ! got a previous scan
              CALL TMADD(IYR4,IDAYR4,IHR4,MIN4,ISC4,itlate(istn),
     .              IYR6,IDAYR6,IHR6,MIN6,ISC6)
C             idt = tape start - previous tape stop
              idt = isecdif(idayr5,ihr5,min5,isc5,
     .                      idayr6,ihr6,min6,isc6)
              ket = idt.gt.itgap(istn)
            else ! first scan
              ket = .false.
            endif 
          else ! non-S2 check the next scan
            idt = isecdif(idayr5_next,ihr5_next,min5_next,isc5_next,
     .                    idayr7,ihr7,min7,isc7)
            ket = idt.gt.itgap(istn)
          endif ! S2/non-S2
        else
          ket = .true.
        endif

C <<<previous>>>>  <<<<<<<<<<current>>>>>>>>>>>>>>>>>>>>>>  <<<next>>>>>>>>>
C time4=   time6=  time5=        time= time2=               time5_next=
C data     tape   tape           data   data         tape    tape
C stop     stop   start          start  stop         stop    start
C  ^         ^      ^              ^      ^            ^      ^
C  |---------|------|--------------|------|------------|------|-------------|
C  <late stop><-idt-><-early start-><-dur-><-late stop-><-idt-><-early start>
C             (gap)                                     (gap)
C
C*** Continuous recording NOT supported yet.
C  For continuous recording, never stop the tape, unless end of a pass.
C         if (tape_motion_type(istn).eq.'continuous') ket = .false.
C
C
C     3. Output the SNAP commands.  Format of the entries is:

C     SOURCE=sourcena,ra,dec,epoch
C     CHECKbmp  (parity check if enough time) [not for S2]
C     !hhmmss   [only S2, only if long gap, previous stop + late]
C     ET        [only S2, only if long gap]
C     ffbmp=p   (ff=frequency, b=bandwidth, m=mode, p=subpass, e.g. SX2C1=B,3)
C               (p=pass number) 
C     ffbmp=g   [S2 g=group number]
C     !hhmmss   (start time - early) [only for non-zero early, and only
C               if not already recording]
C     ST        [only if previous !]
C     !hhmmss   (start time - cal)
C     PREOB
C     !hhmmss   (start time)
C     DATA_VALID=ON [S2 only]
C     TAPE
C     ST        [only if early=0]
C     MIDOB
C     !hhmmss+dur
C     ET         [not S2]
C     !+3S       [not S2]
C     TAPE
C     DATA_VALID=OFF [S2 only]
C     POSTOB
C
C     Additional commands:
C     FASTF=mmMssS or FASTR=mmMssS if tape must be moved to correct foot count
C     MIDTP after SOURCE if this is the end of a pass
C     UNLOAD after SOURCE if new tape starts with this observation
C     READY after the setup procedure if a new tape starts
C                with this observation
C
C SOURCE command
          IOBSP = IOBSP+1
          CALL IFILL(IBUF2,1,iblen,32)
          NCH = ichmv_ch(IBUF2,1,'SOURCE=')
C         For celestial sources, set up normal command
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
            ENDIF !1950 or 2000
          CALL RADED(SORRA, SORDEC,0.0d0,IRAH,IRAM,RAS,
     .     LDS,IDCD,IDCM,DCS,L,I,I,D)
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
          nch = nch + ir2as(ras,ibuf2,nch,-4,-1)
          NCH = MCOMA(IBUF2,NCH)
C         Declination, sddmmss.s
          IF (LDS.EQ.hmb) NCH = ICHMV(IBUF2,NCH,LDS,1,1)
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
          if (iaxis(istn).eq.3.or.iaxis(istn).eq.6.or.iaxis(istn).eq.7)
     .      then
            NCH = MCOMA(IBUF2,NCH)
C           
C           if (iobs.eq.0) then ! check cable for first scan
C             CALL SLEWo(ispre,MJDPRE,UTPRE,ISOR,ISTN,
C    .        lcable(istnsk),lcable2(istnsk),TSLEW,0,dum)
C           endif
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
          call inc(LU_OUTFILE,KERR)
C
C  New tape?
          if (ks2) then
            knewtp = ift(istnsk).eq.0.and.ipas(istnsk).eq.0
          else
            KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .      IDIRP,IFTOLD)
          endif
C
C  For S2, stop tape if needed after the SOURCE command
          if (ks2.and.itlate(istn).gt.0.and.iobss.ne.0.and.
     .       ipasp.ge.0.and.
     .       (knewtp.or.ket.or.ipasp.ne.ipas(istnsk).or.
     .        ichcm(lmodep,1,lmode(1,istn,icod),1,8).ne.0)) then
            CALL IFILL(IBUF2,1,iblen,32)
            idum = ichmv_ch(IBUF2,1,'!')
            idum = IB2AS(IDAYR6,IBUF2,2,Z4000+3*Z100+3)
            idum = IB2AS(IHR6,IBUF2,5,Z4000+2*Z100+2)
            idum = IB2AS(MIN6,IBUF2,7,Z4000+2*Z100+2)
            idum = IB2AS(ISC6,IBUF2,9,Z4000+2*Z100+2)
            call hol2lower(ibuf2,(10+1))
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
            call inc(LU_OUTFILE,KERR)
            nch = ichmv_ch(IBUF2,1,'et')
            krunning = .false.
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(2)/2)
            call inc(LU_OUTFILE,KERR)
          endif

C MIDTP procedure when changing direction
C Note this will never be called for S2 because it only records forward.
          IF (KNEWTP) IOBSP = 1  ! first observation on this pass
          IF (LDIR(ISTNSK).NE.LDIRP.AND..NOT.KNEWTP.AND.IPASP.GT.-1)  
     .      THEN
            icheck = 1 !do a check after this observation
            IOBSP = 1
            CALL IFILL(IBUF2,1,iblen,32)
            nch = ichmv_ch(IBUF2,1,'midtp  ')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch-1)/2)
            call inc(LU_OUTFILE,KERR)
          else
            icheck=0
          END IF

C Calculate tape spin time
          TSPINS = TSPIN(IABS(IFT(ISTNSK)-IFTOLD),ISPM,ISPS)
          call char2hol('F',LSPDIR,1,1)
          IF (IFT(ISTNSK).LT.IFTOLD) call char2hol('R',LSPDIR,1,1)
C
C Unload old tape
          IF (KNEWTP.AND.IOBSs.NE.0) THEN !get rid of old tape
            IF (.not.ks2.and.IFTOLD.GT.50 ) THEN !spin down remaining tape
              CALL IFILL(IBUF2,1,iblen,32)
              TSPINS=TSPIN(IFTOLD,ISPM,ISPS)
              CALL LSPIN(hrb,ISPM,ISPS,IBUF2,NCH)
              call hol2lower(ibuf2,(nch+1))
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
              kspin = .true. !Just wrote a FASTx command
              call inc(LU_OUTFILE,KERR)
              TSPINS=0.0
            END IF !spin down remaining tape
            CALL IFILL(IBUF2,1,iblen,32)
            nch = ichmv_ch(IBUF2,1,'unlod   ')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch-1)/2)
            call inc(LU_OUTFILE,KERR)
          END IF !get rid of old tape
C
C Check procedure
          ICHK = 0
C         Add "not krunning" so we don't try a check while it's moving!
          IF (.not.krunning.and..not.ks2
     .      .and..NOT.KNEWTP.AND.IOBSs.GT.0) THEN !check procedure
          IF ((KFLG(2).and.(iobsp.eq.2.or.icheckp.eq.1))
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
            CALL TMadd(IYR4,IDAYR4,IHR4,MIN4,ISC4,ISPPL,IYRch,IDAYRch,
     .      IHRch,MINch,ISCch)
C           Check against start-early for non-zero early,
C           check against start-cal   for early=0.
            if (itearl(istn).ne.0) then
              idt = isecdif(IDAYR5,IHR5,MIN5,ISC5,IDAYRch,
     .           IHRch,MINch,ISCch)
             else
              idt = isecdif(IDAYR3,IHR3,MIN3,ISC3,IDAYRch,
     .           IHRch,MINch,ISCch)
             endif
C CHECK procedure 
              if (idt.gt.IPARTM) then ! enough time 
            ICHK = 1
                CALL IFILL(IBUF2,1,iblen,32)
                NCH = ichmv_ch(IBUF2,1,'CHECK')
                nch = ichmv_ch(ibuf2,nch,'2')
                NCH=ICHMV(IBUF2,NCH,LMODEP     ,1,1)
                NDX = 1
                IF (IDIRP.EQ.-1) NDX = 2
                NCH = NCH + IB2AS(NDX,IBUF2,NCH,1)
                CALL IFILL(IBUF2,NCH,1,Z20)
                call hol2lower(ibuf2,(nch+1))
                call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
                call inc(LU_OUTFILE,KERR)
              endif ! enough time OR force
            ENDIF !do the check
          END IF !check procedure
C
C SETUP procedure 
C This is called on the first scan, if the setup is wanted on this
C scan (flag 1=Y), if tape direction changes, or if a check was done
C prior to this scan.
        IF (IOBSs.EQ.0.OR.KFLG(1).OR.LDIRP.NE.LDIR(ISTNSK)
     .    .OR.ICHK.EQ.1) THEN
          ic=Z8000+3
          nco=iflch(lfreq,2)
          CALL IFILL(IBUF2,1,iblen,32)
          if (ks2) then ! setup 
            nch = ichmv_ch(ibuf2,1,'setup')
C           Add the code index 
            nch = ICHMV(IBUF2,nch,LFREQ,1,nco)           ! ff
          else ! ffbm
            nch = ICHMV(IBUF2,1,LFREQ,1,nco)             ! ff
            ndx = ihddir(1,ipas(istnsk),istn,icod) ! subpass
            call trkall(itras(1,1,1,1,ndx,istn,icod),
     .      lmode(1,istn,icod),itrk,lpmode,npmode,ifan(istn,icod),itrax)
            CALL M3INF(ICOD,SPDIPS,ISP) ! get bandwidth code
C           choices in LBNAME are D,8,4,2,1,H,Q,E
C           corresponding to     16,8,4,2,1,.5,.25,.125
            NCH=ICHMV(ibuf2,NCH,LBNAME,isp,1)            ! b
            NCH=ICHMV(ibuf2,NCH,Lpmode,1,npmode)         ! m
C           Append the subpass code
            if (jchar(lmode,1).eq.ocapv) then           ! p
              NCH=ICHMV_ch(ibuf2,NCH,cvPASS(ndx:ndx))  
            else
              NCH=ICHMV_ch(ibuf2,NCH,cPASS(ndx:ndx))    
            endif      
          endif ! setup or ffbmp 
          NCH = ichmv_ch(IBUF2,NCH,'=')                ! =
          NCH = NCH + IB2AS(IPAS(ISTNSK),IBUF2,NCH,ic) ! pass
          CALL IFILL(IBUF2,NCH,3,Z20)
          call hol2lower(ibuf2,(nch+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
          call inc(LU_OUTFILE,KERR)
        END IF
C
C READY
        IF (KNEWTP) THEN
          CALL IFILL(IBUF2,1,iblen,32)
          nch = ichmv_ch(IBUF2,1,'ready  ')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
          call inc(LU_OUTFILE,KERR)
C Prepass new tape
          IF (.not.ks2.AND.KFLG(3)) THEN !prepass
            CALL IFILL(IBUF2,1,iblen,32)
            NCH = ichmv_ch(IBUF2,1,'prepass  ')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch-1)/2)
            call inc(LU_OUTFILE,KERR)
          END IF !prepass
          IF (.not.ks2.and.IFT(ISTNSK).GT.100) THEN !spin up
            TSPINS=TSPIN(IFT(ISTNSK),ISPM,ISPS)
            CALL LSPIN(ldirc,ISPM,ISPS,IBUF2,NCH)
            call hol2lower(ibuf2,(nch+1))
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
            kspin = .true. !Just wrote a FASTx command
            call inc(LU_OUTFILE,KERR)
          END IF
C Set TSPINS zero here so that no other spin is done
C (move out from previous if test)
          TSPINS=0.0
        END IF

C LOADER 
C Called for S2 if the group changed since the last pass
        if (ks2.and..not.knewtp.and.ipasp.ne.-1.and.
     .      ipasp.ne.ipas(istnsk)) then
          nch = ichmv_ch(ibuf2,1,'loader  ')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
          call inc(LU_OUTFILE,KERR)
        endif
C
C Spin forward if necessary
C Don't spin if we're already running. (? shouldn't happen?)
        IF (.not.krunning.and..not.ks2.and.TSPINS.GT.5.0) THEN
          CALL IFILL(IBUF2,1,iblen,32)
          CALL LSPIN(LSPDIR,ISPM,ISPS,IBUF2,NCH)
          call hol2lower(ibuf2,(nch+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
          kspin = .true. !Just wrote a FASTx command
          call inc(LU_OUTFILE,KERR)
          TSPINS = 0.0
        END IF

C Early start if not already running
        if (itearl(istn).gt.0) then
C           >> always do >>>  ..and..not.krunning) then
C         If FASTx preceeded, add a wait for tape to slow down
          if (kspin) then
            CALL IFILL(IBUF2,1,iblen,Z20)
            nch = ichmv_ch(IBUF2,1,'!+5s ')
            if (spd.gt.200.0) nch = ichmv_ch(IBUF2,1,'!+5s ')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
            call inc(LU_OUTFILE,KERR)
            kspin = .false.
          endif
C  Wait until ITEARL before start time
          CALL IFILL(IBUF2,1,iblen,32)
          idum = ichmv_ch(IBUF2,1,'!')
          idum = IB2AS(IDAYR5,IBUF2,2,Z4000+3*Z100+3)
          idum = IB2AS(IHR5,IBUF2,5,Z4000+2*Z100+2)
          idum = IB2AS(MIN5,IBUF2,7,Z4000+2*Z100+2)
          idum = IB2AS(ISC5,IBUF2,9,Z4000+2*Z100+2)
          call hol2lower(ibuf2,(10+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
          call inc(LU_OUTFILE,KERR)
          idum = ichmv(ibuf_save,1,ibuf2,1,10) ! save time
C   Write out tape monitor command at early start
          CALL IFILL(IBUF2,1,iblen,32)
          idum = ichmv_ch(IBUF2,1,'tape')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
          call inc(LU_OUTFILE,KERR)
C   Start recording
          CALL IFILL(IBUF2,1,iblen,32)
          nch = ichmv_ch(IBUF2,1,'ST=')
          krunning = .true.
          IF (LDIR(ISTNSK).EQ.ldirc) nch=ICHMV(IBUF2,nch,LFOR,1,4)
          IF (LDIR(ISTNSK).EQ.hrb) nch=ICHMV(IBUF2,nch,LREV,1,4)
          if (ks2) then ! s2
            nch=ichmv(ibuf2,nch,ls2speed(1,istn),1,
     .      iflch(ls2speed(1,istn),4))
          else ! mk3/4
            spd = 12.0*speed(icod,istn)
            call spdstr(spd,lspd,nspd)
            if (nspd.le.0) then
              write(luscn,9911) spd,ibuf_save
9911          format('SNAP01 - Illegal speed ',f6.2,' after ',5a2)
              return
            endif
            nch = ichmv(ibuf2,nch,lspd,1,nspd)
          endif ! s2 or mk3/4
          NCH = ichmv_ch(IBUF2,NCH+1,' ') - 1
          call hol2lower(ibuf2,(nch+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
          call inc(LU_OUTFILE,KERR)
C       else if (ks2.and.krunning) then ! issue TAPE and ST again
C         CALL IFILL(IBUF2,1,iblen,32)
C         idum = ichmv_ch(IBUF2,1,'tape')
C         call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
C         call inc(LU_OUTFILE,KERR)
C         CALL IFILL(IBUF2,1,iblen,32)
C         nch = ichmv_ch(IBUF2,1,'ST=FOR,')
C         nch=ichmv(ibuf2,nch,ls2speed(1,istn),1,
C    .    iflch(ls2speed(1,istn),4))
C         NCH = ichmv_ch(IBUF2,NCH+1,' ') - 1
C         call hol2lower(ibuf2,(nch+1))
C         call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
C         call inc(LU_OUTFILE,KERR)
        endif !start tape early/issue ST again
C Wait until CAL time
        IF (ICAL.GE.1) THEN !pre-observation calibration procedure
          CALL IFILL(IBUF2,1,iblen,32)
          idum = ichmv_ch(IBUF2,1,'!')
          idum = IB2AS(IDAYR3,IBUF2,2,Z4000+3*Z100+3)
          idum = IB2AS(IHR3,IBUF2,5,Z4000+2*Z100+2)
          idum = IB2AS(MIN3,IBUF2,7,Z4000+2*Z100+2)
          idum = IB2AS(ISC3,IBUF2,9,Z4000+2*Z100+2)
          call hol2lower(ibuf2,(10+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
          call inc(LU_OUTFILE,KERR)
C                   Wait until ICAL before start time
C PREOB procedure
          CALL IFILL(IBUF2,1,iblen,32)
          idum = ICHMV(IBUF2,1,LPRE,1,6)
          call hol2lower(ibuf2,(6+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(6)/2)
          call inc(LU_OUTFILE,KERR)
        ENDIF
C Wait until data start time
        CALL IFILL(IBUF2,1,iblen,32)
        idum = ichmv_ch(IBUF2,1,'!')
        idum = IB2AS(IDAYR,IBUF2,2,Z4000+3*Z100+3)
        idum = IB2AS(IHR,IBUF2,5,Z4000+2*Z100+2)
        idum = IB2AS(iMIN,IBUF2,7,Z4000+2*Z100+2)
        idum = IB2AS(ISC,IBUF2,9,Z4000+2*Z100+2)
        idum = ichmv(ibuf_save,1,ibuf2,1,10)
        call hol2lower(ibuf2,(10+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
        call inc(LU_OUTFILE,KERR)
C S2 DATA_VALID 
        if (ks2) then
          CALL IFILL(IBUF2,1,iblen,32)
          nch = ichmv_ch(IBUF2,1,'data_valid=on  ')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
          call inc(LU_OUTFILE,KERR)
        endif
C TAPE monitor command
        CALL IFILL(IBUF2,1,iblen,32)
        idum = ichmv_ch(IBUF2,1,'tape')
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
        call inc(LU_OUTFILE,KERR)
C Start tape if not already running.
        if (.not.krunning) then !start tape now
          CALL IFILL(IBUF2,1,iblen,32)
          nch = ichmv_ch(IBUF2,1,'ST=')
          krunning = .true.
          IF (LDIR(ISTNSK).EQ.ldirc) nch=ICHMV(IBUF2,nch,LFOR,1,4)
          IF (LDIR(ISTNSK).EQ.hrb) nch=ICHMV(IBUF2,nch,LREV,1,4)
          if (ks2) then ! s2
            nch=ichmv(ibuf2,nch,ls2speed(1,istn),1,
     .      iflch(ls2speed(1,istn),4))
          else ! mk3/4
            spd = 12.0*speed(icod,istn)
            call spdstr(spd,lspd,nspd)
            if (nspd.le.0) then
              write(luscn,9911) spd,ibuf_save
              return
            endif
            nch = ichmv(ibuf2,nch,lspd,1,nspd)
          endif ! s2 or mk3/4
          krunning = .true.
          call hol2lower(ibuf2,(nch+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
          call inc(LU_OUTFILE,KERR)
        endif !start tape now
C MIDOB procedure
        CALL IFILL(IBUF2,1,iblen,32)
        idum = ICHMV(IBUF2,1,LMID,1,6)
        call hol2lower(ibuf2,(6+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,6/2)
        call inc(LU_OUTFILE,KERR)
        CALL IFILL(IBUF2,1,iblen,32)
C Wait until data end time
        idum = ichmv_ch(IBUF2,1,'!')
        idum = IB2AS(IDAYR2,IBUF2,2,Z4000+3*Z100+3)
        idum = IB2AS(IHR2,IBUF2,5,Z4000+2*Z100+2)
        idum = IB2AS(MIN2,IBUF2,7,Z4000+2*Z100+2)
        idum = IB2AS(ISC2,IBUF2,9,Z4000+2*Z100+2)
        call hol2lower(ibuf2,(10+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
        call inc(LU_OUTFILE,KERR)
C ET command
        if ((ket.and..not.ks2).or.
     .      (ket.and.ks2.and.itlate(istn).eq.0)) then !ET command
C         Wait until late stop time before issuing ET
          if (itlate(istn).gt.0) then
            idum = ichmv_ch(IBUF2,1,'!')
            idum = IB2AS(IDAYR7,IBUF2,2,Z4000+3*Z100+3)
            idum = IB2AS(IHR7,IBUF2,5,Z4000+2*Z100+2)
            idum = IB2AS(MIN7,IBUF2,7,Z4000+2*Z100+2)
            idum = IB2AS(ISC7,IBUF2,9,Z4000+2*Z100+2)
            call hol2lower(ibuf2,(10+1))
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
          endif
          CALL IFILL(IBUF2,1,iblen,Z20)
          idum = ichmv_ch(IBUF2,1,'et')
          krunning = .false.
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(2)/2)
          call inc(LU_OUTFILE,KERR)
C Wait for tape to stop
          if (.not.ks2) then
            idum = ichmv_ch(IBUF2,1,'!+3S')
            if (spd.gt.200.0) idum = ichmv_ch(IBUF2,1,'!+5s')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
            call inc(LU_OUTFILE,KERR)
            CALL IFILL(IBUF2,1,iblen,Z20)
          endif 
        endif!ET command
C Tape monitor command
        idum = ichmv_ch(IBUF2,1,'tape')
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
        call inc(LU_OUTFILE,KERR)
C S2 DATA_VALID 
        if (ks2) then
          CALL IFILL(IBUF2,1,iblen,32)
          nch = ichmv_ch(IBUF2,1,'data_valid=off  ')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
          call inc(LU_OUTFILE,KERR)
        endif

C Save information about this scan before going on to the next one
        idum = ichmv(lmodep,1,LMODE(1,istn,ICOD),1,8)
        IPASP = IPAS(ISTNSK)
        icheckp=icheck
        IOBSs = IOBSs + 1
        LDIRP = LDIR(ISTNSK)
        IDIR=+1
        IF (LDIR(ISTNSK).EQ.hrb) IDIR=-1
        IDIRP=+1
        IF (LDIRP.EQ.hrb) IDIRP = -1
        if (ks2) then
          iftold=ift(istnsk)+idur(istnsk)
          if (ket) iftold=itlate(istn)+iftold+itearl(istn)
        else
          if (ket) IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ITEARL(istn)+
     .      IDUR(ISTNSK))
     .    *speed(icod,istn))
C?? how to calculate this? see lstsum?
          if (.not.ket) iftold=itlate(istn)+iftold+itearl(istn)
        endif
        idum = ICHMV(IBUF2,1,LPST,1,6)
C POSTOB
        call hol2lower(ibuf2,(6+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(6)/2)
        call inc(LU_OUTFILE,KERR)
        IYR4 = IYR2
        IDAYR4 = IDAYR2
        IHR4 = IHR2
        MIN4 = MIN2
        ISC4 = ISC2
      END IF  ! istnsk.ne.0 means our station is in this scan
C
C     Copy ibuf_next into IBUF
      if (ilen.ne.-1) then ! more scans to come
        idum = ichmv(ibuf,1,ibuf_next,1,ibuf_len*2)
        ilen = iflch(ibuf,ibuf_len*2) 
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .  IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     .  MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG)
        CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
      endif

      END DO ! ilen.gt.0,kerr.eq.0,ierr.eq.0
C
      CONTINUE
      TSPINS = TSPIN(IFTOLD,ISPM,ISPS)
      IF (.not.ks2.and.TSPINS.GT.5.) THEN
C       THEN BEGIN "spin off the last tape"
        CALL LSPIN(hrb,ISPM,ISPS,IBUF2,NCH)
            call hol2lower(ibuf2,(nch+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
        kspin = .true. !Just wrote a FASTx command
        call inc(LU_OUTFILE,KERR)
C       ENDT "spin off the last tape"
      END IF
      if (ks2.and.krunning) then ! shut it down
        CALL TMADD(IYR4,IDAYR4,IHR4,MIN4,ISC4,itlate(istn),
     .    IYR6,IDAYR6,IHR6,MIN6,ISC6)
        CALL IFILL(IBUF2,1,iblen,32)
        idum = ichmv_ch(IBUF2,1,'!')
        idum = IB2AS(IDAYR6,IBUF2,2,Z4000+3*Z100+3)
        idum = IB2AS(IHR6,IBUF2,5,Z4000+2*Z100+2)
        idum = IB2AS(MIN6,IBUF2,7,Z4000+2*Z100+2)
        idum = IB2AS(ISC6,IBUF2,9,Z4000+2*Z100+2)
        call hol2lower(ibuf2,(10+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
        call inc(LU_OUTFILE,KERR)
        idum = ichmv_ch(IBUF2,1,'et  ')
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(2)/2)
        call inc(LU_OUTFILE,KERR)
      endif ! shut it down
      idum = ichmv_ch(IBUF2,1,'unlod ')
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(6)/2)
      call inc(LU_OUTFILE,KERR)
C
      close(LU_OUTFILE,iostat=IERR)
      call drchmod(snpname,iperm,ierr)
      IF (KERR.NE.0) WRITE(LUSCN,9902) KERR,SNPNAME(1:ic)
9902  FORMAT(' SNAP03 - Error ',I5,' writing SNAP output file ',A)
      RETURN
        END
