      subroutine vlt_head(ihead,volt,ip)
      implicit none
C
      include '../include/fscom.i'
c
      integer ihead,ip(5)
      real*4 volt
C
C  VLT_HEAD: get head position in volt units
C
C  INPUT:
C     IHEAD - IHEAD to get position of, 1 or 2
C
C  OUTPUT:
C    VOLT - voltage position of head
C    IP - FIeld System return parameters
C    IP(3) = 0 if no error
C
      call fs_get_drive_type(drive_type)
      if(drive_type.eq.vlba2) then
        call fc_v2_vlt_head(ihead,volt,ip)
      else
        call get_atod(ihead,volt,ip)
      endif
C
      return
      end
