      subroutine put_cons(ibuf,nchar)

      include '../include/fscom.i'

      integer*2 ibuf(1)
      integer nchar

      call fs_get_iclbox(iclbox)
      call put_buf(iclbox,ibuf,-nchar,'fs','to')

      return
      end
