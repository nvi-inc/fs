      subroutine put_buf( iclass, buffer, length, parm3, parm4)
      implicit none
      integer*4 iclass
      integer buffer(1), length
      character*(*) parm3, parm4
      integer iparm3,iparm4
c
      integer nchars
c
      nchars=-length
      if(length.gt.0) nchars=length*2
      call char2hol(parm3,iparm3,1,2)
      call char2hol(parm4,iparm4,1,2)
      call fc_cls_snd( iclass, buffer, nchars, iparm3, iparm4)
c
      return
      end
