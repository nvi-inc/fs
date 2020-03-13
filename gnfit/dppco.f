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
      subroutine dppco(a,n,rcond,z,info)
      implicit none
      integer n,info
      real*4 rcond
      double precision a(1),z(1)
C
C  LINPACK ROUTINE TO FACTOR AND FIND CONDITON OF MATRIX A
C  CALLS DPPFA TO GET FACTOR, BLAS CALLS CONVERTED TO HP VIS CALLS
C
      integer j,i,k
      integer j1,ij,kj,kk
      double precision anorm,local,ek,wk,wkm,s,sm,t,ynorm
C
      j1=1
      do j=1,n
        call dvnrm(local,a,1,j)
        z(j)=local
        ij=j1
        j1=j1+j
        do i=1,j-1
          z(i)=z(i)+dabs(a(ij))
          ij=ij+1
        enddo
      enddo
      anorm=0.0d0
      do j=1,n
        anorm=max(anorm,z(j))
      enddo
C
      call dppfa(a,n,info)
      if(info.ne.0) return
C
      ek=1.0d0
      do j=1,n
        z(j)=0.0d0
      enddo
      kk=0
      do k=1,n
        kk=kk+k
        if(z(k).ne.0.0d0) ek=dsign(ek,-z(k))
        if(dabs(ek-z(k)).gt.a(kk)) then
          s=a(kk)/dabs(ek-z(k))
          call dvsmy(s,z,1,z,1,n)
          ek=s*ek
        endif
        wk=ek-z(k)
        wkm=-ek-z(k)
        s=dabs(wk)
        sm=dabs(wkm)
        wk=wk/a(kk)
        wkm=wkm/a(kk)
        kj=kk+k
        if(k+1.le.n) then
          do j=k+1,n
            sm=sm+dabs(z(j)+wkm*a(kj))
            z(j)=z(j)+wk*a(kj)
            s=s+dabs(z(j))
            kj=kj+j
          enddo
          if(s.lt.sm) then
            t=wkm-wk
            wk=wkm
            kj=kk+k
            do j=k+1,n
              z(j)=z(j)+t*a(kj)
              kj=kj+j
            enddo
          endif
        endif
        z(k)=wk
      enddo
      call dvnrm(local,z,1,n)
      s=1.0d0/local
      call dvsmy(s,z,1,z,1,n)
C
      do k=n,1,-1
        if(dabs(z(k)).gt.a(kk)) then
          s=a(kk)/dabs(z(k))
          call dvsmy(s,z,1,z,1,n)
        endif
        z(k)=z(k)/a(kk)
        kk=kk-k
        t=-z(k)
        call dvpiv(t,a(kk+1),1,z,1,z,1,k-1)
      enddo
      call dvnrm(local,z,1,n)
      s=1.0d0/local
      call dvsmy(s,z,1,z,1,n)
C
      ynorm=1.0d0
C
      do k=1,n
        local=0.0d0
        call dvdot(local,a(kk+1),1,z,1,k-1)
        z(k)=z(k)-local
        kk=kk+k
        if(dabs(z(k)).gt.a(kk)) then
          s=a(kk)/dabs(z(k))
          call dvsmy(s,z,1,z,1,n)
          ynorm=s*ynorm
        endif
        z(k)=z(k)/a(kk)
      enddo
      call dvnrm(local,z,1,n)
      s=1.0d0/local
      call dvsmy(s,z,1,z,1,n)
      ynorm=s*ynorm
C
      do k=n,1,-1
        if(dabs(z(k)).gt.a(kk)) then
          s=a(kk)/dabs(z(k))
          call dvsmy(s,z,1,z,1,n)
          ynorm=s*ynorm
        endif
        z(k)=z(k)/a(kk)
        kk=kk-k
        t=-z(k)
        call dvpiv(t,a(kk+1),1,z,1,z,1,k-1)
      enddo
      call dvnrm(local,z,1,n)
      s=1.0d0/local
      call dvsmy(s,z,1,z,1,n)
      ynorm=s*ynorm
C
      if(anorm.ne.0.0d0) then
        rcond=ynorm/anorm
      else
        rcond=0.0d0
      endif
C
      return
      end
