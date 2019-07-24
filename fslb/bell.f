      subroutine bell(lui,ieb)  
      implicit none
      integer i,it,lui,ieb

      do 100 i=1,10 
        call put_cons_raw(2H ,1)
        if (ieb.eq.0) it=25-2*i 
        if (ieb.ne.0) it=5+2*i
        call susp(1,it) 
100   continue

      return
      end 
