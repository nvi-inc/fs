*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
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
