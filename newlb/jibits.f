      integer*4 function jibits(ibuf,start,len)
      implicit none
      integer*4 ibuf,start,len
c
      jibits=and(rshift(ibuf,start),rshift(not(0),32-len))
c
      return
      end
