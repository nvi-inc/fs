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
      subroutine ssrc(lname,ra,dec,epoch,jbuf,il,ierr)
C
      integer*2 jbuf(1),lname(5)
C
      icnext=1
C
      icnext=ichmv(jbuf,icnext,lname,1,10)
C
100   continue
      if (mod(icnext,2).eq.0) icnext=ichmv_ch(jbuf,icnext,' ')
      call scmd(jbuf,0,icnext/2,ierr)
C
      return
      end
