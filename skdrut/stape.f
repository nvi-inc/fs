      SUBROUTINE STAPE(LINSTQ,luscn,ludsp)
C
C     STAPE reads/writes station tape motion.
c     This routine reads the TAPE_MOTION lines in the schedule
C     and handles the MOTION command.
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
C
C  Calls: gtfld,  ifill, wrerr
! functions
      integer istringminmatch
      integer ias2b,trimlen,i2long,ichmv
      integer  igetstatnum2

C  LOCAL
      integer*2 lkeywd(12)
      integer ikey_len,ikey,ich,ic1,ic2,nch,i,idummy,istn
      integer idum,il
      logical kold ! true for the old format TAPE_MOTION ADAPTIVE GAP 10

      character*24 ckeywd
      equivalence (lkeywd,ckeywd)

      integer ilist_len
      parameter (ilist_len=3)
      character*12 list(ilist_len)
      data list/'CONTINUOUS','ADAPTIVE','START&STOP'/

      data ikey_len/20/
C
C MODIFICATIONS:
C 970317 NRV New. Copied from SEARL.
C 970328 nrv Parse/list GAP time for ADAPTIVE type.
C 970729 nrv Handle the old format (for ADAPTIVE only) without the 
C            station list and with the GAP key word.
C 980629 nrv Add tape length to listing.
C 980629 nrv Allow DYNAMIC type.
C 021010 nrv Save tape motion for later restoring.
C
C 2003July03  JMG  Modified to use new scheme.

C     1. Check for some input.  If none, write out current.
C
      kold=.false.
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        IF  (NSTATN.LE.0) THEN  !no stations selected
          write(luscn,'("STAPE00 - Select stations first.")') 
          RETURN
        END IF  !no stations selected
        WRITE(LUDSP,"(' ID  STATION  TAPE_MOTION (gap) ')")
        DO  I=1,NSTATN
          il=trimlen(tape_motion_type(i))
          WRITE(LUDSP,"(1X,A2,2X,A8,3X,a,$)")
     >      cpoCOD(I),cSTNNA(I), tape_motion_type(i)(1:il)
          if (tape_motion_type(i).eq.'ADAPTIVE') then
            write(ludsp,'(3x,i5)') itgap(i)
          else
            write(ludsp,'()')
          endif
        END DO  
        RETURN
      END IF  !no input
C
C
C     2. Something is specified.  Get each station/type combination.
C
      DO WHILE (IC1.NE.0) !more decoding
        NCH = IC2-IC1+1
        ckeywd=" "
        IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,ikey_len))
        istn=igetstatnum2(ckeywd(1:2))
        if(ckeywd .eq. "_") then
          istn=0
        else if (ckeywd .eq. 'ADAPTIVE') then !old format
          istn=0
          kold=.true.
        else if (istn.le.0) then
          write(luscn,9901) ckeywd(1:2)
9901      format('STAPE01 Error - Invalid station ID: ',a2)
C         skip over matching type and get next station name
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! skip type
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! next station
        endif
C       if (kold) ic1 and ic2 already cover 'adaptive'
        if (.not.kold) CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),
     .         IC1,IC2) ! type
        IF  (IC1.EQ.0) THEN  !no matching type
          write(luscn,'(4(a,1x))')
     >     'STAPE02 Error - You must specify a type: ', list(1:3)
          RETURN
        END IF  !no matching type
        nch=min0(ikey_len,ic2-ic1+1)
        ckeywd=" "
        idummy = ichmv(lkeywd,1,linstq(2),ic1,nch)
        ikey=istringminmatch(list,ilist_len,ckeywd)
        if (ikey.eq.0) then ! invalid type
          write(luscn,"('STAPE03 Error - invalid type: ',a)") ckeywd
          write(luscn,'(4(a,1x))') "Must be one of: ",list(1:3)
        else
          if (list(ikey) .eq. "ADAPTIVE") then
C         For old format, skip the 'gap' key word
           if (kold) CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
           CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
           idum=ias2b(linstq(2),ic1,ic2-ic1+1)
           if(idum.lt.0) write(luscn,*) " STAPE03 Error - Invalid gap."
          endif ! get gap
          DO  I = 1,NSTATN
            if ((istn.eq.0).or.(istn.gt.0.and.i.eq.istn)) then
              tape_motion_type(i)=list(ikey)
              if(tape_motion_type(i) .eq. "ADAPTIVE") itgap(i)=idum
              tape_motion_save(i)=tape_motion_type(i)
            endif
          END DO
C       get next station name
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
        ENDIF
      END DO  !more decoding
C
      RETURN
      END

