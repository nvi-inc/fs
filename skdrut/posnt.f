C@POSNT

       subroutine posnt (rlu,err,move)
c
c      Position the file pointer at relative offset MOVE.
c
c      89006   PMR
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

       integer rlu,err,move

       integer i

       err = 0 ! was -1

       if ((move .lt. 0) .and. (ifptr(rlu) .gt. 1)) then
         do i=1,abs(move)
           call backward(rlu,err)
         end do
       else if (move .gt. 0) then
         do i=1,move
           call forward(rlu,err)
         end do
       end if

       return
       end

