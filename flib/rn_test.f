      logical function rn_test(name)
      implicit none
      character*(*) name
c
c  rn_test: resource name test (test lock semaphore for name)
c
c  input: name (first 5 character significant)
c
c  output: (return value) .true. if locked, .false. otherwise
c
      integer fc_nsem_test
c
      rn_test=fc_nsem_test(name).ne.0
      return
      end
