      subroutine GetIauName(ltest,rarad2k,decrad2k)
! get the iau name.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
! input
      real*8 rarad2k,decrad2k
! output
      character*8 ltest
      real*8 ra50,dec50
      real*8 md
      integer ih,im,id,ifd

C Initialized:
C 1. Precess to get the 1950 position.
      call prefr(rarad2k,decrad2k,2000,ra50,dec50)
C 2. Elements of the IAU name.
      ih = ra50*12.d0/pi
      im = ((ra50*12.d0/pi) - ih)*60.d0
      id = dec50*180.d0/pi
      md = ((dec50*180.d0/pi) - id + 0.d0001)*60.d0
      ifd = abs(md)/6.0

C 3. Convert integer to ASCII
      write(ltest,'(2i2.2,1x,i2.2,i1.1)') ih,im,iabs(id),ifd
      if(dec50 .lt. 0) then
         ltest(5:5)="-"
      else
        ltest(5:5)="+"
      endif
      return
      end







