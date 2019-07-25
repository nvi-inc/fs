      subroutine suspend(name)
      implicit none
      character*(*) name
c
c  suspend: suspend on GO semaphore for name (take GO semaphore for name)
c           waiting for a go_suspend
c
c  input: name (first 5 character significant)
c
c  output: (return value) =0 successful lock
c                         =1 already locked
c           errors terminate
c
      call fc_go_take(name,0)
      return
      end






