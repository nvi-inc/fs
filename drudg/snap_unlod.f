      subroutine snap_unlod(ntape)
! write out unlod command
      implicit none
      include 'hardware.ftni'
      integer ntape
! local
      character*7 lprefix
      integer nch

      if(km5) return

      lprefix="unlod"             !lprefix:   unlodX=    , where "= and "X" is optional
      if(krec_append) then
        lprefix(6:6)=crec(irec)
        nch=6
      else
        nch=5
      endif

      if(kk4) then
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
