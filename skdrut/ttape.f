      SUBROUTINE TTAPE(LINSTQ,luscn,ludsp)
C
C     TTAPE reads/writes station tape type. This routine reads
C     the TAPE_TYPE lines in the schedule file and handles the 
C     TAPE command.
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
C  Calls: gtfld, igtst2, ifill, wrerr

C  LOCAL
      real speed
      double precision s2sp,k4sp
      integer*2 lkeyw2(12),LKEYWD(12),lkey,lkey2
      integer ikey_len,ikey,ich,ic1,ic2,nch,i,j,istn
      integer ival,idum,icode,ias2b
      integer ichcm_ch,igtky,i2long,igtst2,ichmv,jchar,ichmv_ch
      character*5 ctype(max_stn)
      character*4 cdens(max_stn)
      logical kdefault,ks2,kk4,ks21,kk41
      data ikey_len/20/
C
C MODIFICATIONS:
C 990524 nrv New. Copied from STAPE.
C 990621 nrv Remove tape_dens and tape_length and use standard common
C            variables bitdens and maxtap.
C 000125 nrv Add S2 length and speed. Add K4 length.
C 000319 nrv Add K4 specification and output.
C 001003 nrv Add SHORT tape option.
C

      IF  (NSTATN.LE.0.or.ncodes.le.0) THEN  
        write(luscn,'("TTAPE00 - Select frequencies and ",
     .  "stations first.")')
        RETURN
      END IF  !no stations selected

C     1. Check for some input.  If none, write out current.
C
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        do i=1,nstatn
          ks2 = ichcm_ch(lterna(1,i),1,'S2').eq.0
          kk4 = ichcm_ch(lterna(1,i),1,'K4').eq.0
          if (ks2) then
            if (ichcm_ch(ls2speed(1,i),1,'LP').eq.0) s2sp=SPEED_LP
            if (ichcm_ch(ls2speed(1,i),1,'SLP').eq.0) s2sp=SPEED_SLP
            ival = idint(0.001 + maxtap(i)/(s2sp*5.d0)) ! feet/(ips*5) = min
          elseif (kk4) then
            k4sp = speed(1,i) ! speed for code 1
            ival = idint(0.001 + maxtap(i)/(60.d0*k4sp)) ! meters
          else 
            cdens(i)='Low'
            if (bitdens(i,1).gt.56000.0) cdens(i)='High'
            ctype(i)='Thin'
            if (maxtap(i).lt.10000.and.maxtap(i).gt.5000) 
     .        ctype(i)='Thick'
            if (maxtap(i).lt.5000) ctype(i)='Short'
          endif
          if (i.eq.1.and.(.not.ks2.and..not.kk4)) WRITE(LUDSP,9910)
9910        FORMAT(' ID  Station   Tape length        Density ')
          if (i.eq.1.and.ks2) WRITE(LUDSP,9911)
9911        FORMAT(' ID  Station   Tape length            Speed ')
          if (i.eq.1.and.kk4) WRITE(LUDSP,9912)
9912        FORMAT(' ID  Station   Tape length            Speed')
        enddo
        DO  I=1,NSTATN
          ks2 = ichcm_ch(lterna(1,i),1,'S2').eq.0
          kk4 = ichcm_ch(lterna(1,i),1,'K4').eq.0
C         Write bit density for freq code 1 only.
          WRITE(LUDSP,9111) LpoCOD(I),(LSTNNA(J,I),J=1,4)
9111      FORMAT(1X,A2,2X,4A2,$)
          if (.not.ks2.and..not.kk4) then
            WRITE(LUDSP,9112) maxtap(i),ctype(i),bitdens(i,1),cdens(i)
9112        FORMAT(i6,'feet (',a,')',3x,f6.0,' (',a,')')
          else if (ks2) then
            if (ichcm_ch(ls2speed(1,i),1,'LP').eq.0) s2sp=SPEED_LP
            if (ichcm_ch(ls2speed(1,i),1,'SLP').eq.0) s2sp=SPEED_SLP
c                             min   feet           slp/lp          ips
            write(ludsp,9113) ival,maxtap(i),(ls2speed(j,i),j=1,2),s2sp
