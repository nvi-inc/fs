      subroutine drchmod(cname,ierr)
      implicit none 
! 2013Jan15 JMGipson. Rewritten and modified.
! 2015Mar30 JMG. Got rid of obsolete argument iperm. 
! 2019Aug21 JMG.  "666-->664" because of NASA IT requirements. Do not want world-writable
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
      ierr= system("chmod 664 "//cname(1:nch)//char(0))
      return

      end
