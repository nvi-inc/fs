*
* Copyright (c) 2020 NVI, Inc.
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
      SUBROUTINE SREAD(IERR,ivexnum)
C Reads schedule file.
C Calls VREAD for VEX files.
C Calls READS to read lines and sked subroutines to parse SKED format.
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

! functions
      integer trimlen
      integer ichmv ! functions
C  Output:
      integer ierr,ivexnum

C  Local:
      integer ical,iyr,idayr,ihr,imin,isc,nstnsk,mjd,mon,ida
      double precision ut,gst
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .          LMON(2),LDAY(2),LPRE(3),LPST(3),LMID(3),LDIR(MAX_STN),
     .          lfreq
      integer   IPAS(MAX_STN),IFT(MAX_STN),IDUR(MAX_STN),ioff(max_stn)
      integer ilen,ich,ic1,ic2,idummy,iret,i

      character*2 ctype  !two letter code.

      logical kcod ! set to ksta when $CODES is found
      logical ksta ! set to true when $STATIONS is found
      logical kvlb ! set to true when $VLBA is found
      logical khed ! set to ksta when $HEAD is found

      character*80 cfirstline

C
C  History
! 2019Aug25.  Merged S/X and broadband.

C  900413 NRV Added re-reading of $CODES section
C  910306 NRV Added reading new parameters: HEAD, EARLY
C  930407 nrv implicit none
C  930708 nrv Add reading $HEAD section
C 951213 nrv Mods for new Mark IV/VLBA setups.
C 951214 nrv Add BARREL
C 960409 nrv Initialize ITRA2
C 960522 nrv Add call to VREAD, store observations in memory.
C 960607 nrv Move initializations into FDRUDG
C 960610 nrv Initialize in call to FRINIT
C 960810 nrv Initialize tape motion values
C 961023 nrv Check for 'TAPE ' along with 'TAPETM' parameter values.
C 970114 nrv Pass CBUF to VREAD so it can check the VEX version
C 970114 nrv Remove the call to VGLINP (put it into VREAD). Write out
C            experiment name, description, PI.
C 970129 nrv Add a check for TAPE_MOTION and GAP
C 970207 nrv Unpack each scan and check the parity flag
C 970219 nrv If parameter values are not in schedule file, set to defaults
C 970307 nrv Initialize ISKREC for SKED files, and time order it at the end.
C 970317 nrv Remove TAPE_MOTION and BARREL
C 970317 nrv Read $PARAM using sked's routines.
C 970401 nrv Set all parameter values to defaults at the start, then if
c            the key words are found in the $PARAM section they get set.
C 970603 nrv Find the start of the cover letter in .drg files.
C 980217 nrv Remove the time-ordering code and call LSKORDER instead.
C 990629 nrv Add late_stop command
C 000517 nrv Find line where $EXPER starts in VEX file and save it.
C 000611 nrv Add call to OBS_SORT for sked files. VEX files already in order.
C 000614 nrv Add call to ATAPE.
C 010102 nrv Add LUSCN to obs_sort call.
C 011011 nrv Move FRINIT call to start.
C 020713 nrv Move reading of $PARAM to DRPRRD.
C 020713 nrv Set kgeo=.true. for sked file, false for VEX. Will be
C            set to .true. if sked_params block is found later in the VEX file.
C 021014 nrv Set kpostpass=.true. for astro (.not.geo) schedules.
C 021021 nrv Don't set default tape motion parameters for VEX files
C            because they have already been read in.
C
! 2006Jul24 JMGipson. Got rid of ilocf, reio. (Remnants of old operating system no longer used.)
! 2018Jun17 JMGipson. Got rid of extra space in output after return from vread.

      close(unit=LU_INFILE)
      open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)

      nstsav=0   !set a flag in freq.ftni.  This indicates we haven't read a F line yet.
      if (ierr.eq.0) then
        rewind(LU_INFILE)
      else
        WRITE(LUSCN,9200) IERR,LSKDFI
9200    FORMAT(' SREAD01 - Error ',I5,' opening file ',A32)
        RETURN
      ENDIF
C
      IRECEL = -1.0
      ksta = .false.
      kcod = .false.
      kvlb = .false.
      khed = .false.
      call frinit(max_stn,max_frq)
