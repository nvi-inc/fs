      SUBROUTINE STAPE(LINSTQ,luscn,ludsp)
C
C     STAPE reads/writes station tape motion.
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
C  Calls: gtfld, igtst2, ifill, wrerr

C  LOCAL
      integer*2 lkeyw2(12),LKEYWD(12),lkey
      integer ikey_len,ikey,ich,ic1,ic2,nch,i,j,idummy,istn
      integer idum,il
      integer ias2b,ichcm_ch,trimlen,igtky,i2long,igtst2,ichmv,jchar 
      logical kold ! true for the old format TAPE_MOTION ADAPTIVE GAP 10
      data ikey_len/20/
C
C MODIFICATIONS:
C 970317 NRV New. Copied from SEARL.
C 970328 nrv Parse/list GAP time for ADAPTIVE type.
C 970729 nrv Handle the old format (for ADAPTIVE only) without the 
C            station list and with the GAP key word.
C 980629 nrv Add tape length to listing.
C 980629 nrv Allow DYNAMIC type.
C

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
        WRITE(LUDSP,9110)
9110    FORMAT(' ID  STATION  TAPE_MOTION(gap) Tape length(feet)')
        DO  I=1,NSTATN
          il=trimlen(tape_motion_type(i))
          WRITE(LUDSP,9111) LpoCOD(I),(LSTNNA(J,I),J=1,4),
     .    tape_motion_type(i)(1:il)
9111      FORMAT(1X,A2,2X,4A2,3X,a,$)
          if (tape_motion_type(i).eq.'ADAPTIVE') then
            write(ludsp,'(3x,i5,$)') itgap(i)
          else
            write(ludsp,'(8x,$)')
          endif
          if (tape_motion_type(i).eq.'DYNAMIC') then
            write(ludsp,'(3x,"auto-allocate")') 
          else
            write(ludsp,'(3x,i5)') maxtap(i)
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
        CALL IFILL(LKEYWD,1,ikey_len,oblank)
        IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,ikey_len))
        IF  (JCHAR(LINSTQ(2),IC1).EQ.OUNDERSCORE) THEN  !all stations
          istn=0
        else if (ichcm_ch(lkeywd,1,'ADAPTIVE').eq.0) then !old format
          istn=0
          kold=.true.
        else if (IGTST2(LKEYWD,ISTN).le.0) THEN !invalid
          write(luscn,9901) lkeywd(1)
9901      format('STAPE01 Error - Invalid station ID: ',a2)
C         skip over matching type and get next station name
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! skip type
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! next station
        endif
C       if (kold) ic1 and ic2 already cover 'adaptive'
        if (.not.kold) CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),
     .         IC1,IC2) ! type
        IF  (IC1.EQ.0) THEN  !no matching type
          write(luscn,9201)
9201      format('STAPE02 Error - You must specify a type.')
          RETURN
        END IF  !no matching type
        nch=min0(ikey_len,ic2-ic1+1)
        idummy = ichmv(lkeyw2(2),1,linstq(2),ic1,nch)
        lkeyw2(1)=nch
        ikey = IGTKY(LKEYW2,14,LKEY)
        if (ikey.eq.0) then ! invalid type
          write(luscn,9203) (lkeyw2(i),i=1,12)
9203      format('STAPE03 Error - invalid type: ',12a2) 
        END IF  !invalid type
        if (ichcm_ch(lkey,1,'AD').eq.0) then ! get gap
C         For old format, skip the 'gap' key word
          if (kold) CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) 
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) 
          idum=ias2b(linstq(2),ic1,ic2-ic1+1)
          if (idum.lt.0) write(luscn,'("STAPE03 Error - Invalid gap.")')
        endif ! get gap
        DO  I = 1,NSTATN
          if ((istn.eq.0).or.(istn.gt.0.and.i.eq.istn)) then
            if (ichcm_ch(lkey,1,'AD').eq.0) then
              tape_motion_type(i)='ADAPTIVE'
              itgap(i)=idum
            else if (ichcm_ch(lkey,1,'CO').eq.0) then
              tape_motion_type(i)='CONTINUOUS'
            else if (ichcm_ch(lkey,1,'SS').eq.0) then
              tape_motion_type(i)='START&STOP'
            else if (ichcm_ch(lkey,1,'DY').eq.0) then
              tape_motion_type(i)='DYNAMIC'
            endif
          endif
        END DO
C       get next station name
        CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      END DO  !more decoding
C
      RETURN
      END

