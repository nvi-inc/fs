      subroutine send_break(name)
      implicit none
      character*(*) name
c
      call fc_brk_snd(name)
c
      return
      end
