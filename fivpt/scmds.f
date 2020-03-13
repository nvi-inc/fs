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
      subroutine scmds(cmess,ic)
      character*(*) cmess
      integer ic
c
      integer*2 imess(128)
c      integer*4 ip(5)
      integer ix
C
c      call clear_prog('fivpt')
      if(len(cmess).gt.256) then
         call put_stderr('scmds message length >256\n'//char(0))
         stop 999
      endif
      call char2hol(cmess,imess,1,len(cmess))
      ix=sign(len(cmess),ic)
      call copin(imess,ix)
c
c      call wait_prog('fivpt',ip)
      call suspend('fivpt')
c
      return
      end
