      subroutine rn_put(name)
      implicit none
      character*(*) name
c
c  rn_put: resource name put (release semaphore for name)
c
c  input: name (first 5 character significant)
c
c  output: none, return indicates that is semaphore released
c           errors terminate
c
      call fc_nsem_put(name)
c
      return
      end
