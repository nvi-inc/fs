      subroutine snap_start_recording
      implicit none
      include 'hardware.ftni'

      character*5 lmid          !for, or rev
      character*3 lpre          !st, or st1
      integer npre

      if(krunning) return
      lpre="st"
      if(krec_append) then
        lpre(3:3)=crec(irec)
        npre=3
      else
        npre=2
      endif

      if(km5) then
        write(luFile,'(a)') 'disc_start=on'
        if (km5_piggyback) write(luFile,'(a)') 'disc_start=on'
      else if(kk4) then
        write(luFile,"(a,'=record')") lpre(1:npre)       !stX=record, where X is optional "1" or "2"
      else
        if(idir .eq. 1) then
          lmid="=for,"
        else
          lmid="=rev,"
        endif
! lspeed ch is ascii version of speed, calculated in snap_calc_speed.
        write(luFile,'(a,a,a)') lpre(1:npre),lmid,lspeed(1:nspdCh)
      endif

      krunning=.true.           !turn on running flag.

      return
      end
