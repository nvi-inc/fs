      subroutine write_quikr
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
c 
c  write fscom_quikr
c
      call fc_shm_write(b_quikr)
c
      return
      end
