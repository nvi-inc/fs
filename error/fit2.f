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
      subroutine fit2(x1,x2,y1,y2,wy1,wy2,npts,par,epar,ipar,phi,
     +  aux,scale,a,b,npar,tol,ntry,f1,f2,rchi,r1nr,r2nr,
     +  nfree,ierr,luse,igp,fec1,fec2,y1r,y2r,rcond,iflags)
C
C     LEAST SQUARES FITTING ROUTINE...FITS TO FUNCTIONS F1 & F2
C     WHICH MUST BE DECLARED EXTERNAL IN THE CALLING ROUTINE.
C
C          THIS ROUTINE FITS DATA IN Y1 AND Y2 TO FUNCTIONS F1 AND F2
C          RESPECTIVELY, SIMULTANEOUSLY ON THE INDEPENDENT VARIABLES
C          X1 AND X2
C
C     PARAMETERS WILL BE RETURNED IN PAR, WHICH SHOULD CONTAIN FIRST
C     GUESSES TO START.  ERRORS ARE RETURNED IN EPAR.
C
C     WEH 831101
C
      dimension x1(1),x2(1),y1(1),ipar(1),y1r(1),y2r(1)
      dimension y2(1),wy1(1),wy2(1),luse(1)
      double precision par(1),epar(1)
      double precision a(1),b(1),aux(1),scale(1)
      double precision sq,sq1,sq2,r,w,eps,x1,x2,r1,r2,wyt1,wyt2
      logical kbit
C
      external f1,f2
      double precision f1,f2
C
C DIMENSION X1(NPTS),X2(NPTS),Y1(NPTS),Y2(NPTS),WY1(NPTS),WY2(NPTS)
C DIMENSION PAR(NPAR),EPAR(NPAR),AUX1(NPAR),AUX2(NPAR),SCAL(NPAR)
C DIMENSION A(NPAR*(NPAR+1)/2),B(NPAR),IPAR(NPAR)
C
      data eps/1d-10/
C
      rchi=0.
      r1nr=0.
      r2nr=0.
      nfree=0
      rcond=0.0
C
      do i=1,npar
        epar(i)=0.0d0
        scale(i)=0.0d0
      enddo
C
      do itry=1,abs(ntry)
        call inine(a,b,npar)
C
        do k=1,npts
          if (kbit(luse,k)) then
            r=y1(k)-f1(0,x1(k),x2(k),par,ipar,phi)
            if(and(iflags,1).eq.1) then
               coslt=cos(x2(k))
               w=1.0d0/(wy1(k)*wy1(k)
     +              +sign(fec1*fec1/(coslt*coslt),fec1))
            else
               w=1.0d0/(wy1(k)*wy1(k)+sign(fec1*fec1,fec1))
            endif
            do i=1,npar
              aux(i)=f1(i,x1(k),x2(k),par,ipar,phi)
            enddo
            call incne(a,b,aux,npar,r,w)
C
            r=y2(k)-f2(0,x1(k),x2(k),par,ipar,phi)
            w=1.0d0/(wy2(k)*wy2(k)+sign(fec2*fec2,fec2))
            do i=1,npar
              aux(i)=f2(i,x1(k),x2(k),par,ipar,phi)
            enddo
            call incne(a,b,aux,npar,r,w)
          endif
        enddo
C
        call scaler(a,b,scale,npar)
        call dppco(a,npar,rcond,aux,ierr)
        if (ierr.ne.0) goto 200
        call dppsl(a,b,npar)
        call dppin(a,npar)
        call unscaler(a,b,scale,npar)
C
        iagain=0
        nxpnt=0
        do i=1,npar
          nxpnt=nxpnt+i
          div=dsqrt(a(nxpnt))
          if (div.lt.dsqrt(eps)) div=dmax1(b(i)*10.0d0/tol,10.0d0/tol)
          if (dabs(b(i)/div).gt.tol) iagain=1
          par(i)=par(i)+b(i)
        enddo
C
        if (iagain.eq.0.or.ntry.lt.0) goto 101
      enddo
C
      ierr=-2
      goto 102
C
101   continue
      ierr=itry
C
102   continue
      nxpnt=0
      do i=1,npar
        nxpnt=nxpnt+i
        epar(i)=dsqrt(a(nxpnt))
        div=1.0d0
        if (scale(i).gt.1d-16) div=1.0d0/scale(i)
        scale(i)=epar(i)*div
      enddo
C
      sq=0.0d0
      sq1=0.0d0
      sq2=0.0d0
      do 120 i=1,npts
        r1=y1(i)-f1(0,x1(i),x2(i),par,ipar,phi)
        r2=y2(i)-f2(0,x1(i),x2(i),par,ipar,phi)
        y1r(i)=r1
        y2r(i)=r2
        if (.not.kbit(luse,i)) goto 120
        if(and(iflags,1).eq.1) then
           coslt=cos(x2(i))
           wyt1=1.0/(wy1(i)*wy1(i)
     +          +sign(fec1*fec1/(coslt*coslt),fec1))
        else
           wyt1=1.0/(wy1(i)*wy1(i)+sign(fec1*fec1,fec1))
        endif
        wyt2=1.0/(wy2(i)*wy2(i)+sign(fec2*fec2,fec2))
        sq=sq+r1*r1*wyt1+r2*r2*wyt2
        sq1=sq1+r1*r1*wyt1
        sq2=sq2+r2*r2*wyt2
120   continue
C
      iapar=0
      do i=1,npar
         if (ipar(i).ne.0.and.scale(i).gt.0.01d0) iapar=iapar+1
      enddo
C
      nfree=2*igp-iapar
      if (nfree.le.0) return
C
      rchi=dsqrt(sq/nfree)
      r1nr=dsqrt(sq1/igp)
      r2nr=dsqrt(sq2/igp)
      nxpnt=0
      do i=1,npar
        nxpnt=nxpnt+i
        epar(i)=rchi*epar(i)
      enddo
      return
C
200   continue
      ierr=-1
C
      return
      end
