      program incom
      implicit none
c
      include '../include/fscom.i'
c
      call setup_fscom
      call sincom
      call write_fscom
c
      end
