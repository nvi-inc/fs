      subroutine rpbr2ma4(ibuf,ibr,ivac)
C     convert repro's bitrate data to mat buffer for Mark IV drive.
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
C     IBR - bitrate selection
C 
C     Format the buffer for the controller. 
C 
      call ichmv_ch(ibuf,1,'.') 
C                   The strobe character for this control word
      call ichmv_ch(ibuf,2,'00000004') 
C                   Fill buffer with zeros to start except
C                   final position is always 4.
      call ichmv(ibuf,6,ihx2a(ivac*4),2,1)
      if(ibr.lt.0.or.ibr.gt.15) then
         ibrx=3
      else
         ibrx=ibr
      endif
      call ichmv(ibuf,8,ihx2a(ibrx),2,1)
C
      return
      end 
