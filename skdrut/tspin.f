      REAL FUNCTION TSPIN(IFEET,ISPM,SPS)
C
C     TSPIN computes the time required to spin the tape at 270 ips=22.5 fps
C     IFEET is the number of feet to move
C     TSPIN returns the number of seconds
C 021014 nrv Change seconds argument to real.
C
      include '../skdrincl/skparm.ftni'
C
      integer ifeet,ispm
      real sps
          TSPIN = (FLOAT(IFEET)-160.0)/22.5 + 10.0
      IF (IFEET.LE.0) TSPIN=0
              ISPM = IFIX(TSPIN/60.0)
              SPS = TSPIN-ISPM*60.0
C
      RETURN
      END
