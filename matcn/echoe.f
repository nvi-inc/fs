      subroutine echoe(inbuf,iebuf,inchar,outchar,maxout)
      implicit none
      integer*2 inbuf(1)
      integer iebuf(1),inchar,outchar,maxout,ifcin,ifcout
C
      character*3 exp(0:31)
      character*6 cobuf
      integer inext,i,idum,ilen,iobuf(3),trimlen
      integer ich,jchar,ichmv
      equivalence (cobuf,iobuf(1))
      data exp/'nul','soh','stx','etx','eot','enq','ack','bel',
     &         'bs ','ht ','lf ','vt ','ff ','cr ','so ','si ',
     &         'dle','dc1','dc2','dc3','dc4','nak','syn','etb',
     &         'can','em ','sub','esc','fs ','gs ','rs ','us '/
C
      inext=1
      do i=1,inchar 
      ich = jchar(inbuf,i)
        ich=iand(jchar(inbuf,i),o'000177')
        if(ich.gt.31.and.ich.ne.127) then
          idum=ichmv(iobuf,1,inbuf,i,1)
          ilen=1
        else if(ich.lt.32) then
          ilen=max(trimlen(exp(ich)),1)
          cobuf='['//exp(ich)(1:ilen)//']'
          ilen=ilen+2
        else
          cobuf='[del]'
          ilen=5
        endif
        if(ilen+inext-1.lt.maxout) then
          inext=ichmv(iebuf,inext,iobuf,1,ilen)
        endif
      enddo
      outchar=inext-1
C
      return
      end
