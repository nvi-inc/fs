      integer function get_buf( iclass, buffer, length, rtn1, rtn2)
      implicit none
      integer*4 iclass
      integer buffer(1), length, rtn1, rtn2
c
      integer fc_cls_rcv, nchars
c
      nchars=-length
      if(length.gt.0) nchars=length*2
      get_buf=fc_cls_rcv( iclass, buffer, nchars, rtn1, rtn2)
c
      if(length.gt.0.and.get_buf.gt.0) get_buf=(get_buf+1)/2
c
      return
      end
