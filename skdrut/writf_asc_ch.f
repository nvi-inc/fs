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
       subroutine writf_asc_ch (iunit,kerr,cbuf)
       implicit none
C  Character only version of WRITF
C  Input:
       integer iunit
C        iunit : logical unit for writing
       character*(*) cbuf
C        cbuf  : character buffer for reading
C
C  Output:
       integer kerr
C        kerr  : variable to return error on output (nonzero if error)
C
       write(iunit,'(a)',ERR=100) cbuf
       kerr=0
       return
c
 100   continue
       kerr=-1
       return
       end

