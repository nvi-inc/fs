      SUBROUTINE SREAD(IERR,ivexnum)   
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'

C  Output:
      integer ierr,ivexnum

C  Local:
      integer ical,iyr,idayr,ihr,imin,isc,nstnsk,mjd,mon,ida
      double precision ut,gst
      integer*2 ibufq(ibuf_len)
      integer*2 LSNAME(max_sorlen/2),LSTN(MAX_STN),LCABLE(MAX_STN),
     .          LMON(2),LDAY(2),LPRE(3),LPST(3),LMID(3),LDIR(MAX_STN),
     .          lfreq,itim1(6),itim2(6)
      integer   IPAS(MAX_STN),IFT(MAX_STN),IDUR(MAX_STN),ioff(max_stn)
      integer irec,ipnt,ilen,ltype,ich,ic1,ic2,idummy,
     .nch,iret,i
      integer htype ! section 2-letter code
      logical kearl
      logical kcod ! set to ksta when $CODES is found
      logical ksta ! set to true when $STATIONS is found
      logical kvlb ! set to true when $VLBA is found
      logical khed ! set to ksta when $HEAD is found
      integer Z24,hbb,hex,hpa,hso,hst,hfr,hsk,hpr,Z20,hhd,idum
      integer iscn_ch,iscnc,jchar,ichcm,ichmv ! functions
      integer ichcm_ch,trimlen
      real rdum,reio
      character*128 cbuf
C Initialized:
      data    Z24/Z'24'/, hbb/2h  /, hex/2hEX/, hpa/2hPA/, hso/2hSO/
      data    hhd/2hHD/
      data    hst/2hST/, hfr/2hFR/, hsk/2hSK/, hpr/2hPR/,Z20/Z'20'/
C
C  History
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
C
C
      close(unit=LU_INFILE)
      open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)

      if (ierr.eq.0) then
        rewind(LU_INFILE)
        call initf(LU_INFILE,IERR)
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
C
      kvex=.false.
      read(lu_infile,'(a)') cbuf
      if (cbuf(1:3).eq.'VEX') then ! read VEX file
        kvex=.true.
        close(lu_infile)
C       read stations, codes, sources
        i=index(cbuf,';')
        call VREAD(cbuf(1:i),lskdfi,luscn,iret,ivexnum,ierr) 
        if (iret.ne.0.or.ierr.ne.0) then
          write(luscn,9009) iret,ierr
9009      format(' from VREAD iret=',i5,' ierr=',i5)
        endif
C       Write out experiment information now.
        write(luscn,'(/"Experiment name: ",4a2)') lexper
        i=trimlen(cexperdes)
        if (i.gt.0) write(luscn,'("Experiment description: ",a)') 
     .  cexperdes(1:i)
        i=trimlen(cpiname)
        if (i.gt.0) write(luscn,'("PI name: ",a)') cpiname(1:i)
        i=trimlen(ccorname)
        if (i.gt.0) write(luscn,'("Correlator: ",a)') ccorname(1:i)
      else ! skd file
        rewind(lu_infile)
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)

      DO WHILE (ILEN.GT.0) !read schedule file
        IF (IERR.NE.0)  THEN
          WRITE(LUSCN,9210) IERR
9210      FORMAT(' Error ',I5,' reading schedule file.')
          RETURN
        END IF
        call char2hol('  ',LTYPE,1,2)
        IF (ichcm_ch(IBUF,1,'$EXPER').EQ.0) THEN
          call char2hol('EX',LTYPE,1,2)
        ELSE IF (ichcm_ch(IBUF,1,'$SOURC').EQ.0) THEN
          call char2hol('SO',LTYPE,1,2)
        ELSE IF (ichcm_ch(IBUF,1,'$STATI').EQ.0) THEN
          call char2hol('ST',LTYPE,1,2)
          ksta = .true.
        ELSE IF (ichcm_ch(IBUF,1,'$SKED ').EQ.0) THEN
          call char2hol('SK',LTYPE,1,2)
        ELSE IF (ichcm_ch(IBUF,1,'$CODES').EQ.0) THEN
          call char2hol('FR',LTYPE,1,2)
          kcod = ksta
          if (ksta) call frinit(nstatn,max_frq)
        ELSE IF (ichcm_ch(IBUF,1,'$HEAD').EQ.0) THEN
          call char2hol('HD',LTYPE,1,2)
          khed = kcod
        ELSE IF (ichcm_ch(IBUF,1,'$PROCE').EQ.0) THEN
          call char2hol('PR',LTYPE,1,2)
        END IF
