      integer function ifeet_init(km5,k4,ks2,iTapeLength)
      logical k4
      logical ks2
      logical km5
      integer iTapeLength
      if(k4) then
       ifeet_init=54
      else if(ks2) then
       ifeet_init=0
      else if(km5) then
       ifeet_init=0
      else
       if(ItapeLength .gt. 10000) then   !Thintape check
         ifeet_init=200
        else
         ifeet_init=100
        endif
! the following is here to test for compatibility. Remove in final.
!      ifeet_init=0
      endif
      return
      end
