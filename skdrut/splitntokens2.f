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
!***********************************************************************
      subroutine SplitNTokens2(ldum,ltokens,MaxToken,NumGot,istart_vec)
! identical to SplitNtokens
      implicit none
      charactER*(*) ldum
      integer MaxToken,NumGot
      character*(*) ltokens(MaxToken)
      integer istart_vec(*)
! function
      logical ktoken     !got token
      logical knospace   !no more space
      logical keol       !eol.
      integer istart,inext,itoken

      istart=1
      do itoken=1,MaxToken
        call ExtractNextToken(ldum,istart,inext,ltokens(itoken),ktoken,
     >   knospace, keol)
         istart_vec(itoken)=istart
         if(.not.ktoken) then
            NumGot=itoken-1
            return
         endif
        istart=inext
      end do
      NumGot=MaxToken

      return
      end

