C@BACKWARD

       subroutine backward(rlu,err)

c
c      Move the actual file pointer back one record.  Error if beginning
c      of file.
c
c      89006  PMR
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

       integer rlu,err

       backspace(rlu,iostat=err)
       if (err.eq.0) ifptr(rlu) = ifptr(rlu) - 1

       return
       end

