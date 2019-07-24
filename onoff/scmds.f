      subroutine scmds(imess,ic)
      integer*2 imess(1)
      integer ic
c
      integer*4 ip(5)
C
      call clear_prog('onoff')
      call copin(imess,-ic)
      call wait_prog('onoff',ip)
      return
      end
