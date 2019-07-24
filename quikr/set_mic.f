      subroutine set_mic(ihead,ipass,micron,ip,tol,koffset)
      implicit none
      integer ihead,ip(5),ipass(2)
      real*4 micron(2),tol
      logical koffset
C
C  SET_MIC: set head position(s) by micron
C
C  INPUT:
C     IHEAD - head to be positioned: 1, 2, or 3 (both)
C     IPASS(2) - pass number for positoning, indexed by head number
C                0 = use uncalibrated positions
C     MICRON(2) - microns to position to, indexed by head number
C     KOFFSET  True if offset of heads are to be applied.
C
C  OUTPUT:
C     IP - Field System return parameters
C     IP(3) = 0, if no error
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920721  Added logical koffset.
C
      integer i
      real*4 volt(2)
C
      do i=1,2
        if(ihead.eq.i.or.ihead.eq.3) then
          call mic2vlt(i,ipass(i),micron(i),volt(i),ip,koffset)
          if(ip(3).ne.0) return
        endif
      enddo
C
      call set_vlt(ihead,volt,ip,tol)
      return
      end
