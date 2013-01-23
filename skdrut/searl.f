      SUBROUTINE SEARL(LINSTQ,luscn,ludsp)
C
C     SEARL reads/writes station early starts
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer*2 LINSTQ(*)
      integer ludsp,luscn
C
C  COMMON:
C     include 'skcom.ftni'
      include '../skdrincl/statn.ftni'
C
C  Calls: gtfld, igtst2, ifill, wrerr

! functions
      integer ias2b,i2long,ichmv,jchar !functions
      integer igetstatnum2

C  LOCAL
      integer*2 LKEYWD(12)
      integer ival,ich,ic1,ic2,nch,i,idummy,istn
      character*24 ckeywd
      equivalence (lkeywd,ckeywd)
C
C MODIFICATIONS:
C 970314 NRV New. Copied from SELEV.
C 970317 nrv Early must be > CAL.
C 970321 nrv Add warning that this works only for non-Mk3 correlators.
! 2010Mar20 JMG. Removed obsolete warning message. 
C

C     1. Check for some input.  If none, write out current.
C
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        IF  (NSTATN.LE.0) THEN  !no stations selected
          write(luscn,'("SEARL00 - Select stations first.")')
          RETURN
        END IF  !no stations selected
        WRITE(LUDSP,'(" ID  STATION  EARLY START (sec)")')
        DO  I=1,NSTATN
          WRITE(LUDSP,"(1X,A,3X,A,1X,i5)") cpoCOD(I),cSTNNA(I),itearl(i)
        END DO  !
        RETURN
      END IF  !no input
C
C
C     2. Something is specified.  Get each station/time combination.
C
C      if (itsync.gt.0) then
C        write(luscn,9200) 
C9200    format('SEARL04 - Error: parameter CORSYNCH must be 0 to use ',
C     .  ' early start.')
C        return
C      endif
      DO WHILE (IC1.NE.0) !more decoding
        NCH = IC2-IC1+1
        CALL IFILL(LKEYWD,1,20,oblank)
        IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,20))
        IF  (JCHAR(LINSTQ(2),IC1).EQ.OUNDERSCORE) THEN  !all stations
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          IF  (IC1.EQ.0) THEN  !no matching time
            write(luscn,9201)
9201        format('SEARL01 Error: No matching time.')
            RETURN
          END IF  !no matching time
          iVAL = iAS2B(LINSTQ(2),IC1,IC2-IC1+1)
          IF  (iVAL.LT.0) THEN  !invalid
            idummy=ichmv(lkeywd,1,linstq(2),ic1,min0(20,ic2-ic1+1))
            write(luscn,9202) (lkeywd(i),i=1,10)
9202        format('SEARL02 Error - Invalid time: ',10a2)
            RETURN
          END IF  !invalid
          DO  I = 1,NSTATN
            itearl(I) = iVAL
          END DO
          RETURN
        END IF  !all stations
        istn=igetstatnum2(ckeywd(1:2))
        if (istn.le.0) then
          write(luscn,9901) ckeywd(1:2)
9901      format('SEARL01 - Invalid station name: ',a2)
C         skip over matching time and get next station name
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
        else ! valid
C         get matching time
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          IF  (IC1.EQ.0) THEN  !no matching time
            write(luscn,9902) lkeywd(1)
9902        format('SEARL02 - No matching time for station ',a2)
            RETURN
          END IF  !no matching time
          iVAL = iAS2B(LINSTQ(2),IC1,IC2-IC1+1)
          IF  (ival.LT.0) THEN  !invalid
            write(luscn,9903) lkeywd(1)
9903        format('SEARL03 - Early start must be > 0 for ',a2)
C          else if (ival.gt.0.and.ival.lt.icalde) then ! too short
C            write(luscn,9904) lkeywd(1)
C9904        format('SEARL03 - Early start must be > CAL for ',a2)
          else ! valid
            ITEARL(ISTN) = ival
C            get next station name
          endif ! invalid/valid time
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
        endif ! invalid/valid station name
      END DO  !more decoding
C
      RETURN
      END

