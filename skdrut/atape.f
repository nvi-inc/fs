      SUBROUTINE ATAPE(LINSTQ,luscn,ludsp)
C
C     ATAPE reads/writes station tape allocation type. This routine 
C     reads the TAPE_ALLOCATION lines in the schedule file and handles 
C     the ALLOCATION command.
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer*2 LINSTQ(*)
      integer luscn,ludsp
C
C  COMMON:
C     include 'skcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
C
C  Called by: fsked, sread

C  LOCAL
      integer*2 LKEYWD(12),lkey,lkeyw2(12)
      integer ikey_len,ikey,ich,ic1,ic2,nch,i,j,istn,idum,il
      integer ichcm_ch,igtky,i2long,igtst2,ichmv,jchar,trimlen
      data ikey_len/20/
C
C MODIFICATIONS:
C 000605 nrv New. Copied from TTAPE.
C

      IF  (NSTATN.LE.0.or.ncodes.le.0) THEN  
        write(luscn,'("ATAPE00 - Select frequencies and ",
     .  "stations first.")')
        RETURN
      END IF  !no stations selected

C     1. Check for some input.  If none, write out current.
C
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        WRITE(LUDSP,9910)
9910    FORMAT(' ID  Station   Tape allocation ')
        DO  I=1,NSTATN
          il=trimlen(tape_allocation(i))
          WRITE(LUDSP,9111) LpoCOD(I),(LSTNNA(J,I),J=1,4),
     .    tape_allocation(i)(1:il)
9111      FORMAT(1X,A2,2X,4A2,2x,a)
        END DO  
        return
      END IF  !no input
C
C
C     2. Something is specified.  Get each station/type combination.
C
      DO WHILE (IC1.NE.0) !more decoding
        NCH = IC2-IC1+1
        CALL IFILL(LKEYWD,1,ikey_len,oblank)
        idum = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,ikey_len))
        IF  (JCHAR(LINSTQ(2),IC1).EQ.OUNDERSCORE) THEN  !all stations
          istn=0
        else if (IGTST2(LKEYWD,ISTN).le.0) THEN !invalid
          write(luscn,9901) lkeywd(1)
9901      format('ATAPE01 Error - Invalid station ID: ',a2)
          return ! don't try to decode the rest of the line
        endif
C       Station ID is valid. Check tape type now.
        CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! type
        IF  (IC1.GT.0) THEN 
          nch=min0(ikey_len,ic2-ic1+1)
          idum = ichmv(lkeyw2(2),1,linstq(2),ic1,nch)
          lkeyw2(1)=nch
          ikey = IGTKY(LKEYW2,25,LKEY)
          if (ikey.eq.0) then ! invalid type
            write(luscn,9203) (lkeyw2(i),i=1,12)
9203        format('ATAPE03 Error - invalid tape allocation type: ',
     .       12a2,', must be ',
     .      'AUTO or SCHEDULED.') 
            return
          END IF  !invalid type
        endif 

C   3. Now set parameters in common.

        DO  I = 1,NSTATN
          if ((istn.eq.0).or.(istn.gt.0.and.i.eq.istn)) then ! this station
            if (ichcm_ch(lkey,1,'AU').eq.0) tape_allocation(i)='AUTO'
            if (ichcm_ch(lkey,1,'SC').eq.0) 
     .        tape_allocation(i)='SCHEDULED'
          endif ! this station
        END DO
C       get next station name
        CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      END DO  !more decoding
C
      RETURN
      END

