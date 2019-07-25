      SUBROUTINE M3INF(ICODE,SPEEX,IVCIND)  !MARK III INFO C#870115:16:10#
C M3INF, given a code index, returns the NOMINAL tape speed
C in ips and the corresponding index.
C
C COMMON BLOCKS:
      INCLUDE 'skparm.ftni'
      INCLUDE 'freqs.ftni'
C INPUT:
      integer icode
C   ICODE - code index in common
C OUTPUT:
      real*4 speex
      integer ivcind
C   SPEEX - nominal tape speed, in ips
C   IVCIND - index for bandwidth and speed, 1 to 6

C Local
      integer i
      real*4 BANDW(6)
      real*4 TAPIPS(6)

C INITIALIZED:
      DATA BANDW/4.0,2.0,1.0,0.5,0.25,0.125/
C Bandwidths in MHz
      DATA TAPIPS/240.0,120.0,60.0,30.0,15.0,7.5/
C Tape speed in inches-per-second
C
C MODIFICATIONS:
C 880411 NRV DE-COMPC'D
C 930407 nrv implicit none
C
      DO I=1,ncodes
        IF (VCBAND(ICODE)+0.0005.GT.BANDW(I).and.
     .      vcband(icode)-0.0005.lt.bandw(i)) GOTO 200
      ENDDO
      I=2
C
C If unknown, use default
200   SPEEX = TAPIPS(I)
      IVCIND = I
C
32767 RETURN
      END
