      subroutine snap_ready(ntape)
! write out ready commands
      implicit none
      include 'hardware.ftni'
      integer ntape
! local
      character*7 lprefix
      integer nch
      character*40 ldum

      lprefix="ready"             !lprefix:   readyX=    , where "= and "X" is optional
      if(krec_append) then
        lprefix(6:6)=crec(irec)
        nch=6
      else
        nch=5
      endif

      if(.not.km5) then
        ntape=ntape+1
      endif

      if(km5) then
        write(luFile,'(a)') 'ready_disc'
      else if(kk4) then
        nch=nch+1
        lprefix(nch:nch)="="
        write(ldum,'(a,i3)') lprefix(1:nch),ntape
        call squeezewrite(lufile,ldum)
      else
        write(lufile,'(a)') lprefix(1:nch)
      endif
      if(km5A_piggy .or. km5P_piggy)  write(luFile,'(a)') 'ready_disc'

      return
      end
