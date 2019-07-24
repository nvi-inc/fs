      subroutine clear_prog(name)
      implicit none
      character*(*) name
c
      call fc_skd_clr(name)
c
      return
      end
