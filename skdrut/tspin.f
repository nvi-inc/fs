      REAL*4 FUNCTION TSPIN(IFEET,ISPM,ISPS)
C
C     TSPIN computes the time required to spin the tape at high speed
C     IFEET is the number of feet to move
C     TSPIN returns the number of seconds
C
      INCLUDE 'skparm.ftni'
C
      integer ifeet,ispm,isps
          TSPIN = (FLOAT(IFEET)-160.0)/22.5 + 10.0
      IF (IFEET.LE.0) TSPIN=0
              ISPM = IFIX(TSPIN/60.0)
              ISPS = IFIX(TSPIN-ISPM*60)
C
      RETURN
      END
