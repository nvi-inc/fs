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
      logical function kget_response(lu,lstring)
! History:
! xxxx   First version
! 10Nov05 JMGipson. Added "Implicit None".
!          changed size of lyt_list. was Char*4
!
! Write out the string, and wait for response.
      implicit none
      character*(*) lstring
      integer lu
! functions
      integer trimlen
      integer iStringMinMatch


! local
      character*10 lresponse    !holds user response
      integer icmd

      integer iyt_list_len
      parameter (iyt_list_len=6)
      character*5 lyt_list(iyt_list_len)
      data lyt_list/"TRUE","YES","ON","FALSE","NO","OFF"/

      do while(.true.)
        write(lu,'(a,1x)') lstring(1:trimlen(lstring))
        read(*,*) lresponse
        call capitalize(lresponse)
        icmd=istringMinMatch(lyt_list,iyt_list_len,lresponse)
        if(icmd .eq. 0) then
           write(*,*) "Invalid response. Try again."
        else if(icmd .le. 3) then
          kget_response=.true.
          return
        else
          kget_response=.false.
          return
        endif
      end do
      end
