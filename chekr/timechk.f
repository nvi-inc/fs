      subroutine timechk(ierror,ierr)

      integer ierror, ierr

C  LOCAL VARIABLES

      integer*4 secs_fm,secs_bef,secs_aft,diff_bef,diff_aft
      integer*4 centisec(2)
      integer it(6),rn_take,fc_get_vtime
      integer ip(5)
C     TIMTOL - tolerance on comparison between formatter and HP 
      integer*4 timtol,diff_both
C
C  INITIALIZED:
C
      data timtol/100/
C                   time tolerance in centi-seconds
C
C
      call rmpar(ip)
      nerr = 0
c
50    continue
      iold=rn_take('fsctl',0)
      idum=fc_get_vtime(centisec,it,ip,0)
      call rn_put('fsctl')
      if (ip(3).lt.0) then
         nerr=nerr+1
         if(nerr.le.3) goto 50
         ierr=-1
         return
      endif
C
      call fc_rte2secs(it,secs_fm)
      if(secs_fm.lt.0) then
        nerr=nerr+1
        if(nerr.gt.2) then
          ierr = -1
          return
        endif
        goto 50
      endif
      call fc_rte_fixt(secs_bef,centisec(1))
      call fc_rte_fixt(secs_aft,centisec(2))
C
C*****************THE REAL THING*******************
C
      diff_bef=(secs_fm-secs_bef)*100+it(1)-centisec(1)
      diff_aft=(secs_aft-secs_fm)*100+centisec(2)-it(1)
C
      diff_both=diff_aft+diff_bef

      if(diff_both.gt.2*timtol) then
        ierror = -328
      else if(diff_bef.lt.-timtol.or.diff_aft.lt.-timtol) then
        ierror = -329
      endif
C
      return
      end
