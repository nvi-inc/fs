      subroutine snap_unload_tape(luscn,itime_tape_stop,
     >   itime_tape_stop_spin,itime_tape_need,iRecNum,ntape,
     >   kpostpass,kcontpass,kcont,klast_tape)
! do end of tape housework
!
      implicit none
      include 'hardware.ftni'
! funciton
      integer itimeDifSec
      real Tspin,Fspin
! passed
      integer luscn                 !
      integer itime_tape_stop(5)    !time tape stopped moving (on previous obs)
      integer itime_tape_stop_spin(5)   !time tape stops moving after spinning
      integer itime_tape_need(5)        !time we need the tape.

      integer iRecNum           !Recorder number
      integer ntape             !for kk4

      logical kpostpass         !postpass the tape?
      logical kcontpass         !was the last pass continuous?
      logical kcont             ! continuous tape.
      logical klast_tape        !on the last pass? Don't do any time checking.

! local variables.
      real tspin_for    !time to spin forward
      integer ispm_for  !minutes to spin tape
      real sps_for      !seconds to spin tape.

      real tspin_rev    !time to spin forward
      integer ispm_rev  !minutes to spin tape
      real sps_rev      !seconds to spin tape.
      integer idt       !difference in times.

      integer iwait5sec !wait 5 seconds

      iwait5sec=5

! stop the tape if necessary.
      if(.not. (km5 .or. kk4)) then
        if(krunning) call snap_et()
      endif ! shut it down

!      itime_tape_stop_spin=itime_tape_stop      !default is no time for spin down.
      call TimeAdd(itime_tape_stop,0,itime_tape_stop_spin)
      if(km5 .or. ks2 .or. kk4) goto 500        !this goes to unload tape.

! In principle need to postpass.
      if (MaxTapeLen.gt.10000.and.kpostpass .and. .not. kcont) then
! But if tape is near the bottom and the last pass is continuous, just spin off.
        if (iftold.lt.200.and.kcontpass) goto 400
        tspin_for = FSPIN(MaxTapeLen-IFTOLD,ISPM_for,SPS_for)
        tspin_rev = FSPIN(MaxTapeLen,       ISPM_rev,SPS_rev)

! Calculate time it takes to do the prepass with 5 second pause between.
        call TimeAdd(itime_tape_stop,
     >        nint(tspin_for+tspin_rev+5.),itime_tape_stop_spin)
 !if a tape change in the middle of the experiment, check that we have time for prepass.
        if(.not. klast_tape) then
           idt=iTimeDifSec(iTime_tape_stop_spin,iTime_tape_need)!tape_stop-tape_need. Should be negative.
           if(idt .gt. 10) then  !strictly speaking, idt should be <0. But 10 secs probably won't hurt.
              write(luscn,'(a)')
     >        "SNAP_UNLOAD_TAPE: Warning! no time for postpass"
              write(luscn,'(a,$)') "Post pass ends at:       "
              call snap_wait_time(luscn,itime_tape_stop_spin)
              write(luscn,'(a,$)') "And we need the tape at: "
              call snap_wait_time(luscn,itime_tape_need)
              write(luscn,'(a)') "Postpass not done. "
              call TimeAdd(itime_tape_stop,0,itime_tape_stop_spin)
!             itime_tape_stop_spin=itime_tape_stop  	!restore time since no spin.
              goto 400              			!no time for prepass.
           endif
        endif

! everything is ok for postpass. Do it.
        call snap_fast(isupfstfor,ISPM_for,SPS_for,iRecNum)  	!fast forward
        call snap_wait_sec(iwait5sec)
        call snap_fast(isupfstrev,ISPM_rev,SPS_rev,irecNum) 	!super fast reverse,
        goto 500                                                !go to unload tape.
      endif ! postpass/spinoff

! come here to spin off tape.
400   continue
      if (iftold.gt.50) then! spin off last tape
       tspin_rev = TSPIN(IFTOLD,ISPM_rev,SPS_rev)
       call snap_fast(ifstrev,ISPM_rev,SPS_rev,iRecNum)              !fast reverse,
       call TimeAdd(itime_tape_stop,int(tspin_rev),itime_tape_stop_spin)
      endif

500   continue
      call snap_unlod(ntape)
      krunning=.false.
      return
      end

