      subroutine unload_tape(
     >   itime_vec, crec_use,iRecNum,ntape,
     >   itime2stop,kpostpass,kcontpass,kcont)
! do end of tape housework
!
      implicit none
      include 'recorder.ftni'
! passed
      integer itime_vec(5)      !end of last obs
      character*1 crec_use      !the number "1","2", etc.
      integer iRecNum           !Recorder number
      integer ntape             !for kk4
      logical krunning          !was the tape moving on entry
      integer itime2stop        !how long does it take the tape to stop
      logical kpostpass         !postpass the tape?
      logical kcontpass         !was the last pass continuous?
      logical kcont

! function
      real Tspin,Fspin
      integer ichmv_ch,ib2as

! local variables.
      integer isupfstfor,ifstfor,ifstrev,isupfstrev             !Fast Forward, reverse settings.
      parameter (isupfstfor=2,ifstfor=1,ifstrev=-1,isupfstrev=-2)

      integer ibuf2(50)
      integer iblen/100/
      integer iwait5sec/5/      !wait 5 seconds
      integer nch

! more local
      real tspins       !time to spin tape
      integer Ispm      !minutes to spin tape
      real sps          !seconds to spin tape.
      logical kerr

      IF (.not.km5.and..not.ks2.and..not.kk4) then ! postpass/spin off
        if (krunning) Then   !stop it first
            call cmd_et(luFile,krec_append,crec_use,itime2Stop,kerr)
            krunning=.false.
        endif
        if (MaxTapeLen.gt.10000.and.kpostpass) THEN ! postpass last thin tape
          if (iftold.lt.200.and.kcontpass) then ! tape is near BOT and the
C                    last pass was continuous, so don't need to postpass
          else ! postpass
            TSPINS = FSPIN(MaxTapeLen-IFTOLD,ISPM,SPS)
            call cmd_fast(luFile,isupfstfor,ISPM,SPS,                !fast forward
     >                crec_use,iRecNum,krec_append)
            call cmd_wait(luFile,iwait5sec)
            TSPINS = FSPIN(MaxTapeLen,ISPM,SPS)
            call cmd_fast(luFile,isupfstrev,ISPM,SPS,                !super fast reverse,
     >                crec_use,iRecNum,krec_append)
          endif
        else if (iftold.gt.50) then! spin off last tape
          TSPINS = TSPIN(IFTOLD,ISPM,SPS)
          call cmd_fast(luFile,ifstrev,ISPM,SPS,                     !fast reverse,
     >                crec_use,iRecNum,krec_append)
        endif ! thin/thick
      endif ! postpass/spinoff

      if (ks2.and.krunning) then ! shut it down
        call cmd_time(luFile,itime_vec)
        call cmd_et(luFile,krec_append,crec_use,itime2Stop,kerr)
      endif ! shut it down

      if (.not.km5) then ! tape
        CALL IFILL(IBUF2,1,iblen,32)
        nch = ichmv_ch(IBUF2,1,'unlod')
        if (krec_append      ) nch = ichmv_ch(ibuf2,nch,crec_use) ! unload the current tape
        if (kk4) then ! append tape number
          nch = ichmv_ch(ibuf2,nch,'=')
          nch = nch + ib2as(ntape,ibuf2,nch,1)
        endif
        call writf_asc(luFile,KERR,IBUF2,(nch+1)/2)
      endif ! tape

      return
      end

