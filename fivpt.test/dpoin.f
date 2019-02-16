      subroutine dpoin(lmess,i,tim,off,temp,sig,np,lbuf,isbuf) 
      integer*2 lbuf(1)
      character*(*) lmess
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,lmess)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+ib2as(i,lbuf,icnext,3)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(tim,lbuf,icnext,-7,0,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      icnext=icnext+jr2as(off*180./RPI,lbuf,icnext,-8,4,isbuf)   
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(temp,lbuf,icnext,-8,3,isbuf)  
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
      if (np.le.1) goto 100 
      icnext=icnext+jr2as(sig,lbuf,icnext,-6,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
100   continue
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ')
      call logit2(lbuf,nchars)

      return
      end
