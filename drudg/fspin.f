      REAL FUNCTION FSPIN(IFEET,ISPM,SPS)
C
C     FSPIN computes the time required to spin the tape at 330 ips=27.5 fps
C     IFEET is the number of feet to move
C     FSPIN returns the number of seconds at super-fast speed.
C 021017 nrv New. Copied from TSPIN which uses 270 ips.
C
      include '../skdrincl/skparm.ftni'
C
      integer ifeet,ispm
      real sps
          FSPIN = (FLOAT(IFEET)-160.0)/27.5 + 10.0
      IF (IFEET.LE.0) FSPIN=0
              ISPM = IFIX(FSPIN/60.0)
              SPS = FSPIN-ISPM*60.0
C
      RETURN
      END
