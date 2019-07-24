      subroutine mic2vlt(ihead,ipass,kauto,micron,volt,ip)
      integer ihead,ip(5),ipass
      real*4 micron,volt
      logical kauto
C
C  MIC2VLT: convert calibrated micron position to voltage
C
C  INPUT:
C    IHEAD: head to convert for, 1 or 2
C    IPASS: pass number to convert, 0 = uncalibrated
C           if odd use forward calibration, even use reverse
C    KAUTO: true to adjust for head pitch of write head
C
C  OUTPUT:
C    VOLT: conrresponding voltage position
C    IP: Field System return parameters, not currently modified
C
      real*4 mic
      include '../include/fscom.i'
C
      mic=micron
      if(ipass.ne.0) then
        mic=mic+foroff(ihead)
        if(mod(ipass,2).eq.0) mic=mic+revoff(ihead)
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
