      subroutine drudg_write(lufile,ldum)
! Routine that:  a.) Removes spaces; b.) converts everthing to lowercase; c.) writes out results. 
      implicit none
! passed
      integer lufile
      character*(*) ldum
! History
! 2015Jun05. JMG. Basically same as "squeezewrite" routine with addtion of 'call lowercase'
! 
! local
      integer ilast_non_blank  !last non-blank
      call lowercase(ldum) 
      call squeezeleft(ldum,ilast_non_blank)
 
      write(lufile,'(a)') ldum(1:ilast_non_blank)
      return
      end
