      function ihx2a(inum)

C     CONVERT INUM TO A HEX CHARACTER, RETURNED IN LOWER BYTE 

cxx      dimension lhex(8) 
      character*16 lhex
      data lhex/'0123456789abcdef'/
C 
      ihx2a = 0 
      if (inum.lt.0.or.inum.gt.15) return 
      call char2hol(lhex(inum+1:inum+1),ihx2a,2,2)
cxx      ihx2a = jchar(lhex,inum+1)

      return
      end 
