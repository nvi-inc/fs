      PROGRAM quikr
C  quick response commands     <910330.0053>
C
C QUIKR is the root for all quick-response applications
C              functions in the Field System
C
C     INPUT VARIABLES:
C         IP(1) - class number containing invocation line
C         IP(2) - branch number, encoded
C
C     OUTPUT VARIABLES:
C         IP(1) - class number, if any
C         IP(2) - number of records in class
C         IP(3) - IERR error code return
C         IP(4) - who caused the error
C
C     COMMON BLOCKS USED
      include '../include/fscom.i'
C
C 3.  LOCAL VARIABLES
      integer*4 ip(5)                     !  rmpar variables
      integer idum,fc_rte_prior
C
C 6.  PROGRAMMERS: NRV (1980), LEF (1987), LAR (1988)
C  WHO  WHEN    DESCRIPTION
C  GAG  910116  Added calls to WEH's new tape head calibration routines.
C  GAG  910124  Removed callS to LOWHI and PARTN.
C  GAG  910205  Rejoined QUIK1 and QUIK2 into this one file.
C  gag  920715  Removed feet command and inserted form4 command.
C
C     PROGRAM STRUCTURE :
C  Get RMPAR parameters, then call the subroutine whose number is in IP(2).
C
      call setup_fscom
      call read_fscom
      idum=fc_rte_prior(FS_PRIOR)
1     continue
      call wait_prog('quikr',ip)
      call read_quikr
      isub = ip(2)/100
      itask = ip(2) - 100*isub
      if (isub.eq.1) then
        if (itask.eq.1) then
          call fm(ip)
        else if (itask.eq.2) then
          call form4(ip)
        endif
      else if (isub.eq.2) then
        call vc(ip,itask)
      else if (isub.eq.3) then
        if(itask.eq.1) then
          call ifd(ip)
        else if(itask.eq.2) then
          call if3(ip)
        endif
      else if (isub.eq.4) then
        if (itask.eq.1.or.itask.eq.8) then
          call ma(ip,itask)
        else if (itask.eq.2) then
          call ib(ip)
        else if (itask.eq.4) then
          call wx(ip)
        else if (itask.eq.5) then
          call wakop(ip)
        else if (itask.eq.6) then
          call chk(ip)
        else if (itask.eq.7) then
          call cal(ip)
        endif
      else if (isub.eq.5) then
        if (itask.eq.1) then
          call tp(ip)
        else if (itask.eq.2) then
          call tppos(ip)
        endif
      else if (isub.eq.6) then
        if (itask.eq.1) then
          call st(ip)
        else if (itask.eq.2) then
          call et(ip)
        else if (itask.ge.3.and.itask.le.6) then
          call rwff(ip,itask)
        else if (itask.eq.7) then
          call rec(ip)
        endif
      else if (isub.eq.7) then
        if (itask.eq.1) then
          call reset(ip)
        else if (itask.eq.2) then
          call newtp(ip)
        else if (itask.eq.3) then
          call label(ip)
        else if (itask.eq.4) then
          call matld(ip)
        end if
      else if (isub.eq.8) then
        call ena(ip)
      else if (isub.eq.9) then
        if (itask.eq.1) then
          call de(ip)
        else if (itask.eq.2) then
          call pe(ip)
        else if (itask.eq.3) then
          call party(ip)
        else if (itask.eq.4) then
          call party4(ip)
        endif
      else if (isub.eq.10) then
        if (itask.eq.1) then
          call repro(ip)
        else if (itask.eq.2) then
          call repro4(ip)
        endif
      else if (isub.eq.11) then
        if (itask.eq.1) then
          call sorce(ip)
        else if (itask.eq.2) then
          call rdoff(ip)
        else if (itask.eq.3) then
          call aeoff(ip)
        else if (itask.eq.4) then
          call onsor(ip)
        else if (itask.eq.6) then
          call xyoff(ip)
        else if (itask.eq.7) then
          call track(ip)
        endif
      else if (isub.eq.12) then
        if (itask.eq.1.or.itask.eq.2.or.itask.eq.13.or.itask.eq.14) then
          call ctemp(ip,itask)
        else if (itask.eq.5.or.itask.eq.6.or.itask.eq.17.or.itask.eq.18)
     &       then
          call tsys(ip,itask)
        else
          call tpi(ip,itask)
        endif
C 13 was for WVR stations only
      else if (isub.eq.13) then
          call cable(ip,itask)
      else if (isub.eq.14) then
        if (itask.eq.1) then
          call pcalc(ip)
        else if (itask.eq.2) then
          call loset(ip)
        else if (itask.eq.3) then
          call patch(ip)
        else if (itask.eq.4) then
          call pcals(ip)
        else if (itask.eq.5) then
          call upset(ip)
        endif
      else if (isub.eq.15) then
        if (itask.eq.1) then
          call lgout(ip)
        else if (itask.eq.2) then
          call oprid(ip)
        else if (itask.eq.3) then
          call fvpnt(ip)
        else if (itask.eq.4) then
          call onofc(ip)
        else if (itask.eq.5) then
          call pc(ip)
        else if (itask.eq.6) then
          call fsvrs(ip)
        endif
      else if (isub.eq.16) then
       call rxmo(ip)
C     else if (isub.eq.17) then
C       if (itask.eq.1) then
C         call head(ip)
C       endif
      else if (isub.eq.18) then
        call tpform(ip)
      else if (isub.eq.19) then
        if (itask.ge.1.and.itask.le.4) then
          call beam(ip,itask)
        else if (itask.ge.11.and.itask.le.14) then
          call flux(ip,itask)
        endif
      else if (isub.eq.21) then
        if (itask.eq.1) then
          call pass(ip)
        else if (itask.eq.2) then
          call stack(ip)
        else if (itask.eq.3) then
          call lvdt(ip,itask)
        else if (itask.eq.4) then
          call peak(ip)
        else if (itask.eq.5) then
          call savev(ip)
        else if (itask.eq.6) then
          call hdcalc(ip)
        else if (itask.eq.7) then
          call hecho(ip)
        else if (itask.eq.8) then
          call locate(ip)
        else if (itask.eq.9) then
          call worm(ip)
        else if (itask.eq.10) then
          call hdata(ip)
        endif
      endif

      call write_quikr

      goto 1

      end
