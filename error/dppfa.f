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
      subroutine dppfa(a,n,info)
      implicit none
      integer n,info
      double precision a(1)
C
C CHOLESKY FACTORIZATION OF A SOLVE FORMAT MATRIX
C
C DOUBLE PRECESION VERSION OF LINPACK SPPFA ROUTINE WITH
C DIRECT CALLS TO THE HP VECTOR INSTRUCTION SET AND
C
      integer j,k
      integer jj,kj,kk
      double precision s,t
C
      jj=0
      do j=1,n
        s=0.0d0
        kj=jj
        kk=0
        do k=1,j-1
          kj=kj+1
          t=0.0d0
          call dvdot(t,a(kk+1),1,a(jj+1),1,k-1)
          t=a(kj)-t
          kk=kk+k
          t=t/a(kk)
          a(kj)=t
          s=s+t*t
        enddo
        jj=jj+j
        s=a(jj)-s
        if(s.le.0.0) then
          info=j
          return
        endif
        a(jj)=dsqrt(s)
      enddo
      info=0
C
      return
      end
