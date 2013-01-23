C@INC

       subroutine inc(rlu,err)
c
c      Increment the file pointer by one.
c
c      89006  PMR
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

       integer rlu,err

       if (err.eq.0) ifptr(rlu) = ifptr(rlu) + 1

       return
       end

