      SUBROUTINE M3INF(ICODE,SPEEX,IVCIND)  

C M3INF, given a code index, returns the NOMINAL tape speed
C in ips and the corresponding index into LBNAME (band name
C array), based on the VC bandwidth.  DO NOT USE THE
C SPEED RETURNED FROM THIS ROUTINE. USE "SPEED" INSTEAD.
C
C COMMON BLOCKS:
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
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
      real*4 BANDW(8)
      real*4 TAPIPS(8)

C INITIALIZED:
      DATA BANDW/16.0,8.0,4.0,2.0,1.0,0.5,0.25,0.125/
C Bandwidths in MHz
      DATA TAPIPS/240.0,240.0,240.0,120.0,60.0,30.0,15.0,7.5/
C Tape speed in inches-per-second. Note the speeds for 16 and 8 MHz
C bandwidths are also 240. Speeds for these modes are not simply
C related to the bandwidth because of fan-out. 
C
C MODIFICATIONS:
C 880411 NRV DE-COMPC'D
C 930407 nrv implicit none
C 951212 nrv Force VCBAND to use chan 1, station 1 for now.
C 951218 nrv Add 16 and 8 MHz, but note that the speed is no longer
C            valid for these bandwidths.
C
      DO I=1,8
        IF (VCBAND(1,1,ICODE)+0.0005.GT.BANDW(I).and.
     .      vcband(1,1,icode)-0.0005.lt.bandw(i)) GOTO 200
      ENDDO
C If unknown, use default
      I=4
C
200   SPEEX = TAPIPS(I)
      IVCIND = I
C
32767 RETURN
      END
