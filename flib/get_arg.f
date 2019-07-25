      subroutine get_arg(n,buff)
      implicit none
      character*(*) buff
      integer n
c
      integer i
c
      call fc_skd_arg(n,buff)
      do i=1,len(buff)
         if(buff(i:i).eq.char(0)) then
            buff(i:)=' '
            return
         endif
      enddo
c
      return
      end
