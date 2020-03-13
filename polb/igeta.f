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
      subroutine igeta(ib,ifc,ilc,ic1,ic2,kerr)

      logical kerr
C
      kerr=.true.
      ic2=0
      ic1=0
      if (ifc.gt.ilc) return 
      ic2=iscn_ch(ib,ifc,ilc,',')
      if (ic2.le.0) goto 20 
      if (ic2.gt.ifc) goto 10 
C 
      ifc=ifc+1 
      ic2=0 
      return
C 
10    continue
      ic1=ifc 
      ifc=ic2+1
      ic2=ic2-1
      kerr=.false.
      return
C
20    continue
      il=iflch(ib,ilc)
      if (il.lt.ifc) return
      ic2=il
      ic1=ifc
      ifc=ilc+1
      kerr=.false.

      return
      end
