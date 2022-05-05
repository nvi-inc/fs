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
C@CLEAR_ARRAY

        subroutine clear_array(cbuf)

C  This routine simply loads a character buffer with blanks
C
C  -P. Ryan

        character*(*) cbuf
        integer     i,j,len

        cbuf = ' '
C       j = len(cbuf)
C       do i=1,j
C         cbuf(i:i) = ' '
C       end do

        return
        end

