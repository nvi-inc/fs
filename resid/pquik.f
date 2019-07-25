      subroutine pquik(iwds,x,y,npts,iwidx,iwidy,
     +                 ixmin,ixmax,iymin,iymax,
     +                 xmin,xmax,ymin,ymax,
     +                 idcb,lut,iobuf,lst,ilabel,ich,
     +                 istrh,listrh,istrv,listrv)
C
      character*(*) iobuf
      integer*2 ilabel(1)
      real x(1),y(1)
      real xmin, ymin, xmax, ymax
      integer*2 ibuf(3072),istr(40)
C
      if (abs(xmin-xmax).lt.1d-6)
     +   call pscal(x,npts,xmin,xmax)
C
      if (abs(ymin-ymax).lt.1d-6)
     +   call pscal(y,npts,ymin,ymax)
C 
      call psetp(iwds,iwidx,iwidy) 
      call pwipe(ibuf)
      call pseto(ixmin,ixmax,iymin,iymax)
      call pbrdr(ibuf)
      call psetv(xmin, xmax, ymin, ymax)
C
      do i=1,npts
        call pplpt(ibuf,x(i),y(i))
      enddo
C
      if (ich.le.0) goto 100
      ichi=min0(iwidx,max0(1,ich))
      ist=(iwidx-ichi)/2+1
      call ppstr(ibuf,ist,iwidy,ilabel,ichi)
      ilen=max0(listrh,listrv)
C
      inext=1
      inext=ichmv_ch(istr,inext,'vert: ')
      inext=ichmv(istr,inext,istrv,1,listrv)
      ifl=ilen-listrv
      if (ifl.gt.0) then
        call ifill_ch(istr,inext,ifl,' ')
        inext=inext+ifl
      endif
      inext=inext+ir2as(ymin,istr,inext,-10,5)
      inext=ichmv_ch(istr,inext,' to ')
      inext=inext+ir2as(ymax,istr,inext,-10,5)
      ichi=min0(iwidx,max0(1,inext-1))
      ist=(iwidx-ichi)/2+1
      call ppstr(ibuf,ist,3,istr,ichi)
C
      inext=1
      inext=ichmv_ch(istr,inext,'horz: ')
      inext=ichmv(istr,inext,istrh,1,listrh)
      ifl=ilen-listrh
      if (ifl.gt.0) then
        call ifill_ch(istr,inext,ifl,' ')
        inext=inext+ifl
      endif
      inext=inext+ir2as(xmin,istr,inext,-10,5)
      inext=ichmv_ch(istr,inext,' to ')
      inext=inext+ir2as(xmax,istr,inext,-10,5)
      ichi=min0(iwidx,max0(1,inext-1))
      ist=(iwidx-ichi)/2+1
      call ppstr(ibuf,ist,2,istr,ichi)
C
      call char2hol(' 1',ichr,1,2)
      call pppnt(ibuf,1,iwidy,ichr)
100   continue
      call pfrme(ibuf,lut,idcb,iobuf,lst)
C
      return
      end
