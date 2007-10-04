      SUBROUTINE SLATE(LINSTQ,luscn,ludsp)
C
C     SLATE reads/writes station late stops
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
C  Calls: gtfld, ifill, wrerr

      integer ias2b,i2long,ichmv,jchar !functions
      integer igetstatnum2
C  LOCAL
      integer*2 LKEYWD(12)
      integer ival,ich,ic1,ic2,nch,i,idummy,istn

      character*24 ckeywd
      equivalence (lkeywd,ckeywd)

C
C MODIFICATIONS:
C 990629 nrv New. Copied from SEARL.
C

C     1. Check for some input.  If none, write out current.
C
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        IF  (NSTATN.LE.0) THEN  !no stations selected
          write(luscn,'("SLATE00 - Select stations first.")')
          RETURN
        END IF  !no stations selected
        WRITE(LUDSP,'(" ID  STATION  LATE STOP (sec)")')
        DO  I=1,NSTATN
          WRITE(LUDSP,"(1X,A,3X,A,1X,i5)") cpoCOD(I),cSTNNA(I),itlate(i)
        END DO  !
        RETURN
      END IF  !no input
C
C
C     2. Something is specified.  Get each station/time combination.
C
      DO WHILE (IC1.NE.0) !more decoding
        NCH = IC2-IC1+1
        CALL IFILL(LKEYWD,1,20,oblank)
        IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,20))
        IF  (JCHAR(LINSTQ(2),IC1).EQ.OUNDERSCORE) THEN  !all stations
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          IF  (IC1.EQ.0) THEN  !no matching time
            write(luscn,9201)
9201        format('SLATE01 Error: No matching time.')
            RETURN
          END IF  !no matching time
          iVAL = iAS2B(LINSTQ(2),IC1,IC2-IC1+1)
          IF  (iVAL.LT.0) THEN  !invalid
            idummy=ichmv(lkeywd,1,linstq(2),ic1,min0(20,ic2-ic1+1))
            write(luscn,9202) (lkeywd(i),i=1,10)
9202        format('SLATE02 Error - Invalid time: ',10a2)
            RETURN
          END IF  !invalid
          DO  I = 1,NSTATN
            itlate(I) = iVAL
          END DO
          RETURN
        END IF  !all stations
        istn= igetstatnum2(ckeywd(1:2))
        if (istn.le.0) then
          write(luscn,9901) ckeywd(1:2)
9901      format('SLATE01 - Invalid station name: ',a2)
C         skip over matching time and get next station name
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
        else ! valid
C         get matching time
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
          IF  (IC1.EQ.0) THEN  !no matching time
            write(luscn,9902) lkeywd(1)
9902        format('SLATE02 - No matching time for station ',a2)
            RETURN
          END IF  !no matching time
          iVAL = iAS2B(LINSTQ(2),IC1,IC2-IC1+1)
          IF  (ival.LT.0) THEN  !invalid
            write(luscn,9903) lkeywd(1)
9903        format('SLATE03 - Late stop must be > 0 for ',a2)
          else ! valid
            ITLATE(ISTN) = ival
            write(luscn,'(a)')"SLATE05 Warning - Late stop by "//
     >      "station is not supported at Mark III correlators."
C           get next station name
          endif ! invalid/valid time
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
        endif ! invalid/valid station name
      END DO  !more decoding
C
      RETURN
      END

