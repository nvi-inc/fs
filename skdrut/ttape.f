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
! functions
      integer istringminmatch
      integer trimlen

C  LOCAL
      real speed
      double precision s2sp,k4sp
      integer*2 LKEYWD(12)
      integer ikey_len,ich,ic1,ic2,nch,i,j,istn
      integer ival,idum,icode,ias2b
      integer i2long,igtst2,ichmv,jchar
      logical kdefault,ks2,kk4
      character*24 ckeywd
      equivalence (lkeywd,ckeywd)
      character*6 cTapeType(max_stn)
      character*4 cTapeDens(max_stn)

      integer ilist_len
      parameter (ilist_len=3)
      character*12 list(ilist_len)

      integer ilist_hl
      parameter (ilist_hl=2)
      character*12 list_hl(ilist_hl)

      integer ilist_lens2
      parameter (ilist_lens2=2)
      character*3 lists2(ilist_lens2)

      integer ikey,ikeyhl,ikeys2

      data list/"SHORT","THICK","THIN"/
      data list_hl/'HIGH','LOW'/
      data listS2/'LP','SLP'/

      data ikey_len/20/
C
C MODIFICATIONS:
C 990524 nrv New. Copied from STAPE.
C 990621 nrv Remove tape_dens and tape_length and use standard common
C            variables bitdens and maxtap.
C 000125 nrv Add S2 length and speed. Add K4 length.
C 000319 nrv Add K4 specification and output.
C 001003 nrv Add SHORT tape option.
C 020111 nrv Check LSTREC not LTERNA to determine S2 and K4 types.
C 020705 nrv Check NCODES not ICODE for KK4.
C 020815 nrv Add number of passes to listing.
C 021003 nrv Adjust K4 output for speed being in dm internally.
C

      IF  (NSTATN.LE.0.or.ncodes.le.0) THEN  
        write(luscn,*)
     >    "TTAPE00 - Select frequencies and stations first."
        RETURN
      END IF  !no stations selected

C     1. Check for some input.  If none, write out current.
C
      ICH = 1
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN  !no input
        do i=1,nstatn
          if (cstrec(i)(1:2).eq.'S2') then
            if (cs2speed(i).eq. 'LP') s2sp=SPEED_LP
            if (cs2speed(i).eq.'SLP') s2sp=SPEED_SLP
            ival = idint(0.1 + maxtap(i)/(s2sp*5.d0)) ! feet/(ips*5) = min
          elseif (cstrec(i)(1:2).eq.'K4') then
            k4sp = speed(1,i)*10.d0 ! speed for code 1 in m/s
            ival = idint(0.1 + maxtap(i)/(60.d0*k4sp)) ! min=m/(60*m/s)
          else 
            cTapeDens(i)='Low'
            if (bitdens(i,1).gt.56000.0) cTapeDens(i)='High'
            cTapeType(i)='Thin'
            if (maxtap(i).lt.10000.and.maxtap(i).gt.5000)
     .        cTapeType(i)='Thick'
            if (maxtap(i).lt.5000) cTapeType(i)='Short'
          endif
          if (i.eq.1.and.(.not.ks2.and..not.kk4)) WRITE(LUDSP,9910)
9910        FORMAT(' ID  Station   Tape length        Density   ',
     .      '    Passes')
          if (i.eq.1.and.ks2) WRITE(LUDSP,9911)
9911        FORMAT(' ID  Station   Tape length            Speed ')
          if (i.eq.1.and.kk4) WRITE(LUDSP,9912)
9912        FORMAT(' ID  Station   Tape length            Speed')
        enddo
        DO  I=1,NSTATN
C         Write bit density for freq code 1 only.
          WRITE(LUDSP,"(1X,A2,2X,A8,$)") cpoCOD(I),cSTNNA(i)
          if(cstrec(i)(1:2) .eq. "S2") then
            if (cs2speed(i).eq. 'LP') s2sp=SPEED_LP
            if (cs2speed(i).eq.'SLP') s2sp=SPEED_SLP
c                             min   feet           slp/lp          ips
            write(ludsp,9113) ival,maxtap(i),(ls2speed(j,i),j=1,2),s2sp
9113        format(i6," min (",i6," feet)",2x,2a2," (",f3.1," ips)")
          else if (cstrec(i)(1:2) .eq. "K4") then
            k4sp = speed(1,i)*1000.0
            write(ludsp,9114) ival,maxtap(i),k4sp
9114        format(i6," min (",i6," m)",2x," ",f5.1," mm/s")
          else
             WRITE(LUDSP,9112) maxtap(i),cTapeType(i),bitdens(i,1),
     >        cTapeDens(i), maxpas(i)
