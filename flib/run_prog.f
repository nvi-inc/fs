      subroutine run_prog(name,wait,ip1,ip2,ip3,ip4,ip5)
      implicit none
      character*(*) name,wait
      integer*4 ip1,ip2,ip3,ip4,ip5
c
      integer*4 ip(5)
c
      ip(1)=ip1
      ip(2)=ip2
      ip(3)=ip3
      ip(4)=ip4
      ip(5)=ip5
      call fc_skd_run(name,wait,ip)
c
      return
      end
