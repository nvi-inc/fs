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
      subroutine apost(x1,x2,aux,wy1,wy2,par,ipar,phi,a,npar,f1,f2,
     +     fec1,fec2,rchi,ap1,ap2,coslt,iflags)
C
C calculate a posterior sigmas
C
      real wy1,wy2
      integer ipar(1)      
      double precision par(1),a(1),aux(1),x1,x2
C
      external f1,f2
      double precision f1,f2
C
      double precision wln1,wlt1,acc1,acc2
C
C DIMENSION A(NPAR*(NPAR+1)/2)
C
      if(and(iflags,1).eq.1) then
         wln1=wy1*wy1+sign((fec1*fec1)/(coslt*coslt),fec1)
      else
         wln1=wy1*wy1+sign((fec1*fec1),fec1)
      endif
      wlt1=wy2*wy2+sign(fec2*fec2,fec2)
C
      do i=1,npar
         aux(i)=f1(i,x1,x2,par,ipar,phi)
      enddo
C
      acc1=0.d0
      do i=1,npar
         do j=1,npar
            acc1=acc1+a(indx(i,j))*aux(i)*aux(j)
         enddo
      enddo
C
      do i=1,npar
         aux(i)=f2(i,x1,x2,par,ipar,phi)
      enddo
C
      acc2=0.d0
      do i=1,npar
         do j=1,npar
            acc2=acc2+a(indx(i,j))*aux(i)*aux(j)
         enddo
      enddo
C
      ap1=rchi*sign(sqrt(abs(wln1-acc1)),wln1-acc1)
      ap2=rchi*sign(sqrt(abs(wlt1-acc2)),wlt1-acc2)
C
      return
      end

