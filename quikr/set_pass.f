      subroutine set_pass(ihead,ipass,micpas,ip,tol)
      implicit none
      integer ihead,ipass(2),ip(5)
      real*4 micpas(2),tol
C
C POS_HEAD: position heads, by pass or micron
C
C  This routine will position the heads by pass number or uncorrected
C  micron position and/or return the current head position.
C
C INPUT ARGUMENTS:
C
C  IHEAD  Head to position 1=write, 2=read, 3=both.
C  IPASS  The pass numbers each head is to positioned to. If zero, then
C         position by uncorrected microns according to MICPAS, is desired.
C  MICPAS The uncorrected micron positions to place the heads at if
C         IPASS is zero.
C
C OUTPUT ARGUMENTS:
C
C  MICPAS The micron position that the pass numbers in IPASS correspond
C         to if IPASS was nonzero.
C  IP     Field System error return array.
C
C HISTORY:
C
C  WHO WHEN   WHAT
C  --- ------ ----
C  WEH 880928 CREATED
C
      integer i
C
      do i=1,2
        if((ihead.eq.i.or.ihead.eq.3).and.ipass(i).gt.0) then
          call pas2mic(i,ipass(i),micpas(i),ip)
          if(ip(3).ne.0) return
        endif
      enddo
C
      call set_mic(ihead,ipass,micpas,ip,tol)
C
      return
      end
