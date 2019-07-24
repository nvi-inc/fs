      subroutine unget(jbuf,ierr,len)
C
      integer leng, ierrg
      integer*2 jbufg(100)
      logical kgot
      common/got/leng,ierrg,jbufg,kgot
C
      integer*2 jbuf(1)
C
      if (kgot) stop 
C 
      kgot=.true. 
      leng=len
      ierrg=ierr
      do i=1,min0(leng,100)
        jbufg(i)=jbuf(i) 
      enddo
C
      return
      end 
