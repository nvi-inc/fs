      subroutine set_mic(ihead,ipass,kauto,micron,ip,tol,indxtp)
      implicit none
      integer ihead,ip(5),ipass(2),indxtp
      real*4 micron(2),tol
      logical kauto
C
C  SET_MIC: set head position(s) by micron
C
C  INPUT:
C     IHEAD - head to be positioned: 1, 2, or 3 (both)
C     IPASS(2) - pass number for positoning, indexed by head number
C                0 = use uncalibrated positions
C     KAUTO - true to adjust write head pitch
C     MICRON(2) - microns to position to, indexed by head number
C
C  OUTPUT:
C     IP - Field System return parameters
C     IP(3) = 0, if no error
C
      integer i
      real*4 volt(2)
C
      do i=1,2
        if(ihead.eq.i.or.ihead.eq.3) then
          call mic2vlt(i,ipass(i),kauto,micron(i),volt(i),ip,indxtp)
          if(ip(3).ne.0) return
        endif
      enddo
C
      call set_vlt(ihead,volt,ip,tol,indxtp)
      return
      end
