      function ickft(ibrk,inewft,icurft,idir,ip)
C  check footage status   .c#870115:04:34# 
C 
C    READ FOOTAGE COUNTER AND RETURN REMAINING FEET TO GO.
C 
      integer*2 ibuf(10)
      dimension ip(5)
      dimension ireg(2)
      integer get_buf
      data ilen/20/ 
C 
      ibrk = 1
cxx      if(ifbrk(idum).lt.0) return 
      ibrk = 0  
cxx      call susp(1,50)   
      call susp(2,1)   
      ibuf(1) = -3
      call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ') 
      call run_matcn(iclass,1) 
      call rmpar(ip)
      iclass = ip(1)
89    format("iclass, ip ",6i10)
      if (ip(3).ge.0) goto 150
        call clrcl(iclass)
        ip(1) = 0 
        ip(2) = 0 
        goto 990
150   ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum) 
      icurft = ias2b(ibuf,7,4)
      if(icurft.gt.10000) icurft = icurft - 20000 
      ickft = icurft - inewft 
      if(idir.eq.0.and.ickft.lt.0) ickft = 0
      if(idir.eq.1.and.ickft.gt.0) ickft = 0
      ickft = iabs(ickft) 
990   return
      end 
