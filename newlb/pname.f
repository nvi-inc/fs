       subroutine pname(ibuf)
       integer*2 ibuf(3)
       integer*2 ibuf_cm(3)
       common/pname_com/ibuf_cm(3)
       inext=ichmv(ibuf,1,ibuf_cm,1,5)
       return
       end
       subroutine putpname(cbuf)
       character*(*) cbuf
       integer*2 ibuf_cm(3)
       common/pname_com/ibuf_cm
       call char2hol(cbuf,ibuf_cm,1,5)
       return
       end
