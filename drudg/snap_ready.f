      subroutine snap_ready(ntape,kfirst_tape)
! write out ready commands
      include 'hardware.ftni'
      integer ntape
! local
      character*7 lprefix
      integer nch
      character*40 ldum
      logical kfirst_tape

      lprefix="ready"             !lprefix:   readyX=    , where "= and "X" is optional
      if(krec_append) then
        lprefix(6:6)=crec(irec)
        nch=6
      else
        nch=5
      endif

      if(.not.km5disk) then
        ntape=ntape+1
      endif

      if((km5disk .or. km5a_piggy.or.km5p_piggy).and.kfirst_tape) then
        write(luFile,'(a)') 'ready_disk'
        kfirst_tape=.false.
      endif

      if(km5disk) then
         return              !don't need to do tape ready.
      else if(kk4) then
        nch=nch+1
        lprefix(nch:nch)="="
        write(ldum,'(a,i3)') lprefix(1:nch),ntape
        call squeezewrite(lufile,ldum)
      else
        write(lufile,'(a)') lprefix(1:nch)
      endif

      return
      end
