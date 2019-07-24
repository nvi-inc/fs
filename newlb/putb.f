      subroutine putb(ibuf,n,i) 
C 
C     ROUTINE TO SET/CLEAR BIT N IN ARRAY IBUF. 
C     LSB OF I SETS/CLEARS SPECIFIED BIT. HIGHER ORDER BITS IN I ARE IGNORED. 
C     FIRST BIT IN IBUF IS BIT #1.
C 
      integer*2 ibuf(1) 
      integer*2 j
C 
      nw=(n+15)/16
      ibit=mod(n-1,16)+1
      j=ibuf(nw)
      if (iand(i,1) .ne. 0) then
C     SET BIT 
        if(ibit.le.8) then
          ibuf(nw)=ibset(j,8-ibit)
        else
          ibuf(nw)=ibset(j,24-ibit)
        endif
      else 
        if(ibit.le.8) then
          ibuf(nw)=ibclr(j,8-ibit)
        else
          ibuf(nw)=ibclr(j,24-ibit)
        endif
      endif
C110  WRITE(16,105) N,I,NW,IBIT,IBUF(NW)
C105  FORMAT("N,I,NW,IBIT,IBUF(NW)=",4I6,O8)
      return
      end 
