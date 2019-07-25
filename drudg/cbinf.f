      subroutine cbinf(cable,wrap)

C     CBINF returns a printable string telling which wrap
C     corresponds to the single hollerith character input.
C  940131 nrv created

C  Input:
      integer*2 cable  ! -, C, or W from schedule
C  Output
      character*7 wrap ! 'NEUTRAL', 'CW', or 'CCW'

C  Local
      integer hn,hc,hw,hlc,hlw

C  Initialized
      data hn/2h- /,hc/2hC /,hw/2hW /
      data          hlc/2hc /,hlw/2hw /

      if (ichcm(cable,1,hn,1,2).eq.0) then
        wrap='NEUTRAL'
      else if (ichcm(cable,1,hc,1,2).eq.0.or.
     .         ichcm(cable,1,hlc,1,2).eq.0) then
        wrap='CW'
      else if (ichcm(cable,1,hw,1,2).eq.0.or.
     .         ichcm(cable,1,hlw,1,2).eq.0) then
        wrap='CCW'
      else
        wrap=' '
      endif

      return
      end
      
