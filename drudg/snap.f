        SUBROUTINE SNAP(cr1,cr2,cr3,cr4)!TRANSLATE SCHEDULE TO SNAP 
C
C     SNAP reads a schedule file and writes a file with SNAP commands
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
C INPUT
      character*(*) cr1,cr2,cr3,cr4  ! Responses to three prompts for
C          1) epoch 1950 or 2000
C          2) add checks Y or N
C          3) force checks Y or N
C          4) OK to delete existing file Y or N
C
C  LOCAL:
C     IFTOLD - foot count at end of previous observation
C     TSPINS - time, in seconds, to spin tape
      integer*2 IBUF2(ibuf_len),ibuf_save(5)
      integer*2 lmodep,ldirp,lspdir,lds,lfreq,lspd(4)
      integer itrax(2,2,max_chan) ! fanned-out version of itras
      integer iblen,i,ilen,iobs,iobsp,icheck,icheckp,
     .ipasp,iftold,kerr,ical,iyr,idayr,ihr,imin,isc,nstnsk,
     .mjd,mon,ida,isor,istnsk,icod,idir,id,iyr2,ierr,ix,idayr2,
     .ihr2,min2,isc2,iyr3,idayr3,ihr3,min3,isc3,iyr5,idayr5,ihr5,
     .min5,isc5,nch,nc,irah,iram,idcd,idcm,l,idirp,nspd,
     .idum,ispm,isps,ic,ichk,ihd,isppl,iyr4,idayr4,ihr4,
     .min4,isc4,itch,iyrch,idayrch,ihrch,minch,iscch,ndx,isp,il
      real*4 tspins,d,epoc,ras,dcs,spdips
      integer*2 LSNAME(4),LSTN(MAX_STN),LCABLE(MAX_STN),LMON(2),
     .          LDAY(2),LPRE(3),LPST(3),LMID(3),LDIR(MAX_STN)
      integer   IPAS(MAX_STN),IFT(MAX_STN),IDUR(MAX_STN)
      integer npmode,itrk(36),nco
      integer*2 lpmode(2),lfan(2)
      real*8 UT,GST
      real*8 SORRA,SORDEC
      real*4 az,el,x30,y30,x85,y85,ha1,dc
      character*4  response,cepoch
      character*3  stat
      character*28 cpass,cvpass
      character    upper
      character*1  maxchk,allchk
      logical    ex
      logical      kdone,kspin,kup
C     LMODEP - mode of previous observation
C     LDIRP  - direction of previous observation
C     IPASP - previous pass

C     IYR ,IHR , etc. - start time of obs.
C     IYR2,IHR2, etc. - stop time
C     IYR3,IHR3, etc. - start time minus cal time
C     IYR4,IHR4, etc. - previous stop time + spin + check
C     IYR5,IHR5, etc. - start time minus early
C     IOBSP - number of obs. this pass
      character*7 cwrap ! cable wrap from CBINF
      integer*2 lwrap(4)
      real*4 spd
      logical KNEWTP,KNEWT
C      - true if a new tape needs to be mounted before
C        beginning the current observation
Cinteger*4 ifbrk
      integer jchar,trimlen,ir2as,ib2as,ichmv,iscnc,mcoma ! functions
      integer iflch,ichcm_ch,ichmv_ch
      real*4 tspin,speed ! functions
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
      DATA LMODEP/2H  /, LDIRP/2H  /, IPASP/0/
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
C
C
      iblen = ibuf_len*2
      if (kmissing) then
        write(luscn,9111)
9111    format(' SNAP00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your SNAP file may be incorrect or ',
     .  ' cause a program abort.')
      endif

C    1. Prompt for additional parameters, epoch of source positions
C    and whether maximal checks are wanted.

      WRITE(LUSCN,9100) (LSTNNA(I,ISTN),I=1,4)
9100  format('SNAP output for ',4a2)
      ierr=1
      if (kbatch) then
        cepoch = cr1
        if (cepoch.ne.'1950'.and.cepoch.ne.'2000') then
          write(luscn,9102) cepoch
          return
        endif
      else
        do while (ierr.ne.0)
          write(luscn,9101)
