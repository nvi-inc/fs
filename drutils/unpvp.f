      SUBROUTINE unpvp(IBUF,ILEN,IERR,LIDPOS,LNAPOS,
     .POSXYZ,LPOSX,LPOSY,LPOSZ,POSLAT,POSLON,LOCCUP)
C
C     UNPVP unpacks a record containing position information.
C
      INCLUDE 'skparm.ftni'
C
C  History
C  NRV 891215 Removed catalog info
C  nrv 930225 implicit none
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer containing the record
C     ILEN  - length of IBUF in words
C
C  OUTPUT:
      integer ierr
      integer*2 lidpos
C     IERR    - error return, 0=ok, -100-n=error in nth field
C     LIDPOS - positon ID, 2 characters
      integer*2 LNAPOS(4)
C            - name of the site position
      real*8 POSXYZ(3)
C            - site coordinates, meters
      integer*2 LOCCUP(4)
C            - occupation code
C     POSLAT - computed latitude, degrees
C     POSLON - computed longitude, degrees
      real*4 poslat,poslon
      integer*2 LPOSX(7),LPOSY(7),LPOSZ(7)
C            - ASCII coordinates, to preserve sigfigs
C
C  LOCAL:
      real*8 DAS2B,R
      integer ich,nch,ic1,ic2,idumy,i,nc,idc,i1
      integer ichmv,iscnc
C
C  INITIALIZED:
      real*8 ERAD,EFLAT
C               - compiled-in values of earth rad and flattening
      DATA ERAD/0.6378145D07/
      DATA EFLAT/0.3352891869D-2/
C
C
C  1. Start the unpacking with the first character of the buffer.
C
      ICH = 1
C
C     The site ID.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.NE.2) THEN
        IERR = -101
        RETURN
      END IF
      call char2hol ('  ',LIDPOS,1,2)
      IDUMY = ICHMV(LIDPOS,1,IBUF,IC1,2)
C
C     Site name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.8) THEN
        IERR = -102
        RETURN
      END IF  !
      CALL IFILL(LNAPOS,1,8,oblank)
      IDUMY = ICHMV(LNAPOS,1,IBUF,IC1,NCH)
C
C     Site position coordinates
C
      DO  I=3,5
C     "coordinates"
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        NC = IC2-IC1+1
        R = DAS2B(IBUF,IC1,NC,IERR)
        IDC = ISCNC(IBUF,IC1,IC2,ODOT)
        IF (IDC.EQ.0) IDC=IC2
        I1 = IC1+9-IDC
        IF  (IERR.LT.0.OR.(IC2-IDC).GT.5.OR.(IDC-IC1).GT.8) THEN
          IERR = -100-I
          RETURN
        END IF  !
        IF  (I.EQ.3) THEN  !"X"
          POSXYZ(1) = R
          CALL IFILL(LPOSX,1,14,oblank)
          IDUMY = ICHMV(LPOSX,I1,IBUF,IC1,NC)
        ELSE IF  (I.EQ.4) THEN  !"Y"
          POSXYZ(2) = R
          CALL IFILL(LPOSY,1,14,oblank)
          IDUMY = ICHMV(LPOSY,I1,IBUF,IC1,NC)
        ELSE IF  (I.EQ.5) THEN  !"Z"
          POSXYZ(3) = R
          CALL IFILL(LPOSZ,1,14,oblank)
          IDUMY = ICHMV(LPOSZ,I1,IBUF,IC1,NC)
        END IF  !"Z"
      END DO  !"coordinates"
C     Now compute derived coordinates
        POSLON = (-DATAN2(POSXYZ(2),POSXYZ(1)))*180.0/PI
        IF (POSLON.LT.0.D0) POSLON=POSLON+360.D0
C                   West longitude = ATAN(y/x)
        POSLAT = (DATAN2(POSXYZ(3)*ERAD**2,
     .    DSQRT((POSXYZ(1)**2+POSXYZ(2)**2)) *
     .    (ERAD**2*(1.D0-EFLAT)**2))) * 180.0/PI
C                   Geocentric latitude = ATAN(z/sqrt(x^2+y^2))
C                   Geodetic latitude includes earth radius and flattening
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH=IC2-IC1+1
      IF  (NCH.NE.8) THEN
        IERR = -106
        RETURN
      END IF  !
      IDUMY = ICHMV(LOCCUP,1,IBUF,IC1,8)
C
      RETURN
      END
