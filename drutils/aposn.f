C@APOSN

       subroutine aposn(rlu,err,irec_no,irb,ioff)
c
c      Position the file pointer at record IREC_NO.  IRB and
c      IOFF are ignored.
c
c      89006  PMR
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

       integer rlu,err,irb,ioff
       integer irec_no

       integer j, next

       next = ifptr(rlu)
       if (irec_no .lt. next) then
           j = 1
           do while ((j.le.(next - irec_no)).and.(err.eq.0))
               j = j + 1
               call backward(rlu,err)
           end do
       else if (irec_no .gt. next) then
           j = 1
           do while((j.le.(irec_no - next)).and.(err.eq.0))
               j = j + 1
               call forward(rlu,err)
           end do
       end if

       return
       end

