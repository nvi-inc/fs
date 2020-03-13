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
c@scanp
       integer function scanp(ibcd,ibsrt,ix) 
C
c 010705 PB - V1.0. 
C
c Part of sorted 'dl' display for pfmed. 
c Copy a line's worth of procedure names into an array 'ibsrt'
c Update total index and return it. 
c
       implicit none
       include '../include/fscom.i'

       Character*(12) ibcd,ibsrt(1)
       integer ix,is,in,nch,jchar,ichmv 

       is = 1

100    continue 
        in = is 
        do while (jchar(ibcd,in).ne.32)
         in = in+1
        enddo
        nch = ichmv(ibsrt(ix),1,ibcd,is,is+12) 
        ix = ix+1
        if (ix.gt.MAX_PROC2) then
          write(6,'("pfmed: Exceeded maximum number of procedures")') 
          scanp = MAX_PROC2 
          return
        endif
        is = in 
        do while (jchar(ibcd,is).eq.32)
         is = is+1
        enddo
       if (is.lt.79) goto 100
 
cc       write (6,'("SCANP ix: ",i3)') ix      
       scanp = ix
       return
       end
 