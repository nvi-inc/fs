      subroutine drchmod(cname,ierr)
      implicit none 
! 2013Jan15 JMGipson. Rewritten and modified.
! 2015Mar30 JMG. Got rid of obsolete argument iperm. 
C Input
      character*128 cname   
C Output
      integer ierr    
! Function
      integer system 
C Local
      integer trimlen
      integer nch 

      nch=trimlen(cname)
      ierr= system("chmod 666 "//cname(1:nch)//char(0))
      return

      end
