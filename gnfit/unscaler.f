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
      subroutine unscaler(matrix, vector, scale, dim)
C
      implicit none
      double precision matrix(1), vector(dim), scale(dim)
      integer dim
C
C  UNSCALE SOLVE FORMAT MATRIX AND B VECTOR
C
      integer i
      integer ij
      double precision local
C
C   unscaling
C
      ij=1
      do i=1,dim
        local=scale(i)
        call dvsmy(local,matrix(ij),1,matrix(ij),1,i)
        call dvmpy(matrix(ij),1,scale,1,matrix(ij),1,i)
        ij = ij + i
      enddo
      call dvmpy(vector,1,scale,1,vector,1,dim)
C
      return
      end
