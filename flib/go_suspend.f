      subroutine go_suspend(name)
      implicit none
      character*(*) name
c
c  go_suspend: release name from GO suspend (put semaphore for name)
c
c  input: name (first 5 character significant)
c
c  output: none, return indicates that is semaphore released
c           errors terminate
c
      call fc_go_put(name)
c
      return
      end
