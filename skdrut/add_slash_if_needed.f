      subroutine add_slash_if_needed(lstring)  
      implicit none 
! Make sure last character is a slash. If not, make it one.
! passed & returned string
      character*(*) lstring
! function
      integer trimlen
! local variables.
      integer nch
      integer ilen

      ilen=len(lstring)

      nch=trimlen(lstring)

      if(nch .gt. 0) then
        if(lstring(nch:nch) .ne. "/") then
          if(nch .lt. ilen) then
             nch=nch+1
          else
             write(*,*)
     >      "WARNGIN: add_slash_if_needed: Not enough space to add '/'"
             write(*,*) "Replacing last character!"
          endif
          lstring(nch:nch)="/"
        endif
      endif
      return
      end






