      subroutine cbinf(cable,wrap)

C     CBINF returns a printable string telling which wrap
C     corresponds to the single hollerith character input.
C  940131 nrv created

C  Input:
      character*2 cable
C  Output
      character*7 wrap ! 'NEUTRAL', 'CW', or 'CCW'

C  Local
      character*2 cable_in

C  Initialized
      cable_in=cable
      call capitalize(cable_in)
      if(cable_in(1:1) .eq. "-") then
        wrap='neutral'
      else if(cable_in(1:1) .eq. "C") then
        wrap='cw'
      else if(cable_in(1:1) .eq. "W") then
        wrap='ccw'
      else
        wrap=' '
      endif

      return
      end
      