C
        htype= (LTYPE)
C
        IF(ichcm(htype,1,hbb,1,2).eq.0) THEN !unrecognized
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
C
        ELSE IF(ichcm(htype,1,hex,1,2).eq.0) THEN !experiment line
          ICH = ISCNC(IBUF,1,ILEN,Z20)
          CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
          CALL IFILL(LEXPER,1,8,Z20)
          IF (IC1.GT.0) IDUMMY = ICHMV(LEXPER,1,IBUF,IC1,IC2-IC1+1)
          rdum= reio(2,LUSCN,IBUF,-ILEN)
C         write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
C         Get the next line
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,3)
          DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1) ! read all lines
            call hol2char(ibuf,1,ilen*2,cbuf)
            write(luscn,'(a)') cbuf(1:trimlen(cbuf))
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,3)
          END DO
C
        ELSE IF(ichcm(htype,1,hso,1,2).eq.0 
     .  .or.    ichcm(htype,1,hst,1,2).eq.0 
     .  .or.    ichcm(htype,1,hfr,1,2).eq.0 
     .  .or.    ichcm(htype,1,hhd,1,2).eq.0 )
     .  THEN !parameter section
          rdum= reio(2,LUSCN,IBUF,-ILEN)
C         write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
C
C         Get the first line of this section
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1)
            IF (IERR.LT.0)  THEN
              WRITE(LUSCN,9220) IERR
9220          FORMAT(' Error ',I5,' reading schedule file.')
              RETURN
            END IF
            ILEN=(ILEN+1)/2
            IF(ichcm(ltype,1,hso,1,2).eq.0) then
              CALL SOINP(IBUF,ILEN,LUSCN,IERR)
            else IF(ichcm(ltype,1,hst,1,2).eq.0) then
              CALL STINP(IBUF,ILEN,LUSCN,IERR)
            else IF(ichcm(ltype,1,hfr,1,2).eq.0.and.ksta) then
              CALL FRINP(IBUF,ILEN,LUSCN,IERR)
            else IF(ichcm(ltype,1,hhd,1,2).eq.0.and.kcod) then
              CALL HDINP(IBUF,ILEN,LUSCN,IERR)
            END IF
C           Do not return on error.  Information messages from
C           xxINP routines provide sufficient warnings.
C
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          END DO
C
        ELSE IF(ichcm(htype,1,hsk,1,2).eq.0) THEN !schedule
          rdum= reio(2,LUSCN,IBUF,-ILEN)
C         write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
C
C         Read the first line of the schedule
          call locf(LU_INFILE,IRECSK)
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1)
            IF (IERR.LT.0)  THEN
              WRITE(LUSCN,9220) IERR
              RETURN
            END IF
            NOBS = NOBS + 1
C           Store in memory
            call ifill(lskobs(1,nobs),1,ibuf_len*2,z20)
            idum = ichmv(lskobs(1,nobs),1,ibuf,1,ilen)
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
        ELSE IF(ichcm(htype,1,hpr,1,2).eq.0) THEN !procedures
          rdum= reio(2,LUSCN,IBUF,-ILEN)
C         write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
C         Get the position of this section
          call locf(LU_INFILE,IRECPR)
