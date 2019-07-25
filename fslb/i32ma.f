      subroutine i32ma(ibuf,iat,imix,isw1,isw2,isw3,isw4)
C 
C     I32MA converts data for the IF3 distributor to an MAT buffer.
C 
C  INPUT: 
C 
C     IBUF - buffer to use
C     IAT - attenuator setting
      integer*2 ibuf(1) 
C 
C     The buffer is set up as follows:
C                       00000sab
C     where each letter represents a character (half word). 
C                   0  = these bits unused
C                   s  = switch setting
C                   a  = mixer, and high bits of atten.
C                   b  = remaining atten. bits
C 
C  Fill unused fields with zeros 
C
      call ifill_ch(ibuf,1,5,'0') 
C 
      iswh=(2-isw1)+(2-isw2)*2+(2-isw3)*4+(2-isw4)*8
      call ichmv(ibuf,6,ihx2a(iswh),2,1) 
c
C  Put upper two bits (of six) into char 7 plus mixer control
c
      call ichmv(ibuf,7,ihx2a((2-imix)*4+and(iat,o'60')/o'20'),2,1)
c
C  Put lower four bits into next character.
c
      call ichmv(ibuf,8,ihx2a(and(iat,o'17')),2,1)
C 
      return
      end 
