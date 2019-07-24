      subroutine vlt2mic(ihead,ipass,kauto,volt,micron,ip)
      integer ihead,ip(5),ipass
      real*4 micron,volt
      logical kauto
C
C  VLT2MIC: convert voltage to micron position
C
C  INPUT:
C     IHEAD - head voltage being converted
C     IPASS - pass number assumed, 0 = uncalibarted
C             odd,  use forward calibration
C             even, use reverse calibration
C     KAUTO - if write head should have pitch adjusted
C     VOLT - voltage to convert
C
C  OUTPUT:
C     MICRON - microns corresponding to input
C     IP(5) - Field System return parameters
C             currently unused
C
      include '../include/fscom.i'
C
      if(volt.ge.0.0) then
        micron=volt*pslope(ihead)
      else
        micron=volt*rslope(ihead)
      endif
      if(ipass.ne.0) then
        if(ihead.eq.1) then
          if(kauto) then
            ipitch=wrhd_fs
          else
            ipitch=0
          endif
        else
          ipitch=rdhd_fs
        endif
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
