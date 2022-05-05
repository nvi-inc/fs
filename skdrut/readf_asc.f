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
C@READF_ASC

       subroutine readf_asc (iunit,kerr,ibuf,ibl,il)
C
C  ASCII only version of READF
      implicit none
C 000907 nrv Call IFILL with IBL instead of 80

C  Input:
       integer iunit
C        -iunit : logical unit for reading
       integer kerr
C        -kerr  : variable to return error on input (nonzero if error)
       integer ibl
C        -ibl : buffer length
       logical*4 ex,opn
C
C  Output:
       integer il
C        -il    : number of characters read in
       integer*2 ibuf(*)
C        -ibuf  : integer buffer for reading
C
C  Local:
       character*1024 ch,nam
C        -ch    : character buffer for initial input
       integer     trimlen
C        -trimlen : find number of character read in
       integer*4 k
       integer oblank
       data oblank /O'40'/
C        -k : variable for iostat error-checking
C
C  880523  -written by P. Ryan
C 960212 nrv Extend buffer
C
       inquire(iunit,exist=ex,opened=opn,name=nam)
       read(iunit,10,end=20,iostat=k) ch
10     format (A1024)
       kerr = k
       il   = trimlen(ch)
       if(il .gt. 0 .and. ch(il:il) .eq. char(13)) then
         ch(il:il)=" "
         il=trimlen(ch)
       endif

       if (kerr .ne. 0) then
         il = -1
         return
       else
         call ifill(ibuf,1,ibl,oblank)
         call char2hol (ch,ibuf,1,il)
         il = (il+1)/2  ! changes to number of memory words
         return
       end if

20     il = -1   !  EOF has been reached
       kerr = 0
       return

       end

