      subroutine vlt2mic(ihead,ipass,volt,micron,ip,koffset)

      integer ihead,ip(5),ipass
      real*4 micron,volt
      logical koffset
C
C  VLT2MIC: convert voltage to micron position
C
      include '../include/fscom.i'
C
C
C  INPUT:
C     IHEAD - head voltage being converted
C     IPASS - pass number assumed, 0 = uncalibarted
C             odd,  use forward calibration
C             even, use reverse calibration
C     VOLT - voltage to convert
C     KOFFSET - if true, apply offset
C
C  OUTPUT:
C     MICRON - microns corresponding to input
C     IP(5) - Field System return parameters
C             currently unused
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920721  Added koffset for Mark IV. If true apply offsets.
C
      if(volt.ge.0.0) then
        micron=volt*pslope(ihead)
      else
        micron=volt*rslope(ihead)
      endif
      if ((ipass.ne.0).and.(koffset)) then
        ipitch=wrhd_fs
        if(ihead.eq.2) ipitch=rdhd_fs
        if(mod(ipass,2).eq.0) then
          if(ipitch.eq.1) micron=micron-698.5
        else
          if(ipitch.eq.2) micron=micron+698.5
        endif
        micron=micron-foroff(ihead)
        if(mod(ipass,2).eq.0) micron=micron-revoff(ihead)
      endif
C
      return
      end
