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
      subroutine jmvbits(ifrom,ist,ilen,ito,itost)
      implicit none
      integer*4 ifrom,ist,ilen,ito,itost
c
      integer*4 ibits,imask
c
      imask=not(lshift(not(0),ilen))
      ibits=lshift(and(rshift(ifrom,ist),imask),itost)
      imask=not(lshift(imask,itost))
      ito=or(and(ito,imask),ibits)
c
      return
      end
