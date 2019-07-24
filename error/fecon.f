      subroutine fecon(feclon,feclat,lonoff,wln,latoff,wlt,npts,luse,
     &                 emnln,emnlt)
      real lonoff(npts),latoff(npts)
      double precision lonsum,latsum,di,dim1di
      real wln(npts),wlt(npts)
      logical kbit
      include '../include/dpi.i'
C
      flon1=-emnln
      flat1=-emnlt
      flon2=max(+2.0*deg2rad,2.0d0*emnln)
      flat2=max(+2.0*deg2rad,2.0d0*emnlt)
C
      do itry=1,64
        feclon=flon1+.5*(flon2-flon1)
        feclat=flat1+.5*(flat2-flat1)
C
        lonsum=0.0d0
        latsum=0.0d0
        ipts=0
C
        do 210 i=1,npts
C
          if (.not.kbit(luse,i)) goto 210
          ipts=ipts+1
          dim1di=dble(float(ipts-1))/dble(float(ipts))
          di=1.0d0/dble(float(ipts))
          lonsum=lonsum*dim1di+((lonoff(i)*lonoff(i))/
     +       (wln(i)*wln(i)+sign(feclon*feclon,feclon)))*di
          latsum=latsum*dim1di+((latoff(i)*latoff(i))/
     +       (wlt(i)*wlt(i)+sign(feclat*feclat,feclat)))*di
210     continue
C
        lonsum=dsqrt(lonsum)
        latsum=dsqrt(latsum)
C
        if (dabs(lonsum-1.0d0).lt.0.001.and.
     +     dabs(latsum-1.0d0).lt.0.001) goto 510
        if (lonsum.gt.1.0d0) flon1=feclon
        if (lonsum.lt.1.0d0) flon2=feclon
        if (latsum.gt.1.0d0) flat1=feclat
        if (latsum.lt.1.0d0) flat2=feclat
      enddo
C
      feclon=0.0
      feclat=0.0
C
510   continue
      return
      end
