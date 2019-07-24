      subroutine setup_fscom
      implicit none
      include '../include/fscom.i'
c 
c  attach to shared memory and setup the mapping to fscom
c
      call fc_setup_ids
      call fc_shm_map(b_init,e_init,b_quikr,e_quikr)
c
      return
      end
