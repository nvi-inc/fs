      subroutine spdstr(spd,lspd,nspd)

C SPDSTR returns a Hollerith "lspd" with the appropriate speed for
C the value of "spd". "nspd" is the number of characters in lspd.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960116 nrv New.
C 960815 nrv Add 80, 160 speeds.
C 960923 nrv Add 320 ips
C 961121 nrv Add 66.66 speed
C 970103 nrv Add 40 speed
C 970118 nrv Add the rest of the valid speeds.

C INPUT:
      real*4 spd ! speed in inches per second, e.g. 133.33

C OUTPUT:
      integer*2 lspd(4) ! speed for the ST= command
      integer nspd ! number of characters in lspd, -1 if no match

C Local
      integer i,maxspd
      real*4 sp(23)
      character*8 csp(23)
      integer ichmv_ch

C INITIALIZED:
C     Organized according to types:
C       Both   VLBA    Mk3/4
C        thin  thick   thick
C         2.5   4.44    3.375
C         5     8.88    7.785
C        10    16.66   16.875
C        20    33.33   33.375
C        40    66.66   67.5
C        80   133.33  135
C       160   266.66  270
C       320    
      data maxspd/23/
      data sp/0.0,2.5,3.375,4.44,
     .        5.0,7.785,8.88,
     .       10.0,16.66,16.875,
     .       20.0,33.33,33.75,
     .       40.0,66.66,67.5,
     .       80.0,133.33,135.0,
     .      160.0,266.66,270.0,320.0/
      data csp/'0','2.5','4.21875','4.44',
     .             '5','8.4375','8.88',
     .             '10','16.66','16.875',
     .             '20','33.33','33.75',
     .             '40','66.66','67.5',
     .             '80','133.33','135',
     .            '160','266.66','270','320'/

      i=1
      do while (i.le.maxspd.and.
     .   .not.(spd+.05.gt.sp(i).and.spd-.05.le.sp(i)))
        i=i+1
      enddo
      if (i.le.maxspd) then ! match
        call ifill(lspd,1,8,oblank)
        nspd = ichmv_ch(lspd,1,csp(i))-1
      else ! error
        nspd=-1
      endif
     
      return
      end
