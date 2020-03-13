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
      subroutine scaler(matrix, vector, scale, dim)
C
      implicit none
      double precision matrix(1), vector(dim), scale(dim)
      integer dim
C
C  SCALE SOLVE FORMAT MATRIX AND B VECTOR
C
      integer i
      integer ii,ij
      integer*2 ibuf(20)
      double precision local,div
C
C   scaling
C
      ii=0
      do i=1,dim
        ii = ii+i
        if (matrix(ii) .lt. 0.d0) then
          write(6,*) 'scaler stop ',i
c          call char2hol('scaler stop ',ibuf,1,12)
c          call ib2as(i,ibuf,14,5)
c          call po_put_i(ibuf,20)
          pause
        endif
        div=dsqrt(matrix(ii))
c        if (div.lt.1d-14) then
        if (div.lt.1d-10) then
          scale(i)=0.0d0
        else
          scale(i)=1.0d0/div
        endif
        matrix(ii) = 1.0d0
        local=scale(i)
        ij=1+ii-i
        call dvsmy(local,matrix(ij),1,matrix(ij),1,i-1)
        call dvmpy(matrix(ij),1,scale,1,matrix(ij),1,i-1)
      enddo
      call dvmpy(vector,1,scale,1,vector,1,dim)
C
      return
      end
