      subroutine vlt_read(ihead,volt,ip)
      implicit none
      integer ihead,ip(5)
      real*4 volt(2)
C
C  VLT_READ: read head vaoltage(s)
C
C  INPUT:
C     IHEAD: Head to read voltage of: 1, 2, or 3 (both)
C
C  OUTPUT:
C     VOLT(2): voltage or voltages (1), (2), or both
C     IP - Field System return parameters
C     IP(3) = 0, if no error
C
      integer i
C
      do i=1,2
        if(i.eq.ihead.or.ihead.eq.3) then
          call vlt_head(i,volt(i),ip)
          if(ip(3).ne.0) return
        endif
      enddo
C
      return
      end
