      subroutine drudg_write_comment(lu, lstring)

! Write a comment line. This is text preceded by double quotes. 
! Does not do any processing of comment line except for truncation at last blank.
! 2018Sep05. First version.
 
      implicit none 
      integer lu
      character*(*) lstring
! local
      integer nch
      character*1 lq
! function
      integer trimlen
      lq='"'
   
   
      nch=trimlen(lstring)

      write(lu,'(a,a)') lq,lstring(1:nch)
      return
      end 




