c@sortp
        subroutine sortp(isrt,nx)
c
C 010705 PB V1.0 - simple sort & display of character array
C 010709 PB V1.1 - max strings to 256; error return added. 
C 010726 WEH                      MAX_PROC2
C 010830 PB - min(j+5,nx)
C
        implicit none
        include '../include/params.i'
c
        character*(*) isrt(1)
        integer i,j,nx,lu,nxmax
        data nxmax/MAX_PROC2/
        data lu/6/
        
        if (nx.gt.nxmax) then 
          nx = nxmax
          write (lu,'("Insufficient space to dislay full sort.")')
          return
        endif
 
cc        write (lu,'("sortp: Sorted Display")')
        call sortq(isrt,nx) 

c Display the names in lines of 6 sets of 12 chars:

        j = 1 

        do while (j.le.nx)

         do i = j,min(j+5,nx)  
          write (lu,20) isrt(i)
20        format(a12," ",$) 
         enddo
          write (lu,'(" ")')     ! Next line. 
         
        j = j+6    
        enddo 

        return 
        end
