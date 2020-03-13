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
      subroutine fit2(x,y,x2,par,epar,npts,npar,tol,ntry,f,chi,ierr)
C 
C     LEAST SQUARES FITTING ROUTINE...FITS TO FUNCTION F
C     WHICH MUST BE DECLARED EXTERNAL IN THE CALLING ROUTINE. 
C     MAXIMUM NUMBER OF PARAMETERS IS 5.  NOTE THAT AN
C     ERROR RESULTS IN A RETURN OF IERR <= 0.  THIS ROUTINE 
C     REQUIRES SUBROUTINE MATINV.   
C 
      dimension par(1),x(1),y(1),a(5,5),b(5),aux(5),epar(1) 
      dimension x2(1) 
C 
       include '../include/fscom.i'
C 
      do 100 itry=1,ntry
      do 20 i=1,npar
      b(i)=0. 
      do 20 j=1,npar
20    a(i,j)=0. 
      do 40 k=1,npts
      do 30 i=1,npar
30    aux(i)=f(i,x(k),x2(k),par)
      r=y(k)-f(0,x(k),x2(k),par)
      do 40 i=1,npar
      b(i)=b(i)+r*aux(i)
      do 40 j=1,npar
40    a(i,j)=a(i,j)+aux(i)*aux(j) 
C 
      call matin(npar,a,b,mback)
      if (mback.ne.-1) goto 200 
      iagain=0
      do 60 i=1,npar
      if (abs(b(i)/sqrt(abs(a(i,i)))).gt.tol) iagain=1   
60    par(i)=par(i)+b(i)
      if (iagain.eq.0) goto 101 
100   continue
      ierr=-2     
      goto 102 
C 
101   continue
      ierr=itry 
C 
102   continue
      chi=0.
      do 110 i=1,npar 
        epar(i)=sqrt(abs(a(i,i))) 
110   continue
      nfree=npts-npar 
      if (nfree.le.0) return 
      xsum=0. 
      xsq=0.
      do 120 i=1,npts 
      r=y(i)-f(0,x(i),x2(i),par)
120   xsq=xsq+r*r 
      chi=sqrt(xsq/nfree) 
      do 140 i=1,npar 
140   epar(i)=chi*sqrt(abs(a(i,i))) 
      return

200   ierr=-1   

      return
      end 
