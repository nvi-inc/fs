      subroutine fit2(x,y,f,npts,par,epar,
     +  aux,scale,a,b,npar,tol,ntry,rchi,nfree,ierr,rcond)
      implicit none
C
C     LEAST SQUARES FITTING ROUTINE...FITS TO FUNCTION F
C     WHICH MUST BE DECLARED EXTERNAL IN THE CALLING ROUTINE.
C
C          THIS ROUTINE FITS DATA IN Y TO FUNCTIONS F
C          ON THE INDEPENDENT VARIABLES X
C
C     PARAMETERS WILL BE RETURNED IN PAR, WHICH SHOULD CONTAIN FIRST
C     GUESSES TO START.  ERRORS ARE RETURNED IN EPAR.
C
C     WEH 831101
C
      double precision x(1),y(1)
      double precision par(1),epar(1)
      double precision a(1),b(1),aux(1),scale(1)
      double precision sq,r,eps,w,div,rchi,av
      real rcond,tol
      integer i,iagain,nxpnt,itry,ierr,npar,npts,ntry,nfree,k
C
      external f
      double precision f
C
C DIMENSION X(NPTS),Y(NPTS)
C DIMENSION PAR(NPAR),EPAR(NPAR),AUX1(NPAR),AUX2(NPAR),SCAL(NPAR)
C DIMENSION A(NPAR*(NPAR+1)/2),B(NPAR)
C
      data eps/1d-10/,w/1.0/
C
      rchi=0.
      nfree=0
      rcond=0.0
C
      do i=1,npar
        epar(i)=0.0d0
        scale(i)=0.0d0
      enddo
C
      do itry=1,ntry
        call inine(a,b,npar)
C
        do k=1,npts
	  r=y(k)-f(0,x(k),par,npar)
          do i=1,npar
            aux(i)=f(i,x(k),par,npar)
          enddo
          call incne(a,b,aux,npar,r,w)
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
        if (iagain.eq.0) goto 101
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
      av=0.0d0
      sq=0.0d0
      do i=1,npts
        r=y(i)-f(0,x(i),par,npar)
        av=av+r
        sq=sq+r*r
      enddo
C
      av=av/npts
      sq=sqrt(abs(sq/npts-av*av))
C
      nfree=npts-npar
      if (nfree.le.0) return
C
      rchi=sq*sqrt(float(npts)/float(nfree))

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
