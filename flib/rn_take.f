      integer function rn_take(name,flags)
      implicit none
      character*(*) name
      integer flags
c
c  rn_take: resource name take (lock semaphore for name)
c
c  input: name (first 5 character significant)
c         flags =0 block, =1 non-blocking
c
c  output: (return value) =0 successful lock
c                         =1 already locked
c           errors terminate
c
      integer fc_nsem_take
c
      rn_take=fc_nsem_take(name,flags)
      return
      end
