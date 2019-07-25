      subroutine tp2ma(ibuf,ilow,irst)
C  convert tp data to mat buffer c#870407:12:40#
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
C     ILOW - low tape sensor
C     IRST - footage counter, -1 means no reset 
C 
C     Format the buffer for the controller. 
C     The buffer is set up as follows:
C                   (l0f00000 
C     where each letter represents a character (half word). 
C                   where l = 0 for lowtape OFF, 8 for ON 
C                         f = 0 for leave footage counter, 4 for RESET
C 
      call ichmv_ch(ibuf,1,'(') 
C                   The strobe character
      call ib2as(ilow*8,ibuf,2,1) 
      call ichmv_ch(ibuf,3,'0') 
      call ib2as(irst*4,ibuf,4,1) 
      call ifill_ch(ibuf,5,5,'0') 
C 
      return
      end 
