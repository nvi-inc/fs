      function jr2as(re,lbuf,icn,it,id,isbuf)
      integer*2 lbuf(1)
C
      jr2as=ir2as(re,lbuf,icn,it,id)
      if (.not.jchar(lbuf,icn).eq.36) return
      ita=min0(iabs(it)+iabs(id)+1,isbuf*2-icn+1)
      jr2as=ir2as(re,lbuf,icn,ita,id)
      jr2as=iabs(it)

      return
      end
