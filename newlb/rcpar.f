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
      subroutine rcpar(n,arg)
      implicit none
      integer n
      character*(*) arg
c
c  rcpar: run-string parameters returned in character variable
c
c  returns the n-th argument in arg,
c  if n < 0 undefined
c     n = 0 program name
c  arg is set to blank if n exceeds the actual number of supplied
c     arguments OR the argument is blank or empty
c
      integer iargc
c
      if(n.lt.0) return
c
      if(n.gt.iargc()) then
        arg=' '
      else
        call getarg(n,arg)
      endif
c
      return
      end
