      SUBROUTINE STINP(IBUFX,ILEN,LU,IERR)
C
C     This routine reads and decodes a station entry
C
      include '../skdrincl/skparm.ftni'
      include "../skdrincl/constants.ftni"
C
C  INPUT:
      integer*2 IBUFX(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUFX in words
C     LU - unit for writing error messages
C
C  OUTPUT:
      integer ierr
C     IERR - error number, non-zero is bad
C
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
C
! functions
      integer ichcm,igtba,ichcm_ch,ichmv_ch,ichmv,jchar ! functions

C  LOCAL:
      integer*2 ibufin(40)
      character*80 cbufin
      equivalence (ibufin,cbufin)

      logical kline,ks2,kk4
      integer*2 LNAME(4),LAXIS(2)
      real*4 SLRATE(2),ANLIM1(2),ANLIM2(2)
      integer*2 LD(7),LOCC(4)
      integer islcon(2)
      REAL*4 AZH(MAX_HOR),ELH(MAX_HOR),CO1(MAX_COR),CO2(MAX_COR)
      real*4 DIAM
      real*4 sefd(max_band),par(max_sefdpar,max_band)
      integer*2 lb(max_band)
      real*8 POSXYZ(3),AOFF

      character*8 cname
      equivalence (cname,lname)

C      - these are used in unpacking station info
      INTEGER J,itype,nr,maxt,npar(max_band)
      integer idummy,ib,ii,nco,nhz,i,idum
      integer*2 lidt(2),lid,lidpos,lidhor,lrack(4),lrec1(4),lrec2(4)

      character*8 crack,crec1,crec2
      equivalence (crack,lrack),(crec1,lrec1),(crec2,lrec2)
      character*4 cidt
      equivalence (cidt,lidt)

      double precision poslat,poslon
      integer ibitden
      integer nstack
      integer*2 ls2sp(2)
      character*4 cs2sp
      equivalence (ls2sp,cs2sp)

      real s2sp

C
C  INITIALIZED
C
C  PROGRAMMER: NRV
C  WHEN   WHO  CHANGES
C  830423 NRV ADDED AXIS TYPES 2,4 FOR X,Y MOUNTS
C  840924 MWH GET STATION NAME FROM POSITION ENTRY
C  880314 NRV DE-COMPC'D
C  880603 PMR revised for workstation (removed PCOUNT)
C  881221 GAG added nrv's calls to UNPVH for HORIZON AND COORDINATE MASKS
C  891116 NRV Changed UNPVT call to get multiple SEFDs and bands
C  891117 NRV restored UNPVT call
C  891215 NRV Store antenna names in new array LANTNA
C  891228 NRV Changed UNPVA call to add PCOUNT
C  900116 NRV Changed UNPVT call to add SEFD info
C  900119 NRV Removed lb, sefd from UNPVT and moved to LO lines
C  900125 NRV Changed terminal ID to integer
C  900126 NRV Changed calling sequence to replace INUM with LU
C  921101 nrv Add nr to unpvt call
C  930225 nrv implicit none
C  940428 nrv Always store away LBSEFD even if frequencies are available.
C             If new frequencies are selected, this array is checked, so
C             it needs to be set up correctly and this is the place to do it.
C 951116 nrv Remove maxpass and replace with bit density
C 960208 nrv Increment NSTATN after checking for MAX_STN
C 960227 nrv Make terminal ID up to 4 characters, not integer.
C 960409 nrv Change UNPVT call to include nstack, ibitden 
C 980629 nrv If "auto" for tape length, set tape_motion_type=DYNAMIC
C 990607 nrv Add rack,rec,fm to UNPVT call. Store values.
C 990620 nrv Check rack,rec,frm types for consistency.
C 990620 nrv Store S2 mode.
C 991028 nrv Initialize second recorder type to 'none'.
C 991103 nrv For errors in later fields on the input lines, try decoding anyway.
C 991103 nrv Remove checks for recorder/rack pairs. Add recb to unpvt call.
C 991122 nrv Remove S2 speed and mode to be set in the modes section. Set
c            S2 speed.
C 991123 nrv Recorder 1 and 2, not a and b.
C 000126 nrv Convert S2 tape length from minutes (e.g. 360) to feet
C            (e.g. 7560) using speed.
C
C     1. Find out what type of entry this is.  Decode as appropriate.
C
      do i=1,min(ilen,40)
        ibufin(i)=ibufx(i)
      end do

      ITYPE=0
      IF (JCHAR(IBUFX,1).EQ.OCAPA) THEN !      'A'
        ITYPE=1
      ELSE IF (JCHAR(IBUFX,1).EQ.OCAPP) THEN ! 'P'
        ITYPE=2
      ELSE IF (JCHAR(IBUFX,1).EQ.OCAPT) THEN ! 'T'
        ITYPE=3
      ELSE IF (JCHAR(IBUFX,1).EQ.OCAPC) THEN ! 'C'
        ITYPE=4
      ELSE IF (JCHAR(IBUFX,1).EQ.OCAPH) THEN ! 'H'
        ITYPE=5
      END IF

      IF (ITYPE.EQ.1) THEN
        J=16
        CALL UNPVA(IBUFX(2),ILEN-1,IERR,LID,LNAME,
     .    LAXIS,AOFF,SLRATE,ANLIM1,ANLIM2,DIAM,LIDPOS,LIDT,
     .    LIDHOR,ISLCON,J)
      ELSE IF (ITYPE.EQ.2) THEN
        J = 12
        CALL UNPVP(IBUFX(2),ILEN-1,IERR,LID,LNAME,
     .    POSXYZ,LD,LD,LD,POSLAT,POSLON,LOCC)
      ELSE IF (ITYPE.EQ.3) THEN
        j=8
        CALL UNPVT(IBUFX(2),ILEN-1,IERR,LIDT,LNAME,ibitden,
     .  nstack,maxt,nr,ls2sp,
     .  lb,sefd,j,par,npar,lrack,lrec1,lrec2)
      ELSE IF (ITYPE.EQ.4) THEN
        J = 8
        CALL UNPVH(IBUFX(2),ILEN-1,IERR,LID,NCO,CO1,CO2)
      ELSE IF (ITYPE.EQ.5) THEN
        J = 8
        CALL UNPVH(IBUFX(2),ILEN-1,IERR,LID,NHZ,AZH,ELH)
      END IF
C
C
C     2. Now decide what to do with this information.
C     We have ignored the terminal type of entry, this is only for
C     the correlator.
C     If we have an antenna entry, check for its name already established
C     by the $CODES section.  If we have a position entry, then we must
C     already have the antenna entry.
C
9105  format("STINP23 - Error in field ",i4," of the following line"
     ./120a2)
C
      IF  (ITYPE.EQ.1) THEN  !antenna entry
        IF  (IERR.NE.0) THEN
          IERR = -(IERR+100)
          write(lu,9105) ierr,(ibufx(i),i=2,ilen)
          if (ierr.lt. 5) RETURN
        END IF  !
C
        I=1
        DO WHILE (i.le.nstatn.and.LID.NE.LSTCOD(I))
          I=I+1
        END DO
        IF  (I.GT.NSTATN) THEN  !new entry
          IF  (i.GT.MAX_STN) THEN  !
            write(lu,'("STINP20 - Too many antennas.  Max is ",i3)')
     >         max_stn
            goto 900
          END IF  !
          NSTATN = NSTATN+1
        END IF  !new entry
C
C     2.2 Now we have, in "I", the proper index to use for the antenna
C     information.
C NO: Store the position ID temporarily into the first word of STNPOS.
C     Put the position ID into a permanent place in LPOCOD
C
        LSTCOD(I) = LID
        call axtyp(laxis,iaxis(i),1)
        STNRAT(1,I) = SLRATE(1)*deg2rad/60.0d0
        STNRAT(2,I) = SLRATE(2)*deg2rad/60.0d0
        ISTCON(1,I) = ISLCON(1)
        ISTCON(2,I) = ISLCON(2)
        STNLIM(1,1,I) = ANLIM1(1)*deg2rad
        STNLIM(2,1,I) = ANLIM1(2)*deg2rad
        STNLIM(1,2,I) = ANLIM2(1)*deg2rad
        STNLIM(2,2,I) = ANLIM2(2)*deg2rad
        AXISOF(I)=AOFF
        DIAMAN(I)=DIAM
        LPOCOD(I)   = LIDPOS
        idummy = ichmv(LTERID(1,I),1,LIDT,1,4)
        lhccod(i) = lidhor
        NHORZ(I) = 0
        cantna(i)=cname
C
C     END IF  !antenna entry
C
C     2.3 Here we handle the position information.
C     It is not an error to have the occ. code or lat,lon missing.
C
      ELSE IF  (ITYPE.EQ.2) THEN  !position entry
        IF  (IERR.NE.0) THEN
          IERR = -(IERR+100)
          write(lu,9105) ierr,(ibufx(i),i=2,ilen)
          if (ierr.le.5) RETURN
        END IF
C
        I=1
        DO WHILE (i.le.nstatn.and.LID.NE.LPOCOD(I))
          I=I+1
        END DO
        IF  (I.GT.NSTATN) THEN  !entry not found
          write(lu,'("STINP21 - Pointer not found. ")')
          goto 900
        END IF  !entry not found
C
C     2.3 Now "I" contains the index into which we will put the
C     position information.
C
!        IDUMMY = ICHMV(LSTNNA(1,I),1,LNAME,1,8)
        cstnna(i)=cname
        STNPOS(1,I) = POSLON*deg2rad
        STNPOS(2,I) = POSLAT*deg2rad
        stnxyz(1,i) = posxyz(1)
        stnxyz(2,i) = posxyz(2)
        stnxyz(3,i) = posxyz(3)
        idum=ichmv(loccup(1,i),1,locc,1,8)
C
C  2.4 Here we handle terminal information
C
      ELSE IF  (ITYPE.EQ.3) THEN  !terminal entry
        IF  (IERR.NE.0) THEN
          write(lu,9105) ierr,(ibufx(i),i=2,ilen)
          if (ierr.lt.5) return
        END IF  !
        if (ichcm_ch(lidt,1,'    ').ne.0.and.
     .      ichcm_ch(lidt,1,'--').ne.0) then ! try to match IDs
          I = 1
          DO WHILE (i.le.nstatn.and.ichcm(LIDT,1,LTERID(1,I),1,4).ne.0)
            I=I+1
          END DO
        else
          i=nstatn+1
        endif
        if (i.gt.nstatn) then ! try to match station name
          I = 1
          DO WHILE (i.le.nstatn.and.cname .ne. cstnna(i))
            I=I+1
          END DO
        endif
        IF  (I.GT.NSTATN) THEN  !matching entry not found
          write(lu,'("STINP24 - Name or ID match not found.",a)') cname
          goto 900
        END IF  !matching entry not found
C  Got a match. Initialize names.
!        IDUMMY = ICHMV(LTERNA(1,I),1,LNAME,1,8)
        cterna(i)=cname
C       It used to be that the recorder type was encoded in the DAT name.
C       ks2 = ichcm_ch(lterna(1,i),1,'S2').eq.0
C       kk4 = ichcm_ch(lterna(1,i),1,'K4').eq.0
!        idummy = ichmv_ch(lstrack(1,i),1,'unknown ')
!        idummy = ichmv_ch(lstrec(1,i),1,'unknown ')
!        idummy = ichmv_ch(lstrec2(1,i),1,'none    ')
!        idummy = ichmv_ch(ls2speed(1,i),1,'    ')
        cstrack(i)="unknown"
        cstrec(i)="unknown"
        cstrec2(i)="none"
        cs2speed(i)=" "


C  Store equipment names.
        if (crack .ne. " ") then
          cstrack(i)=crack
        endif
        if (crec1 .ne. " ") then
           cstrec(i)=crec1
        endif
C       If second recorder is specified and the first recorder was S2
C       then save the second recorder field as the S2 mode.
        if (crec2 .ne. " ") then
          if (crec1 .eq. 'S2')then
            idummy = ichmv(ls2mode(1,i,1),1,lrec2,1,16) ! S2 mode, code 1
          else 
            cstrec2(i)=crec2
          endif
        endif
        idummy = ichmv_ch(lfirstrec(i),1,'1 ') ! starting recorder default
C       Now set the S2 and K4 switches depending on the recorder type.
        ks2=cstrec(i).eq."S2"
        kk4=cstrec(i).eq."K4"
C    Store other info depending on the type.
        nrecst(i) = nr
        if (ks2) then ! set S2 variables
!          idummy = ichmv(ls2speed(1,i),1,ls2sp,1,4)
          cs2speed(i)=cs2sp
          if(cs2sp.eq.   "LP") s2sp=SPEED_LP
          if(cs2sp .eq. "SLP") s2sp=SPEED_SLP
          nheadstack(i)=1
          ibitden_save(i)=1
          maxtap(i)=maxt*5.0*s2sp ! convert from minutes to feet
        else if (kk4) then ! set K4 variables
          nheadstack(i)=1
          maxtap(i) = maxt ! conversion??
          ibitden_save(i)=1
        else ! set Mk34 variables
          maxtap(i) = maxt
          ibitden_save(i)=ibitden
          nheadstack(i)=nstack
        endif
        do ib=1,2
          idum = igtba(lb(ib),ii)
          if (ii.ne.0) then ! got frequencies selected already
            sefdst(ii,i) = sefd(ib)
            if (npar(ii).gt.0) then
              do j=1,npar(ii)
                sefdpar(j,ii,i) = par(j,ii)
              enddo
            endif
            nsefdpar(ii,i) = npar(ii)
            lbsefd(ib,i) = lb(ib)
          else ! store away until frequencies are selected
            sefdst(ib,i) = sefd(ib)
            if (npar(ib).gt.0) then
              do j=1,npar(ib)
                sefdpar(j,ib,i) = par(j,ib)
              enddo
            endif
            nsefdpar(ib,i) = npar(ib)
            lbsefd(ib,i) = lb(ib)
          end if
        enddo
C
C 2.5 Here we handle the horizon mask
C
      ELSE IF (ITYPE.EQ.5) THEN  !horizon mask
        kline=.true.
        IF (IERR.NE.0) THEN
          if (ierr.lt.-200) then
            write(lu,*) "STINP252 - Horizon mask azimuths are out "//
     >      "of order. Error in field ", -(ierr+200)
            write(lu,'(80a2)') (ibufx(i),i=2,ilen) 
            RETURN
          endif
          if (ierr.eq.-99)then
            write(lu,'("STINP250 - Too many horizon mask az/el pairs. ",
     .      "Max is ",i5)') max_hor 
            write(lu,'(80a2)') (ibufx(i),i=2,ilen) 
            RETURN
          endif
          if (ierr.eq.-103) then
C           write(lu,'("STINP251 - No matching el for last azimuth,",
C    .      " wraparound value used.")')
C           write(lu,'(80a2)') (ibufx(i),i=2,ilen) 
            elh(nhz)=elh(1)
            kline=.false.
          endif
        END IF   !
        I =1
        DO WHILE (LID.NE.LHCCOD(I).AND.I.LE.NSTATN)
          I=I+1
        END DO
        if (i.gt.nstatn) then !check position codes too
          write(lu,*) "STINP251 - Horizon mask pointer not found. "//
     >      "Checking position code."
          write(lu,'(40a2)')  (ibufx(i),i=2,min(ilen,40))
          I =1
          DO WHILE (LID.NE.LPOCOD(I).AND.I.LE.NSTATN)
            I=I+1
          END DO
        endif
        IF (I.GT.NSTATN) THEN  !matching entry not found
          write(lu,'("STINP25 - Pointer not found.  Horizon mask ")')
          goto 900
        ELSE  ! keep it
          if (kline) then
            klineseg(i)=.true.
C           write(lu,'("STINP255 - Line segment horizon mask being ",
C    .      "used for ",4a2)') (lstnna(j,i),j=1,4)
          else
            klineseg(i)=.false.
C           write(lu,'("STINP255 - Step function horizon mask being ",
C    .      "used for ",4a2)') (lstnna(j,i),j=1,4)
          endif
          NHORZ(I) = NHZ
          DO J=1,NHORZ(I)
            AZHORZ(J,I) = AZH(J)*deg2rad
            ELHORZ(J,I) = ELH(J)*deg2rad
          END DO
        END IF
C     END IF   ! horizon mask
C
C 2.6 Here we handle the coordinate mask
C
      ELSE IF (ITYPE.EQ.4) THEN ! coordinate mask
        IF (IERR.NE.0) THEN
          if (ierr.eq.-99) then
            write(lu,*)
     >      "STINP260 - Too many coordinate mask pairs. Max is ",max_cor
            goto 900
          endif
          if (ierr.eq.-103) then
C           error for no matching value, which is ok
          endif
        END IF  !
        I = 1
        DO WHILE (LID.NE.LhcCOD(I).AND.I.LE.NSTATN)
          I = I+1
        END DO
        IF (I.GT.NSTATN) THEN ! matching entry not found
          write(lu,'("STINP26 - Pointer not found.  Coordinate mask ")')
          goto 900
        ELSE ! keep it
          NCORD(I) = NCO
          DO J=1,NCORD(I)
            CO1MASK(J,I) = CO1(J)*deg2rad
            CO2MASK(J,I) = CO2(J)*deg2rad
          END DO
        END IF
      END IF
      RETURN
C! come here on bad line.
900   continue
      write(lu,'("Ignoring: ",40a2)') (ibufx(i),i=2,min(ilen,40))
      RETURN

      END
