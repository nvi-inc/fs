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
      integer function igthx(jbuf,ifc,ilc,ifield,iferr)

      integer*2 jbuf(1)

      igthx=0

      ifield=ifield+1
      call gtfld(jbuf,ifc,ilc,ic1,ic2)
      if(ic1.le.0.or.ic2-ic1+1.gt.8) then
         iferr=-ifield
         return
      endif

      do i=ic1,ic2
         iv=ia2hx(jbuf,i)
         if(iv.lt.0) then
            iferr=-ifield
            return
         endif
         igthx=iv+ishft(igthx,4)
      enddo

      return
      end
