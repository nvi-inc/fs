c@sortq

       subroutine sortq(isrt,nx)
C
C 010705 V1.0 PB - simple bubble sort of string array 
C 010831 v1.1 PB - fix nx return value. 
C
C isrt - array of character*12 with procedure names 
C nx - number of elements in the array.  
C
       implicit none
       
       integer i,j,nx,nc,ichcm
       character*12 temp,isrt(1)

cc       write (6,'("SORTQ isrt(1): ",12a)') isrt(1)

       do i = 1,nx

         do j = 1,nx-i-1
           
           nc = ichcm(isrt(j+1),1,isrt(j),1,12)
           if (nc.gt.0) then
             temp = isrt(j) 
             isrt(j) = isrt(j+1)
             isrt(j+1) = temp 
           endif 

         enddo

       enddo 

       nx = nx -1   ! 010831 correct this 

       return 
       end
