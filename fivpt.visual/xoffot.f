      subroutine xoffot(lonpos,latpos,lonoff,latoff,ilon,ilat,
     +     elnsig,eltsig, lbuf,isbuf)
      real lonpos,latpos,lonoff,latoff,elnsig,eltsig
      integer*2 lbuf(1)
C
       include '../include/fscom.i'
       include '../include/dpi.i'
C
      icnext=1
      icnext=ichmv_ch(lbuf,1,'xoffset ')
C
      icnext=icnext+jr2as(lonpos*180.0/RPI,lbuf,icnext,-9,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      icnext=icnext+jr2as(latpos*180.0/RPI,lbuf,icnext,-9,4,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      icnext=icnext+jr2as(cos(latpos)*lonoff*180.0/RPI,lbuf,icnext,
     &     -9,5,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C
      icnext=icnext+jr2as(latoff*180.0/RPI,lbuf,icnext,-9,5,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(cos(latpos)*elnsig*180.0/RPI,lbuf,icnext,
     &     -8,5,isbuf)     
      icnext=ichmv_ch(lbuf,icnext,' ')  
C
      icnext=icnext+jr2as(eltsig*180.0/RPI,lbuf,icnext,-8,5,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+ib2as(ilon,lbuf,icnext,1)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+ib2as(ilat,lbuf,icnext,1)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ')
      call logit2(lbuf,nchars)

      return
      end
