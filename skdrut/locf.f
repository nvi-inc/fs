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
C@LOCF

C      subroutine locf(rlu,err,rec,rb,off)
       subroutine locf(rlu,rec)
c
c      Check the current file pointer and save it in REC.
c
c      89006  PMR
C  910702 NRV Changed calling sequence to include only
C             lu and rec#
c
       implicit none
       integer ifptr
       common /position/ ifptr(256)

C      integer rlu,err,rec,rb,off
       integer rlu,rec

       rec = ifptr(rlu)

       return
       end

