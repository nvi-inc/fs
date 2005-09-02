      subroutine put_esc_in_string(ldum)
! Very simple routine to put an escape if it see a naked "@"
! passed
      character*(*) ldum
! function
      integer trimlen
! local
      character*1024 ltemp
      integer i,ind,iptr
      character*1 lslash

      lslash=char(92)          !\


      ind=index(ldum,"@")
      if(ind .eq. 0) return

      nch=trimlen(ldum)
      if(nch .gt. 1023) then
        write(*,*)"Not enough space!!!"
      endif

      ltemp=ldum

      iptr=ind-1
      do i=ind,nch
        if(ldum(i:i) .eq. "@") then
          if(i .eq. 1 .or. ldum(i-1:i-1) .ne. lslash) then  !insert escape if nessecary
             if(ltemp(iptr:iptr) .ne. lslash) then
               iptr=iptr+1
               ltemp(iptr:iptr)=lslash
             endif
          endif
       endif
       iptr=iptr+1
       ltemp(iptr:iptr)=ldum(i:i)
      end do
      if(iptr .gt. len(ldum)) then
         writE(*,*) "Put_esc_in_string: Not enough space!"
      endif
      ldum=ltemp(1:iptr)
      return
      end