9112        FORMAT(i6,'feet (',a,')',3x,f6.0,' (',a,')',3x,i3)

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
          ks2 = cstrec(istn)(1:2).eq.'S2'
          kk4 = cstrec(istn)(1:2).eq.'K4'
        else ! all stations
          ks2 = cstrec(1)(1:2).eq.'S2'
          kk4 = cstrec(1)(1:2).eq.'K4'
          do i=2,nstatn
            if((ks2 .and. cstrec(i)(1:2) .ne. "S2") .or.
     >         (kk4 .and. cstrec(i)(1:2) .ne. "K4")) then
              write(luscn,
     >       "('TTAPE99:  All stations must be identical to use _ ',a)")
     >        cstnna(i)
              return
            endif
          enddo
        endif ! one/all stations
        if (kk4.and.ncodes.eq.0) then ! need speed
          write(luscn,9993)
9993      format('TTAPE93 - Select K4 recording mode first.')
          return
        endif ! need speed
        if (.not.ks2.and..not.kk4) then ! Mk3/4
          CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2) ! type
          IF  (IC1.GT.0) THEN 
            nch=min0(ikey_len,ic2-ic1+1)
            ckeywd=" "
            idum = ichmv(lkeywd,1,linstq(2),ic1,nch)
            ikey=istringminmatch(ckeywd,list,ilist_len)
            if (ikey.eq.0) then ! invalid type
              write(luscn,9203) ckeywd(1:trimlen(ckeywd))
9203          format('TTAPE03 Error - invalid type: ',a,', must be ',
     .        'THICK or THIN or SHORT.') 
              return
            END IF  !invalid type
            kdefault = .false.
          else ! use defaults for type and density
            kdefault = .true.
          endif ! type/use defaults
          if((list(ikey) .eq. "SHORT" .or. list(ikey) .eq. "THIN")
     .      .and..not.kdefault) then ! density 
            CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
            IF  (IC1.EQ.0) THEN  !no matching density
              write(luscn,9201)
9201          format('TTAPE02 Error - You must specify HIGH or LOW ',
     .        'bit density for thin or short tape.')
              RETURN
            endif ! no matching density
            nch=min0(ikey_len,ic2-ic1+1)
            ckeywd=" "
            idum = ichmv(lkeywd,1,linstq(2),ic1,nch)
            ikeyhl=istringminmatch(ckeywd,list_hl,ilist_hl)
            if (ikeyhl.eq.0) then ! invalid type
              write(luscn,9204) ckeywd
9204          format('TTAPE03 Error - invalid bit density: ',a,
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
            ckeywd=" "
            idum = ichmv(lkeywd,1,linstq(2),ic1,nch)
            ikeys2=istringminmatch(ckeywd,lists2,ilist_lens2)
            if (ikeys2.eq.0) then ! invalid speed
              write(luscn,9207) ckeywd
9207          format('TTAPE03 Error - invalid S2 speed: ',a,
     .        ', must be SLP or LP.') 
              return
            END IF  !invalid speed
          else ! use defaults for length and speed 
            kdefault = .true.
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
          endif ! type/use defaults
        endif 

C   3. Now set parameters in common.

        DO  I = 1,NSTATN
          if ((istn.eq.0).or.(istn.gt.0.and.i.eq.istn)) then ! this station
            if (cstrec(i)(1:2).eq."S2") then
              if (lists2(ikeys2) .eq. "LP") then
                cs2speed(i)="LP"
                s2sp = SPEED_LP
              else
                cs2speed(i)="SLP"
                s2sp = SPEED_SLP
              endif 
              maxtap(i)=ival*5.d0*s2sp ! convert to feet
            else if (cstrec(i)(1:2) .eq. "K4") then
              k4sp = speed(1,i) ! for code 1
              maxtap(i)=ival*k4sp*60.d0 ! convert to meters
            else
              if (list(ikey) .eq. "THICK") then
                maxtap(i)=thick_length
                do icode=1,NCODES
                  bitdens(i,icode)=33333
                enddo
              elseif(list(ikey).eq."THIN".or.list(ikey).eq."SHORT")then
                maxtap(i)=thin_length
                if(list(ikey) .eq. "SHORT") maxtap(i)=short_length
                if (list_hl(ikeyhl).eq. 'HIGH') then
                  do icode=1,NCODES
                    if (cmode(i,icode)(1:1) .eq. "V") then
                      bitdens(i,icode)=56700 ! VLBA non-data replacement
                    else
                      bitdens(i,icode)=56250 ! Mark3/4 data replacement
                    endif
                  enddo
                else                            !low density.
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
            endif
          endif ! this station
        END DO
C       get next station name
        CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      END DO  !more decoding
C
      RETURN
      END

