      SUBROUTINE raded(RA,DEC,HA,IRAH,IRAM,RAS,
     .LDSIGN,IDECD,IDECM,DECS,
     .LHSIGN,IHAH,IHAM,HAS)
C
C     RADED converts ra,dec,ha in radians to the hms, dms, hms.
C
      implicit none
C  INPUT:
      real*8 RA,DEC,HA
C     RA, DEC, HA - in radians
C
C  OUTPUT:
      integer irah,iram,idecd,idecm,ihah,iham
      integer ldsign,lhsign
      real*4 ras,decs,has
C     IRAH,IRAM,RAS - hms for ra
C     LDSIGN,IDECD,IDECM,DECS - sign, dms for dec
C     LHSIGN,IHAH,IHAM,HAS - sign, hms for hour angle
C
C  LOCAL:
      real*8 PI,H,D
C
C  CONSTANTS:
      DATA PI/3.1415926535D0/
C
C
C     1. First convert the RA.
C
      H = RA*12.D0/PI
      IRAH = H
      IRAM = (H-IRAH)*60.D0
      RAS = (H-IRAH-IRAM/60.D0)*3600.D0
      IF  (RAS.GE.60.D0) THEN  !
        RAS=RAS-60.D0
        IRAM=IRAM+1
      END IF  !
      IF  (IRAM.GE.60) THEN  !
        IRAM=IRAM-60
        IRAH=IRAH+1
      END IF  !
      IF (IRAH.GE.24) IRAH=IRAH-24
C
C
C     2. Next the declination.
C
      D = DABS(DEC)*180.D0/PI
      IDECD = D
      IDECM = (D - IDECD)*60.D0
      DECS = (D-IDECD-IDECM/60.D0)*3600.D0
      IF  (DECS.GE.60.D0)  THEN  !
        DECS=DECS-60.D0
        IDECM=IDECM+1
      END IF  !
      IF  (IDECM.GE.60) THEN  !
        IDECM=IDECM-60
        IDECD=IDECD+1
      END IF  !
C
      call char2hol ('+ ',LDSIGN,1,2)
      IF (DEC.LT.0.D0) call char2hol('- ',LDSIGN,1,2)
C
C
C     3. Finally the hour angle.
C
      H = DABS(HA)*12.D0/PI
      IHAH = H
      IHAM = (H - IHAH)*60.D0
      HAS = (H - IHAH - IHAM/60.D0)*3600.D0
      call char2hol('  ',LHSIGN,1,2)
      IF  (HAS.GE.60.D0)  THEN  !
        HAS=HAS-60.D0
        IHAM=IHAM+1
      END IF  !
      IF  (IHAM.GE.60)  THEN  !
        IHAM=IHAM-60
        IHAH=IHAH+1
      END IF  !
C
      IF (HA.LT.0.D0) call char2hol('- ',LHSIGN,1,2)
      RETURN
      END
