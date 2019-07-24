      subroutine ma2mv(ibuf,idir,isp,lgen)

C  convert mat buffer to mv data c#870407:12:42#
C 
C     This routine converts the buffers returned from the MAT 
C     into the tape motion information. 
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
C     IDIR - direction
C     ISP - speed 
      dimension lgen(1) 
C       - rate generator frequency
C 
C 
C     The format of the buffer from MATCN is: 
C        TPsrrr0000 
C     where each letter is a character with the following bits
C                  s = direction (top bit) and speed (3 bits) 
C            rrr = 3 digit rate, ASCII value 720 or 960 
C     Note we are only concerned with the last 8 characters 
C 
      ia = ia2hx(ibuf,3)
      isp = iand(ia,7)
      idir = iand(ia,8)/8 
      call ichmv(lgen,1,ibuf,4,3) 
C 
      return
      end 
