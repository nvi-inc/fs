C@INITF

       subroutine initf(rlu,err)
c
c      Initialize the file pointer to one.  Called after OPEN and
c      REWIND
c
c      89006  PMR
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

       integer rlu,err

       if (err.eq.0) ifptr(rlu) = 1

       return
       end

