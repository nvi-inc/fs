      subroutine prfot(stoc,sefd,ae,aedts,lbuf,isbuf)
      real stoc,sefd,ae,aedts
      integer*2 lbuf(1)
C
       include '../include/fscom.i'
C
      icnext=1
      icnext=ichmv_ch(lbuf,1,'perform ')
C
      icnext=icnext+jr2as(stoc,lbuf,icnext,-8,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(sefd,lbuf,icnext,-7,1,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(ae,lbuf,icnext,-8,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      icnext=icnext+jr2as(aedts,lbuf,icnext,-8,3,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ')
      call logit2(lbuf,nchars)

      return
      end
