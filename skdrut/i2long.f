      integer function i2long(ishort)
C This function takes a short integer and returns
C a long one. 
C 951017 nrv created
      implicit none
      integer*2 ishort
      i2long = ishort
      return
      end
