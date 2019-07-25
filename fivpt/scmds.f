      subroutine scmds(cmess,ic)
      character*(*) cmess
      integer ic
c
      integer*2 imess(128)
      integer*4 ip(5)
      integer ix
C
      call clear_prog('fivpt')
      if(len(cmess).gt.256) stop 999
      call char2hol(cmess,imess,1,len(cmess))
      ix=sign(len(cmess),ic)
      call copin(imess,ix)
      call wait_prog('fivpt',ip)
c
      return
      end
