*
* Copyright (c) 2020-2021 NVI, Inc.
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
! 2021Jan12 JMG Modified so that program would not crash if lnamep passed like
!                call proc_write_define(lufile,luscn, 'foobaz') 


! passed
      integer lufile
      integer luscn             !screen
      character*(*) lnamep      !procedure name.
! local
      character*35 ldum
      integer ind
      integer trimlen 
      integer nproc
      save nproc

      if(lnamep .eq. " ") then
        nproc=0
        return
      endif
      if(lufile .eq. -1) then
        write(luscn,'()') " "       !flush the buffer.
        return
      endif

      ldum="define                00000000000x"

      ind=trimlen(lnamep) 
      write(ldum(9:ind+8),'(a)') lnamep(1:ind)
      call lowercase(ldum)
      write(lufile,'(a)') ldum(1:trimlen(ldum))
   
! This part writes the procedures to the screen.
      if(nproc .eq. 0) then             !indent first proc 5 spaces
         WRITE(luscn,"('   Defining:   ',a,$)") lnamep(1:ind) 
         nproc =nproc+1
      elseif(nproc .lt. 12) then
         WRITE(luscn,"(' ',a,$)") lnamep(1:ind) !skip a space for next
         nproc =nproc+1
      else
         WRITE(luscn,"(' ',a)") lnamep(1:ind)    !close after 5
         nproc=0
      endif

      return
      end

