      subroutine mic_read(ihead,ipass,kauto,micnow,ip)
      implicit none
      integer ihead,ipass(2),ip(5)
      real*4 micnow(2)
      logical kauto
C
C  MIC_READ: read head position(s) in microns
C
C  INPUT:
C     IHEAD - head to get position of: 1, 2, or both
C     IPASS(2) - pass number to assume for calibration,
C                0 for uncalibrated, indexed by head number
C     KAUTO - true for adjust write head position for head.ctl
C
C  OUTPUT:
C     MICNOW(2) - current positon for requested head(s),
C                 indexed by head number
C     IP(5) - Field System return parameters
C             IP(3) = 0, if no error
C
      integer i
      real*4 volt(2)
C
      call vlt_read(ihead,volt,ip)
      if(ip(3).ne.0) return
C
      do i=1,2
        if(ihead.eq.i.or.ihead.eq.3) then
          call vlt2mic(i,ipass(i),kauto,volt(i),micnow(i),ip)
          if(ip(3).ne.0) return
        endif
      enddo
C
      return
      end
