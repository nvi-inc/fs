      subroutine mic2vlt(ihead,ipass,micron,volt,ip,koffset)
      integer ihead,ip(5),ipass
      real*4 micron,volt
      logical koffset
C
C  MIC2VLT: convert calibrated micron position to voltage
C
C  INPUT:
C    IHEAD: head to convert for, 1 or 2
C    IPASS: pass number to convert, 0 = uncalibrated
C           if odd use forward calibration, even use reverse
C    KOFFSET  True if offset of heads are to be applied.
C
C  OUTPUT:
C    VOLT: conrresponding voltage position
C    IP: Field System return parameters, not currently modified
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920721  Added logical koffset.
C
      real*4 mic
      include '../include/fscom.i'
C
      mic=micron
      if ((ipass.ne.0).and.(koffset)) then
        mic=mic+foroff(ihead)
        if(mod(ipass,2).eq.0) mic=mic+revoff(ihead)
        ipitch=wrhd_fs
        if(ihead.eq.2) ipitch=rdhd_fs
        if(mod(ipass,2).eq.0) then
          if(ipitch.eq.1) mic=mic+698.5
        else
          if(ipitch.eq.2) mic=mic-698.5
        endif
      endif
      if(mic.ge.0.0) then
        volt=mic/pslope(ihead)
      else
        volt=mic/rslope(ihead)
      endif
C
      if(volt.gt.9.9940.or.volt.lt.-9.9960) then
        ip(3)=-410
        call char2hol('q@',ip(4),1,2)
      endif
C
      return
      end
