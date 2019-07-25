      subroutine put_buf_ch( iclass, buffer, parm3, parm4)
      implicit none
      integer*4 iclass
      integer iparm3, iparm4
      character*(*) buffer, parm3,parm4
c
      integer nchars
c
      nchars=len(buffer)
      call char2hol(parm3,iparm3,1,2)
      call char2hol(parm4,iparm4,1,2)
      call fc_cls_sndc( iclass, buffer, nchars, iparm3, iparm4)
c
      return
      end