9101    format(' Source position epoch 1950 or 2000 ? [default 1950,',
     .  ' 0 to quit] ',$)
          read(luusr,'(a)') response
          if (response(1:1).eq.'0') return
          if (response(1:1).eq.' ') response(1:4)='1950'
          if (response(1:4).ne.'1950'.and.response(1:4).ne.'2000') then
            write(luscn,9102) response(1:4)
9102      format(' Invalid epoch ',a,'.  Must be 1950 or 2000.')
          else
            cepoch = response(1:4)
            ierr=0
          endif
        enddo
      endif

      ierr=1
       if (kbatch) then
         maxchk = upper(cr2)
         if (maxchk.ne.'Y'.and.maxchk.ne.'N') then
           write(luscn,9104) maxchk
           return
         endif
       else
        maxchk = ' '
        do while (ierr.ne.0)
          write(luscn,9103)
9103    format(' Add parity checks when there is enough time, ',
     .  'enter Y or N, 0 to quit ? [default N] ',$)
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
      endif

      ierr=1
      if (kbatch) then
        allchk = upper(cr3)
        if (allchk.ne.'Y'.and.allchk.ne.'N') then
          write(luscn,9106) allchk
          return
        endif
      else
        allchk = ' '
        do while (ierr.ne.0)
          write(luscn,9105)
9105    format(' Force a parity check on every scan, ',
     .  'enter Y or N, 0 to quit ? [default N] ',$)
          read(luusr,'(a)') response
          if (response(1:1).eq.'0') return
          response(1:1) = upper(response(1:1))
          if (response(1:1).eq.' ') response(1:1) = 'N'
          if (response(1:1).ne.'Y'.and.response(1:1).ne.'N') then
            write(luscn,9106) response(1:1)
9106        format('Invalid parity force response ',a,'. Enter Y or N.')
          else
            allchk = response(1:1)
            ierr=0
          endif
        enddo
      endif


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
      CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
      IOBS = -1
      IOBSP = 0
      icheck=0
      icheckp=0
      call char2hol('  ',LMODEP,1,2)
      IPASP = 0
      IFTOLD = 0
      kerr=0
      kspin = .false.
C
      DO WHILE (ILEN.GT.0.AND.KERR.EQ.0.and.ierr.eq.0
     ..AND.JCHAR(IBUF,1).NE.Z24)
C
        CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .       IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     .       MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG)
        CALL CKOBS(LSNAME,LSTN,NSTNSK,LFREQ,ISOR,ISTNSK,ICOD)
          IF (ISOR.EQ.0.OR.ICOD.EQ.0) RETURN
C
        IF (IOBS.EQ.-1)   THEN
          call snapintr(1,iyr)
          IOBS = 0
        END IF
        IF (ISTNSK.NE.0)  THEN
          IDIR = +1
          IF (LDIR(ISTNSK).EQ.hrb) IDIR=-1
          ID=IDUR(ISTNSK)
          CALL TMADD(IYR,IDAYR,IHR,iMIN,ISC,ID,
     .    IYR2,IDAYR2,IHR2,MIN2,ISC2)
C                   Get stop time by adding duration to start
          CALL TMSUB(IYR,IDAYR,IHR,iMIN,ISC,ICAL,IYR3,IDAYR3,IHR3,
     .               MIN3,ISC3)
C                   Find time ICAL sec before tape start
            call tmsub(iyr,idayr,ihr,imin,isc,ITEARL,iyr5,idayr5,ihr5,
     .               min5,isc5)
