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
      subroutine incne(a,b,aux,npar,r,w)
C
      implicit none
      integer npar
      double precision a(1),b(1),aux(1),r,w
C
      integer nxpnt,i,j
C
      nxpnt=0
      do i=1,npar
        b(i)=b(i)+r*aux(i)*w
        do j=1,i
          a(nxpnt+j)=a(nxpnt+j)+aux(i)*aux(j)*w
        enddo
        nxpnt=nxpnt+i
      enddo
C
      return
      end
