      subroutine timechk(ierror,ierr)

      integer ierror, ierr

C  LOCAL VARIABLES

      integer*4 secs_fm,secs_bef,secs_aft,diff_bef,diff_aft
      integer itm(13),it(6)
      integer ip(5)
C     TIMTOL - tolerance on comparison between formatter and HP 
      integer*4 timtol,timchk,diff_both
C
C  INITIALIZED:
C
      data timtol/200/
C                   time tolerance in centi-seconds
C
C
      call rmpar(ip)
      nerr = 0
c
50    continue
      call fc_get_vtime(itm(1),itm(7),it,ip)
      if (ip(3).lt.0) then
         nerr=nerr+1
         if(nerr.le.3) goto 50
         ierr=-1
         return
      endif
C
      call rte2secs(it,secs_fm)
      if(secs_fm.lt.0) then
        nerr=nerr+1
        if(nerr.gt.2) then
          ierr = -1
          return
        endif
        goto 50
      endif
      call rte2secs(itm,secs_bef)
      if(secs_bef.lt.0) then
        nerr=nerr+1
        if(nerr.gt.2) then
          ierr = -1
          return
        endif
        goto 50
      endif
      call rte2secs(itm(7),secs_aft)
      if(secs_aft.lt.0) then
        nerr=nerr+1
        if(nerr.gt.2) then
          ierr = -1
          return
        endif
        goto 50
      endif
C
C*****************THE REAL THING*******************
C
C     diff_bef=abs((secs_fm-secs_bef)*100+it(1)-itm(1))
      diff_aft=abs((secs_fm-secs_aft)*100+it(1)-itm(7))
C
      diff_both=abs(diff_aft-diff_bef)
      timchk=timtol

      if(diff_both.gt.2*timchk) then
        ierror = -328
      else if(diff_bef.gt.timchk.or.diff_aft.gt.timchk) then
        ierror = -329
      endif
C
      return
      end
