      SUBROUTINE unpva(IBUF,ILEN,IERR,LIDANT,LNAANT,LAXIS,
     .AXISOF,SLRATE,ANLIM1,ANLIM2,DIAMAN,LIDPOS,IDTER,lidhor,
     .ISLCON,ipcount)
C
C     UNPVA unpacks a record containing antenna information.
C
      include 'skparm.ftni'
C
C  History:
C  NRV 891215 Removed call to catalog info unpacking routine,
C             added horizon mask ID
C  NRV 900301 Allow terminal ID to be numeric or hollerith
C  nrv 930225 implicit none
C  nrv 940719 Allow numerals as station IDs
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,ipcount
C           - buffer containing the record
C     ILEN  - length of IBUF in words
C     ipcount - number of parameters
C        5 gets name and ID only
C        16 (or anything >5) gets all values
C
C  OUTPUT:
      integer ierr,idter
      integer*2 lidhor
C     IERR    - error return, 0=ok, -100-n=error in nth field
C     LIDANT - antenna ID, 1 character in upper byte, lower byte is blank
      integer*2 LNAANT(4),lidant,lidpos
C            - name of the antenna
      integer*2 LAXIS(2)
      integer islcon(2)
C            - type of axis
      real*8 AXISOF
C            - axis offset, meters
      real*4 SLRATE(2),ANLIM1(2),ANLIM2(2),diaman
C            - antenna slew rates for axis 1 and 2, degrees/minute
C            - antenna upper,lower limits for axis 1, degrees
C            - antenna upper,lower limits for axis 2, degrees
C     DIAMAN - diameter of antenna, in m
C     LIDPOS  - 2-char ID of the position information
C     IDTER  - 2-char ID of the Mark III terminal information
C     lidhor  - 2-char ID of the horizon mask entry
C
C  LOCAL:
      real*8 DAS2B,R
      integer*2 ldum(2)
      integer ich,nch,ic1,ic2,idumy,iax,i,id
      integer jchar,ichmv,ias2b ! function
C
C
C  1. Start the unpacking with the first character of the buffer.
C
      ICH = 1
C
C     The antenna ID.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  ((NCH.NE.1).OR.
     .   ((JCHAR(IBUF,IC1).LT.OCAPA.OR.JCHAR(IBUF,IC1).GT.OCAPZ)
     ..and.(jchar(ibuf,ic1).lt.OSMALLA.or.jchar(ibuf,ic1).gt.OSMALLZ)
     ..and.(JCHAR(IBUF,IC1).LT.Oone .OR.JCHAR(IBUF,IC1).GT.Onine)))
     .  THEN 
        IERR = -101
        RETURN
      END IF
      call char2hol ('  ',LIDANT,1,2)
      IDUMY = ICHMV(LIDANT,1,IBUF,IC1,1)
C
C     Antenna name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8.or.NCH.le.0) THEN  !
        IERR = -102
        RETURN
      END IF  !
      CALL IFILL(LNAANT,1,8,oblank)
      IDUMY = ICHMV(LNAANT,1,IBUF,IC1,NCH)
C
      if (ipcount.le.5) return
C
C     Axis type, 4 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF (NCH.GT.4) then
        IERR = -103
        RETURN
      END IF  !
      CALL IFILL(LDUM,1,4,oblank)
      idumy = ichmv(ldum,1,ibuf,ic1,nch)
      call axtyp(ldum,iax,1)
      if (iax.eq.0) then
        ierr=-103
        return
      endif
      CALL IFILL(LAXIS,1,4,oblank)
      IDUMY = ICHMV(LAXIS,1,IBUF,IC1,NCH)
C
C    Axis offset, two slew rates, axis-1 limits, axis-2 limits, and
C     size are
C
      DO  I=4,13 !a passel of real numbers
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        R = DAS2B(IBUF,IC1,IC2-IC1+1,IERR)
        IF  (IERR.LT.0) THEN
          IERR = -100-I
          RETURN
        END IF
        IF (I.EQ.4) THEN
          AXISOF = R
        ELSE IF (I.EQ.5) THEN
          SLRATE(1) = R
        ELSE IF (I.EQ.6) THEN
          ISLCON(1) = R
        ELSE IF (I.EQ.7) THEN
          ANLIM1(1) = R
        ELSE IF (I.EQ.8) THEN
          ANLIM1(2) = R
        ELSE IF (I.EQ.9) THEN
          SLRATE(2) = R
        ELSE IF (I.EQ.10) THEN
          ISLCON(2) = R
        ELSE IF (I.EQ.11) THEN
          ANLIM2(1) = R
        ELSE IF (I.EQ.12) THEN
          ANLIM2(2) = R
        ELSE IF (I.EQ.13) THEN
          DIAMAN = R
        END IF
      END DO  !"a passel of real numbers
C
C     The position ID.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF (NCH.NE.2) THEN
        IERR = -114
        RETURN
      END IF
      call char2hol ('  ',LIDPOS,1,2)
      IDUMY = ICHMV(LIDPOS,1,IBUF,IC1,2)
C
C     The Mark III ID, OK if it's not a number.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      id=-1
      if (nch.gt.0) id = ias2b(ibuf,ic1,nch)
      IF (id.lt.0) THEN
        idumy = ichmv(idter,1,ibuf,ic1,min0(nch,2))
      else
        idter = id
      END IF
C
C     The horizon ID (optional, blank if not there). 
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      call char2hol ('  ',LIDHOR,1,2)
      NCH = IC2-IC1+1
      IF (NCH.EQ.2) IDUMY = ICHMV(LIDHOR,1,IBUF,IC1,2)
C
      RETURN
      END