C                   Find time ITEARL sec before start
C
C
C     3. Output the SNAP commands.  Format of the entries is:
C     SOURCE=sourcena,ra,dec,1950.0
C  OR SOURCE=sourcena,ra,dec,2000.0
C     CHECKbmp
C     ffbmp=B,p (ff=frequency, b=bandwidth, m=mode, p=pass, e.g. SX2C1=B,3)
C               (p=pass)   [only for stations with tape density upgrade]
C     !hhmmss   (start time - early) [only for non-zero early]
C     ST        [only if previous !]
C     !hhmmss   (start time - cal)
C     PREOB
C     !hhmmss   (start time)
C     TAPE
C     ST        [only if early=0]
C     MIDOB
C     !hhmmss+dur
C     ET
C     !+3S
C     TAPE
C
C     Additional commands:
C     FASTF=mmMssS or FASTR=mmMssS if tape must be moved to correct foot count
C     MIDTP after SOURCE if this is the midpoint of the tape
C     REWND after SOURCE if previous tape was mode A
C     UNLOAD after SOURCE if new tape starts with this observation
C     READY after the setup procedure if a new tape starts
C                with this observation
C
          IOBSP = IOBSP+1
          CALL IFILL(IBUF2,1,iblen,32)
          NCH = ichmv_ch(IBUF2,1,'SOURCE=')
C         For celestial sources, set up normal command
C               SOURCE=name,ra,dec,epoch 
        IF (ISOR.LE.NCELES) THEN !celestial source
          NC = ISCNC(LSORNA(1,ISOR),1,8,Z20)
          IF (NC.EQ.0) NC=9
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
C      Check procedure commands and tape spins.
C
          KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .    IDIRP,IFTOLD)
C
          IF (KNEWTP) IOBSP = 1
C         IF (IOBSP.EQ.2.AND.MAXPAS(ISTN).GT.1.AND.KFLG(4)) THEN
C           CALL IFILL(IBUF2,1,iblen,32)
C           NCH = ICHMV(IBUF2,1,4HPEAK,1,4)
C           NCH = ICHMV(IBUF2,NCH,LDIRP,1,2)
C           call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
C           call inc(LU_OUTFILE,KERR)
C         END IF
          IF (LDIR(ISTNSK).NE.LDIRP.AND..NOT.KNEWTP.AND.IPASP.GT.0) THEN
            icheck = 1 !do a check after this observation
            IOBSP = 1
            CALL IFILL(IBUF2,1,iblen,32)
            nch = ichmv_ch(IBUF2,1,'midtp  ')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch-1)/2)
            call inc(LU_OUTFILE,KERR)
          else
            icheck=0
          END IF
          TSPINS = TSPIN(IABS(IFT(ISTNSK)-IFTOLD),ISPM,ISPS)
          call char2hol('F',LSPDIR,1,1)
          IF (IFT(ISTNSK).LT.IFTOLD) call char2hol('R',LSPDIR,1,1)
C
          IF (KNEWTP.AND.IOBS.NE.0) THEN !get rid of old tape
            IF (JCHAR(LMODEP,1).EQ.Z41.AND.MAXPAS(ISTN).EQ.1) THEN
C              !rewind mode A tape
              CALL IFILL(IBUF2,1,iblen,32)
              nch = ichmv_ch(IBUF2,1,'rewnd  ')
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch-1)/2)
              call inc(LU_OUTFILE,KERR)
              IFTOLD=0
            ENDIF !rewind mode A tape
            IF (IFTOLD.GT.50 ) THEN !spin down remaining tape
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
C
            IF (MAXPAS(ISTN).GT.1.AND.KFLG(3)) THEN !prepass
              CALL IFILL(IBUF2,1,iblen,32)
              NCH = ichmv_ch(IBUF2,1,'prepass  ')
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch-1)/2)
              call inc(LU_OUTFILE,KERR)
            END IF !prepass
C
          END IF !get rid of old tape
C
          ICHK = 0
          IF ((.NOT.KNEWTP).AND.(IOBS.GT.0)) THEN !check procedure
            ICHK = 1
                IF (KFLG(2).and.((iobsp.eq.2.or.icheckp.eq.1)
     .          .or.MAXCHK.eq.'Y')) THEN !do a check
