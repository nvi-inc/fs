      subroutine spdstr(spd,lspd,nspd)

C SPDSTR returns a Hollerith "lspd" with the appropriate speed for
C the value of "spd". "nspd" is the number of characters in lspd.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960116 nrv New.
C 960815 nrv Add 80, 160 speeds.
C 960923 nrv Add 320 ips

C INPUT:
      real*4 spd ! speed in inches per second, e.g. 133.33

C OUTPUT:
      integer*2 lspd(4) ! speed for the ST= command
      integer nspd ! number of characters in lspd, -1 if no match

C Local
      integer i,maxspd
      real*4 sp(13)
      character*8 csp(13)
      integer ichmv_ch

C INITIALIZED:
      data maxspd/13/
      data sp/0,3.375,7.785,16.875,33.75,67.5,80.0,133.33,135.0,
     .        160.0,266.66,270.0,320.0/
      data csp/'0','3.375','7.785','16.875','33.75','67.5','80',
     .        '133.33','135','160','266.66','270','320'/

      i=1
      do while (i.le.maxspd.and.
     .   .not.(spd+.05.gt.sp(i).and.spd-.05.le.sp(i)))
        i=i+1
      enddo
      if (i.le.maxspd) then ! match
        nspd = ichmv_ch(lspd,1,csp(i))-1
      else ! error
        nspd=-1
      endif
     
      return
      end
