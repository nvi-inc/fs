      REAL FUNCTION TSPIN(IFEET,ISPM,SPS,iTapeSpinDelay)
C
C     TSPIN computes the time required to spin the tape at 270 ips=22.5 fps
C     IFEET is the number of feet to move
C     TSPIN returns the number of seconds
C 021014 nrv Change seconds argument to real.
! 2003Nov12  JMGipson changed calculation. Added iSpinDelay
C
      include '../skdrincl/skparm.ftni'
C
      integer ifeet,ispm
      integer iTapeSpinDelay  !time to startup
      real sps
! Changed this logic.
!      TSPIN = (FLOAT(IFEET)-160.0)/22.5 + 10.0
      Tspin=float(ifeet)/22.5+iTapeSpinDelay
      IF (IFEET.LE.0) TSPIN=0
      ISPM = IFIX(TSPIN/60.0)
      SPS = TSPIN-ISPM*60.0
C
      RETURN
      END