C            Do check if flag is set, but only if there is enough time.
C            Do check if MAXCHK and if there is enough time.
C            Check against start-early for non-zero early,
C            check against start-cal   for early=0.
C              Enough time = (SOURCE+SPIN+PARITY+SETUP+TAPE+3S)
                  IHD = 0
                  if (ldirp.ne.ldir(istnsk)) ihd=ihdtm
                  ISPPL = TSPINS + IPARTM+ISETTM+ISORTM+ITAPTM+3+ihd
              CALL TMADD(IYR4,IDAYR4,IHR4,MIN4,ISC4,ISPPL,IYR4,IDAYR4,
     .           IHR4,MIN4,ISC4)
                  if (itearl.eq.0) then
                    itch = ICAL
                  else
                    itch = itearl
                  endif
                  call tmsub(iyr,idayr,ihr,imin,isc,itch,iyrch,idayrch,
     .        ihrch,minch,iscch)
                  if (allchk.eq.'Y') goto 300
                  IF (IYR4.LT.IYRch) GOTO 300
                  IF (IYR4.GT.IYRch) GOTO 310
                  IF (IDAYR4.LT.IDAYRch) GOTO 300
                  IF (IDAYR4.GT.IDAYRch) GOTO 310
                  IF (IHR4.LT.IHRch) GOTO 300
                  IF (IHR4.GT.IHRch) GOTO 310
                  IF (MIN4.LT.MINch) GOTO 300
                  IF (MIN4.GT.MINch.OR.ISC4.GT.ISCch) GOTO 310
300           CALL IFILL(IBUF2,1,iblen,32)
              NCH = ichmv_ch(IBUF2,1,'CHECK')
C             NCH=ICHMV(IBUF2,NCH,LB,ISPP,1)
C             Always check at 120 speed
              nch = ichmv_ch(ibuf2,nch,'2')
              NCH=ICHMV(IBUF2,NCH,LMODEP     ,1,1)
              NDX = 1
              IF (IDIRP.EQ.-1) NDX = 2
              NCH = NCH + IB2AS(NDX,IBUF2,NCH,1)
              CALL IFILL(IBUF2,NCH,1,Z20)
            call hol2lower(ibuf2,(nch+1))
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
              call inc(LU_OUTFILE,KERR)
            ENDIF !do the check
          END IF !check procedure
C
310       IF (IOBS.EQ.0.OR.KFLG(1).OR.LDIRP.NE.LDIR(ISTNSK)
     .        .OR.ICHK.EQ.1) THEN
C           THEN BEGIN "set-up procedure"
            CALL IFILL(IBUF2,1,iblen,32)
            nco=iflch(lfreq,2)
            nch = ICHMV(IBUF2,1,LFREQ,1,nco)
          call trkall(itras(1,1,1,ipas(istnsk),istn,icod),
     .    lmode(1,istn,icod),itrk,lpmode,npmode,lfan,itrax)
            CALL M3INF(ICOD,SPDIPS,ISP)
