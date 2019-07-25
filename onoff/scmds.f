      subroutine scmds(cmess,ic)
      character*(*) cmess
      integer ic
c
      integer*2 imess(128)
c      integer*4 ip(5)
      integer ix
C
c      call clear_prog('onoff')
      if(len(cmess).gt.256) stop 999
      call char2hol(cmess,imess,1,len(cmess))
      ix=sign(len(cmess),-ic)
      call copin(imess,ix)
c      call wait_prog('onoff',ip)
      call suspend('onoff')
c
      return
      end
