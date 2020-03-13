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
      subroutine check_csb_list(lcsb_list,num_csb,
     >      lsked_csb,num_tracks,imask,ierr)
      implicit none 
! Check to see if all of the elements in lsked_csb are in lcsb_list.
! If not, return with error.
! If so,  set imask.
! Passed
      character*4 lcsb_list(num_csb)
      integer num_csb
      character*4 lsked_csb(*)
      integer num_tracks                 
  
! output
      integer*4 imask(2)     !mask if any
      integer   ierr 
! Function
      integer iwhere_in_string_list 
! History
! 2015Jun10 JMG First version. 
! 2018Aug18 JMG Setup so that can have 64 bit mask. 
! 2019Aug26 Always initialize both masks to 0.
! local
      integer*4 itemp
      integer ic    !counter
      integer ibit   
      logical kdebug
      integer i12   !takes on value of 1 or 2 depending on if first or second half of 64 bit mask.
      integer i, icnt 
      kdebug=.true.   
      kdebug=.false.
      imask(1)=0
      imask(2)=0
    
      if(kdebug) then 
! Write out list to check against. 
        icnt=0
        do i=1, num_csb
          write(*,'(a," ",$)') lcsb_list(i)
          icnt=icnt+1
          if(icnt .gt. 15) then
            write(*,*) " "
            icnt=0
          endif
        end do
        if(icnt .ne. 0) write(*,*) " "
      endif 

!      write(*,'(a, " ")') lcsb_list(1:num_csb) 
     
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lcsb_list,num_csb,lsked_csb(ic))   
        if(ibit .eq. 0) then              
          if(kdebug)  then
             write(*,*) " "
             write(*,"('     Did not find: ',a)")  lsked_csb(ic)  
             write(*,"('Checking: ', $)") 
          endif 
          ierr=ic     !return track that is not found. 
          return
        endif
        itemp=1
        if(ibit .le. 32) then
          i12=1
        else
! Set one of the upper 32 bits. 
          i12=2
          ibit=ibit-32
        endif
         
        itemp=ishft(itemp,ibit-1)
        imask(i12)=ior(imask(i12),itemp)    !set the appropriate bit.
      end do 
! Success.  Found matches for all.
      ierr=0
      return     
      end
!
