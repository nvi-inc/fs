      program quikc
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
C
C     PROGRAM STRUCTURE :
C  Get RMPAR parameters, then call the subroutine whose number is in IP(2).
C
      call setup_fscom
      call read_fscom
      idum=fc_rte_prior(FS_PRIOR)
1     continue
      call wait_prog('quikc',ip)
      call read_quikr
      isub = ip(2)/100
      itask = ip(2) - 100*isub
C for WVR stations only    else if (isub.eq.13) then
      if (isub.eq.14) then
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
      endif

      call write_quikr

      goto 1

      end
