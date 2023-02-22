*
* Copyright (c) 2020, 2023 NVI, Inc.
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
      subroutine strip_path(lfullpath,lfilnam)
! strip off the path, return the filename.
      implicit none
! fucntions
      integer trimlen
! passed
      character*(*) lfullpath           !passed
      character*(*) lfilnam             !filename
! History
! 2023-02-21  JMGipson. Substantially re-written.  Previously  did not check
!             to see if there was enough space when extracting lfilnam. Now does.
! local
      integer ilen_full,ilen_file
      integer i
      integer iend
      integer ibeg

      ilen_full=len(lfullpath)
      ilen_file=len(lfilnam)

! Initialize to blank
      lfilnam=" "

      iend =trimlen(lfullpath)
!      write(*,*) "iend ", iend
      if(iend  .eq. 0) return

      ibeg=0
      do i=iend,1,-1
        if(lfullpath(i:i) .eq. "/") then
           ibeg=i
           goto 10
        endif
      end do

10    continue
      ibeg=ibeg+1
!      write(*,*) "ibeg ", ibeg
!      write(*,*) "ilen_full ", ilen_full
!      write(*,*) "ilen_file ", ilen_file, iend-ibeg+1

      if(iend-ibeg+1 .gt. ilen_file) then
        write(*,*) "Strip_path: not enough name to store filename ",
     >   lfullpath(ibeg:iend)
        write(*,*) "Need ",iend-ibeg+1, " characters but only have ",
     >   ilen_file
        stop
      endif
      lfilnam(1:iend-ibeg+1)= lfullpath(ibeg:iend)
      return
      end
