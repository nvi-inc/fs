C@FORWARD

       subroutine forward(rlu,err)

       implicit none
       integer     rlu
c         rlu - unit for reading
       integer     err
c  
c  Move the actual file pointer forward one record
c
c  89006  PMR
c
       integer ifptr
       common /position/ ifptr(256)

       character*256 dev_null

       read(rlu,'(A)',iostat=err) dev_null
       if (err.eq.0) ifptr(rlu) = ifptr(rlu) + 1

       return
       end

