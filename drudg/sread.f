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
      integer ilen,ltype,ich,ic1,ic2,idummy,ic,
     .icx,nch,iret
      integer htype ! section 2-letter code
      logical kcod ! set to ksta when $CODES is found
      logical ksta ! set to true when $STATIONS is found
      logical kvlb ! set to true when $VLBA is found
      logical khed ! set to ksta when $HEAD is found
      integer Z24,hbb,hex,hpa,hso,hst,hfr,hsk,hpr,Z20,hhd,idum
      integer iscnc,iscn_CH,ias2b,jchar,ichcm,ichmv ! functions
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
        call VREAD(lskdfi,luscn,iret,ivexnum,ierr) ! read stations, codes, sources
        if (iret.ne.0.or.ierr.ne.0) then
          write(luscn,9009) iret,ierr
9009      format(' from VREAD iret=',i5,' ierr=',i5)
        endif
        call vglinp(ivexnum,luscn,ierr)
        if (ierr.ne.0) then
          write(luscn,9010) ierr
9010      format(' from VEXINP ierr=',i5)
        endif
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
        ELSE IF (ichcm_ch(IBUF,1,'$PARAM').EQ.0) THEN
          call char2hol('PA',LTYPE,1,2)
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
        ELSE IF(ichcm(htype,1,hpa,1,2).eq.0) THEN !parameter section
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          DO WHILE (JCHAR(IBUF,1).NE.Z24.AND.ILEN.NE.-1)
            IF (ichcm_ch(IBUF,1,'ELEVATION').EQ.0) THEN !el line
              IF (IRECEL.EQ.-1.0) call locf(LU_INFILE,IRECEL) 
            ELSE
              IC = ISCN_CH(IBUF,1,ILEN*2,'PARITY')
              IF (IC.NE.0) THEN !parity time
                CALL GTFLD(IBUF,IC+6,ILEN*2,IC1,IC2)
                IPARTM=IAS2B(IBUF,IC1,IC2-IC1+1)
              ENDIF !parity time
              IC = ISCN_CH(IBUF,1,ILEN*2,'SETUP')
              IF (IC.NE.0) THEN !setup time
                CALL GTFLD(IBUF,IC+5,ILEN*2,IC1,IC2)
                ISETTM=IAS2B(IBUF,IC1,IC2-IC1+1)
              ENDIF !setup time
              IC = ISCN_CH(IBUF,1,ILEN*2,'BARREL')
              IF (IC.NE.0) THEN !barrel roll
                CALL GTFLD(IBUF,IC+7,ILEN*2,IC1,IC2)
              if (ic1.ne.0) idummy = ichmv(lbarrel,1,ibuf,ic1,ic2-ic1+1)
                  ENDIF !barrel roll
              IC = ISCN_CH(IBUF,1,ILEN*2,'SOURCE')
              IF (IC.NE.0) THEN !source time
                CALL GTFLD(IBUF,IC+6,ILEN*2,IC1,IC2)
                ISORTM=IAS2B(IBUF,IC1,IC2-IC1+1)
                  ENDIF !source time
                  IC = ISCN_CH(IBUF,1,ILEN*2,'HEAD')
                  IF (IC.NE.0) THEN !head time
                    CALL GTFLD(IBUF,IC+4,ILEN*2,IC1,IC2)
                    IHDTM=IAS2B(IBUF,IC1,IC2-IC1+1)
                  ENDIF !head time
                  IC = ISCN_CH(IBUF,1,ILEN*2,'EARLY')
                  IF (IC.NE.0) THEN !early time
                    CALL GTFLD(IBUF,IC+5,ILEN*2,IC1,IC2)
                    ITEARL=IAS2B(IBUF,IC1,IC2-IC1+1)
                  ENDIF !early time
                  IC = ISCN_CH(IBUF,1,ILEN*2,'TAPE')
              ICX= ISCN_CH(IBUF,1,ILEN*2,'TAPETM')
              IF (IC.NE.0.OR.ICX.NE.0) THEN !tape time
                IF (IC.EQ.0) ICH=ICX+6
                IF (ICX.EQ.0) ICH=IC+4
                CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
                nch=ic2-ic1+1
                if (nch.gt.0) ITAPTM=IAS2B(IBUF,IC1,nch)
              ENDIF !tape time
            ENDIF
C
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
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
C
C           Read the next schedule entry
            CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
          END DO
C
        ELSE IF(ichcm(htype,1,hpr,1,2).eq.0) THEN !procedures
          rdum= reio(2,LUSCN,IBUF,-ILEN)
C         write(luscn,'(20a2)') (ibuf(i),i=1,(ilen+1)/2)
C
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
C
      endif ! VEX/skd
      RETURN
      END
