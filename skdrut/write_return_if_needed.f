      subroutine write_return_if_needed(lu,kwrite_return)
      integer lu
      logical kwrite_return
      if(kwrite_return) then
         write(luscn,*) " "
         kwrite_return=.false.
      endif
      return 
      end subroutine
