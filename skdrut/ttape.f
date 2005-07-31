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

C  LOCAL
      real speed
      double precision s2sp,k4sp
      integer*2 LKEYWD(12)
      integer ikey_len,ich,ic1,ic2,nch,i,istn
      integer ival,idum,icode,ias2b
      integer i2long,igtst2,ichmv,jchar
      logical kdefault,ks2,kk4
      character*24 ckeywd
      equivalence (lkeywd,ckeywd)
      character*6 cTapeType(max_stn)
      character*6 cTapeDens(max_stn)

      integer ilist_len
      parameter (ilist_len=5)
      character*12 list(ilist_len)

      integer ilist_hl
      parameter (ilist_hl=4)
      character*12 list_hl(ilist_hl)

      integer ilist_lens2
      parameter (ilist_lens2=2)
      character*3 lists2(ilist_lens2)

      integer ikey,ikeyhl,ikeys2

      data list/"SHORT","THICK","THIN","MK5","MARK5A"/
      data list_hl/'HIGH','LOW','SUPER','DUPER'/
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
! 2004Jun21 JMG. Added "Super" tape density

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
        kk4=cterna(1)(1:2).eq."K4"
        ks2=cterna(1)(1:2).eq."S2"
! write header
        if(ks2) then
          WRITE(LUDSP,'(a)')
     >     ' ID  Station   Tape length            Speed '
        else if(kk4) then
          WRITE(LUDSP,'(a)')
     >     ' ID  Station   Tape length            Speed '
        else
          WRITE(LUDSP,'(a)')
     >  ' ID  Station   Tape length         Density         Passes'
        endif

        do i=1,nstatn
          WRITE(LUDSP,"(1X,A2,2X,A8,$)") cpoCOD(I),cSTNNA(i)
          if (cstrec(i)(1:2).eq.'S2') then
            if (cs2speed(i).eq. 'LP') s2sp=SPEED_LP
            if (cs2speed(i).eq.'SLP') s2sp=SPEED_SLP
            ival = idint(0.1 + maxtap(i)/(s2sp*5.d0)) ! feet/(ips*5) = min
            write(ludsp,9113) ival,maxtap(i),cs2speed(i),s2sp
9113        format(i6," min (",i6," feet)",2x,a," (",f3.1," ips)")
          elseif (cstrec(i)(1:2).eq.'K4') then
            k4sp = speed(1,i)*1000.0
            ival = idint(0.1 + maxtap(i)/(60.d0*k4sp)) ! min=m/(60*m/s)
            write(ludsp,9114) ival,maxtap(i),k4sp
9114        format(i6," min (",i6," m)",2x," ",f5.1," mm/s")
          else 
            if(bitDens(i,1)      .gt.5600000.0) then
               cTapeDens(i)="DUPER"
            else if(bitDens(i,1) .gt.560000.0) then
               cTapeDens(i)="SUPER"
            else if(bitDens(i,1) .gt.56000.0) then
               cTapeDens(i)="HIGH"
            else
               cTapeDens(i)="Low"
            endif
            cTapeType(i)='Thin'
            if (maxtap(i).lt.10000.and.maxtap(i).gt.5000)
     .        cTapeType(i)='Thick'
            if (maxtap(i).lt.5000) cTapeType(i)='Short'

            if(cstrec(i) .eq. "Mark5A") then
               write(ludsp,'(" Mark5A")')
            else
              WRITE(LUDSP,9112) maxtap(i),cTapeType(i),
     >          int(bitdens(i,1)), cTapeDens(i), maxpas(i)
            endif
9112        FORMAT(i6,'feet (',a,')',3x,i7,' (',a,')',3x,i3)
          endif
        enddo
        RETURN
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
9901      format('TTAPE01 Error - Invalid station ID: ',a2)
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
            call capitalize(ckeywd)
            ikey=istringminmatch(list,ilist_len,ckeywd)
            if (ikey.eq.0) then ! invalid type
              write(luscn,'("TTAPE03: Invalid tape type: ",a)') ckeywd
              write(luscn,'("  Valid types: ",10a)') (list(i),i=1,5)
              return
            else if(ikey .eq. 4 .or. ikey .eq. 5) then
               cstrec(istn) = "Mark5A"
            endif
            kdefault = .false.
          else ! use defaults for type and density
            kdefault = .true.
          endif ! type/use defaults
          if(.not. kdefault) then
            if(list(ikey).eq. "SHORT" .or. list(ikey).eq."THIN") then
              CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
              IF  (IC1.EQ.0) THEN  !no matching density
                write(luscn,'(a)') "TTAPE02 Error:  You must specify "//
     >               "HIGH or LOW bit density for thin or short tape."
                RETURN
              endif ! no matching density
              nch=min0(ikey_len,ic2-ic1+1)
              ckeywd=" "
              idum = ichmv(lkeywd,1,linstq(2),ic1,nch)
              ikeyhl=istringminmatch(list_hl,ilist_hl,ckeywd)
              if (ikeyhl.eq.0) then ! invalid type
                write(luscn,9204) ckeywd
9204            format('TTAPE04 Error - invalid bit density: ',a,
     .          ', must be HIGH or LOW.')
                return
              END IF  !invalid type
            endif
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
              write(luscn,'(a)')
     >         "TTAPE06 Error - You must also specify SLP or LP speed."
              RETURN
            endif ! no speed
            nch=min0(ikey_len,ic2-ic1+1)
            ckeywd=" "
            idum = ichmv(lkeywd,1,linstq(2),ic1,nch)
            ikeys2=istringminmatch(lists2,ilist_lens2,ckeywd)
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
              if(cstrec(i) .eq. "Mark5A") then
                do icode=1,ncodes
                  bitdens(i,icode)=1.d9   !Very high density means we don't need to worry about it.
                end do
                maxtap(i)=10000         !set to 10 thousand feet.
              else if (kdefault) then
                maxtap(i)=maxtap(1)
                do icode=1,NCODES
                  bitdens(i,icode)=bitdens(1,icode) ! code 1 only
                enddo
              else if (list(ikey) .eq. "THICK") then
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
                else if(list_hl(ikeyhl) .eq. 'SUPER') then
                  do icode=1,NCODES
                     bitdens(i,icode)=562500.0
                  end do
                else if(list_hl(ikeyhl) .eq. 'DUPER') then
                  do icode=1,NCODES
                     bitdens(i,icode)=5625000.0
                  end do
                else                            !low density.
                  do icode=1,NCODES
                    bitdens(i,icode)=33333
                  enddo
                endif
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

