!    2010Apr07 JMGipson
!*************************************************************************
      function iwhere_in_int_list(ilist,num_list,value)
      INTEGER iwhere_in_int_list
      INTEGER num_list
      integer ilist(*),value
  
      do iwhere_in_int_list=1,num_list
        IF(value .EQ. ilist(iwhere_in_int_list)) return   
      end do
      iwhere_in_int_list=0
      return
      END

