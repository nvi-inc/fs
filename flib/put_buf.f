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
      subroutine put_buf( iclass, buffer, length, parm3, parm4)
      implicit none
      integer*4 iclass
      integer buffer(1), length
      character*(*) parm3, parm4
      integer iparm3,iparm4
c
      integer nchars
c
      nchars=-length
      if(length.gt.0) nchars=length*2
      call char2hol(parm3,iparm3,1,2)
      call char2hol(parm4,iparm4,1,2)
      call fc_cls_snd( iclass, buffer, nchars, iparm3, iparm4)
c
      return
      end
