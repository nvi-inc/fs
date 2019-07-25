      subroutine dpnt2(cmess,i,tim,aoff,boff,vlt,sig,np,lbuf,
     +                isbuf)
      dimension vlt(2),sig(2)
      character*(*) cmess
      integer*2 lbuf(1)
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,cmess)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+ib2as(i,lbuf,icnext,2)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(tim,lbuf,icnext,-6,0,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(aoff*180./RPI,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(boff*180./RPI,lbuf,icnext,-7,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(vlt(1),lbuf,icnext,-8,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(vlt(2),lbuf,icnext,-8,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      if (np.le.1) goto 100 
      icnext=icnext+jr2as(sig(1),lbuf,icnext,-5,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
      icnext=icnext+jr2as(sig(2),lbuf,icnext,-5,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
100   continue
      nchars=icnext-1 
      if(1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 

      return
      end 
