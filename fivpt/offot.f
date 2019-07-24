      subroutine offot(lonpos,latpos,lonoff,latoff,ilon,ilat,lbuf,
     +                 isbuf)
      real lonpos,latpos,lonoff,latoff
      integer*2 lbuf(1)
C
       include '../include/fscom.i'
C
      icnext=1
      icnext=ichmv(lbuf,1,8Hoffset  ,1,7)
C
      icnext=icnext+jr2as(lonpos*180.0/pi,lbuf,icnext,-9,4,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)  
C 
      icnext=icnext+jr2as(latpos*180.0/pi,lbuf,icnext,-9,4,isbuf)     
      icnext=ichmv(lbuf,icnext,2H  ,1,1)  
C 
      icnext=icnext+jr2as(lonoff*180.0/pi,lbuf,icnext,-9,5,isbuf)     
      icnext=ichmv(lbuf,icnext,2H  ,1,1)  
C
      icnext=icnext+jr2as(latoff*180.0/pi,lbuf,icnext,-9,5,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+ib2as(ilon,lbuf,icnext,2)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+ib2as(ilat,lbuf,icnext,2)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1)
      call logit2(lbuf,nchars)

      return
      end
