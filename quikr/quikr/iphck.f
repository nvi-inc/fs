      function iphck(i)
C  checks for phase cal in track c#870115:04:51 #
C 
C     Given a track #, IPHCK checks for phase cal < 50kHz 
C     and returns as 0 if there is no phase cal.
C     If the phase cal is OK, IPHCK returns as the track #. 
C 
      double precision pcal 
C 
      iphck = 0 
      call phcal(pcal,i,idum) 
      if (pcal.le.50000.) iphck = i 
      return
      end 
