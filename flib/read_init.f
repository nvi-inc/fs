      subroutine read_init
      implicit none
      include '../include/params.i'
      include '../include/fscom_init.i'
c 
c  read fscom_init
c
      call fc_shm_read(b_init)
c
      return
      end
