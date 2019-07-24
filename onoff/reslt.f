      subroutine reslt(imes,nc,imes2,nc2,az,el,avg1,avg2,sig1,sig2, 
     +                 np,lbuf,isbuf) 
      dimension imes(1),imes2(1)
      integer*2 lbuf(1)
C 
      include '../include/fscom.i'
C 
      icnext=1
      icnext=ichmv(lbuf,icnext,imes,1,nc) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
      icnext=ichmv(lbuf,icnext,imes2,1,nc2) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+jr2as(az*180./pi,lbuf,icnext,-5,1,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+jr2as(el*180./pi,lbuf,icnext,-4,1,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+jr2as(avg1,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+jr2as(avg2,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      if (np.le.1) goto 100
      icnext=icnext+jr2as(sig1,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
      icnext=icnext+jr2as(sig2,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
100   continue
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1) 
      call logit2(lbuf,nchars) 

      return
      end 
