      subroutine snap_start_recording(kin2net)
      implicit none
      include 'hardware.ftni'
      logical kin2net

      character*5 lmid          !for, or rev
      character*3 lpre          !st, or st1
      integer npre

      lpre="st"
      if(krec_append) then
        lpre(3:3)=crec(irec)
        npre=3
      else
        npre=2
      endif

      if(km5A.or.KM5P) then
        if(kin2net) then
            write(lufile,'(a)') "in2net=on"
        else
           write(luFile,'("disk_record=on")')
        endif
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
      if(km5A_piggy.or.km5P_piggy) write(luFile,'("disk_record=on")')

      krunning=.true.           !turn on running flag.

      return
      end
