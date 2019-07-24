      subroutine put_buf( iclass, buffer, length, parm3, parm4)
      implicit none
      integer*4 iclass
      integer buffer(1), length, parm3, parm4
c
      integer nchars
c
      nchars=-length
      if(length.gt.0) nchars=length*2
      call fc_cls_snd( iclass, buffer, nchars, parm3, parm4)
c
      return
      end
