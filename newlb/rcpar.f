      subroutine rcpar(n,arg)
      implicit none
      integer n
      character*(*) arg
c
c  rcpar: run-string parameters returned in character variable
c
c  returns the n-th argument in arg,
c  if n < 0 undefined
c     n = 0 program name
c  arg is set to blank if n exceeds the actual number of supplied
c     arguments OR the argument is blank or empty
c
      integer iargc
c
      if(n.lt.0) return
c
      if(n.gt.iargc()) then
        arg=' '
      else
        call getarg(n,arg)
      endif
c
      return
      end
