      subroutine reslt(cmes,imes2,nc2,az,el,avg1,avg2,sig1,sig2, 
     +                 np,lbuf,isbuf) 
      dimension imes2(1)
      integer*2 lbuf(1)
      character*(*) cmes
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,cmes) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=ichmv(lbuf,icnext,imes2,1,nc2) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(az*180./RPI,lbuf,icnext,-5,1,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(el*180./RPI,lbuf,icnext,-4,1,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(avg1,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(avg2,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      if (np.le.1) goto 100
      icnext=icnext+jr2as(sig1,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(sig2,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
100   continue
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 

      return
      end 
