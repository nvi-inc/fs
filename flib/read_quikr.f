      subroutine read_quikr
      implicit none
      include '../include/params.i'
      include '../include/fscom_quik.i'
c 
c  read fscom_quikr
c
      call fc_shm_read(b_quikr)
c
      return
      end
