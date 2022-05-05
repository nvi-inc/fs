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
      subroutine dppsl(a,b,n)
      implicit none
      integer n
      double precision a(1),b(1)
C
C SOLVE FROM A CHOLESKY FACTORIZATION OF A SOLVE FORMAT MATRIX
C
C DOUBLE PRECESION VERSION OF LINPACK SPPSL ROUTINE WITH
C DIRECT CALLS TO THE HP VECTOR INSTRUCTION SET
C
      integer k
      integer kk
      double precision t
C
      kk=0
      do k=1,n
        t=0.0d0
        call dvdot(t,a(kk+1),1,b,1,k-1)
        kk=kk+k
        b(k)=(b(k)-t)/a(kk)
      enddo
C
      do k=n,1,-1
        b(k)=b(k)/a(kk)
        kk=kk-k
        t=-b(k)
        call dvpiv(t,a(kk+1),1,b,1,b,1,k-1)
      enddo
C
      return
      end
