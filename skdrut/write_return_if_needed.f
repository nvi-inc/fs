      subroutine write_return_if_needed(lu,kwrite_return)
! 2015Mar22 JMG Changed "end subroutine" to "end".  Former did not work with some older compilers. 
      integer lu
      logical kwrite_return
      if(kwrite_return) then
         write(luscn,*) " "
         kwrite_return=.false.
      endif
      return 
      end 
