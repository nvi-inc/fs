      subroutine matin(n,a,b,msignl)
C 
C     MATRIX INVERSION ROUTINE 5 PARAMETERS.
C 
      dimension a(5,5),b(5),pivot(5),ipivot(5),index(5,5) 
C 
      determ=1
      do j=1,n 
        ipivot(j)=0 
      enddo
      do 550 i=1,n
      amaxi=0.
      do 105 j=1,n
        if (ipivot(j).eq.1) goto 105
        do 100 k=1,n
          if (ipivot(k).eq.1) goto 100
          if (ipivot(k).gt.1) goto 730
          if (abs(amaxi).ge.abs(a(j,k))) goto 100 
          irow=j
          icolum=k
          amaxi=a(j,k)
100     continue
105   continue
C 
      ipivot(icolum)=ipivot(icolum)+1 
      if (irow.eq.icolum) goto 260
      determ=-determ
      do l=1,n
        swap=a(irow,l)
        a(irow,l)=a(icolum,l) 
        a(icolum,l)=swap
      enddo
      swap=b(irow)
      b(irow)=b(icolum) 
      b(icolum)=swap
260   index(i,1)=irow 
      index(i,2)=icolum 
      pivot(i)=a(icolum,icolum) 
      if (pivot(i).lt.1e-30) goto 710
320   det=determ*pivot(i) 
      if (det.ne.0.) goto 329 
      msignl=0
      determ=determ*1.0e16
      goto 320 
329   determ=det
      a(icolum,icolum)=1. 
      do l=1,n
        if(pivot(i).lt.abs(a(icolum,l))*1d-30) goto 710
        a(icolum,l)=a(icolum,l)/pivot(i)
      enddo
      b(icolum)=b(icolum)/pivot(i)
      do 550 l1=1,n 
      if (l1.eq.icolum) goto 550
      t=a(l1,icolum)
      a(l1,icolum)=0. 
      do l=1,n
        a(l1,l)=a(l1,l)-a(icolum,l)*t 
      enddo
      b(l1)=b(l1)-b(icolum)*t 
550   continue
C 
      do 709 i=1,n
        l=n+1-i 
        if (index(l,1).eq.index(l,2)) goto 709
        jrow=index(l,1) 
        jcolum=index(l,2) 
        do k=1,n
          swap=a(k,jrow)
          a(k,jrow)=a(k,jcolum) 
          a(k,jcolum)=swap
        enddo
709   continue
      msignl=-1 
      return
C
C     MIXED DIMENSIONS
730   msignl=2
      return
C
C     SINGULAR MATRIX 
710   msignl=1

      return
      end 
