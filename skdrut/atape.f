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
! functions
      integer istringminmatch
      integer trimlen
C
C  Called by: fsked, sread

C  LOCAL
      integer*2 LKEYWD(12)
      integer ikey
      integer ikey_len,ich,ic1,ic2,nch,i,istn,idum,il
      integer i2long,igtst2,ichmv,jchar

      character*24 ckeywd
      equivalence (lkeywd,ckeywd)

      integer ilist_len
      parameter (ilist_len=2)
      character*12 list(ilist_len)
      data list/'AUTO','SCHEDULED'/


      data ikey_len/20/
C
C MODIFICATIONS:
C 000605 nrv New. Copied from TTAPE.
C

      IF (NSTATN.LE.0.or.ncodes.le.0) THEN
        write(luscn,*)"ATAPE00 - Select frequencies and stations first."
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
          WRITE(LUDSP,'(1X,A2,2X,A8,2x,a)') cpoCOD(I),cSTNNA(I),
     >        tape_allocation(i)(1:il)
        END DO  
        return
      END IF  !no input
C
C
C     2. Something is specified.  Get each station/type combination.
C
      DO WHILE (IC1.NE.0) !more decoding
       NCH = IC2-IC1+1
        ckeywd=" "
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
        if(ic1 .le. 0) then
          write(luscn,'(3(a,1x))')
     >     "ATAPE02 Error - You must specify a type: ",list(1:2)
          return
        else IF  (IC1.GT.0) THEN
          nch=min0(ikey_len,ic2-ic1+1)
          ckeywd=" "
          idum = ichmv(lkeywd,1,linstq(2),ic1,nch)
          ikey=istringminmatch(list,ilist_len,ckeywd)
          if (ikey.eq.0) then ! invalid type
            write(luscn,
     >     '("ATAPE03 Error - invalid type. Must be one of ",4(a,1x))')
     >      list
            return
          END IF  !invalid type
        endif 

C   3. Now set parameters in common.

        DO  I = 1,NSTATN
          if ((istn.eq.0).or.(istn.gt.0.and.i.eq.istn)) then ! this station
            tape_allocation(i)=list(ikey)
          endif ! this station
        END DO
C       get next station name
        CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      END DO  !more decoding
C
      RETURN
      END

