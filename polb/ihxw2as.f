      FUNCTION IHXW2AS(IN,IOUT,IC,NC)
      character*16 lhex
      data lhex/'0123456789abcdef'/
c
      ins=in
      DO I=NC,1,-1
        iv=and(ins,15)        
        call char2hol(lhex(iv+1:iv+1),iout,ic+i-1,ic+i-1)
        ins=ishft(ins,-4)
      enddo
      do i=ic,ic+nc-2
         if(ichcm_ch(iout,i,"0").ne.0) return
         idum=ichmv_ch(iout,i," ")
      enddo
      
      IHXW2AS=IC+NC   
      RETURN
      END