C         And read the first line
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
        call initf(LU_INFILE,IERR)
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        DO WHILE (ILEN.GT.0) !read schedule file
          IF (ichcm_ch(IBUF,1,'$CODES').EQ.0) THEN
            rdum= reio(2,LUSCN,IBUF,-ILEN)
C           write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1)
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
        call initf(LU_INFILE,IERR)
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        DO WHILE (ILEN.GT.0) 
          IF (ichcm_ch(IBUF,1,'$HEAD ').EQ.0) THEN
            rdum= reio(2,LUSCN,IBUF,-ILEN)
C           write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1)
              ILEN=(ILEN+1)/2
              CALL HDINP(IBUF,ILEN,LUSCN,IERR)
              CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            enddo 
          endif
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        enddo 
      endif
C Go back to parameter section and read it now.
        write(luscn,'(" Re-reading ... ",$)')
        rewind(LU_INFILE)
        do i=1,nstatn
          tape_motion_type(i)='START&STOP'
          itearl(i)=0
          itgap(i)=0
          itlate(i)=0
        enddo
        isettm = 20
        ipartm = 70
        itaptm = 1
        isortm = 5
        ihdtm = 6
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        DO WHILE (ILEN.GT.0) !read schedule file
          IF (ichcm_ch(IBUF,1,'$PARAM').EQ.0) THEN
            rdum= reio(2,LUSCN,IBUF,-ILEN)
C           write(luscn,'(40a2)') (ibuf(i),i=1,(ilen+1)/2)
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1)
              ich=1
              CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
              nch=ilen-ic2+1
              if (ichcm_ch(ibuf,ic1,'ELEVATION ').eq.0) then
                ibufq(1)=nch
                idum=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
                call selev(ibufq,luscn,luscn)
              else if (ichcm_ch(ibuf,ic1,'TAPE_MOTION').eq.0) then
                ibufq(1)=nch
                idum=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
                call stape(ibufq,luscn,luscn)
              else if (ichcm_ch(ibuf,ic1,'EARLY_START ').eq.0) then
                ibufq(1)=nch
                idum=ichmv(ibufq(2),1,ibuf,ic2+1,nch)
                call searl(ibufq,luscn,luscn)
              else if (ichcm_ch(ibuf,ic1,'SNR  ').eq.0) then
              else if (ichcm_ch(ibuf,ic1,'SCAN  ').eq.0) then
              else if (ichcm_ch(ibuf,ic1,'SUBNET  ').eq.0) then
              else if (ichcm_ch(ibuf,ic1,'WEIGHT  ').eq.0) then
              else
                ibufq(1)=ilen
                idum=ichmv(ibufq(2),1,ibuf,1,ilen)
                call drset(ibufq)
              endif
              CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
            enddo !read $PARAM section
          endif
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,1)
        enddo !read schedule file
C       Look for the string "Cover Letter"
        ireccv=0
        if (kdrg_infile) then ! .drg file
          rewind(lu_infile)
          call initf(lu_infile,ierr)
          write(luscn,'(" Re-reading to find the cover letter ... ",$)')
          CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILEN)
          call inc(lu_infile,ierr)
          DO WHILE (ILEN.GT.0.and.ireccv.eq.0) !read schedule file
            IF (iscn_ch(IBUF,1,ilEN*2,'Cover Letter').gt.0) THEN
              call locf(LU_INFILE,IRECCV)
            endif
            CALL READF_ASC(lu_infile,iERR,IBUF,ISKLEN,ILEN)
            call inc(lu_infile,ierr)
          enddo !read schedule file
          write(luscn,'()')
        endif ! .drg file
C Close the schedule file.
      close(lu_infile)
C
C Order the observations, in case they were not so in the $SKED section.
      if (nobs.le.0) then
        write(luscn,9901)
9901    format('SREAD02 - No observations found in the schedule')
      else
C Comment this out until it's fixed.
C       call lskorder(2) ! order the whole thing
      endif
C
      endif ! VEX/skd
C
      RETURN
      END
