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
       integer function trimlen(string)
       implicit none
       character*(*) string
c
c trimlen returns the index of the last nonblank character in string
c                 0 if all characters are blank
c
       trimlen=len(string)
c
c read backwards down array, stopping at first non-blank character
c
       do while (trimlen.gt.0)
         if(string(trimlen:trimlen).ne.' ') return
         trimlen = trimlen - 1
       enddo
c
       return
       end