C choices in LBNAME are D,8,4,2,1,H,Q,E
          NCH=ICHMV(ibuf2,NCH,LBNAME,isp,1)
          NCH=ICHMV(ibuf2,NCH,Lpmode,1,npmode)
          ndx = ihddir(ipas(istnsk),istn,icod)
          if (jchar(lpmode,1).eq.ocapv) then
            NCH=ICHMV_ch(ibuf2,NCH,cvPASS(ndx:ndx))
          else
            NCH=ICHMV_ch(ibuf2,NCH,cPASS(ndx:ndx))
          endif      
          NCH = ichmv_ch(IBUF2,NCH,'=') 
          ic=Z8000+3
          NCH = NCH + IB2AS(IPAS(ISTNSK),IBUF2,NCH,ic) 
          CALL IFILL(IBUF2,NCH,3,Z20)
            call hol2lower(ibuf2,(nch+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
          call inc(LU_OUTFILE,KERR)
        END IF
C
          IF (KNEWTP) THEN
            CALL IFILL(IBUF2,1,iblen,32)
            nch = ichmv_ch(IBUF2,1,'ready  ')
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
            call inc(LU_OUTFILE,KERR)
            IF (IFT(ISTNSK).GT.100) THEN !spin up
              TSPINS=TSPIN(IFT(ISTNSK),ISPM,ISPS)
              CALL LSPIN(ldirc,ISPM,ISPS,IBUF2,NCH)
            call hol2lower(ibuf2,(nch+1))
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
              kspin = .true. !Just wrote a FASTx command
              call inc(LU_OUTFILE,KERR)
              TSPINS=0.0
            END IF
          END IF
C
          IF (TSPINS.GT.5.0) THEN
            CALL IFILL(IBUF2,1,iblen,32)
            CALL LSPIN(LSPDIR,ISPM,ISPS,IBUF2,NCH)
            call hol2lower(ibuf2,(nch+1))
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
            kspin = .true. !Just wrote a FASTx command
            call inc(LU_OUTFILE,KERR)
            TSPINS = 0.0
            END IF

            if (itearl.gt.0) then !start tape early
C  If FASTx preceeded, add a wait
                if (kspin) then
                  CALL IFILL(IBUF2,1,iblen,Z20)
                  nch = ichmv_ch(IBUF2,1,'!+5s ')
                  if (isp.gt.200) nch = ichmv_ch(IBUF2,1,'!+5s ')
                  call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch)/2)
                  call inc(LU_OUTFILE,KERR)
                  kspin = .false.
                endif
C   Wait until ITEARL before start time
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
C   Write out tape monitor command
              CALL IFILL(IBUF2,1,iblen,32)
              idum = ichmv_ch(IBUF2,1,'tape')
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
              call inc(LU_OUTFILE,KERR)
C   Start recording
              CALL IFILL(IBUF2,1,iblen,32)
              nch = ichmv_ch(IBUF2,1,'ST=')
              IF (LDIR(ISTNSK).EQ.ldirc) nch=ICHMV(IBUF2,nch,LFOR,1,4)
              IF (LDIR(ISTNSK).EQ.hrb) nch=ICHMV(IBUF2,nch,LREV,1,4)
              spd = 12.0*speed(icod,istn)
              call spdstr(spd,lspd,nspd)
              if (nspd.lt.0) then
                write(luscn,9911) spd,ibuf_save
9911            format('SNAP01 - Illegal speed ',f6.2,' after ',5a2)
                return
              endif
              nch = ichmv(ibuf2,nch,lspd,1,nspd)
C             nch = nch+ir2as(spd,IBUF2,NCH,6,2)
              NCH = ichmv_ch(IBUF2,NCH+1,' ') - 1
            call hol2lower(ibuf2,(nch+1))
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
              call inc(LU_OUTFILE,KERR)
            endif !start tape early
C
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
C PREOB
            CALL IFILL(IBUF2,1,iblen,32)
            idum = ICHMV(IBUF2,1,LPRE,1,6)
            call hol2lower(ibuf2,(6+1))
            call writf_asc(LU_OUTFILE,KERR,IBUF2,(6)/2)
            call inc(LU_OUTFILE,KERR)
            ENDIF
C
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
C                   Wait until start time
          CALL IFILL(IBUF2,1,iblen,32)
          idum = ichmv_ch(IBUF2,1,'tape')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
          call inc(LU_OUTFILE,KERR)
C                     Write out tape monitor command
            if (itearl.eq.0) then !start tape now
              CALL IFILL(IBUF2,1,iblen,32)
              nch = ichmv_ch(IBUF2,1,'ST=')
              IF (LDIR(ISTNSK).EQ.ldirc) nch=ICHMV(IBUF2,nch,LFOR,1,4)
              IF (LDIR(ISTNSK).EQ.hrb) nch=ICHMV(IBUF2,nch,LREV,1,4)
              spd = 12.0*speed(icod,istn)
              call spdstr(spd,lspd,nspd)
              if (nspd.lt.0) then
                write(luscn,9911) spd,ibuf_save
                return
              endif
              nch = ichmv(ibuf2,nch,lspd,1,nspd)