C
      read(lu_infile,'(a)') cfirstline
C*********************************************************
C vex file section
C*********************************************************
      if (cfirstline(1:3).eq.'VEX') then ! read VEX file
        kvex=.true.
        kgeo=.false. ! will be set to true if SKED_PARAMS is found later
C       Read up to the $EXPER section to find the line number
        rewind(lu_infile)
        ireccv=0
        CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILEN)
        DO WHILE (ILEN.GT.0.and.cbuf(1:6) .ne. "$EXPER") !read schedule file
          CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILEN)
        enddo !read schedule file
        close(lu_infile)
C       read stations, codes, sources
        i=index(cfirstline,';')
        call VREAD(cfirstline(1:i),lskdfi,luscn,iret,ivexnum,ierr)
        if (iret.ne.0.or.ierr.ne.0) then
          write(luscn,9009) iret,ierr
9009      format(' from VREAD iret=',i5,' ierr=',i5)
        endif
C       Write out experiment information now.
        write(luscn,'("Experiment name: ",a)') cexper
        i=trimlen(cexperdes)
        if (i.gt.0) write(luscn,'("Experiment description: ",a)')
     .  cexperdes(1:i)
        i=trimlen(cpiname)
        if (i.gt.0) write(luscn,'("PI name: ",a)') cpiname(1:i)
        i=trimlen(ccorname)
        if (i.gt.0) write(luscn,'("Correlator: ",a)') ccorname(1:i)

C*********************************************************
C sked file section
C*********************************************************
      else ! sked file
        kvex=.false.
        kgeo=.true.
        rewind(lu_infile)
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)

      DO WHILE (ILEN.GT.0) !read schedule file
        IF (IERR.NE.0)  THEN
          WRITE(LUSCN,9210) IERR
9210      FORMAT(' Error ',I5,' reading schedule file.')
          RETURN
        END IF
        ctype=" "
        IF (cbuf(1:6) .eq. '$EXPER') THEN
          ctype="EX"
        ELSE IF (cbuf(1:7) .eq. '$SOURCE') THEN
          ctype="SO"
        ELSE IF (cbuf(1:8) .eq. '$STATION') THEN
          ctype="ST"
          ksta = .true.
        ELSE IF (cbuf(1:5) .eq. '$SKED') THEN
          ctype="SK"
        ELSE IF (cbuf(1:6) .eq. '$CODES') THEN
          ctype="FR"
          kcod = ksta
        ELSE IF (cbuf(1:5) .eq. '$HEAD') THEN
          ctype="HD"
          khed = kcod
        ELSE IF (cbuf(1:5) .eq. '$PROC') THEN
          ctype="PR"
        END IF
C
C
        IF(ctype .eq. " ") THEN !unrecognized
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        ELSE IF(ctype .eq. "EX") THEN !experiment line
          ich=index(cbuf," ")
          CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
          cexper=" "
          IF (IC1.GT.0) IDUMMY = ICHMV(LEXPER,1,IBUF,IC1,IC2-IC1+1)
          write(luscn,*) cexper
C         Get the next line
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,3)
          DO WHILE (cbuf(1:1) .ne. "$" .and. ilen .ne. -1)
            write(luscn,'(a)') cbuf(1:trimlen(cbuf))
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,3)
          END DO
C
        ELSE IF(ctype .eq. "SO" .or. ctype .eq. "ST" .or.
     >          ctype .eq. "FR" .or. ctype .eq. "HD") then
          write(*,*) cbuf(1:ilen)
C         Get the first line of this section
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          DO WHILE (cbuf(1:1) .ne. "$" .and. ilen .ne. -1)
            IF (IERR.LT.0)  THEN
              WRITE(LUSCN,9220) IERR
9220          FORMAT(' Error ',I5,' reading schedule file.')
              RETURN
            END IF
            ILEN=(ILEN+1)/2
            IF(ctype .eq. "SO") then
              CALL SOINP(cbuf,LUSCN,IERR)
            else IF(ctype .eq. "ST") then
              CALL STINP(IBUF,ILEN,LUSCN,IERR)
            else IF(ctype .eq. "FR" .and. ksta) then
              CALL FRINP(IBUF,ILEN,LUSCN,IERR)
            else IF(ctype .eq. "HD" .and. kcod) then
              CALL HDINP(IBUF,ILEN,LUSCN,IERR)
            END IF
