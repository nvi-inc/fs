      subroutine read_nolf(lu,cbuf,kend)
      implicit none
! Input
      integer lu             !logical unit
      character*(*) cbuf     !character buffer
      logical kend           !Reached EOF.
! History
! 2015Dec01    JMGipson
!
! Read a line from the input file. Replace ^M (=linefeed) with space. 

! local
      integer ind           !index
   
! Default is reach EOF.       
      kend=.true.
      read(lu,'(a)',end=100) cbuf
      
! Hmmm. Did not reach EOF.   Set this to false. 
      kend=.false. 
! Replace ^M with space. 
      ind=index(cbuf(1:len(cbuf)),char(13)) 
      if(ind .ne. 0) cbuf(ind:ind) = " " 

100   continue
      return 

      end 

      

     
      


