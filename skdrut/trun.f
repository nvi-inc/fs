      REAL FUNCTION TRUN(IFEET,spd,ISPM,ISPS)
C
C     TRUN computes the time required to run the tape at record speed
C     IFEET is the number of feet to move
C     TRUN returns the number of seconds
C
      include '../skdrincl/skparm.ftni'
C
      real spd
      integer ifeet,ispm,isps
          TRUN = (FLOAT(IFEET))/spd 
      IF (IFEET.LE.0) TSPIN=0
              ISPM = IFIX(TRUN/60.0)
              ISPS = IFIX(TRUN-ISPM*60)
C
      RETURN
      END