C           Do not return on error.  Information messages from
C           xxINP routines provide sufficient warnings.
C
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          END DO
C
        ELSE IF(ctype .eq. "SK") then !schedule
          write(luscn,*) cbuf(1:ilen)
C         write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
C
C         Read the first line of the schedule
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          DO WHILE (cbuf(1:1) .ne. "$" .and. ilen .ne. -1)
            IF (IERR.LT.0)  THEN
              WRITE(LUSCN,9220) IERR
              RETURN
            END IF
            NOBS = NOBS + 1
C           Store in memory
            cskobs(nobs)=cbuf
            iskrec(nobs)=nobs ! initialize the array in order
C         Unpack the scan just to get kflg
          CALL UNPSK(IBUF,ILEN,LSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .    IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,LCABLE,
     .    MJD,UT,GST,MON,IDA,LMON,LDAY,IERR,KFLG,ioff)
C           If any scans have flag2 set, remember this.
            if (kflg(2)) kparity = .true.
C           If any scans have flag3 set, remember this.
            if (kflg(3)) kprepass = .true.
C
C           Read the next schedule entry
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          END DO
C
        ELSE IF(ctype .eq. "PR") then !procedures
          ksked_proc=.true.
          write(luscn,*) cbuf(1:ilen)
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)

        END IF
      END DO
C
C  Now re-read $CODES section if needed.  No error checking is
C  needed, because it was checked before.
      if (.not.kcod) then
        write(luscn,'(" Re-reading ... ",$)')
        ncodes=0
        if (ksta) call frinit(nstatn,max_frq)
        rewind(LU_INFILE)
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        DO WHILE (ILEN.GT.0) !read schedule file
          IF (cbuf(1:6) .eq. "$CODES") then
            write(luscn,*) cbuf(1:ilen)
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            DO WHILE (cbuf(1:1) .ne. "$" .and. ilen .ne. -1)
              ILEN=(ILEN+1)/2
              CALL FRINP(IBUF,ILEN,LUSCN,IERR)
              CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            enddo !read $CODES section
          endif
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        enddo !read schedule file
      endif
C Re-read $HEAD section if needed.
      if (.not.khed) then
        write(luscn,'(" Re-reading ... ",$)')
        rewind(LU_INFILE)
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        DO WHILE (ILEN.GT.0)
          IF (cBUF(1:5) .eq. "$HEAD") THEN
            write(luscn,*) cbuf(1:ilen)

            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            DO WHILE (cbuf(1:1) .ne. "$" .and. ilen .ne. -1)
              ILEN=(ILEN+1)/2
              CALL HDINP(IBUF,ILEN,LUSCN,IERR)
              CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            enddo
          endif
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        enddo
      endif
C       Look for the string "Cover Letter" in .drg file
        ireccv=0
        if (kdrg_infile) then ! .drg file
          rewind(lu_infile)
          write(luscn,'(" Re-reading to find the cover letter ... ",$)')
          CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILEN)
          DO WHILE (ILEN.GT.0.and.cbuf(1:12) .ne. 'Cover Letter')
            CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILEN)
          enddo !read schedule file
          write(luscn,'()')
        endif ! .drg file
C
C Order the observations, in case they were not so in the $SKED section.
C Not needed for VEX because they are read in when station is selected.
      if (nobs.le.0) then
        write(luscn,9901)
9901    format('SREAD02 - No observations found in the schedule')
      else
        call obs_sort(luscn,nobs)   ! order the whole thing
      endif
C
      endif ! VEX/sked

      isettm = 20
      ipartm = 70
      itaptm = 1
      isortm = 5
      ihdtm = 6
      call drprrd(ivexnum)
! Added 2019Aug25 JMG
      if(.not.kvex) then
        call read_broadband_section
      endif
      if (.not.kgeo) kpostpass=.true.
C      if (.not.kgeo) kpostpass=.false.
C
C Close the schedule file.
      close(lu_infile)

      RETURN
      END