9113        format(i6," min (",i6," feet)",2x,2a2," (",f3.1," ips)")
          else if (kk4) then
            k4sp = speed(1,i)*1000.0
            write(ludsp,9114) ival,maxtap(i),k4sp
9114        format(i6," min (",i6," m)",2x," ",f5.1," mm/s")
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
        idum = ICHMV(LKEYWD,1,LINSTQ(2),IC1,MIN0(NCH,ikey_len))
        IF  (JCHAR(LINSTQ(2),IC1).EQ.OUNDERSCORE) THEN  !all stations
          istn=0
        else if (IGTST2(LKEYWD,ISTN).le.0) THEN !invalid
          write(luscn,9901) lkeywd(1)
9901      format('TTAPE01 Error - Invalid station ID: ',a2)
C         Since this station is invalid, skip over the type and
C         density and go get next station name for checking
C         CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! skip type
C         CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! skip density
C         CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! next station
          return ! don't try to decode the rest of the line
        endif
C       Station ID is valid. Check tape type now.
        if (istn.gt.0) then ! individual station
          ks2 = ichcm_ch(lterna(1,istn),1,'S2').eq.0
          kk4 = ichcm_ch(lterna(1,istn),1,'K4').eq.0
        else ! all stations
          ks2 = ichcm_ch(lterna(1,1),1,'S2').eq.0
          kk4 = ichcm_ch(lterna(1,1),1,'K4').eq.0
          do i=2,nstatn
            ks21 = ichcm_ch(lterna(1,i),1,'S2').eq.0
            if (ks2.and..not.ks21) then
              write(luscn,9991) (lstnna(j,i),j=1,4)
9991          format('TTAPE99 - All stations must be S2 to use the ',
     .        '_ character.')
              return
            endif
            kk41 = ichcm_ch(lterna(1,i),1,'K4').eq.0
            if (kk4.and..not.kk41) then
              write(luscn,9992) (lstnna(j,i),j=1,4)
9992          format('TTAPE99 - All stations must be K4 to use the ',
     .        '_ character.')
              return
            endif
          enddo
        endif ! one/all stations
        if (kk4.and.icode.eq.0) then ! need speed
          write(luscn,9993)
9993      format('TTAPE93 - Select K4 recording mode first.')
          return
        endif ! need speed
        if (.not.ks2.and..not.kk4) then ! Mk3/4
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! type
          IF  (IC1.GT.0) THEN 
            nch=min0(ikey_len,ic2-ic1+1)
            idum = ichmv(lkeyw2(2),1,linstq(2),ic1,nch)
            lkeyw2(1)=nch
            ikey = IGTKY(LKEYW2,23,LKEY)
            if (ikey.eq.0) then ! invalid type
              write(luscn,9203) (lkeyw2(i),i=1,12)
9203          format('TTAPE03 Error - invalid type: ',12a2,', must be ',
     .        'THICK or THIN or SHORT.') 
              return
            END IF  !invalid type
            kdefault = .false.
          else ! use defaults for type and density
            kdefault = .true.
            idum = ichmv_ch(lkey,1,'  ')
          endif ! type/use defaults
          if ((ichcm_ch(lkey,1,'TN').eq.0.or.ichcm_ch(lkey,1,'SH').eq.0)
     .      .and..not.kdefault) then ! density 
            CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
            IF  (IC1.EQ.0) THEN  !no matching density
              write(luscn,9201)
9201          format('TTAPE02 Error - You must specify HIGH or LOW ',
     .        'bit density for thin or short tape.')
              RETURN
            endif ! no matching density
            nch=min0(ikey_len,ic2-ic1+1)
            idum = ichmv(lkeyw2(2),1,linstq(2),ic1,nch)
            lkeyw2(1)=nch
            ikey = IGTKY(LKEYW2,23,LKEY2)
            if (ikey.eq.0) then ! invalid type
              write(luscn,9204) (lkeyw2(i),i=1,12)
9204          format('TTAPE03 Error - invalid bit density: ',12a2,
     .        ', must be HIGH or LOW.') 
              return
            END IF  !invalid type
          endif ! density
        else if (ks2) then
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! length in min
          IF  (IC1.GT.0) THEN 
            nch=ic2-ic1+1
            ival = ias2b(linstq(2),ic1,nch)
            if (ival.le.0) then ! invalid length
              write(luscn,9205) ival
