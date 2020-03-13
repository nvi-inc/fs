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
      subroutine dppin(a,n)
      implicit none
      double precision a(1)
      integer n
C
C CALCULATE INVERSE FROM A CHOLESKY FACTORIZATION OF A SOLVE FORMAT MATRIX
C
C DOUBLE PRECISION VERSION OF LINPACK SPPDI ROUTINE WITH
C DIRECT CALLS TO THE HP VECTOR INSTRUCTION SET AND
C ONLY THE INVERSION PART OF THE ORIGINAL LINPACK IS HERE
C
      integer j,k
      integer k1,kk,j1,kj,jj
      double precision t
C
      kk=0
      do k=1,n
        k1=kk+1
        kk=kk+k
        a(kk)=1.0d0/a(kk)
        t=-a(kk)
        call dvsmy(t,a(k1),1,a(k1),1,k-1)
        j1=kk+1
        kj=kk+k
        do j=k+1,n
          t=a(kj)
          a(kj)=0.0d0
          call dvpiv(t,a(k1),1,a(j1),1,a(j1),1,k)
          j1=j1+j
          kj=kj+j
        enddo
      enddo
C
      jj=0
      do j=1,n
        j1=jj+1
        jj=jj+j
        k1=1
        kj=j1
        do k=1,j-1
          t=a(kj)
          call dvpiv(t,a(j1),1,a(k1),1,a(k1),1,k)
          k1=k1+k
          kj=kj+1
        enddo
        t=a(jj)
        call dvsmy(t,a(j1),1,a(j1),1,j) 
      enddo 
C 
      return
      end 
