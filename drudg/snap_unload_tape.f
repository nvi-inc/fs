      subroutine snap_unload_tape(itime_vec,iRecNum,ntape,
     >   kpostpass,kcontpass,kcont)
! do end of tape housework
!
      implicit none
      include 'hardware.ftni'
! passed
      integer itime_vec(5)      !end of last obs
      integer iRecNum           !Recorder number
      integer ntape             !for kk4

      logical kpostpass         !postpass the tape?
      logical kcontpass         !was the last pass continuous?
      logical kcont

! function
      real Tspin,Fspin

! local variables.
      real tspins       !time to spin tape
      integer Ispm      !minutes to spin tape
      real sps          !seconds to spin tape.
      integer iwait5sec !wait 5 seconds
      data iwait5sec/5/

      IF (.not.km5.and..not.ks2.and..not.kk4) then ! postpass/spin off
        if (krunning) Then   !stop it first
            call snap_et()
        endif
        if (MaxTapeLen.gt.10000.and.kpostpass) THEN ! postpass last thin tape
          if (iftold.lt.200.and.kcontpass) then ! tape is near BOT and the
!                    last pass was continuous, so don't need to postpass
          else ! postpass
            TSPINS = FSPIN(MaxTapeLen-IFTOLD,ISPM,SPS)
            call snap_fast(isupfstfor,ISPM,SPS,iRecNum)   	!fast forward
            call snap_wait_sec(iwait5sec)
            TSPINS = FSPIN(MaxTapeLen,ISPM,SPS)
            call snap_fast(isupfstrev,ISPM,SPS,irecNum) 	!super fast reverse,
          endif
        else if (iftold.gt.50) then! spin off last tape
          TSPINS = TSPIN(IFTOLD,ISPM,SPS)
          call snap_fast(ifstrev,ISPM,SPS,iRecNum)                     !fast reverse,
        endif ! thin/thick
      endif ! postpass/spinoff

      if (ks2.and.krunning) then ! shut it down
        call snap_et()
      endif ! shut it down

      call snap_unlod(ntape)
      krunning=.false.

      return
      end

