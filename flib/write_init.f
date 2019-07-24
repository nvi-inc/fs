      subroutine write_init
      implicit none
      include '../include/params.i'
      include '../include/fscom_init.i'
c 
c  write fscom_init
c
      call fc_shm_write(b_init)
c
      return
      end
