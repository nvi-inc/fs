C     Last change:  JG    9 Nov 2006    9:19 am
!     Last change
!*************************************************************************
      function iwhere_in_real4_list(r4list,num_list,value)
      INTEGER iwhere_in_real4_list
      INTEGER num_list
      real*4 r4list(*),value

      do iwhere_in_real4_list=1,num_list
        IF(value .EQ. r4list(iwhere_in_real4_list)) return
      end do
      iwhere_in_real4_list=0
      return
      END

