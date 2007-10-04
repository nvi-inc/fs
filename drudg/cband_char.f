      character*1 function cband_char(vcband)
! return the bandwidth code.
! passed
      implicit none
      real vcband    !video bandwidth

      real bandw(8)
      character*1 cband(8)
      integer i
! Return a character
      DATA BANDW/16.0,8.0,4.0,2.0,1.0,0.5,0.25,0.125/
      data cband/'D','8','4', '2','1','H','Q', 'E'/

      do i=1,8
       if(abs(bandw(i)-vcband) .le. 0.01) then
         cband_char=cband(i)
         return
       endif
      end do
      write(*,*) "ERROR: cband_char: Invalid band!"
      cband_char="?"
      return
      end

