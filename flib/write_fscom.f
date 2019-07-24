      subroutine write_fscom
      implicit none
      include '../include/params.i'
c 
c  write all of fscom, except 'rt', which is handled separately
c
      call write_init
      call write_quikr
c
      return
      end
