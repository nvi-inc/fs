      subroutine snap_ready(ntape)
! write out ready commands
      implicit none
      include 'hardware.ftni'
      integer ntape
! local
      character*7 lprefix
      integer nch

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
        if(km5_piggyback)  write(luFile,'(a)') 'ready_disc'
      else if(kk4) then
        nch=nch+1
        lprefix(nch:nch)="="
        if(ntape .le. 9) then
          write(lufile, '(a,i1)') lprefix(1:nch),ntape
         else if(ntape .le. 99) then
           write(lufile,'(a,i2)') lprefix(1:nch),ntape
         else if(ntape .le. 999) then
           write(lufile,'(a,i3)') lprefix(1:nch),ntape
         endif
      else
        write(lufile,'(a)') lprefix(1:nch)
      endif
      return
      end
