      program incom
      implicit none
c
c rdg 010529 added ip and changed the call to sincom.
c            also added conditional code to errors.
c
      include '../include/fscom.i'
c
      integer*4 ip(5)

      ip(3)=0
      call setup_fscom
      call sincom(ip)
      if(ip(3).ne.0) call fc_exit(-1)
      call write_fscom
c
      end
