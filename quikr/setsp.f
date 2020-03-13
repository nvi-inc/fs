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
      subroutine setsp(idir,isp,ip)
C  set tape speed  c#870115:04:34# 
C 
      integer*2 ibuf(10),lgen(2)
      dimension ip(1)
C 
      ibuf(1) = 0 
      call char2hol('tp',ibuf(2),1,2)
      call char2hol('720',lgen,1,4)
      call mv2ma(ibuf(3),idir,isp,lgen)
      iclass = 0
      call put_buf(iclass,ibuf,-13,'fs','  ')
      call run_matcn(iclass,1) 
      call rmpar(ip)
      iclass = ip(1)
      call clrcl(iclass)
      ip(1) = 0 
      ip(2) = 0 
      return
      end 
