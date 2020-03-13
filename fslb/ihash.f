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
      integer*2 function ihash(ias,ifc,nchar) 
      integer*2 ias(1)
      integer*2 mask,istate
      integer n,ifb,nb
      data n/16/,mask/o'040003'/
c
      istate = 0
      ifb=1+(ifc-1)*8
      nb=nchar*8
      zero=0
      call crcc(n,mask,istate,ias,ifb,nb,ias,zero)
      ihash = istate

      return
      end 
