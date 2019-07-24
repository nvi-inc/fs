      subroutine mv2ma(ibuf,idir,isp,lgen)

C  convert mv data to mat buffer c#870407:12:39#
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      dimension lgen(1) 
C      - rate generator, ASCII 720 or 880 
C     IDIR - direction
C     ISP - speed 
C 
C     Format the buffer for the controller. 
C     The buffer is set up as follows:
C                   )srrr0000 
C     where each letter represents a character (half word). 
C                   s  = speed (lower 3 bits) and direction (top bit) 
C                 rrr  = rate generator frequency 
C 
      call ichmv(ibuf,1,2H) ,1,1) 
      call ichmv(ibuf,2,ihx2a(idir*o'10'+isp),2,1)
      call ichmv(ibuf,3,lgen,1,3) 
      call ifill_ch(ibuf,6,4,'0') 
C 
      return
      end 
