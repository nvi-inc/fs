      subroutine spdstr(spd,lspd,nspd)

C SPDSTR returns a Hollerith "lspd" with the appropriate speed for
C the value of "spd". "nspd" is the number of characters in lspd.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960116 nrv New.

C INPUT:
      real*4 spd ! speed in inches per second, e.g. 133.33

C OUTPUT:
      integer*2 lspd(4) ! speed for the ST= command
      integer nspd ! number of characters in lspd, -1 if no match

C Local
      integer i,maxspd
      real*4 sp(10)
      character*8 csp(10)
      integer ichmv_ch

C INITIALIZED:
      data maxspd/10/
      data sp/0,3.375,7.785,16.875,33.75,67.5,133.33,135.0,
     .        266.66,270.0/
      data csp/'0','3.375','7.785','16.875','33.75','67.5',
     .        '133.33','135','266.66','270'/

      i=1
      do while (i.le.maxspd.and.
     .   .not.(spd+.005.gt.sp(i).and.spd-.005.le.sp(i)))
        i=i+1
      enddo
      if (i.le.maxspd) then ! match
        nspd = ichmv_ch(lspd,1,csp(i))-1
      else ! error
        nspd=-1
      endif
     
      return
      end
