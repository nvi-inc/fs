      subroutine putcon_ch(string)

      include '../include/fscom.i'

      character*(*) string
 
      integer nchar

      nchar = len(string)

      call fs_get_iclbox(iclbox)
      call put_buf(iclbox,string,-nchar,2Hfs,2Hto)

      return
      end
