      logical function kget_response(lu,lstring)
! History:
! xxxx   First version
! 10Nov05 JMGipson. Added "Implicit None".
!          changed size of lyt_list. was Char*4
!
! Write out the string, and wait for response.
      implicit none
      character*(*) lstring
      integer lu
! functions
      integer trimlen
      integer iStringMinMatch


! local
      character*10 lresponse    !holds user response
      integer icmd

      integer iyt_list_len
      parameter (iyt_list_len=6)
      character*5 lyt_list(iyt_list_len)
      data lyt_list/"TRUE","YES","ON","FALSE","NO","OFF"/

      do while(.true.)
        write(lu,'(a,1x)') lstring(1:trimlen(lstring))
        read(*,*) lresponse
        call capitalize(lresponse)
        icmd=istringMinMatch(lyt_list,iyt_list_len,lresponse)
        if(icmd .eq. 0) then
           write(*,*) "Invalid response. Try again."
        else if(icmd .le. 3) then
          kget_response=.true.
          return
        else
          kget_response=.false.
          return
        endif
      end do
      end
