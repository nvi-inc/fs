      subroutine drchmod(cname,iperm,ierr)
! 2013Jan15 JMGipson. Rewritten and modified.
! Does not use iperm at all!
C Input
      character*128 cname 
      integer iperm
C Output
      integer ierr    
C Local
      integer trimlen
      integer nch 

      nch=trimlen(cname)
      ierr= system("chmod 666 "//cname(1:nch)//char(0))
      return

      end
