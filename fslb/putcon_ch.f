      subroutine putcon_ch(string)

      include '../include/fscom.i'

      character*(*) string
 
      integer nchar

      nchar = len(string)

      call fs_get_iclbox(iclbox)
      call put_buf_ch(iclbox,string,'fs','to')

      return
      end
