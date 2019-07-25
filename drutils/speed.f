      real*4 FUNCTION SPEED(ICODE)
C     SPEED returns the actual tape speed in feet per second
C
      INCLUDE 'skparm.ftni'
C
C  COMMON BLOCKS:
      INCLUDE 'freqs.ftni'
C
C  INPUT:
      integer icode
C     ICODE - code index in common
C
C  OUTPUT:
C     SPEED - tape speed, fps
C
C  LOCAL:
      real BANDW(6)
      integer i
      real TAPIPS(6)
      DATA BANDW/4.0,2.0,1.0,0.5,0.25,0.125/
C                   Bandwidths, in MHz
      DATA TAPIPS/240.0,120.0,60.0,30.0,15.0,7.5/
C                   Tape speed, in inches-per-second
C
C
      DO  I=1,6
        IF (abs(VCBAND(ICODE)-BANDW(I)).lt..001) GOTO 200
      END DO
      I=2
C                   If unknown, use default
C
200   SPEED = TAPIPS(I)*135.0/1440.0
C
      RETURN
      END
