      subroutine strip_path(lfullpath,lfilnam)
! strip off the path, return the filename.
      implicit none
! fucntions
      integer trimlen
! passed
      character*(*) lfullpath           !passed
      character*(*) lfilnam             !filename
! local
      integer ilen
      integer i
      integer ilast_non_blank
      integer islash

      ilen=len(lfullpath)

      ilast_non_blank=trimlen(lfullpath)
      if(ilast_non_blank .eq. 0) then
        lfilnam=" "
        return
      endif

      islash=0
      do i=ilast_non_blank,1,-1
        if(lfullpath(i:i) .eq. "/") then
           islash=i
           goto 10
        endif
      end do

10    continue
      if(ilast_non_blank-islash .gt. ilen) then
         lfilnam=lfullpath(islash+1:islash+ilen)
      else
         lfilnam=" "
         lfilnam=lfullpath(islash+1:ilast_non_blank)
      endif
      return
      end
