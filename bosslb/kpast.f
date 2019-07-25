      logical function kpast(it1,it2,it3,it)
C
C     KPAST determines if the time IT1,IT2,IT3 (FS format)
C           is in the past compared to IT (HP format).
C     If IT(1)=0 then it is assumed IT should be the current time.
C
      dimension it(1)
      double precision tnow,t1
      logical know
C
      know=it(5).eq.0
1     continue
      if (know) call fc_rte_time(it,idum)
C         Get the current time
      tnow = 86400.d0*it(5)+it(4)*3600.d0+it(3)*60.d0
     .       +it(2) + it(1)/100.d0
      t1 = 86400.d0*mod(it1,1024) + it2*60.d0 + it3/100.d0
C
      if(know) then
        kpast = t1 .lt. tnow+0.025d0
        if(kpast.and.t1.gt.tnow+.005d0) then
          call susp(1,1)
          go to 1
        endif
      else
        kpast = t1 .lt. tnow
      endif
C
      return
      end
