      subroutine proc_check8bbc(km3be,km3ac,lwhich8,ichan,
     >  ib,kinclude)
      implicit none
! Check to see if we should do this BBC.
! This is only called in the case we have 8 BBCs.
! History
!  2007Jul12 JMGipson. Split off from proc.

! passed
      logical km3be     !Mark3 mode B or E
      logical km3ac     !Mark3 mode A or C
      character*1 lwhich8      !flag indicating (F)irst or (L)ast 8 BBCs
      integer ichan     !which channel
! returned
      integer ib
      logical kinclude  !

      ib=ichan          !default
      if (km3be) then
!        ib=ichan
      else if (km3ac) then
        if (lwhich8 .eq. "F") then
!          ib=ichan
          if (ib.gt.8) kinclude=.false.
C           Write out a max of 8 channels for 8-BBC stations
        else if (lwhich8 .eq. "L") then
           ib=ichan-6
           if (ib.le.0) kinclude=.false.
        endif
      endif
      return
      end
