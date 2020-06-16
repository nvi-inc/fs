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
      subroutine put_esc_in_string(ldum)
! Very simple routine to put an escape if it see a naked "@"
! passed
      implicit none  !2020Jun15 JMGipson automatically inserted.
      character*(*) ldum
! function
      integer trimlen
! local
      character*1024 ltemp
      integer i,ind,iptr
      character*1 lslash
      integer nch

      lslash=char(92)          !\


      ind=index(ldum,"@")
      if(ind .eq. 0) return

      nch=trimlen(ldum)
      if(nch .gt. 1023) then
        write(*,*)"Not enough space!!!"
      endif

      ltemp=ldum

      iptr=ind-1
      do i=ind,nch
        if(ldum(i:i) .eq. "@") then
          if(i .eq. 1 .or. ldum(i-1:i-1) .ne. lslash) then  !insert escape if nessecary
             if(ltemp(iptr:iptr) .ne. lslash) then
               iptr=iptr+1
               ltemp(iptr:iptr)=lslash
             endif
          endif
       endif
       iptr=iptr+1
       ltemp(iptr:iptr)=ldum(i:i)
      end do
      if(iptr .gt. len(ldum)) then
         writE(*,*) "Put_esc_in_string: Not enough space!"
      endif
      ldum=ltemp(1:iptr)
      return
      end
