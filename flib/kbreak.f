      logical function kbreak(name)
      implicit none
      character*(*) name
c
      integer fc_brk_chk
c
      kbreak=fc_brk_chk(name).ne.0
c
      return
      end