9205          format('TTAPE05 Error - Invalid tape length ',i5,'. '
     .        'Must be > 0.') 
              return
            END IF  !invalid length
            kdefault = .false.
            CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! speed
            IF  (IC1.EQ.0) THEN  !no speed
              write(luscn,9206)
9206          format('TTAPE06 Error - You must also specify SLP or LP',
     .        ' speed.')
              RETURN
            endif ! no speed
            nch=min0(ikey_len,ic2-ic1+1)
            idum = ichmv(lkeyw2(2),1,linstq(2),ic1,nch)
            lkeyw2(1)=nch
            ikey = IGTKY(LKEYW2,23,LKEY2)
            if (ikey.eq.0) then ! invalid speed
              write(luscn,9207) (lkeyw2(i),i=1,12)
9207          format('TTAPE03 Error - invalid S2 speed: ',12a2,
     .        ', must be SLP or LP.') 
              return
            END IF  !invalid speed
          else ! use defaults for length and speed 
            kdefault = .true.
            idum = ichmv_ch(lkey,1,'  ')
          endif ! type/use defaults
        else if (kk4) then
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! length in min
          IF  (IC1.GT.0) THEN 
            nch=ic2-ic1+1
            ival = ias2b(linstq(2),ic1,nch)
            if (ival.le.0) then ! invalid length
              write(luscn,9208) ival
9208          format('TTAPE08 Error - Invalid tape length ',i5,'. ',
     .        'Must be > 0.') 
              return
            END IF  !invalid length
            kdefault = .false.
          else ! use defaults for length and speed 
            kdefault = .true.
            idum = ichmv_ch(lkey,1,'  ')
          endif ! type/use defaults
        endif 

C   3. Now set parameters in common.

        DO  I = 1,NSTATN
          kk4 = ichcm_ch(lterna(1,i),1,'K4').eq.0
          ks2 = ichcm_ch(lterna(1,i),1,'S2').eq.0
          if ((istn.eq.0).or.(istn.gt.0.and.i.eq.istn)) then ! this station
            if (.not.ks2.and..not.kk4) then ! Mk3/4
              if (ichcm_ch(lkey,1,'TH').eq.0) then
                maxtap(i)=thick_length
                do icode=1,NCODES
                  bitdens(i,icode)=33333
                enddo
              else if (ichcm_ch(lkey,1,'TN').eq.0.or.
     .                 ichcm_ch(lkey,1,'SH').eq.0) then
                maxtap(i)=thin_length
                if (ichcm_ch(lkey,1,'SH').eq.0) maxtap(i)=short_length
                if (ichcm_ch(lkey2,1,'HI').eq.0) then
                  do icode=1,NCODES
                    if (ichcm_ch(lmode(1,i,icode),1,'V').eq.0) then
                      bitdens(i,icode)=56700 ! VLBA non-data replacement
                    else
                      bitdens(i,icode)=56250 ! Mark3/4 data replacement
                    endif
                  enddo
                else if (ichcm_ch(lkey2,1,'LO').eq.0) then
                  do icode=1,NCODES
                    bitdens(i,icode)=33333
                  enddo
                endif
              else if (kdefault) then
                maxtap(i)=maxtap(i)
                do icode=1,NCODES
                  bitdens(i,icode)=bitdens(i,icode) ! code 1 only
                enddo
              endif
            else if (ks2) then !S2
              if (ichcm_ch(lkey2,1,'LP').eq.0) then
                idum = ichmv_ch(ls2speed(1,i),1,'LP  ')
                s2sp = SPEED_LP
              else
                idum = ichmv_ch(ls2speed(1,i),1,'SLP ')
                s2sp = SPEED_SLP
              endif 
              maxtap(i)=ival*5.d0*s2sp ! convert to feet
            else if (kk4) then !S2
              k4sp = speed(1,i) ! for code 1
              maxtap(i)=ival*k4sp*60.d0 ! convert to meters
            endif ! Mk3/4/S2/K4
          endif ! this station
        END DO
C       get next station name
        CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      END DO  !more decoding
C
      RETURN
      END

