      subroutine dpoin(lmess,mchars,i,tim,off,temp,sig,np,lbuf,isbuf) 
      integer*2 lmess(2),lbuf(1)
C 
       include '../include/fscom.i'
C 
      icnext=1
      icnext=ichmv(lbuf,icnext,lmess,1,mchars)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
      icnext=icnext+ib2as(i,lbuf,icnext,3)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
      icnext=icnext+jr2as(tim,lbuf,icnext,-7,0,isbuf) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)  
C 
      icnext=icnext+jr2as(off*180./pi,lbuf,icnext,-8,4,isbuf)   
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
      icnext=icnext+jr2as(temp,lbuf,icnext,-8,3,isbuf)  
      icnext=ichmv(lbuf,icnext,2H  ,1,1)  
C 
      if (np.le.1) goto 100 
      icnext=icnext+jr2as(sig,lbuf,icnext,-6,3,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
100   continue
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1)
      call logit2(lbuf,nchars)

      return
      end
