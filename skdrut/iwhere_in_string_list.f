!     Last change:  JG   12 May 2000    8:09 am
!*************************************************************************
      function iwhere_in_string_list(list,num_list,lvalue)
      INTEGER iwhere_in_string_list
      INTEGER num_list
      CHARACTER*(*) list(*),lvalue

      do iwhere_in_string_list=1,num_list
        IF(lvalue .EQ. list(iwhere_in_string_list)) return
      end do
      iwhere_in_string_list=0
      return
      END

