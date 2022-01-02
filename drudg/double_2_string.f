*
* Copyright (c) 2021 NVI, Inc.
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
      subroutine double_2_string(dtemp, lformat, lstring,nch,ierr)
      implicit none
! Convert a double to a string. 
! minimun format is f3.1, e.g., something like 9.4
! Write dtemp to lstring. Then left align and strip extra zeros at end. 
      real*8 dtemp                !number to convert
      character*(*) lformat       !format statement to use
      character*(*) lstring       !output string
      integer nch                 !lenght of output string.
      integer ierr
! functions
      integer trimlen 

! local
      integer i 
      integer ilen 
      integer iptr 
 
      ierr=0
      ilen=len(lstring)
      if(ilen .lt. 3) then 
        ierr=-2
        write(*,*) "Minimum length is 3"
        return
      endif 

      write(lstring,lformat,err=500) dtemp
      if(lstring(1:1) .eq. "*") goto 500 
      nch=trimlen(lstring)
!      write(*,*) "1>", lstring 

! get rid of trailing 0s
      iptr=nch
      do i=3,nch
        if(lstring(iptr-1:iptr-1) .eq. ".") goto 10      
        if(lstring(iptr:iptr) .eq. "0") then
           lstring(iptr:iptr)=" "
        else if(lstring(iptr:iptr) .ne. " ") then
           goto 10
        endif
        iptr=iptr-1
      end do
10    continue
!      write(*,*) "2>", lstring 
 
! now strip leading space+
      do i=1,iptr
        if(lstring(i:i) .ne. " ") goto 20
      end do
20    continue 
      nch=iptr-i+1 
      if(i .eq. 1) return

! i is now th the first non-blank character.
      lstring(1:nch)=lstring(i:iptr)
      lstring(nch+1:iptr)=" "
!      write(*,*) "3>", lstring 
      return      

500   continue      
      write(*,*) "double_2_string: Could not write ", dtemp
      write(*,*) "to string of length ", ilen, "with format ",lformat 
      ierr=-1
      return
      end 
