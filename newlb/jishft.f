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
      integer*4 function jishft(iar,inum)
      implicit none
      integer*4 iar
      integer inum
c
      integer*4 imask
c
      if(inum.ge.0) then
        jishft=lshift(iar,inum)
      else
        imask=not(lshift(not(0),32+inum))
        jishft=and(rshift(iar,-inum),imask)
      endif
c
      return
      end
