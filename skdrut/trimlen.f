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
C@TRIMLEN

       integer function trimlen (cbuf)
C
C  Trimlen returns the length of a
C  character array.
C           -P. Ryan
C
       implicit none

       integer     j
C        - j    : variable for indexing
       character*(*) cbuf
C        - cbuf : character buffer

C get total length of string
       j = len(cbuf)
C
C Read backwards down array, stopping at first non-blank character
C
       do while ((j.gt.0).and.(cbuf(j:j).eq.' '.or.
     . cbuf(j:j).eq.char(0)))
         j = j - 1
       end do
       trimlen = j
       return
       end

