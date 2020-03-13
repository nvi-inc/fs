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
      subroutine unget(jbuf,ierr,len)
C
      integer leng, ierrg
      integer*2 jbufg(100)
      logical kgot
      common/got/leng,ierrg,jbufg,kgot
C
      integer*2 jbuf(1)
C
      if (kgot) stop 
C 
      kgot=.true. 
      leng=len
      ierrg=ierr
      do i=1,min0(leng,100)
        jbufg(i)=jbuf(i) 
      enddo
C
      return
      end 
