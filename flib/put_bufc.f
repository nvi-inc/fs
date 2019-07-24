      subroutine put_bufc( iclass, buffer, length, parm3, parm4)
      implicit none
      integer*4 iclass
      integer length, parm3, parm4
      character*(*) buffer
c
      integer nchars
c
      nchars=-length
      if(length.gt.0) nchars=length*2
      call fc_cls_sndc( iclass, buffer, nchars, parm3, parm4)
c
      return
      end
