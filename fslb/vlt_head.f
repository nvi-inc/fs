      subroutine vlt_head(ihead,volt,ip,indxtp)
      implicit none
C
      include '../include/fscom.i'
c
      integer ihead,ip(5),indxtp
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
      call fs_get_drive(drive)
      call fs_get_reccpu(reccpu,indxtp)
      if(drive(indxtp).eq.VLBA.and.drive_type(indxtp).eq.VLBA2) then
        call fc_v2_vlt_head(ihead,volt,ip,indxtp)
      else if((drive(indxtp).eq.VLBA.or.drive(indxtp).eq.VLBA4).and.
     &       reccpu(indxtp).eq.162) then
         call v_vlt_head(ihead,volt,ip,indxtp)
      else
        call get_atod(ihead,volt,ip,indxtp)
      endif
C
      return
      end
