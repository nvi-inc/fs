      integer function jd2as(dv,lbuf,icn,it,id,isbuf)

      double precision dv
      integer*2 lbuf(1)
      integer icn,it,id,isbuf
      integer id2as
C
      jd2as=id2as(dv,lbuf,icn,it,id)
      if (.not.jchar(lbuf,icn).eq.36) return
      ita=min0(iabs(it)+iabs(id)+1,isbuf*2-icn+1)
      jd2as=id2as(dv,lbuf,icn,ita,id) 
      jd2as=iabs(it)

      return
      end 
