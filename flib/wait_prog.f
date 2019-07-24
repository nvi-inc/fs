      subroutine wait_prog(name,ip)
      implicit none
      character*(*) name
      integer*4 ip(5)
c
      call fc_skd_wait(name,ip,0)
c
      return
      end