C             nch = nch+ir2as(spd,IBUF2,NCH,6,2)
              NCH = ichmv_ch(IBUF2,NCH+1,' ') - 1
            call hol2lower(ibuf2,(nch+1))
              call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
              call inc(LU_OUTFILE,KERR)
C             Start recording
            endif !start tape now
C MIDOB
            CALL IFILL(IBUF2,1,iblen,32)
          idum = ICHMV(IBUF2,1,LMID,1,6)
            call hol2lower(ibuf2,(6+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,6/2)
          call inc(LU_OUTFILE,KERR)
C                   Invoke a procedure in mid-observation
          CALL IFILL(IBUF2,1,iblen,32)
          idum = ichmv_ch(IBUF2,1,'!')
          idum = IB2AS(IDAYR2,IBUF2,2,Z4000+3*Z100+3)
          idum = IB2AS(IHR2,IBUF2,5,Z4000+2*Z100+2)
          idum = IB2AS(MIN2,IBUF2,7,Z4000+2*Z100+2)
          idum = IB2AS(ISC2,IBUF2,9,Z4000+2*Z100+2)
            call hol2lower(ibuf2,(10+1))
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(10)/2)
          call inc(LU_OUTFILE,KERR)
C                   Wait until stop time
          CALL IFILL(IBUF2,1,iblen,Z20)
          idum = ichmv_ch(IBUF2,1,'et')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(2)/2)
          call inc(LU_OUTFILE,KERR)
C                   End recording
          idum = ichmv_ch(IBUF2,1,'!+3S')
          if (isp.gt.200) idum = ichmv_ch(IBUF2,1,'!+5s')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
          call inc(LU_OUTFILE,KERR)
          CALL IFILL(IBUF2,1,iblen,Z20)
          idum = ichmv_ch(IBUF2,1,'tape')
          call writf_asc(LU_OUTFILE,KERR,IBUF2,(4)/2)
          call inc(LU_OUTFILE,KERR)
C                     Wait for the tape to stop and send tape monitor command
          IOBS = IOBS + 1
          LMODEP = LMODE(1,istn,ICOD)
          IPASP = IPAS(ISTNSK)
          icheckp=icheck
          LDIRP = LDIR(ISTNSK)
          IDIR=+1
          IF (LDIR(ISTNSK).EQ.hrb) IDIR=-1
          IDIRP=+1
          IF (LDIRP.EQ.hrb) IDIRP = -1
            IFTOLD = IFT(ISTNSK)+IFIX(IDIR*(ITEARL+IDUR(ISTNSK))
     .    *speed(icod,istn))
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
C         ENDT "process this observation"
        END IF  !"istnsk.ne.0"
C
801     CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
        IF (ichcm_ch(LPRE,1,'MARK2').EQ.0) GOTO 801
C            Skip this one if it's a MARK II run
C            ENDW "Schedule file entries"

C   if (ifbrk().lt.0) return

        END DO !"ilen.gt.0,kerr.eq.0,not $"
C
980   CONTINUE
      TSPINS = TSPIN(IFTOLD,ISPM,ISPS)
      IF (TSPINS.GT.5.) THEN
C       THEN BEGIN "spin off the last tape"
        CALL LSPIN(hrb,ISPM,ISPS,IBUF2,NCH)
            call hol2lower(ibuf2,(nch+1))
        call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH)/2)
        kspin = .true. !Just wrote a FASTx command
        call inc(LU_OUTFILE,KERR)
C       ENDT "spin off the last tape"
      END IF
      idum = ichmv_ch(IBUF2,1,'unlod ')
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(6)/2)
      call inc(LU_OUTFILE,KERR)
C
990   close(LU_OUTFILE,iostat=IERR)
      call drchmod(snpname,iperm,ierr)
      IF (KERR.NE.0) WRITE(LUSCN,9902) KERR,SNPNAME(1:ic)
9902  FORMAT(' SNAP03 - Error ',I5,' writing SNAP output file ',A)
      RETURN
        END
