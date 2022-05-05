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
      SUBROUTINE proc_write_define(lufile,luscn,LNAMEP)
      implicit none
! write "define  lnamep        00000000000x"
! to the (proc) output file, and write lnamep to the screen.

! passed
      integer lufile
      integer luscn             !screen
      character*(*) lnamep      !procedure name.
! local
      character*46 ldum
      integer ind
      integer nproc
      save nproc

      if(lnamep .eq. " ") then
        nproc=0
        return
      endif
      if(lufile .eq. -1) then
        write(luscn,'()')        !flush the buffer.
        return
      endif

      ldum="define                00000000000x"

      call c2lower(lnamep,lnamep)
      ind=index(lnamep," ")
      if(ind .eq. 0) ind=len(lnamep)
      write(ldum(9:ind+8),'(a)') lnamep(1:ind)
!     call c2lower(ldum,ldum)
      write(lufile,'(a)') ldum

! This part writes the procedures to the screen.
      if(nproc .eq. 0) then             !indent first proc 5 spaces
         WRITE(luscn,"(5x,a12,$)") lnamep
         nproc =nproc+1
      elseif(nproc .lt. 4) then
         WRITE(luscn,"(' ',a12,$)") lnamep !skip a space for next
         nproc =nproc+1
      else
         WRITE(luscn,"(' ',a12)") lnamep   !close after 5
         nproc=0
      endif

      return
      end

