      subroutine update_string_list(cstring_list,
     >     num_in_list,max_in_list,cstring,iptr)
! Find where cstring is in cstring_list.
! If it is in the list, return iptr.
! If it is not, and there is enough space, put it at the end.
! If not enough space, return an error.
! on entry
!
      implicit none
      integer num_in_list                       !number in list now.
      integer max_in_list                       !maximum allowed
      character*(*) cstring_list(max_in_list)      !The list
      character*(*) cstring                     !String to check
      integer iptr                              !-1 if no space, otherwise location.
!
! History.
!  2005Nov21  JMGipson.  First version.
!
! functions
      integer iwhere_in_string_list
! local variables

      iptr=iwhere_in_string_list(cstring_list,num_in_list,cstring)
      if(iptr .eq. 0) then
        if(num_in_list .lt. max_in_list) then
          num_in_list=num_in_list+1
          cstring_list(num_in_list)=cstring
          iptr=num_in_list
        else
          iptr=-1
        endif
      endif
      return
      end
