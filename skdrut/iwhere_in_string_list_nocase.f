!*************************************************************************
      function iwhere_in_string_list_nocase(list,num_list,lvalue)
      implicit none
! 2019Nov20 WEH  made list_tmp, lvalue_tmp fixed lenght for backward compatibility with f77
! find a string match ignoring case
      INTEGER iwhere_in_string_list_nocase
      INTEGER num_list
      CHARACTER*(*) list(*),lvalue
      character*256   list_tmp
      character*256 lvalue_tmp

      do iwhere_in_string_list_nocase=1,num_list
        list_tmp=list(iwhere_in_string_list_nocase)
        lvalue_tmp=lvalue
        call capitalize(list_tmp)
        call capitalize(lvalue_tmp)
        if(lvalue_tmp .eq. list_tmp) return     
      end do
      iwhere_in_string_list_nocase=0
      return
      END

