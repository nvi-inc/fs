      logical function kpast(it1,it2,it3,it)
C
C     KPAST determines if the time IT1,IT2,IT3 (FS format)
C           is in the past compared to IT (HP format).
C     If IT(5)=0 then it is assumed IT should be the current time.
C
      integer it(6)
      integer itt(6)
      integer*4 secst,secsnow,delta
      logical know
C
      know=it(5).eq.0
1     continue
      if (know) call fc_rte_time(it,it(6))
C         Get the current time
c not Y2038 compliant
      call fc_rte2secs(it,secsnow)
      if(secsnow.lt.0) call logit7ci(0,0,0,1,-258,'bo',0)
      ihsnow=it(1)
c
      itt(6)=it1/1024+1970
      itt(5)=mod(it1,1024)
      itt(4)=it2/60
      itt(3)=mod(it2,60)
      itt(2)=it3/100
      itt(1)=mod(it3,100)
c not Y2038 compliant
      call fc_rte2secs(itt,secst)
      if(secst.lt.0) call logit7ci(0,0,0,1,-259,'bo',0)
      ihst=itt(1)
c
c not Y2038 compliant
      delta=(secst-secsnow)*100+ihs1-ihsnow
c
      if(know) then
        kpast = delta.le.2 
        if(kpast.and.delta.gt.0) then
          call susp(1,1)
          go to 1
        endif
      else
        kpast = delta .le. 0
      endif
C
      return
      end

